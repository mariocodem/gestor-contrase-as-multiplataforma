import 'package:flutter/material.dart';

// Brushed steel ground, a graphite shell panel, brass for the one primary action.
const steelLightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF876214),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFE9C46A),
  onPrimaryContainer: Color(0xFF251A00),
  inversePrimary: Color(0xFFE9C46A),
  secondary: Color(0xFF4E5D69),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD2DEE8),
  onSecondaryContainer: Color(0xFF0B1D29),
  tertiary: Color(0xFF2F5BD3),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFDCE2FF),
  onTertiaryContainer: Color(0xFF001550),
  error: Color(0xFFB3261E),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFF9DEDC),
  onErrorContainer: Color(0xFF410E0B),
  surface: Color(0xFFF1F3F5),
  onSurface: Color(0xFF191C1F),
  onSurfaceVariant: Color(0xFF434A51),
  surfaceTint: Color(0xFF876214),
  inverseSurface: Color(0xFF2D3237),
  onInverseSurface: Color(0xFFEEF1F4),
  outline: Color(0xFF737A82),
  outlineVariant: Color(0xFFC2C8CE),
  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
  surfaceBright: Color(0xFFF7F9FA),
  surfaceDim: Color(0xFFD2D7DC),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFEBEEF1),
  surfaceContainer: Color(0xFFE5E9EC),
  surfaceContainerHigh: Color(0xFFDFE3E7),
  surfaceContainerHighest: Color(0xFFD8DDE2),
);

const steelDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFE9C46A),
  onPrimary: Color(0xFF3D2E00),
  // Brass stays brass at night: the primary action keeps its metal instead of going muddy.
  primaryContainer: Color(0xFFCFA444),
  onPrimaryContainer: Color(0xFF221800),
  inversePrimary: Color(0xFF876214),
  secondary: Color(0xFFB6C5D2),
  onSecondary: Color(0xFF20303C),
  secondaryContainer: Color(0xFF374653),
  onSecondaryContainer: Color(0xFFD2E1EE),
  tertiary: Color(0xFFB4C4FF),
  onTertiary: Color(0xFF00287D),
  tertiaryContainer: Color(0xFF1C42B0),
  onTertiaryContainer: Color(0xFFDCE2FF),
  error: Color(0xFFF2B8B5),
  onError: Color(0xFF601410),
  errorContainer: Color(0xFF8C1D18),
  onErrorContainer: Color(0xFFF9DEDC),
  surface: Color(0xFF101316),
  onSurface: Color(0xFFE1E5E9),
  onSurfaceVariant: Color(0xFFBEC6CD),
  surfaceTint: Color(0xFFE9C46A),
  inverseSurface: Color(0xFFE1E5E9),
  onInverseSurface: Color(0xFF2D3237),
  outline: Color(0xFF899198),
  outlineVariant: Color(0xFF3F474E),
  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
  surfaceBright: Color(0xFF353A3F),
  surfaceDim: Color(0xFF101316),
  surfaceContainerLowest: Color(0xFF0B0E10),
  surfaceContainerLow: Color(0xFF171B1E),
  surfaceContainer: Color(0xFF1B1F23),
  surfaceContainerHigh: Color(0xFF252A2E),
  surfaceContainerHighest: Color(0xFF303539),
);

/// An anodized aluminium key cap: the only place colour marks an account's identity.
@immutable
class KeyCapColor {
  const KeyCapColor({required this.cap, required this.stamp});

  final Color cap;
  final Color stamp;
}

const anodizedCaps = <KeyCapColor>[
  KeyCapColor(cap: Color(0xFF2F5BD3), stamp: Color(0xFFFFFFFF)), // cobalt
  KeyCapColor(cap: Color(0xFF1F7F54), stamp: Color(0xFFFFFFFF)), // green
  KeyCapColor(cap: Color(0xFF7046C2), stamp: Color(0xFFFFFFFF)), // violet
  KeyCapColor(cap: Color(0xFFB4532A), stamp: Color(0xFFFFFFFF)), // copper
  KeyCapColor(cap: Color(0xFFC99A2E), stamp: Color(0xFF221800)), // brass
  KeyCapColor(cap: Color(0xFF0F7C86), stamp: Color(0xFFFFFFFF)), // teal
  KeyCapColor(cap: Color(0xFFAE3678), stamp: Color(0xFFFFFFFF)), // magenta
  KeyCapColor(cap: Color(0xFF4B5967), stamp: Color(0xFFFFFFFF)), // slate
];

/// Colours Material's scheme has no role for: the graphite shell, plates and the strength scale.
@immutable
class BovedaColors extends ThemeExtension<BovedaColors> {
  const BovedaColors({
    required this.plate,
    required this.shell,
    required this.onShell,
    required this.onShellVariant,
    required this.shellField,
    required this.shellIndicator,
    required this.onShellIndicator,
    required this.strength,
    required this.secretDigit,
    required this.secretSymbol,
    this.keyCaps = anodizedCaps,
  });

  /// A raised steel plate holding a secret: always lighter than the ground, in both themes.
  final Color plate;
  final Color shell;
  final Color onShell;
  final Color onShellVariant;
  final Color shellField;
  final Color shellIndicator;
  final Color onShellIndicator;

  /// Very weak → very strong.
  final List<Color> strength;

  /// Inks for reading a secret back character by character: digits in blued steel, symbols in a
  /// lighter graphite. Neither is a key-cap hue nor the brass of the primary action.
  final Color secretDigit;
  final Color secretSymbol;
  final List<KeyCapColor> keyCaps;

  static const light = BovedaColors(
    plate: Color(0xFFFFFFFF),
    shell: Color(0xFF20262C),
    onShell: Color(0xFFF1F3F5),
    onShellVariant: Color(0xFFAAB3BB),
    shellField: Color(0xFF2E353C),
    shellIndicator: Color(0xFFE9C46A),
    onShellIndicator: Color(0xFF251A00),
    strength: [Color(0xFFB3261E), Color(0xFFC2541B), Color(0xFF9A6B00), Color(0xFF2E7D4F), Color(0xFF14694F)],
    secretDigit: Color(0xFF3B5C80),
    secretSymbol: Color(0xFF5C646C),
  );

  static const dark = BovedaColors(
    plate: Color(0xFF1B1F23),
    shell: Color(0xFF1B2025),
    onShell: Color(0xFFE1E5E9),
    onShellVariant: Color(0xFF9AA3AB),
    shellField: Color(0xFF283037),
    shellIndicator: Color(0xFFE9C46A),
    onShellIndicator: Color(0xFF251A00),
    strength: [Color(0xFFF2B8B5), Color(0xFFFFB68E), Color(0xFFF0C04C), Color(0xFF7FD8A0), Color(0xFF5FD6B0)],
    secretDigit: Color(0xFF9EBBDB),
    secretSymbol: Color(0xFF9AA3AB),
  );

  /// With system colours the shell follows Material's own surfaces instead of graphite; caps,
  /// secret inks and the strength scale keep their values.
  factory BovedaColors.dynamicFrom(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final base = dark ? BovedaColors.dark : BovedaColors.light;
    return base.copyWith(
      plate: dark ? scheme.surfaceContainer : scheme.surfaceContainerLowest,
      shell: scheme.surfaceContainer,
      onShell: scheme.onSurface,
      onShellVariant: scheme.onSurfaceVariant,
      shellField: scheme.surfaceContainerHighest,
      shellIndicator: scheme.secondaryContainer,
      onShellIndicator: scheme.onSecondaryContainer,
    );
  }

  @override
  BovedaColors copyWith({
    Color? plate,
    Color? shell,
    Color? onShell,
    Color? onShellVariant,
    Color? shellField,
    Color? shellIndicator,
    Color? onShellIndicator,
    List<Color>? strength,
    Color? secretDigit,
    Color? secretSymbol,
  }) =>
      BovedaColors(
        plate: plate ?? this.plate,
        shell: shell ?? this.shell,
        onShell: onShell ?? this.onShell,
        onShellVariant: onShellVariant ?? this.onShellVariant,
        shellField: shellField ?? this.shellField,
        shellIndicator: shellIndicator ?? this.shellIndicator,
        onShellIndicator: onShellIndicator ?? this.onShellIndicator,
        strength: strength ?? this.strength,
        secretDigit: secretDigit ?? this.secretDigit,
        secretSymbol: secretSymbol ?? this.secretSymbol,
      );

  @override
  BovedaColors lerp(BovedaColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return BovedaColors(
      plate: mix(plate, other.plate),
      shell: mix(shell, other.shell),
      onShell: mix(onShell, other.onShell),
      onShellVariant: mix(onShellVariant, other.onShellVariant),
      shellField: mix(shellField, other.shellField),
      shellIndicator: mix(shellIndicator, other.shellIndicator),
      onShellIndicator: mix(onShellIndicator, other.onShellIndicator),
      strength: [for (var i = 0; i < strength.length; i++) mix(strength[i], other.strength[i])],
      secretDigit: mix(secretDigit, other.secretDigit),
      secretSymbol: mix(secretSymbol, other.secretSymbol),
    );
  }
}
