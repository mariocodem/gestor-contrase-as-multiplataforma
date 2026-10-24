package com.example.myapplication.designsystem.theme

import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color

// Brushed steel ground, a graphite shell panel, brass for the one primary action.
internal val SteelLightScheme = lightColorScheme(
    primary = Color(0xFF876214),
    onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFE9C46A),
    onPrimaryContainer = Color(0xFF251A00),
    inversePrimary = Color(0xFFE9C46A),
    secondary = Color(0xFF4E5D69),
    onSecondary = Color(0xFFFFFFFF),
    secondaryContainer = Color(0xFFD2DEE8),
    onSecondaryContainer = Color(0xFF0B1D29),
    tertiary = Color(0xFF2F5BD3),
    onTertiary = Color(0xFFFFFFFF),
    tertiaryContainer = Color(0xFFDCE2FF),
    onTertiaryContainer = Color(0xFF001550),
    error = Color(0xFFB3261E),
    onError = Color(0xFFFFFFFF),
    errorContainer = Color(0xFFF9DEDC),
    onErrorContainer = Color(0xFF410E0B),
    background = Color(0xFFF1F3F5),
    onBackground = Color(0xFF191C1F),
    surface = Color(0xFFF1F3F5),
    onSurface = Color(0xFF191C1F),
    surfaceVariant = Color(0xFFDCE1E6),
    onSurfaceVariant = Color(0xFF434A51),
    surfaceTint = Color(0xFF876214),
    inverseSurface = Color(0xFF2D3237),
    inverseOnSurface = Color(0xFFEEF1F4),
    outline = Color(0xFF737A82),
    outlineVariant = Color(0xFFC2C8CE),
    scrim = Color(0xFF000000),
    surfaceBright = Color(0xFFF7F9FA),
    surfaceDim = Color(0xFFD2D7DC),
    surfaceContainerLowest = Color(0xFFFFFFFF),
    surfaceContainerLow = Color(0xFFEBEEF1),
    surfaceContainer = Color(0xFFE5E9EC),
    surfaceContainerHigh = Color(0xFFDFE3E7),
    surfaceContainerHighest = Color(0xFFD8DDE2),
)

internal val SteelDarkScheme = darkColorScheme(
    primary = Color(0xFFE9C46A),
    onPrimary = Color(0xFF3D2E00),
    // Brass stays brass at night: the primary action keeps its metal instead of going muddy.
    primaryContainer = Color(0xFFCFA444),
    onPrimaryContainer = Color(0xFF221800),
    inversePrimary = Color(0xFF876214),
    secondary = Color(0xFFB6C5D2),
    onSecondary = Color(0xFF20303C),
    secondaryContainer = Color(0xFF374653),
    onSecondaryContainer = Color(0xFFD2E1EE),
    tertiary = Color(0xFFB4C4FF),
    onTertiary = Color(0xFF00287D),
    tertiaryContainer = Color(0xFF1C42B0),
    onTertiaryContainer = Color(0xFFDCE2FF),
    error = Color(0xFFF2B8B5),
    onError = Color(0xFF601410),
    errorContainer = Color(0xFF8C1D18),
    onErrorContainer = Color(0xFFF9DEDC),
    background = Color(0xFF101316),
    onBackground = Color(0xFFE1E5E9),
    surface = Color(0xFF101316),
    onSurface = Color(0xFFE1E5E9),
    surfaceVariant = Color(0xFF3F474E),
    onSurfaceVariant = Color(0xFFBEC6CD),
    surfaceTint = Color(0xFFE9C46A),
    inverseSurface = Color(0xFFE1E5E9),
    inverseOnSurface = Color(0xFF2D3237),
    outline = Color(0xFF899198),
    outlineVariant = Color(0xFF3F474E),
    scrim = Color(0xFF000000),
    surfaceBright = Color(0xFF353A3F),
    surfaceDim = Color(0xFF101316),
    surfaceContainerLowest = Color(0xFF0B0E10),
    surfaceContainerLow = Color(0xFF171B1E),
    surfaceContainer = Color(0xFF1B1F23),
    surfaceContainerHigh = Color(0xFF252A2E),
    surfaceContainerHighest = Color(0xFF303539),
)

/** An anodized aluminium key cap: the only place colour marks an account's identity. */
@Immutable
data class KeyCapColor(val cap: Color, val stamp: Color)

internal val AnodizedCaps = listOf(
    KeyCapColor(cap = Color(0xFF2F5BD3), stamp = Color.White), // cobalt
    KeyCapColor(cap = Color(0xFF1F7F54), stamp = Color.White), // green
    KeyCapColor(cap = Color(0xFF7046C2), stamp = Color.White), // violet
    KeyCapColor(cap = Color(0xFFB4532A), stamp = Color.White), // copper
    KeyCapColor(cap = Color(0xFFC99A2E), stamp = Color(0xFF221800)), // brass
    KeyCapColor(cap = Color(0xFF0F7C86), stamp = Color.White), // teal
    KeyCapColor(cap = Color(0xFFAE3678), stamp = Color.White), // magenta
    KeyCapColor(cap = Color(0xFF4B5967), stamp = Color.White), // slate
)

/** Colours Material's scheme has no role for: the graphite shell, plates and the strength scale. */
@Immutable
data class BovedaColors(
    /** A raised steel plate holding a secret: always lighter than the ground, in both themes. */
    val plate: Color,
    val shell: Color,
    val onShell: Color,
    val onShellVariant: Color,
    val shellField: Color,
    val shellIndicator: Color,
    val onShellIndicator: Color,
    /** Very weak → very strong. */
    val strength: List<Color>,
    /**
     * Inks for reading a secret back character by character: digits in blued steel, symbols in a
     * lighter graphite. Neither is a key-cap hue nor the brass of the primary action.
     */
    val secretDigit: Color,
    val secretSymbol: Color,
    val keyCaps: List<KeyCapColor> = AnodizedCaps,
)

internal val SteelLightColors = BovedaColors(
    plate = Color(0xFFFFFFFF),
    shell = Color(0xFF20262C),
    onShell = Color(0xFFF1F3F5),
    onShellVariant = Color(0xFFAAB3BB),
    shellField = Color(0xFF2E353C),
    shellIndicator = Color(0xFFE9C46A),
    onShellIndicator = Color(0xFF251A00),
    strength = listOf(
        Color(0xFFB3261E),
        Color(0xFFC2541B),
        Color(0xFF9A6B00),
        Color(0xFF2E7D4F),
        Color(0xFF14694F),
    ),
    secretDigit = Color(0xFF3B5C80),
    secretSymbol = Color(0xFF5C646C),
)

internal val SteelDarkColors = BovedaColors(
    plate = Color(0xFF1B1F23),
    shell = Color(0xFF1B2025),
    onShell = Color(0xFFE1E5E9),
    onShellVariant = Color(0xFF9AA3AB),
    shellField = Color(0xFF283037),
    shellIndicator = Color(0xFFE9C46A),
    onShellIndicator = Color(0xFF251A00),
    strength = listOf(
        Color(0xFFF2B8B5),
        Color(0xFFFFB68E),
        Color(0xFFF0C04C),
        Color(0xFF7FD8A0),
        Color(0xFF5FD6B0),
    ),
    secretDigit = Color(0xFF9EBBDB),
    secretSymbol = Color(0xFF9AA3AB),
)
