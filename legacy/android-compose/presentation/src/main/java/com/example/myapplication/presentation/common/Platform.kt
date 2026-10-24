package com.example.myapplication.presentation.common

import androidx.activity.compose.LocalActivity
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG
import androidx.biometric.BiometricPrompt
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.platform.LocalView
import androidx.core.content.ContextCompat
import androidx.core.view.WindowCompat
import androidx.fragment.app.FragmentActivity
import javax.crypto.Cipher

/** Shows the system biometric sheet and hands back [cipher] once it's authorized for one use. */
fun FragmentActivity.authenticateWithBiometrics(
    title: String,
    negativeButton: String,
    cipher: Cipher,
    onSuccess: (Cipher) -> Unit,
    onError: (String) -> Unit,
) {
    val callback = object : BiometricPrompt.AuthenticationCallback() {
        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
            result.cryptoObject?.cipher?.let(onSuccess)
        }

        override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
            val cancelled = errorCode == BiometricPrompt.ERROR_NEGATIVE_BUTTON ||
                errorCode == BiometricPrompt.ERROR_USER_CANCELED ||
                errorCode == BiometricPrompt.ERROR_CANCELED
            if (!cancelled) onError(errString.toString())
        }
    }
    val promptInfo = BiometricPrompt.PromptInfo.Builder()
        .setTitle(title)
        .setNegativeButtonText(negativeButton)
        .setAllowedAuthenticators(BIOMETRIC_STRONG)
        .build()
    BiometricPrompt(this, ContextCompat.getMainExecutor(this), callback)
        .authenticate(promptInfo, BiometricPrompt.CryptoObject(cipher))
}

/** Keeps the status and navigation bar icons legible over whatever this screen draws behind them. */
@Composable
fun SystemBarIcons(statusBarBackground: Color, navigationBarBackground: Color) {
    val window = LocalActivity.current?.window ?: return
    val view = LocalView.current
    SideEffect {
        WindowCompat.getInsetsController(window, view).apply {
            isAppearanceLightStatusBars = statusBarBackground.luminance() > 0.5f
            isAppearanceLightNavigationBars = navigationBarBackground.luminance() > 0.5f
        }
    }
}
