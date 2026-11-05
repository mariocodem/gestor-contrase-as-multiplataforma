import 'password_options.dart';

/// How long the vault stays unlocked while the app is in the background.
enum AutoLockTimeout {
  immediately(Duration.zero),
  seconds30(Duration(seconds: 30)),
  minute1(Duration(minutes: 1)),
  minutes5(Duration(minutes: 5)),
  minutes15(Duration(minutes: 15));

  const AutoLockTimeout(this.duration);

  final Duration duration;
}

/// Whether the app follows the system's light or dark setting, or keeps its own.
enum AppThemeMode { system, light, dark }

final class AppSettings {
  const AppSettings({
    this.autoLock = AutoLockTimeout.minute1,
    this.dynamicColor = false,
    this.themeMode = AppThemeMode.system,
    this.generatorOptions = const PasswordOptions(),
  });

  final AutoLockTimeout autoLock;

  /// Use the system (wallpaper or accent) palette instead of the app's own.
  final bool dynamicColor;

  final AppThemeMode themeMode;

  /// The generator opens with whatever the user picked last time.
  final PasswordOptions generatorOptions;

  AppSettings copyWith({
    AutoLockTimeout? autoLock,
    bool? dynamicColor,
    AppThemeMode? themeMode,
    PasswordOptions? generatorOptions,
  }) =>
      AppSettings(
        autoLock: autoLock ?? this.autoLock,
        dynamicColor: dynamicColor ?? this.dynamicColor,
        themeMode: themeMode ?? this.themeMode,
        generatorOptions: generatorOptions ?? this.generatorOptions,
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.autoLock == autoLock &&
      other.dynamicColor == dynamicColor &&
      other.themeMode == themeMode &&
      other.generatorOptions == generatorOptions;

  @override
  int get hashCode => Object.hash(autoLock, dynamicColor, themeMode, generatorOptions);
}
