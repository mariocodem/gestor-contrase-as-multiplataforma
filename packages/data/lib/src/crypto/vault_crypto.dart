import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import 'pbkdf2_sha256.dart';

/// The AES-GCM tag didn't verify: wrong key, wrong authenticated data, or tampered bytes.
class CiphertextRejected implements Exception {
  const CiphertextRejected();

  @override
  String toString() => 'CiphertextRejected';
}

/// How PBKDF2-HMAC-SHA256 runs here: the platform's own where there is one, else a tuned Dart
/// implementation on a background isolate so the UI keeps moving.
typedef KeyStretcher = Future<Uint8List> Function(String password, List<int> salt, int iterations);

Future<Uint8List> platformPbkdf2(String password, List<int> salt, int iterations) async {
  final native = kIsWeb || defaultTargetPlatform == TargetPlatform.android;
  if (native) {
    // WebCrypto in browsers; javax.crypto on Android (package:cryptography_flutter).
    final algorithm = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);
    final key = await algorithm.deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
    return Uint8List.fromList(await key.extractBytes());
  }
  return compute(_isolatePbkdf2, (password, Uint8List.fromList(salt), iterations));
}

Uint8List _isolatePbkdf2((String, Uint8List, int) args) =>
    pbkdf2HmacSha256(utf8.encode(args.$1), args.$2, args.$3, 32);

/// The tuned Dart implementation on the calling isolate; for tests and tools.
Future<Uint8List> dartPbkdf2(String password, List<int> salt, int iterations) async =>
    pbkdf2HmacSha256(utf8.encode(password), salt, iterations, 32);

/// Client-side encryption for the vault. Nothing readable ever reaches the server:
///
/// - A random 256-bit *vault key* encrypts every entry with AES-256-GCM.
/// - The vault key is stored on the server wrapped (encrypted) with a key derived from the master
///   password via PBKDF2-HMAC-SHA256. A wrong password fails the GCM tag check.
///
/// Every ciphertext is laid out as `iv (12 bytes) || ciphertext || tag (16 bytes)`, byte for byte
/// what the Android app wrote.
class VaultCrypto {
  VaultCrypto({this._pbkdf2 = platformPbkdf2, Random? random}) : _random = random ?? Random.secure();

  /// OWASP's 2023 recommendation for PBKDF2-HMAC-SHA256. Stored per vault so it can change.
  static const defaultIterations = 600000;
  static const kdfName = 'PBKDF2WithHmacSHA256';

  static const _keyBytes = 32;
  static const _saltBytes = 16;
  static const _ivBytes = 12;
  static const _tagBytes = 16;
  static final _wrapAad = utf8.encode('vault-key');

  final KeyStretcher _pbkdf2;
  final Random _random;
  final _aes = AesGcm.with256bits();

  Uint8List randomBytes(int length) => Uint8List.fromList(List.generate(length, (_) => _random.nextInt(256)));

  Uint8List newSalt() => randomBytes(_saltBytes);

  Uint8List newVaultKey() => randomBytes(_keyBytes);

  Future<Uint8List> deriveKey(String password, List<int> salt, int iterations) => _pbkdf2(password, salt, iterations);

  Future<Uint8List> encrypt(List<int> key, List<int> plaintext, {List<int>? aad}) async {
    final iv = randomBytes(_ivBytes);
    final box = await _aes.encrypt(plaintext, secretKey: SecretKey(key), nonce: iv, aad: aad ?? const []);
    return Uint8List.fromList([...iv, ...box.cipherText, ...box.mac.bytes]);
  }

  /// Throws [CiphertextRejected] if the key or [aad] is wrong or the data was tampered with.
  Future<Uint8List> decrypt(List<int> key, List<int> data, {List<int>? aad}) async {
    if (data.length < _ivBytes + _tagBytes) throw const CiphertextRejected();
    final box = SecretBox(
      data.sublist(_ivBytes, data.length - _tagBytes),
      nonce: data.sublist(0, _ivBytes),
      mac: Mac(data.sublist(data.length - _tagBytes)),
    );
    try {
      return Uint8List.fromList(await _aes.decrypt(box, secretKey: SecretKey(key), aad: aad ?? const []));
    } on SecretBoxAuthenticationError {
      throw const CiphertextRejected();
    }
  }

  Future<Uint8List> wrapKey(List<int> wrappingKey, List<int> key) => encrypt(wrappingKey, key, aad: _wrapAad);

  Future<Uint8List> unwrapKey(List<int> wrappingKey, List<int> wrapped) => decrypt(wrappingKey, wrapped, aad: _wrapAad);

  /// The account auth key: the account password stretched on the device, so neither it nor
  /// anything cheap to guess from it reaches the server. The reset web page derives it the same way.
  Future<String> deriveAuthKey(String accountPassword, String email) async {
    final salt = await Sha256().hash(utf8.encode('boveda-auth-v1:${email.trim().toLowerCase()}'));
    return base64.encode(await _pbkdf2(accountPassword, salt.bytes, defaultIterations));
  }
}
