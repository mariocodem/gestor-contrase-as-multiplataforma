import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/dependencies.dart';
import '../common/error_messages.dart';
import '../common/strings.dart';

class AuthState {
  const AuthState({
    this.email = '',
    this.password = '',
    this.isRegistering = false,
    this.isWorking = false,
    this.error,
    this.info,
  });

  final String email;
  final String password;
  final bool isRegistering;
  final bool isWorking;
  final String? error;
  final String? info;

  AuthState copyWith({
    String? email,
    String? password,
    bool? isRegistering,
    bool? isWorking,
    String? Function()? error,
    String? Function()? info,
  }) =>
      AuthState(
        email: email ?? this.email,
        password: password ?? this.password,
        isRegistering: isRegistering ?? this.isRegistering,
        isWorking: isWorking ?? this.isWorking,
        error: error == null ? this.error : error(),
        info: info == null ? this.info : info(),
      );
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._deps) : super(const AuthState());

  final Dependencies _deps;

  void onEmailChange(String value) => emit(state.copyWith(email: value, error: () => null, info: () => null));

  void onPasswordChange(String value) => emit(state.copyWith(password: value, error: () => null, info: () => null));

  void toggleMode() => emit(state.copyWith(isRegistering: !state.isRegistering, error: () => null, info: () => null));

  /// True when the account opened; the root screen then moves on by itself.
  Future<bool> submit() async {
    if (state.isWorking) return false;
    final current = state;
    _working();
    final result = current.isRegistering
        ? await _deps.register(current.email, current.password)
        : await _deps.signIn(current.email, current.password);
    if (isClosed) return result.isSuccess;
    switch (result) {
      case Success():
        emit(state.copyWith(password: '', isWorking: false));
        return true;
      case Failure(:final error):
        emit(state.copyWith(isWorking: false, error: () => errorMessage(error)));
        return false;
    }
  }

  Future<void> requestPasswordReset() async {
    if (state.isWorking) return;
    _working();
    final result = await _deps.sendPasswordReset(state.email);
    if (isClosed) return;
    emit(switch (result) {
      Success() => state.copyWith(isWorking: false, info: () => S.authResetSent),
      Failure(:final error) => state.copyWith(isWorking: false, error: () => errorMessage(error)),
    });
  }

  void _working() => emit(state.copyWith(isWorking: true, error: () => null, info: () => null));
}
