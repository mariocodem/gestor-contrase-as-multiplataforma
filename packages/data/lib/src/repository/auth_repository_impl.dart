import 'dart:async';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:rxdart/rxdart.dart';

import '../crypto/vault_crypto.dart';
import '../local/session_store.dart';
import '../remote/boveda_api.dart';

/// Accounts on the Bóveda Worker. The account password never leaves the device: what's sent is an
/// auth key derived from it ([VaultCrypto.deriveAuthKey]). A stored session opens offline; the
/// server's verdict on it arrives in the background and signs out if it was revoked.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._api, required this._store, required this._crypto}) {
    _api.onUnauthorized = _expire;
    unawaited(_restore());
  }

  final BovedaApi _api;
  final SessionStore _store;
  final VaultCrypto _crypto;
  final _user = BehaviorSubject<User?>();

  @override
  Stream<User?> get currentUser => _user.stream.distinct();

  Future<void> _restore() async {
    final user = await _store.load();
    _user.add(user);
    if (user == null) return;
    try {
      final fresh = await _api.session();
      if (fresh != _user.valueOrNull && _user.valueOrNull?.id == fresh.id) {
        await _store.save(_store.token!, fresh);
        _user.add(fresh);
      }
    } on AppException {
      // Offline or the server is down: keep the stored session. A revoked one already called _expire.
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    final authKey = await _crypto.deriveAuthKey(password, email);
    await _open(await _api.login(email.trim().toLowerCase(), authKey));
  }

  @override
  Future<void> register(String email, String password) async {
    final authKey = await _crypto.deriveAuthKey(password, email);
    await _open(await _api.register(email.trim().toLowerCase(), authKey));
  }

  Future<void> _open(SessionDto session) async {
    await _store.save(session.token, session.user);
    _user.add(session.user);
  }

  @override
  Future<void> sendPasswordReset(String email) => _api.requestPasswordReset(email.trim().toLowerCase());

  @override
  Future<void> signOut() async {
    if (_store.token != null) {
      // Best effort: the session is forgotten here either way.
      unawaited(_api.logout().catchError((_) {}));
    }
    await _store.clear();
    _user.add(null);
  }

  void _expire() {
    if (_user.valueOrNull == null) return;
    unawaited(_store.clear());
    _user.add(null);
  }
}
