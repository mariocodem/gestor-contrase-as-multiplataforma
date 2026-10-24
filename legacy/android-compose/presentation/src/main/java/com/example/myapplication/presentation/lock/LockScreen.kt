package com.example.myapplication.presentation.lock

import androidx.activity.compose.LocalActivity
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.FragmentActivity
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.myapplication.designsystem.component.LockEmblem
import com.example.myapplication.designsystem.component.CenteredForm
import com.example.myapplication.designsystem.component.PasswordField
import com.example.myapplication.designsystem.icon.BovedaIcons
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.domain.model.User
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.FormMessage
import com.example.myapplication.presentation.common.PasswordStrengthIndicator
import com.example.myapplication.presentation.common.SystemBarIcons
import com.example.myapplication.presentation.common.authenticateWithBiometrics

/**
 * Creates the vault when [isSetup], otherwise unlocks it. [opening] is set while the screen leaves
 * because the vault opened, so the emblem's shackle lifts; [arrivedFromUnlocked] makes it close
 * on arrival, after a lock.
 */
@Composable
fun LockScreen(
    user: User,
    isSetup: Boolean,
    onSignOut: () -> Unit,
    opening: Boolean = false,
    arrivedFromUnlocked: Boolean = false,
    viewModel: LockViewModel = hiltViewModel<LockViewModel, LockViewModel.Factory>(key = "lock-${user.id}") {
        it.create(user)
    },
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    val activity = LocalActivity.current as? FragmentActivity
    val passwordFocus = remember { FocusRequester() }
    val promptTitle = stringResource(R.string.lock_biometric_prompt)
    val promptCancel = stringResource(R.string.action_cancel)

    val promptBiometrics: () -> Unit = {
        val cipher = viewModel.biometricCipher()
        if (activity != null && cipher != null) {
            activity.authenticateWithBiometrics(
                title = promptTitle,
                negativeButton = promptCancel,
                cipher = cipher,
                onSuccess = viewModel::onBiometricAuthenticated,
                onError = viewModel::onBiometricError,
            )
        }
    }
    val submit = { viewModel.submit(isSetup) }
    // The ViewModel resets as soon as the key is accepted; while this screen fades out over the
    // opening vault it keeps showing the work it just finished instead of flicking back to idle.
    val working = state.isWorking || opening

    LaunchedEffect(user.id, isSetup) {
        if (!isSetup && state.biometricEnabled) promptBiometrics() else passwordFocus.requestFocus()
    }

    SystemBarIcons(MaterialTheme.colorScheme.surface, MaterialTheme.colorScheme.surface)
    Scaffold { padding ->
        CenteredForm(padding) {
            LockEmblem(locked = !opening, rejections = state.rejections, startOpen = arrivedFromUnlocked)
            Spacer(Modifier.height(24.dp))
            Text(
                text = stringResource(if (isSetup) R.string.lock_title_setup else R.string.lock_title_locked),
                style = MaterialTheme.typography.headlineSmall,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text = stringResource(if (isSetup) R.string.lock_body_setup else R.string.lock_body_locked),
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            if (isSetup) {
                Spacer(Modifier.height(16.dp))
                RecoveryWarning()
            }

            Spacer(Modifier.height(24.dp))
            PasswordField(
                value = state.password,
                onValueChange = viewModel::onPasswordChange,
                label = stringResource(R.string.lock_master_password),
                enabled = !working,
                imeAction = if (isSetup) ImeAction.Next else ImeAction.Done,
                onImeAction = { if (!isSetup) submit() },
                modifier = Modifier.focusRequester(passwordFocus),
            )
            if (isSetup) {
                AnimatedVisibility(
                    visible = state.password.isNotEmpty(),
                    enter = expandVertically(tween(BovedaMotion.MEDIUM, easing = BovedaMotion.EmphasizedDecelerate)) + fadeIn(),
                    exit = shrinkVertically(tween(BovedaMotion.SHORT)) + fadeOut(tween(100)),
                ) {
                    PasswordStrengthIndicator(state.strength, Modifier.fillMaxWidth().padding(top = 4.dp, bottom = 8.dp))
                }
                Spacer(Modifier.height(8.dp))
                PasswordField(
                    value = state.confirmation,
                    onValueChange = viewModel::onConfirmationChange,
                    label = stringResource(R.string.lock_repeat_master_password),
                    enabled = !working,
                    onImeAction = submit,
                )
            }
            FormMessage(state.error, color = MaterialTheme.colorScheme.error)

            Spacer(Modifier.height(24.dp))
            Button(onClick = submit, enabled = !working, modifier = Modifier.fillMaxWidth().height(52.dp)) {
                AnimatedContent(
                    targetState = working,
                    transitionSpec = { fadeIn(tween(BovedaMotion.SHORT)) togetherWith fadeOut(tween(100)) using SizeTransform(clip = false) },
                    contentAlignment = Alignment.Center,
                    label = "unlock-button",
                ) { busy ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        if (busy) {
                            CircularProgressIndicator(Modifier.size(20.dp), strokeWidth = 2.dp)
                            Spacer(Modifier.width(12.dp))
                            Text(stringResource(if (isSetup) R.string.lock_creating else R.string.lock_unlocking))
                        } else {
                            Text(stringResource(if (isSetup) R.string.lock_create else R.string.lock_unlock))
                        }
                    }
                }
            }
            if (!isSetup && state.biometricEnabled) {
                Spacer(Modifier.height(12.dp))
                OutlinedButton(
                    onClick = promptBiometrics,
                    enabled = !working,
                    modifier = Modifier.fillMaxWidth().height(52.dp),
                ) {
                    Icon(painterResource(BovedaIcons.Fingerprint), contentDescription = null)
                    Spacer(Modifier.width(8.dp))
                    Text(stringResource(R.string.lock_use_biometrics))
                }
            }
            Spacer(Modifier.height(24.dp))
            user.email?.let {
                Text(
                    stringResource(R.string.lock_signed_in_as, it),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            TextButton(onClick = onSignOut, enabled = !working) { Text(stringResource(R.string.action_sign_out)) }
        }
    }
}

@Composable
private fun RecoveryWarning() {
    Surface(
        color = MaterialTheme.colorScheme.surfaceContainerHigh,
        shape = MaterialTheme.shapes.medium,
        modifier = Modifier.fillMaxWidth(),
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.Top) {
            Icon(
                painterResource(BovedaIcons.Warning),
                contentDescription = null,
                tint = MaterialTheme.colorScheme.error,
                modifier = Modifier.size(20.dp),
            )
            Spacer(Modifier.width(12.dp))
            Text(stringResource(R.string.lock_warning), style = MaterialTheme.typography.bodyMedium)
        }
    }
}
