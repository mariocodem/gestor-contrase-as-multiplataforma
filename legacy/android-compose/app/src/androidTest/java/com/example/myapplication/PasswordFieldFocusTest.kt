package com.example.myapplication

import androidx.compose.foundation.layout.Column
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.assertIsFocused
import androidx.compose.ui.test.hasSetTextAction
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.performImeAction
import androidx.compose.ui.test.requestFocus
import androidx.compose.ui.text.input.ImeAction
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.myapplication.designsystem.component.PasswordField
import com.example.myapplication.designsystem.theme.BovedaTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/** The master password form: "Next" on the on-screen keyboard must land in the confirmation field. */
@RunWith(AndroidJUnit4::class)
class PasswordFieldFocusTest {
    @get:Rule
    val compose = createComposeRule()

    @Test
    fun nextSkipsTheRevealButtonAndReachesTheFollowingField() {
        compose.setContent {
            BovedaTheme {
                Column {
                    var password by remember { mutableStateOf("") }
                    var confirmation by remember { mutableStateOf("") }
                    PasswordField(password, { password = it }, label = "Contraseña maestra", imeAction = ImeAction.Next)
                    PasswordField(confirmation, { confirmation = it }, label = "Repite la contraseña maestra")
                }
            }
        }
        val fields = compose.onAllNodes(hasSetTextAction())

        // Focus through semantics rather than an injected tap: the device stays in touch mode, as
        // it is for anyone typing on the on-screen keyboard.
        fields[0].requestFocus()
        fields[0].performImeAction()

        fields[1].assertIsFocused()
    }
}
