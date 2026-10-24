import 'dart:convert';

import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../session/vault_session.dart';

/// The vault key kept on this device behind a strong biometric check, never on the server:
///
/// - Android: an AES key in the Keystore that needs a Class 3 biometric for every use and is
///   destroyed when fingerprints or faces are added (what the Android app did by hand).
/// - iOS and macOS: a Keychain item bound to the biometrics enrolled now (biometryCurrentSet).
///
/// Elsewhere (web, Windows, Linux) there is no storage that only biometrics can open, so the
/// feature reports itself unavailable instead of pretending.
class BiometricRepositoryImpl implements BiometricRepository {
  BiometricRepositoryImpl({
    required this._session,
    LocalAuthentication? localAuth,
    SharedPreferencesAsync? preferences,
    FlutterSecureStorage Function(BiometricPrompt prompt)? storageFor,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _preferences = preferences ?? SharedPreferencesAsync(),
        _storageFor = storageFor ?? _platformStorage;

  final VaultSession _session;
  final LocalAuthentication _localAuth;
  final SharedPreferencesAsync _preferences;
  final FlutterSecureStorage Function(BiometricPrompt prompt) _storageFor;

  static bool get _platformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static FlutterSecureStorage _platformStorage(BiometricPrompt prompt) => FlutterSecureStorage(
        aOptions: AndroidOptions.biometric(
          storageNamespace: 'boveda_biometric',
          enforceBiometrics: true,
          requireBiometricsPerOperation: true,
          biometricType: AndroidBiometricType.strongBiometricOnly,
          biometricPromptTitle: prompt.title,
          biometricPromptSubtitle: '',
          biometricPromptNegativeButton: prompt.cancel,
        ),
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.passcode,
          accessControlFlags: [AccessControlFlag.biometryCurrentSet],
        ),
        mOptions: const MacOsOptions(
          accessibility: KeychainAccessibility.passcode,
          accessControlFlags: [AccessControlFlag.biometryCurrentSet],
        ),
      );

  String _keyName(String userId) => 'vault_key_$userId';

  String _flagName(String userId) => 'biometric_enabled_$userId';

  @override
  Future<BiometricStatus> status(String userId) async {
    final enabled = await _preferences.getBool(_flagName(userId)) ?? false;
    return BiometricStatus(available: await _available(), enabled: enabled);
  }

  Future<bool> _available() async {
    if (!_platformSupported) return false;
    try {
      if (!await _localAuth.isDeviceSupported()) return false;
      final kinds = await _localAuth.getAvailableBiometrics();
      // Android reports the class; Apple platforms report the kind (Face ID / Touch ID).
      return defaultTargetPlatform == TargetPlatform.android
          ? kinds.contains(BiometricType.strong)
          : kinds.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> enable(String userId, BiometricPrompt prompt) async {
    final vault = _session.current;
    if (vault == null || vault.uid != userId) throw const AppException(AppError.vaultLocked);
    try {
      await _storageFor(prompt).write(key: _keyName(userId), value: base64.encode(vault.key));
    } on PlatformException catch (e) {
      if (_cancelled(e)) return false;
      throw AppException(AppError.biometricFailed, e);
    }
    await _preferences.setBool(_flagName(userId), true);
    return true;
  }

  @override
  Future<bool> unlock(String userId, BiometricPrompt prompt) async {
    final String? stored;
    try {
      stored = await _storageFor(prompt).read(key: _keyName(userId));
    } on PlatformException catch (e) {
      if (_cancelled(e)) return false;
      if (_invalidated(e)) {
        await disable(userId);
        throw AppException(AppError.biometricInvalidated, e);
      }
      throw AppException(AppError.biometricFailed, e);
    }
    if (stored == null) {
      // The system dropped the key (new fingerprints or faces were enrolled): start over.
      await disable(userId);
      throw const AppException(AppError.biometricInvalidated);
    }
    _session.open(userId, base64.decode(stored));
    return true;
  }

  @override
  Future<void> disable(String userId) async {
    await _preferences.remove(_flagName(userId));
    try {
      // Deleting needs no authentication.
      await _storageFor(const BiometricPrompt(title: '', cancel: '')).delete(key: _keyName(userId));
    } on PlatformException {
      // Already gone.
    }
  }

  /// BiometricPrompt's cancel codes (5, 10, 13) on Android; errSecUserCanceled (-128) on Apple.
  static bool _cancelled(PlatformException e) {
    final text = '${e.message} ${e.details}';
    final code = RegExp(r'error \[(\d+)\]').firstMatch(text)?.group(1);
    return const {'5', '10', '13'}.contains(code) || e.details == -128 || text.contains('-128');
  }

  static bool _invalidated(PlatformException e) =>
      '${e.message} ${e.details}'.contains('KeyPermanentlyInvalidated') || e.details == -25293;
}
