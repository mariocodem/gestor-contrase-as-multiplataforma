import '../model/app_settings.dart';
import '../model/password_options.dart';

abstract interface class SettingsRepository {
  /// Emits the current settings on listen, then every change.
  Stream<AppSettings> get settings;

  Future<void> setAutoLock(AutoLockTimeout timeout);

  Future<void> setDynamicColor(bool enabled);

  Future<void> setGeneratorOptions(PasswordOptions options);
}
