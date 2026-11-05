import 'package:flutter/material.dart';

// Monochrome: a near-white or near-black ground, solid ink for the one action, hairlines for edges.
// Colour is kept for what it means: which account (the caps), how strong, and what went wrong.
const bovedaLightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF171717),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF171717),
  onPrimaryContainer: Color(0xFFFFFFFF),
  inversePrimary: Color(0xFFEDEDED),
  secondary: Color(0xFF666666),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFEBEBEB),
  onSecondaryContainer: Color(0xFF171717),
  tertiary: Color(0xFF0068D6),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFE6F0FB),
  onTertiaryContainer: Color(0xFF00264D),
  error: Color(0xFFD6001C),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFDE8EA),
  onErrorContainer: Color(0xFF5C0011),
  surface: Color(0xFFFAFAFA),
  onSurface: Color(0xFF171717),
  onSurfaceVariant: Color(0xFF666666),
  surfaceTint: Colors.transparent,
  inverseSurface: Color(0xFF171717),
  onInverseSurface: Color(0xFFEDEDED),
  outline: Color(0xFF8F8F8F),
  outlineVariant: Color(0xFFEBEBEB),
  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
  surfaceBright: Color(0xFFFFFFFF),
  surfaceDim: Color(0xFFEBEBEB),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF7F7F7),
  surfaceContainer: Color(0xFFF2F2F2),
  surfaceContainerHigh: Color(0xFFEBEBEB),
  surfaceContainerHighest: Color(0xFFE0E0E0),
);

const bovedaDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFEDEDED),
  onPrimary: Color(0xFF0A0A0A),
  primaryContainer: Color(0xFFEDEDED),
  onPrimaryContainer: Color(0xFF0A0A0A),
  inversePrimary: Color(0xFF171717),
  secondary: Color(0xFFA1A1A1),
  onSecondary: Color(0xFF0A0A0A),
  secondaryContainer: Color(0xFF2E2E2E),
  onSecondaryContainer: Color(0xFFEDEDED),
  tertiary: Color(0xFF52A8FF),
  onTertiary: Color(0xFF0A0A0A),
  tertiaryContainer: Color(0xFF0A2A4D),
  onTertiaryContainer: Color(0xFFCFE6FF),
  error: Color(0xFFFF6166),
  onError: Color(0xFF0A0A0A),
  errorContainer: Color(0xFF3C0A0E),
  onErrorContainer: Color(0xFFFFD5D8),
  surface: Color(0xFF0A0A0A),
  onSurface: Color(0xFFEDEDED),
  onSurfaceVariant: Color(0xFFA1A1A1),
  surfaceTint: Colors.transparent,
  inverseSurface: Color(0xFFEDEDED),
  onInverseSurface: Color(0xFF171717),
  outline: Color(0xFF707070),
  outlineVariant: Color(0xFF2E2E2E),
  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
  surfaceBright: Color(0xFF2E2E2E),
  surfaceDim: Color(0xFF0A0A0A),
  surfaceContainerLowest: Color(0xFF000000),
  surfaceContainerLow: Color(0xFF111111),
  surfaceContainer: Color(0xFF1A1A1A),
  surfaceContainerHigh: Color(0xFF232323),
  surfaceContainerHighest: Color(0xFF2E2E2E),
);

/// A key cap: the only place colour marks an account's identity.
@immutable
class KeyCapColor {
  const KeyCapColor({required this.cap, required this.stamp});

  final Color cap;
  final Color stamp;
}

// The order is part of the data: an account's hue is its label's hash modulo this list.
const anodizedCaps = <KeyCapColor>[
  KeyCapColor(cap: Color(0xFF3B5BA5), stamp: Color(0xFFFFFFFF)), // cobalt
  KeyCapColor(cap: Color(0xFF2F7D5B), stamp: Color(0xFFFFFFFF)), // green
  KeyCapColor(cap: Color(0xFF6B55A8), stamp: Color(0xFFFFFFFF)), // violet
  KeyCapColor(cap: Color(0xFFA8583A), stamp: Color(0xFFFFFFFF)), // copper
  KeyCapColor(cap: Color(0xFFB8963F), stamp: Color(0xFF1A1400)), // brass
  KeyCapColor(cap: Color(0xFF2A7A80), stamp: Color(0xFFFFFFFF)), // teal
  KeyCapColor(cap: Color(0xFFA0456F), stamp: Color(0xFFFFFFFF)), // magenta
  KeyCapColor(cap: Color(0xFF5A6672), stamp: Color(0xFFFFFFFF)), // slate
];

/// Colours Material's scheme has no role for: the top-level frame, plates and the strength scale.
@immutable
class BovedaColors extends ThemeExtension<BovedaColors> {
  const BovedaColors({
    required this.plate,
    required this.plateEdge,
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

  /// A raised plate holding a secret: always lighter than the ground, in both themes.
  final Color plate;

  /// The hairline at a plate's edge, in place of a shadow.
  final Color plateEdge;
  final Color shell;
  final Color onShell;
  final Color onShellVariant;
  final Color shellField;
  final Color shellIndicator;
  final Color onShellIndicator;

  /// Very weak → very strong.
  final List<Color> strength;

  /// Inks for reading a secret back character by character: digits in blue, symbols in grey.
  final Color secretDigit;
  final Color secretSymbol;
  final List<KeyCapColor> keyCaps;

  static const light = BovedaColors(
    plate: Color(0xFFFFFFFF),
    plateEdge: Color(0x14000000),
    shell: Color(0xFFFFFFFF),
    onShell: Color(0xFF171717),
    onShellVariant: Color(0xFF666666),
    shellField: Color(0xFFF2F2F2),
    shellIndicator: Color(0xFF171717),
    onShellIndicator: Color(0xFFFFFFFF),
    strength: [Color(0xFFD6001C), Color(0xFFC25E00), Color(0xFF946800), Color(0xFF1C7C4A), Color(0xFF0F6B45)],
    secretDigit: Color(0xFF0B5CAD),
    secretSymbol: Color(0xFF707070),
  );

  static const dark = BovedaColors(
    plate: Color(0xFF171717),
    plateEdge: Color(0x24FFFFFF),
    shell: Color(0xFF0A0A0A),
    onShell: Color(0xFFEDEDED),
    onShellVariant: Color(0xFFA1A1A1),
    shellField: Color(0xFF1A1A1A),
    shellIndicator: Color(0xFFEDEDED),
    onShellIndicator: Color(0xFF0A0A0A),
    strength: [Color(0xFFFF6166), Color(0xFFFF9F45), Color(0xFFF0C04C), Color(0xFF62C98F), Color(0xFF3FD09A)],
    secretDigit: Color(0xFF7DB6F0),
    secretSymbol: Color(0xFF8F8F8F),
  );

  /// With system colours the frame follows Material's own surfaces; caps, secret inks and the
  /// strength scale keep their values.
  factory BovedaColors.dynamicFrom(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final base = dark ? BovedaColors.dark : BovedaColors.light;
    return base.copyWith(
      plate: dark ? scheme.surfaceContainer : scheme.surfaceContainerLowest,
      plateEdge: scheme.outlineVariant,
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
    Color? plateEdge,
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
        plateEdge: plateEdge ?? this.plateEdge,
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
      plateEdge: mix(plateEdge, other.plateEdge),
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
