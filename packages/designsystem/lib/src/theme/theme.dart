import 'package:flutter/material.dart';

import '../component/button.dart';
import 'colors.dart';
import 'typography.dart';

/// Tight corners: buttons and fields at 6 to 8, plates at 12.
abstract final class BovedaShapes {
  static const extraSmall = BorderRadius.all(Radius.circular(4));
  static const small = BorderRadius.all(Radius.circular(6));
  static const medium = BorderRadius.all(Radius.circular(8));
  static const large = BorderRadius.all(Radius.circular(12));
  static const extraLarge = BorderRadius.all(Radius.circular(16));
}

/// The theme. With [dynamicScheme] (opt-in from Ajustes where the system offers one) the
/// system palette replaces it; key caps keep their hues either way, because they identify accounts.
ThemeData bovedaTheme({required Brightness brightness, ColorScheme? dynamicScheme}) {
  final dark = brightness == Brightness.dark;
  final scheme = dynamicScheme ?? (dark ? bovedaDarkScheme : bovedaLightScheme);
  final colors = dynamicScheme != null ? BovedaColors.dynamicFrom(scheme) : (dark ? BovedaColors.dark : BovedaColors.light);
  final text = bovedaTextTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  final fieldEdge = BorderSide(color: colors.plateEdge);

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
    // InkSparkle runs a fragment shader on every tap; the ripple reads the same for a fraction of it.
    splashFactory: InkRipple.splashFactory,
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
    filledButtonTheme: FilledButtonThemeData(style: bovedaButtonStyle(scheme, colors, text)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: bovedaButtonStyle(scheme, colors, text, type: BovedaButtonType.secondary)),
    textButtonTheme: TextButtonThemeData(style: bovedaButtonStyle(scheme, colors, text, type: BovedaButtonType.tertiary)),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      focusElevation: 2,
      hoverElevation: 3,
      highlightElevation: 1,
      shape: const RoundedRectangleBorder(borderRadius: BovedaShapes.medium),
      extendedTextStyle: text.labelLarge,
      extendedSizeConstraints: const BoxConstraints.tightFor(height: 48),
      extendedPadding: const EdgeInsetsDirectional.only(start: 14, end: 18),
      extendedIconLabelSpacing: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.plate,
      border: OutlineInputBorder(borderRadius: BovedaShapes.medium, borderSide: fieldEdge),
      enabledBorder: OutlineInputBorder(borderRadius: BovedaShapes.medium, borderSide: fieldEdge),
      focusedBorder: OutlineInputBorder(borderRadius: BovedaShapes.medium, borderSide: BorderSide(color: scheme.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BovedaShapes.medium, borderSide: BorderSide(color: scheme.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BovedaShapes.medium, borderSide: BorderSide(color: scheme.error, width: 1.5)),
      disabledBorder: OutlineInputBorder(
        borderRadius: BovedaShapes.medium,
        borderSide: BorderSide(color: scheme.onSurface.withValues(alpha: 0.08)),
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
      tileColor: Colors.transparent,
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
      shape: const RoundedRectangleBorder(borderRadius: BovedaShapes.large),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      actionTextColor: scheme.inversePrimary,
      shape: const RoundedRectangleBorder(borderRadius: BovedaShapes.medium),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      textStyle: text.bodyLarge,
      shape: const RoundedRectangleBorder(borderRadius: BovedaShapes.medium),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.shell,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 80,
      indicatorColor: colors.shellIndicator,
      indicatorShape: const RoundedRectangleBorder(borderRadius: BovedaShapes.medium),
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
      indicatorShape: const RoundedRectangleBorder(borderRadius: BovedaShapes.medium),
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: text.labelMedium?.copyWith(color: colors.onShell),
      unselectedLabelTextStyle: text.labelMedium?.copyWith(color: colors.onShellVariant),
      selectedIconTheme: IconThemeData(size: 24, color: colors.onShellIndicator),
      unselectedIconTheme: IconThemeData(size: 24, color: colors.onShellVariant),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withValues(alpha: 0.12),
      activeTickMarkColor: Colors.transparent,
      inactiveTickMarkColor: Colors.transparent,
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
