import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/dependencies.dart';
import '../common/error_messages.dart';

class LockUiState {
  const LockUiState({
    this.password = '',
    this.confirmation = '',
    this.strength = PasswordStrength.empty,
    this.isWorking = false,
    this.error,
    this.biometricEnabled = false,
    this.rejections = 0,
  });

  final String password;
  final String confirmation;
  final PasswordStrength strength;
  final bool isWorking;
  final String? error;
  final bool biometricEnabled;

  /// Failed attempts since the screen opened; each one swings the emblem.
  final int rejections;

  LockUiState copyWith({
    String? password,
    String? confirmation,
    PasswordStrength? strength,
    bool? isWorking,
    String? Function()? error,
    bool? biometricEnabled,
    int? rejections,
  }) =>
      LockUiState(
        password: password ?? this.password,
        confirmation: confirmation ?? this.confirmation,
        strength: strength ?? this.strength,
        isWorking: isWorking ?? this.isWorking,
        error: error == null ? this.error : error(),
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        rejections: rejections ?? this.rejections,
      );
}

/// Creates the vault (first run) or unlocks it, with the master password or biometrics.
class LockCubit extends Cubit<LockUiState> {
  LockCubit(this._deps, this._user) : super(const LockUiState()) {
    biometricsKnown = _refreshBiometrics();
  }

  final Dependencies _deps;
  final User _user;

  /// Completes once biometric availability is known, so the screen can offer it straight away.
  late final Future<void> biometricsKnown;

  Future<void> _refreshBiometrics() async {
    final status = await _deps.biometricStatus(_user.id);
    if (!isClosed) emit(state.copyWith(biometricEnabled: status.available && status.enabled));
  }

  void onPasswordChange(String value) =>
      emit(state.copyWith(password: value, strength: _deps.evaluateStrength(value), error: () => null));

  void onConfirmationChange(String value) => emit(state.copyWith(confirmation: value, error: () => null));

  Future<void> submit({required bool isSetup}) async {
    if (state.isWorking) return;
    final current = state;
    emit(state.copyWith(isWorking: true, error: () => null));
    final result = isSetup
        ? await _deps.createVault(_user.id, current.password, current.confirmation)
        : await _deps.unlockVault(_user.id, current.password);
    if (isClosed) return;
    switch (result) {
      case Success():
        _forgetTypedSecrets();
      case Failure(:final error):
        emit(_rejected(state.copyWith(isWorking: false), error));
    }
  }

  Future<void> unlockWithBiometrics(BiometricPrompt prompt) async {
    if (state.isWorking) return;
    final result = await _deps.unlockWithBiometrics(_user.id, prompt);
    if (isClosed) return;
    switch (result) {
      case Success(value: true):
        _forgetTypedSecrets();
      case Success(value: false):
        break; // Cancelled: the password field is right there.
      case Failure(:final error):
        emit(_rejected(state, error));
        await _refreshBiometrics();
    }
  }

  /// The master password has done its job; don't keep it in memory.
  void _forgetTypedSecrets() => emit(LockUiState(biometricEnabled: state.biometricEnabled));

  LockUiState _rejected(LockUiState from, AppError error) =>
      from.copyWith(error: () => errorMessage(error), rejections: from.rejections + 1);
}
