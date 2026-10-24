import '../model/app_settings.dart';
import '../model/password_options.dart';
import '../repository/settings_repository.dart';

class ObserveSettingsUseCase {
  const ObserveSettingsUseCase(this._settings);

  final SettingsRepository _settings;

  Stream<AppSettings> call() => _settings.settings;
}

class SetAutoLockTimeoutUseCase {
  const SetAutoLockTimeoutUseCase(this._settings);

  final SettingsRepository _settings;

  Future<void> call(AutoLockTimeout timeout) => _settings.setAutoLock(timeout);
}

class SetDynamicColorUseCase {
  const SetDynamicColorUseCase(this._settings);

  final SettingsRepository _settings;

  Future<void> call(bool enabled) => _settings.setDynamicColor(enabled);
}

class SaveGeneratorOptionsUseCase {
  const SaveGeneratorOptionsUseCase(this._settings);

  final SettingsRepository _settings;

  Future<void> call(PasswordOptions options) => _settings.setGeneratorOptions(options);
}
