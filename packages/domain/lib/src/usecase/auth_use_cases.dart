import '../error/app_error.dart';
import '../error/result.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart';
import '../repository/vault_repository.dart';

class ObserveCurrentUserUseCase {
  const ObserveCurrentUserUseCase(this._auth);

  final AuthRepository _auth;

  Stream<User?> call() => _auth.currentUser;
}

class SignInUseCase {
  const SignInUseCase(this._auth);

  final AuthRepository _auth;

  Future<Result<void>> call(String email, String password) => resultOf(() async {
        final trimmed = email.trim();
        if (trimmed.isEmpty || password.isEmpty) throw const AppException(AppError.missingCredentials);
        await _auth.signIn(trimmed, password);
      });
}

class RegisterUseCase {
  const RegisterUseCase(this._auth);

  final AuthRepository _auth;

  /// The server only ever receives a key derived from the account password, so the device is
  /// where its length is checked.
  static const minAccountPasswordLength = 8;

  Future<Result<void>> call(String email, String password) => resultOf(() async {
        final trimmed = email.trim();
        if (trimmed.isEmpty || password.isEmpty) throw const AppException(AppError.missingCredentials);
        if (!looksLikeEmail(trimmed)) throw const AppException(AppError.invalidEmail);
        if (password.length < minAccountPasswordLength) throw const AppException(AppError.weakAccountPassword);
        await _auth.register(trimmed, password);
      });
}

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._auth);

  final AuthRepository _auth;

  Future<Result<void>> call(String email) => resultOf(() async {
        final trimmed = email.trim();
        if (trimmed.isEmpty) throw const AppException(AppError.missingEmail);
        if (!looksLikeEmail(trimmed)) throw const AppException(AppError.invalidEmail);
        await _auth.sendPasswordReset(trimmed);
      });
}

/// Locks first, so no decrypted data outlives the account session.
class SignOutUseCase {
  const SignOutUseCase(this._auth, this._vault);

  final AuthRepository _auth;
  final VaultRepository _vault;

  Future<void> call() async {
    _vault.lock();
    await _auth.signOut();
  }
}

/// Deliberately loose, like the server: one @, something on each side, a dot in the domain.
bool looksLikeEmail(String email) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
