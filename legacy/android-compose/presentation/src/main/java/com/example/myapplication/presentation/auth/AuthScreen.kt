package com.example.myapplication.presentation.auth

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.autofill.ContentType
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentType
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.myapplication.designsystem.component.AppEmblem
import com.example.myapplication.designsystem.component.CenteredForm
import com.example.myapplication.designsystem.component.PasswordField
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.designsystem.theme.BovedaTheme
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.FormMessage
import com.example.myapplication.presentation.common.SystemBarIcons

@Composable
fun AuthScreen(viewModel: AuthViewModel = hiltViewModel()) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    AuthContent(
        state = state,
        onEmailChange = viewModel::onEmailChange,
        onPasswordChange = viewModel::onPasswordChange,
        onSubmit = viewModel::submit,
        onToggleMode = viewModel::toggleMode,
        onForgotPassword = viewModel::requestPasswordReset,
    )
}

@Composable
private fun AuthContent(
    state: AuthUiState,
    onEmailChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onSubmit: () -> Unit,
    onToggleMode: () -> Unit,
    onForgotPassword: () -> Unit,
) {
    SystemBarIcons(MaterialTheme.colorScheme.surface, MaterialTheme.colorScheme.surface)
    Scaffold { padding ->
        CenteredForm(padding) {
            AppEmblem()
            Spacer(Modifier.height(24.dp))
            Text(stringResource(R.string.app_title), style = MaterialTheme.typography.headlineMedium)
            Spacer(Modifier.height(8.dp))
            ModeCrossfade(state.isRegistering) { registering ->
                Text(
                    text = stringResource(if (registering) R.string.auth_subtitle_register else R.string.auth_subtitle_sign_in),
                    style = MaterialTheme.typography.bodyLarge,
                    textAlign = TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            Spacer(Modifier.height(32.dp))

            OutlinedTextField(
                value = state.email,
                onValueChange = onEmailChange,
                label = { Text(stringResource(R.string.auth_email)) },
                singleLine = true,
                enabled = !state.isWorking,
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Email,
                    autoCorrectEnabled = false,
                    imeAction = ImeAction.Next,
                ),
                modifier = Modifier.fillMaxWidth().semantics { contentType = ContentType.EmailAddress },
            )
            Spacer(Modifier.height(12.dp))
            PasswordField(
                value = state.password,
                onValueChange = onPasswordChange,
                label = stringResource(R.string.auth_password),
                enabled = !state.isWorking,
                supportingText = if (state.isRegistering) stringResource(R.string.auth_password_hint) else null,
                onImeAction = onSubmit,
                secretStyle = false,
                modifier = Modifier.semantics {
                    contentType = if (state.isRegistering) ContentType.NewPassword else ContentType.Password
                },
            )

            FormMessage(state.error, color = MaterialTheme.colorScheme.error)
            FormMessage(state.info, color = MaterialTheme.colorScheme.onSurfaceVariant)

            Spacer(Modifier.height(24.dp))
            Button(
                onClick = onSubmit,
                enabled = !state.isWorking,
                modifier = Modifier.fillMaxWidth().height(52.dp),
            ) {
                ModeCrossfade(state.isWorking to state.isRegistering) { (working, registering) ->
                    if (working) {
                        CircularProgressIndicator(Modifier.size(20.dp), strokeWidth = 2.dp)
                    } else {
                        Text(stringResource(if (registering) R.string.auth_register else R.string.auth_sign_in))
                    }
                }
            }
            Spacer(Modifier.height(8.dp))
            TextButton(onClick = onToggleMode, enabled = !state.isWorking) {
                ModeCrossfade(state.isRegistering) { registering ->
                    Text(stringResource(if (registering) R.string.auth_switch_to_sign_in else R.string.auth_switch_to_register))
                }
            }
            AnimatedVisibility(
                visible = !state.isRegistering,
                enter = expandVertically(tween(BovedaMotion.MEDIUM, easing = BovedaMotion.EmphasizedDecelerate)) + fadeIn(),
                exit = shrinkVertically(tween(BovedaMotion.SHORT)) + fadeOut(tween(100)),
            ) {
                TextButton(onClick = onForgotPassword, enabled = !state.isWorking) {
                    Text(stringResource(R.string.auth_forgot))
                }
            }
        }
    }
}

/** Swaps copy between sign-in and registration with a quick cross-fade instead of a cut. */
@Composable
private fun <T> ModeCrossfade(target: T, content: @Composable (T) -> Unit) {
    AnimatedContent(
        targetState = target,
        transitionSpec = { fadeIn(tween(BovedaMotion.SHORT, delayMillis = 50)) togetherWith fadeOut(tween(100)) using SizeTransform(clip = false) },
        contentAlignment = Alignment.Center,
        label = "auth-mode",
    ) { content(it) }
}

@Preview(showSystemUi = true)
@Composable
private fun AuthPreview() {
    BovedaTheme {
        AuthContent(AuthUiState(email = "ana@correo.es"), {}, {}, {}, {}, {})
    }
}
