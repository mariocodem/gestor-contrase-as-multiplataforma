import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One snackbar at a time: a new message replaces the one showing.
void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// Keeps the status and navigation bar icons legible over whatever this screen draws behind them.
SystemUiOverlayStyle systemBarsOver(Color statusBackground, Color navigationBackground) {
  Brightness iconsFor(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark ? Brightness.light : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
    statusBarIconBrightness: iconsFor(statusBackground),
    // iOS reads the bar's brightness, the opposite of the icons'.
    statusBarBrightness: iconsFor(statusBackground) == Brightness.dark ? Brightness.light : Brightness.dark,
    systemNavigationBarIconBrightness: iconsFor(navigationBackground),
  );
}

/// Whether the platform offers system colours (Material You, an accent colour); set by the root.
class DynamicColorAvailability extends InheritedWidget {
  const DynamicColorAvailability({super.key, required this.available, required super.child});

  final bool available;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DynamicColorAvailability>()?.available ?? false;

  @override
  bool updateShouldNotify(DynamicColorAvailability old) => old.available != available;
}
