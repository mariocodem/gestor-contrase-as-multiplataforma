package com.example.myapplication.presentation.root

import androidx.activity.compose.LocalActivity
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.EnterExitState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.LocalViewModelStoreOwner
import com.example.myapplication.designsystem.component.AppEmblem
import com.example.myapplication.designsystem.component.CenteredForm
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.designsystem.theme.BovedaTheme
import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.model.AppState
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.auth.AuthScreen
import com.example.myapplication.presentation.common.SystemBarIcons
import com.example.myapplication.presentation.common.asString
import com.example.myapplication.presentation.common.toUiText
import com.example.myapplication.presentation.lock.LockScreen
import com.example.myapplication.presentation.navigation.UnlockedApp

/** Entry point: picks the part of the app the current [AppState] allows. */
@Composable
fun BovedaApp(viewModel: RootViewModel = hiltViewModel()) {
    val state by viewModel.appState.collectAsStateWithLifecycle()
    val dynamicColor by viewModel.dynamicColor.collectAsStateWithLifecycle()

    val target by rememberUpdatedState(state)
    val previous = remember { StateHistory(state) }.update(state)

    BovedaTheme(dynamicColor = dynamicColor) {
        AnimatedContent(
            targetState = state,
            contentKey = { it::class },
            transitionSpec = {
                if (initialState.isLockScreen() && targetState is AppState.Unlocked) {
                    // The shackle lifts first; the vault then comes up through the lock screen,
                    // already usable while the lock fades.
                    (fadeIn(tween(220, delayMillis = 120)) +
                        scaleIn(tween(320, delayMillis = 120, easing = BovedaMotion.EmphasizedDecelerate), initialScale = 0.97f)) togetherWith
                        fadeOut(tween(160, delayMillis = 140))
                } else {
                    fadeIn(tween(220, delayMillis = 60)) togetherWith fadeOut(tween(120))
                }
            },
            label = "app-state",
        ) { current ->
            // True only for a lock screen on its way out because the vault opened.
            val opening = transition.targetState == EnterExitState.PostExit && target is AppState.Unlocked
            val closing = previous is AppState.Unlocked
            when (current) {
                AppState.Loading -> LoadingScreen()
                AppState.SignedOut -> AuthScreen()
                is AppState.NeedsSetup -> LockScreen(
                    user = current.user,
                    isSetup = true,
                    onSignOut = viewModel::signOut,
                    opening = opening,
                )
                is AppState.Locked -> LockScreen(
                    user = current.user,
                    isSetup = false,
                    onSignOut = viewModel::signOut,
                    opening = opening,
                    arrivedFromUnlocked = closing,
                )
                is AppState.Unlocked -> {
                    val activity = LocalActivity.current
                    DisposableEffect(viewModel) {
                        // A rotation recreates the activity but keeps the session; locking ends it.
                        onDispose { if (activity?.isChangingConfigurations != true) viewModel.endSession() }
                    }
                    CompositionLocalProvider(LocalViewModelStoreOwner provides viewModel.sessionViewModelStoreOwner) {
                        UnlockedApp(user = current.user)
                    }
                }
                is AppState.Failed -> FailureScreen(current.error, onRetry = viewModel::retry, onSignOut = viewModel::signOut)
            }
        }
    }
}

private fun AppState.isLockScreen() = this is AppState.Locked || this is AppState.NeedsSetup

/** Remembers the state before the current one, to tell a fresh lock screen from one the vault just closed into. */
private class StateHistory(private var current: AppState) {
    private var previous: AppState? = null

    fun update(state: AppState): AppState? {
        if (state != current) {
            previous = current
            current = state
        }
        return previous
    }
}

@Composable
private fun LoadingScreen() {
    SystemBarIcons(MaterialTheme.colorScheme.surface, MaterialTheme.colorScheme.surface)
    Scaffold { padding ->
        CenteredForm(padding) {
            AppEmblem()
            Spacer(Modifier.height(28.dp))
            LinearProgressIndicator(Modifier.width(160.dp))
            Spacer(Modifier.height(16.dp))
            Text(
                stringResource(R.string.loading_vault),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun FailureScreen(error: AppError, onRetry: () -> Unit, onSignOut: () -> Unit) {
    SystemBarIcons(MaterialTheme.colorScheme.surface, MaterialTheme.colorScheme.surface)
    Scaffold { padding ->
        CenteredForm(padding) {
            AppEmblem()
            Spacer(Modifier.height(24.dp))
            Text(stringResource(R.string.error_screen_title), style = MaterialTheme.typography.headlineSmall, textAlign = TextAlign.Center)
            Spacer(Modifier.height(8.dp))
            Text(
                error.toUiText().asString(),
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(Modifier.height(28.dp))
            Column(
                Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Button(onClick = onRetry, modifier = Modifier.fillMaxWidth().height(52.dp)) {
                    Text(stringResource(R.string.action_retry))
                }
                TextButton(onClick = onSignOut) { Text(stringResource(R.string.action_sign_out)) }
            }
        }
    }
}
