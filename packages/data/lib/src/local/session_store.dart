import 'dart:convert';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The signed-in account's bearer token and identity, in the platform's secure storage (Keystore,
/// Keychain, DPAPI, libsecret; an encrypted entry in browser storage on the web).
class SessionStore {
  SessionStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(storageNamespace: 'boveda_session'),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
              mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
            );

  static const _key = 'session';

  final FlutterSecureStorage _storage;
  String? _token;

  /// Kept in memory once loaded, so every request can read it synchronously.
  String? get token => _token;

  /// The stored session, or null when signed out.
  Future<User?> load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _token = json['token'] as String;
      return User(id: json['id'] as String, email: json['email'] as String?);
    } catch (_) {
      // Unreadable (restored from another device, keystore reset): treat as signed out.
      await clear();
      return null;
    }
  }

  Future<void> save(String token, User user) async {
    _token = token;
    await _storage.write(key: _key, value: jsonEncode({'token': token, 'id': user.id, 'email': user.email}));
  }

  Future<void> clear() async {
    _token = null;
    try {
      await _storage.delete(key: _key);
    } catch (_) {
      // Nothing stored is as good as deleted.
    }
  }
}
