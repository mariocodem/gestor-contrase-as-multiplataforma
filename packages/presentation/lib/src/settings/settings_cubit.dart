import 'dart:async';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/dependencies.dart';
import '../common/error_messages.dart';
import '../common/strings.dart';

class SettingsState {
  const SettingsState({
    this.email,
    this.autoLock = AutoLockTimeout.minute1,
    this.dynamicColor = false,
    this.biometricAvailable = false,
    this.biometricEnabled = false,
  });

  final String? email;
  final AutoLockTimeout autoLock;
  final bool dynamicColor;
  final bool biometricAvailable;
  final bool biometricEnabled;
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._deps, this._user) : super(SettingsState(email: _user.email)) {
    _settings = _deps.observeSettings().listen((settings) {
      _latest = settings;
      unawaited(_publish());
    });
  }

  final Dependencies _deps;
  final User _user;
  final _messages = StreamController<String>();
  late final StreamSubscription<AppSettings> _settings;
  AppSettings _latest = const AppSettings();

  Stream<String> get messages => _messages.stream;

  Future<void> _publish() async {
    final biometric = await _deps.biometricStatus(_user.id);
    if (isClosed) return;
    emit(
      SettingsState(
        email: _user.email,
        autoLock: _latest.autoLock,
        dynamicColor: _latest.dynamicColor,
        biometricAvailable: biometric.available,
        biometricEnabled: biometric.enabled,
      ),
    );
  }

  Future<void> setAutoLock(AutoLockTimeout timeout) => _deps.setAutoLock(timeout);

  Future<void> setDynamicColor(bool enabled) => _deps.setDynamicColor(enabled);

  Future<void> enableBiometric(BiometricPrompt prompt) async {
    final result = await _deps.enableBiometrics(_user.id, prompt);
    switch (result) {
      case Success(value: true):
        _messages.add(S.settingsBiometricOn);
      case Success(value: false):
        break;
      case Failure(:final error):
        _messages.add(errorMessage(error));
    }
    await _publish();
  }

  Future<void> disableBiometric() async {
    await _deps.disableBiometrics(_user.id);
    _messages.add(S.settingsBiometricOff);
    await _publish();
  }

  void lockNow() => _deps.lockVault();

  Future<void> signOut() => _deps.signOut();

  @override
  Future<void> close() async {
    await _settings.cancel();
    // Not awaited: a stream nobody listened to never reports done.
    unawaited(_messages.close());
    return super.close();
  }
}
