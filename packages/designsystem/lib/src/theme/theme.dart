import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// Softly machined corners: Material's slots at 6, 10, 14, 20 and 28.
abstract final class BovedaShapes {
  static const extraSmall = BorderRadius.all(Radius.circular(6));
  static const small = BorderRadius.all(Radius.circular(10));
  static const medium = BorderRadius.all(Radius.circular(14));
  static const large = BorderRadius.all(Radius.circular(20));
  static const extraLarge = BorderRadius.all(Radius.circular(28));
}

/// The steel-and-brass theme. With [dynamicScheme] (opt-in from Ajustes where the system offers
/// one) the system palette replaces it; key caps keep their anodized hues either way, because
/// they identify accounts.
ThemeData bovedaTheme({required Brightness brightness, ColorScheme? dynamicScheme}) {
  final dark = brightness == Brightness.dark;
  final scheme = dynamicScheme ?? (dark ? steelDarkScheme : steelLightScheme);
  final colors = dynamicScheme != null ? BovedaColors.dynamicFrom(scheme) : (dark ? BovedaColors.dark : BovedaColors.light);
  final text = bovedaTextTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  const pill = StadiumBorder();

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    textTheme: text,
    // Packaged fonts are addressed by their full asset family name.
    fontFamily: 'packages/boveda_designsystem/$uiFontFamily',
    extensions: [colors, SecretTypography.standard],
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 64,
      titleTextStyle: text.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: pill,
        textStyle: text.labelLarge,
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: pill,
        textStyle: text.labelLarge,
        side: BorderSide(color: scheme.outline),
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: pill, textStyle: text.labelLarge, minimumSize: const Size(48, 40)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      shape: const RoundedRectangleBorder(borderRadius: BovedaShapes.large),
      extendedTextStyle: text.labelLarge,
      extendedSizeConstraints: const BoxConstraints.tightFor(height: 56),
      extendedPadding: const EdgeInsetsDirectional.only(start: 16, end: 20),
      extendedIconLabelSpacing: 12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(borderRadius: BovedaShapes.extraSmall),
      enabledBorder: OutlineInputBorder(borderRadius: BovedaShapes.extraSmall, borderSide: BorderSide(color: scheme.outline)),
      focusedBorder:
          OutlineInputBorder(borderRadius: BovedaShapes.extraSmall, borderSide: BorderSide(color: scheme.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BovedaShapes.extraSmall, borderSide: BorderSide(color: scheme.error)),
      focusedErrorBorder:
          OutlineInputBorder(borderRadius: BovedaShapes.extraSmall, borderSide: BorderSide(color: scheme.error, width: 2)),
      disabledBorder: OutlineInputBorder(
        borderRadius: BovedaShapes.extraSmall,
        borderSide: BorderSide(color: scheme.onSurface.withValues(alpha: 0.12)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
      floatingLabelStyle: text.bodySmall,
      hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
      helperStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      errorStyle: text.bodySmall?.copyWith(color: scheme.error),
      helperMaxLines: 3,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: 0.35),
      selectionHandleColor: scheme.primary,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: scheme.surface,
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      titleTextStyle: text.bodyLarge,
      subtitleTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      horizontalTitleGap: 16,
      minVerticalPadding: 8,
      minTileHeight: 56,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BovedaShapes.extraLarge),
      titleTextStyle: text.headlineSmall,
      contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      actionTextColor: scheme.inversePrimary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      insetPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      textStyle: text.bodyLarge,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.shell,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 80,
      indicatorColor: colors.shellIndicator,
      indicatorShape: pill,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text.labelMedium?.copyWith(
          color: states.contains(WidgetState.selected) ? colors.onShell : colors.onShellVariant,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected) ? colors.onShellIndicator : colors.onShellVariant,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colors.shell,
      elevation: 0,
      indicatorColor: colors.shellIndicator,
      indicatorShape: pill,
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: text.labelMedium?.copyWith(color: colors.onShell),
      unselectedLabelTextStyle: text.labelMedium?.copyWith(color: colors.onShellVariant),
      selectedIconTheme: IconThemeData(size: 24, color: colors.onShellIndicator),
      unselectedIconTheme: IconThemeData(size: 24, color: colors.onShellVariant),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      circularTrackColor: Colors.transparent,
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
      decoration: BoxDecoration(color: scheme.inverseSurface, borderRadius: const BorderRadius.all(Radius.circular(4))),
    ),
  );
}

/// The Bóveda extensions of the current theme.
extension BovedaThemeContext on BuildContext {
  BovedaColors get bovedaColors => Theme.of(this).extension<BovedaColors>()!;

  SecretTypography get secretType => Theme.of(this).extension<SecretTypography>()!;
}
