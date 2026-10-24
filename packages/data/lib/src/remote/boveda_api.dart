import 'dart:async';
import 'dart:convert';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:http/http.dart' as http;

/// Public parameters needed to turn the master password back into the vault key.
class VaultMetaDto {
  const VaultMetaDto({required this.salt, required this.iterations, required this.wrappedKey});

  factory VaultMetaDto.fromJson(Map<String, dynamic> json) => VaultMetaDto(
        salt: json['salt'] as String,
        iterations: (json['kdfIterations'] as num).toInt(),
        wrappedKey: json['wrappedKey'] as String,
      );

  /// Base64.
  final String salt;
  final int iterations;

  /// Base64.
  final String wrappedKey;

  Map<String, dynamic> toJson() => {
        'version': 1,
        'kdf': 'PBKDF2WithHmacSHA256',
        'kdfIterations': iterations,
        'salt': salt,
        'wrappedKey': wrappedKey,
      };
}

/// One queued write: a new ciphertext for an entry, or its deletion.
class ChangeDto {
  const ChangeDto.put(this.id, String this.data) : deleted = false;

  const ChangeDto.delete(this.id)
      : data = null,
        deleted = true;

  factory ChangeDto.fromJson(Map<String, dynamic> json) =>
      json['op'] == 'delete' ? ChangeDto.delete(json['id'] as String) : ChangeDto.put(json['id'] as String, json['data'] as String);

  final String id;

  /// Base64 ciphertext; null for a deletion.
  final String? data;
  final bool deleted;

  Map<String, dynamic> toJson() => deleted ? {'op': 'delete', 'id': id} : {'op': 'put', 'id': id, 'v': 1, 'data': data};
}

class EntryRowDto {
  const EntryRowDto({required this.id, required this.data, required this.deleted, required this.revision});

  factory EntryRowDto.fromJson(Map<String, dynamic> json) => EntryRowDto(
        id: json['id'] as String,
        data: json['data'] as String?,
        deleted: json['deleted'] == true,
        revision: (json['revision'] as num).toInt(),
      );

  final String id;
  final String? data;
  final bool deleted;
  final int revision;
}

class SyncResponseDto {
  const SyncResponseDto({required this.revision, required this.reset, required this.entries});

  final int revision;

  /// The server never reached the revision the device sent: replace everything with [entries].
  final bool reset;
  final List<EntryRowDto> entries;
}

class SessionDto {
  const SessionDto({required this.token, required this.user});

  final String token;
  final User user;
}

/// The Bóveda Worker on Cloudflare (backend/). Every failure is thrown as [AppException]; a revoked
/// or expired session also calls [onUnauthorized] so the app signs out.
class BovedaApi {
  BovedaApi({required this.baseUrl, required this.token, http.Client? client, this.timeout = const Duration(seconds: 20)})
      : _client = client ?? http.Client();

  final Uri baseUrl;

  /// The current bearer token, or null when signed out.
  final String? Function() token;
  final Duration timeout;
  final http.Client _client;

  /// Called when the server rejects the session.
  void Function()? onUnauthorized;

  /// Changes per sync request: the Worker caps them to stay within D1's per-request query limit.
  static const maxChangesPerSync = 40;

  Future<SessionDto> register(String email, String authKey) async =>
      _session(await _send('POST', '/v1/register', body: {'email': email, 'authKey': authKey}, authenticated: false));

  Future<SessionDto> login(String email, String authKey) async =>
      _session(await _send('POST', '/v1/login', body: {'email': email, 'authKey': authKey}, authenticated: false));

  Future<User> session() async => _user((await _send('GET', '/v1/session'))['user'] as Map<String, dynamic>);

  Future<void> logout() => _send('DELETE', '/v1/session');

  Future<void> requestPasswordReset(String email) =>
      _send('POST', '/v1/password-reset', body: {'email': email}, authenticated: false);

  /// Null when this account has no vault yet.
  Future<VaultMetaDto?> getVault() async {
    try {
      return VaultMetaDto.fromJson(await _send('GET', '/v1/vault'));
    } on _ApiFailure catch (failure) {
      if (failure.code == 'vault_missing') return null;
      throw failure.toAppException();
    }
  }

  Future<void> createVault(VaultMetaDto meta) => _send('POST', '/v1/vault', body: meta.toJson());

  Future<SyncResponseDto> sync(int since, List<ChangeDto> changes) async {
    final json = await _send('POST', '/v1/vault/sync', body: {
      'since': since,
      'changes': [for (final change in changes) change.toJson()],
    });
    return SyncResponseDto(
      revision: (json['revision'] as num).toInt(),
      reset: json['reset'] == true,
      entries: [for (final row in json['entries'] as List<dynamic>) EntryRowDto.fromJson(row as Map<String, dynamic>)],
    );
  }

  SessionDto _session(Map<String, dynamic> json) =>
      SessionDto(token: json['token'] as String, user: _user(json['user'] as Map<String, dynamic>));

  User _user(Map<String, dynamic> json) => User(id: json['id'] as String, email: json['email'] as String?);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final request = http.Request(method, baseUrl.resolve(path));
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    if (authenticated) {
      final bearer = token();
      if (bearer == null) throw const AppException(AppError.sessionExpired);
      request.headers['Authorization'] = 'Bearer $bearer';
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request).timeout(timeout)).timeout(timeout);
    } on TimeoutException catch (e) {
      throw AppException(AppError.network, e);
    } on http.ClientException catch (e) {
      throw AppException(AppError.network, e);
    } on Exception catch (e) {
      // SocketException and friends (dart:io isn't available on the web build).
      throw AppException(AppError.network, e);
    }

    final decoded = response.body.isEmpty ? null : _tryJson(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : const {};
    }
    final code = decoded is Map<String, dynamic> && decoded['error'] is String ? decoded['error'] as String : null;
    final failure = _ApiFailure(response.statusCode, code);
    if (failure.isUnauthorized && authenticated) onUnauthorized?.call();
    if (path == '/v1/vault' && method == 'GET') throw failure;
    throw failure.toAppException();
  }

  static Object? _tryJson(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }
}

class _ApiFailure implements Exception {
  const _ApiFailure(this.status, this.code);

  final int status;
  final String? code;

  bool get isUnauthorized => status == 401 && code == 'unauthorized';

  AppException toAppException() => AppException(switch ((status, code)) {
        (_, 'invalid_credentials') => AppError.invalidCredentials,
        (_, 'unauthorized') => AppError.sessionExpired,
        (_, 'email_in_use') => AppError.emailAlreadyInUse,
        (_, 'registration_closed') => AppError.registrationClosed,
        (_, 'invalid_email') => AppError.invalidEmail,
        (_, 'too_many_requests') || (429, _) => AppError.tooManyRequests,
        (_, 'vault_exists') => AppError.vaultAlreadyExists,
        (_, 'vault_missing') => AppError.vaultDataCorrupted,
        (_, 'reset_unavailable') => AppError.passwordResetUnavailable,
        (>= 500, _) => AppError.serviceUnavailable,
        _ => AppError.unexpected('HTTP $status${code == null ? '' : ' ($code)'}'),
      }, this);

  @override
  String toString() => 'ApiFailure($status, $code)';
}
