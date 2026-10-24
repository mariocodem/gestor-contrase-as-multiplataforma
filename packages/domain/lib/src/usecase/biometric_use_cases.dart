import '../error/result.dart';
import '../model/app_state.dart';
import '../repository/biometric_repository.dart';

class GetBiometricStatusUseCase {
  const GetBiometricStatusUseCase(this._biometrics);

  final BiometricRepository _biometrics;

  Future<BiometricStatus> call(String userId) async {
    try {
      return await _biometrics.status(userId);
    } catch (_) {
      return BiometricStatus.unavailable;
    }
  }
}

/// Keeps the unlocked vault's key behind biometrics. Success(false) means the prompt was cancelled.
class EnableBiometricUnlockUseCase {
  const EnableBiometricUnlockUseCase(this._biometrics);

  final BiometricRepository _biometrics;

  Future<Result<bool>> call(String userId, BiometricPrompt prompt) =>
      resultOf(() => _biometrics.enable(userId, prompt));
}

/// Success(false) means the prompt was cancelled.
class UnlockWithBiometricsUseCase {
  const UnlockWithBiometricsUseCase(this._biometrics);

  final BiometricRepository _biometrics;

  Future<Result<bool>> call(String userId, BiometricPrompt prompt) =>
      resultOf(() => _biometrics.unlock(userId, prompt));
}

class DisableBiometricUnlockUseCase {
  const DisableBiometricUnlockUseCase(this._biometrics);

  final BiometricRepository _biometrics;

  Future<void> call(String userId) => _biometrics.disable(userId);
}
