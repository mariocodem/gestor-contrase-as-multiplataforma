package com.example.myapplication.designsystem.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.platform.LocalContext

private val LocalBovedaColors = staticCompositionLocalOf { SteelLightColors }
private val LocalSecretTypography = staticCompositionLocalOf { SecretTypography() }

/**
 * The steel-and-brass theme. With [dynamicColor] (Android 12+, opt-in from Settings) Material You
 * colours from the wallpaper replace the palette; key caps keep their anodized hues either way,
 * because they identify accounts.
 */
@Composable
fun BovedaTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit,
) {
    val useDynamic = dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
    val scheme = when {
        useDynamic && darkTheme -> dynamicDarkColorScheme(LocalContext.current)
        useDynamic -> dynamicLightColorScheme(LocalContext.current)
        darkTheme -> SteelDarkScheme
        else -> SteelLightScheme
    }
    val colors = when {
        useDynamic -> dynamicShell(scheme, darkTheme)
        darkTheme -> SteelDarkColors
        else -> SteelLightColors
    }
    CompositionLocalProvider(
        LocalBovedaColors provides colors,
        LocalSecretTypography provides SecretTypography(),
    ) {
        MaterialTheme(colorScheme = scheme, typography = BovedaTypography, shapes = BovedaShapes, content = content)
    }
}

/** With wallpaper colours the shell follows Material's own surfaces instead of graphite. */
private fun dynamicShell(scheme: ColorScheme, darkTheme: Boolean): BovedaColors {
    val base = if (darkTheme) SteelDarkColors else SteelLightColors
    return base.copy(
        plate = if (darkTheme) scheme.surfaceContainer else scheme.surfaceContainerLowest,
        shell = scheme.surfaceContainer,
        onShell = scheme.onSurface,
        onShellVariant = scheme.onSurfaceVariant,
        shellField = scheme.surfaceContainerHighest,
        shellIndicator = scheme.secondaryContainer,
        onShellIndicator = scheme.onSecondaryContainer,
    )
}

object BovedaTheme {
    val colors: BovedaColors
        @Composable @ReadOnlyComposable get() = LocalBovedaColors.current

    val secret: SecretTypography
        @Composable @ReadOnlyComposable get() = LocalSecretTypography.current
}
