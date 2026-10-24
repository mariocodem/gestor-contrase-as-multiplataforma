import '../model/user.dart';

/// The account decides *whose* vault can be read; it never sees the master password.
/// Failures are thrown as [AppException].
abstract interface class AuthRepository {
  /// The signed-in user, or null when signed out. Emits the current value on listen.
  Stream<User?> get currentUser;

  Future<void> signIn(String email, String password);

  Future<void> register(String email, String password);

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
