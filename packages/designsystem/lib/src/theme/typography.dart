import 'package:flutter/material.dart';

// Atkinson Hyperlegible was drawn to keep similar letters apart (I l 1, O 0), which is exactly
// what reading and retyping a password needs. One family for the UI, its mono for secrets.
const _package = 'boveda_designsystem';
const uiFontFamily = 'AtkinsonHyperlegibleNext';
const secretFontFamily = 'AtkinsonHyperlegibleMono';

TextStyle _style(double size, double line, FontWeight weight, [double tracking = 0]) => TextStyle(
      fontFamily: uiFontFamily,
      package: _package,
      fontWeight: weight,
      fontSize: size,
      height: line / size,
      letterSpacing: tracking,
      leadingDistribution: TextLeadingDistribution.even,
    );

// A tight scale (about 1.15 per step); rank comes from weight more than from size.
final bovedaTextTheme = TextTheme(
  displayLarge: _style(48, 56, FontWeight.w600),
  displayMedium: _style(40, 48, FontWeight.w600),
  displaySmall: _style(34, 42, FontWeight.w600),
  headlineLarge: _style(30, 38, FontWeight.w600),
  headlineMedium: _style(26, 34, FontWeight.w600),
  headlineSmall: _style(23, 30, FontWeight.w600),
  titleLarge: _style(20, 28, FontWeight.w600),
  titleMedium: _style(16, 24, FontWeight.w600, 0.1),
  titleSmall: _style(14, 20, FontWeight.w600, 0.1),
  bodyLarge: _style(16, 24, FontWeight.w400, 0.15),
  bodyMedium: _style(14, 20, FontWeight.w400, 0.15),
  bodySmall: _style(12, 16, FontWeight.w400, 0.2),
  labelLarge: _style(14, 20, FontWeight.w600, 0.1),
  labelMedium: _style(12, 16, FontWeight.w600, 0.3),
  labelSmall: _style(11, 16, FontWeight.w600, 0.3),
);

TextStyle _secret(double size, double line) => TextStyle(
      fontFamily: secretFontFamily,
      package: _package,
      fontWeight: FontWeight.w500,
      fontSize: size,
      height: line / size,
      leadingDistribution: TextLeadingDistribution.even,
    );

/// Styles for secrets and numbers people compare character by character.
@immutable
class SecretTypography extends ThemeExtension<SecretTypography> {
  const SecretTypography({required this.large, required this.medium, required this.small});

  static final standard = SecretTypography(large: _secret(24, 34), medium: _secret(17, 24), small: _secret(13, 18));

  final TextStyle large;
  final TextStyle medium;
  final TextStyle small;

  @override
  SecretTypography copyWith({TextStyle? large, TextStyle? medium, TextStyle? small}) =>
      SecretTypography(large: large ?? this.large, medium: medium ?? this.medium, small: small ?? this.small);

  @override
  SecretTypography lerp(SecretTypography? other, double t) => other == null
      ? this
      : SecretTypography(
          large: TextStyle.lerp(large, other.large, t)!,
          medium: TextStyle.lerp(medium, other.medium, t)!,
          small: TextStyle.lerp(small, other.small, t)!,
        );
}
