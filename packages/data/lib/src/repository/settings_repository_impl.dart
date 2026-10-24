import 'dart:async';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Plain preferences: nothing here is secret, so it isn't encrypted.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl([SharedPreferencesAsync? preferences]) : _preferences = preferences ?? SharedPreferencesAsync() {
    unawaited(_load());
  }

  final SharedPreferencesAsync _preferences;
  final _settings = BehaviorSubject<AppSettings>();

  static const _autoLock = 'auto_lock';
  static const _dynamicColor = 'dynamic_color';
  static const _length = 'generator_length';
  static const _uppercase = 'generator_uppercase';
  static const _lowercase = 'generator_lowercase';
  static const _digits = 'generator_digits';
  static const _symbols = 'generator_symbols';
  static const _avoidAmbiguous = 'generator_avoid_ambiguous';

  @override
  Stream<AppSettings> get settings => _settings.stream.distinct();

  Future<void> _load() async {
    const defaults = AppSettings();
    final generator = defaults.generatorOptions;
    try {
      final autoLock = await _preferences.getString(_autoLock);
      _settings.add(
        AppSettings(
          autoLock: AutoLockTimeout.values.where((value) => value.name == autoLock).firstOrNull ?? defaults.autoLock,
          dynamicColor: await _preferences.getBool(_dynamicColor) ?? defaults.dynamicColor,
          generatorOptions: PasswordOptions(
            length: await _preferences.getInt(_length) ?? generator.length,
            uppercase: await _preferences.getBool(_uppercase) ?? generator.uppercase,
            lowercase: await _preferences.getBool(_lowercase) ?? generator.lowercase,
            digits: await _preferences.getBool(_digits) ?? generator.digits,
            symbols: await _preferences.getBool(_symbols) ?? generator.symbols,
            avoidAmbiguous: await _preferences.getBool(_avoidAmbiguous) ?? generator.avoidAmbiguous,
          ),
        ),
      );
    } catch (_) {
      _settings.add(defaults);
    }
  }

  Future<AppSettings> get _current async => _settings.valueOrNull ?? await _settings.first;

  @override
  Future<void> setAutoLock(AutoLockTimeout timeout) async {
    _settings.add((await _current).copyWith(autoLock: timeout));
    await _preferences.setString(_autoLock, timeout.name);
  }

  @override
  Future<void> setDynamicColor(bool enabled) async {
    _settings.add((await _current).copyWith(dynamicColor: enabled));
    await _preferences.setBool(_dynamicColor, enabled);
  }

  @override
  Future<void> setGeneratorOptions(PasswordOptions options) async {
    _settings.add((await _current).copyWith(generatorOptions: options));
    await Future.wait([
      _preferences.setInt(_length, options.length),
      _preferences.setBool(_uppercase, options.uppercase),
      _preferences.setBool(_lowercase, options.lowercase),
      _preferences.setBool(_digits, options.digits),
      _preferences.setBool(_symbols, options.symbols),
      _preferences.setBool(_avoidAmbiguous, options.avoidAmbiguous),
    ]);
  }
}
