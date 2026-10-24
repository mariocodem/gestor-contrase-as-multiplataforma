package com.example.myapplication.designsystem.component

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.focusProperties
import androidx.compose.ui.input.InputMode
import androidx.compose.ui.platform.LocalInputModeManager
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import com.example.myapplication.designsystem.R
import com.example.myapplication.designsystem.icon.BovedaIcons
import com.example.myapplication.designsystem.theme.BovedaTheme

/**
 * A password input with a show/hide toggle. Shown in clear it uses the secret mono and colours
 * digits and symbols; [secretStyle] off keeps the regular face (account passwords at sign-in).
 */
@Composable
fun PasswordField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    isError: Boolean = false,
    supportingText: String? = null,
    imeAction: ImeAction = ImeAction.Done,
    onImeAction: () -> Unit = {},
    secretStyle: Boolean = true,
    extraTrailingIcon: (@Composable () -> Unit)? = null,
) {
    var visible by rememberSaveable { mutableStateOf(false) }
    val colors = BovedaTheme.colors
    // Like a View that isn't focusable in touch mode: "Next" on the on-screen keyboard goes on to
    // the following field instead of stopping on the eye, which a hardware keyboard still reaches.
    val keyboardOnly = LocalInputModeManager.current.inputMode == InputMode.Keyboard
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        modifier = modifier.fillMaxWidth(),
        enabled = enabled,
        isError = isError,
        singleLine = true,
        supportingText = supportingText?.let { { Text(it) } },
        textStyle = if (secretStyle && visible) BovedaTheme.secret.medium else LocalTextStyle.current,
        visualTransformation = when {
            !visible -> PasswordVisualTransformation()
            secretStyle -> CharacterClassTransformation(colors.secretDigit, colors.secretSymbol)
            else -> VisualTransformation.None
        },
        keyboardOptions = KeyboardOptions(
            keyboardType = KeyboardType.Password,
            autoCorrectEnabled = false,
            imeAction = imeAction,
        ),
        keyboardActions = KeyboardActions(
            onAny = {
                onImeAction()
                // A custom handler replaces the default one, so "Next" has to move focus itself.
                if (imeAction == ImeAction.Next) defaultKeyboardAction(ImeAction.Next)
            },
        ),
        trailingIcon = {
            Row(Modifier.focusProperties { canFocus = keyboardOnly }) {
                IconButton(onClick = { visible = !visible }) {
                    Icon(
                        painter = painterResource(if (visible) BovedaIcons.VisibilityOff else BovedaIcons.Visibility),
                        contentDescription = stringResource(if (visible) R.string.ds_hide_password else R.string.ds_show_password),
                    )
                }
                extraTrailingIcon?.invoke()
            }
        },
    )
}
