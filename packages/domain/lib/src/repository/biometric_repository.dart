import '../model/app_state.dart';

/// Optional fingerprint/face unlock. The vault key is kept on this device only, in hardware-backed
/// storage that releases it after a strong biometric check; the system shows the [BiometricPrompt].
abstract interface class BiometricRepository {
  Future<BiometricStatus> status(String userId);

  /// Stores the unlocked vault's key behind biometrics. False when the user cancelled the prompt.
  Future<bool> enable(String userId, BiometricPrompt prompt);

  /// Opens the vault with the stored key. False when the user cancelled the prompt.
  Future<bool> unlock(String userId, BiometricPrompt prompt);

  Future<void> disable(String userId);
}
