package com.example.myapplication.presentation.lock;

import com.example.myapplication.domain.model.User;
import com.example.myapplication.domain.usecase.biometric.GetBiometricStatusUseCase;
import com.example.myapplication.domain.usecase.biometric.PrepareBiometricUnlockUseCase;
import com.example.myapplication.domain.usecase.biometric.UnlockWithBiometricsUseCase;
import com.example.myapplication.domain.usecase.generator.EvaluatePasswordStrengthUseCase;
import com.example.myapplication.domain.usecase.vault.CreateVaultUseCase;
import com.example.myapplication.domain.usecase.vault.UnlockVaultUseCase;
import dagger.internal.DaggerGenerated;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import javax.annotation.processing.Generated;

@ScopeMetadata
@QualifierMetadata
@DaggerGenerated
@Generated(
    value = "dagger.internal.codegen.ComponentProcessor",
    comments = "https://dagger.dev"
)
@SuppressWarnings({
    "unchecked",
    "rawtypes",
    "KotlinInternal",
    "KotlinInternalInJava",
    "cast",
    "deprecation",
    "nullness:initialization.field.uninitialized"
})
public final class LockViewModel_Factory {
  private final Provider<CreateVaultUseCase> createVaultProvider;

  private final Provider<UnlockVaultUseCase> unlockVaultProvider;

  private final Provider<EvaluatePasswordStrengthUseCase> evaluateStrengthProvider;

  private final Provider<GetBiometricStatusUseCase> getBiometricStatusProvider;

  private final Provider<PrepareBiometricUnlockUseCase> prepareBiometricUnlockProvider;

  private final Provider<UnlockWithBiometricsUseCase> unlockWithBiometricsProvider;

  private LockViewModel_Factory(Provider<CreateVaultUseCase> createVaultProvider,
      Provider<UnlockVaultUseCase> unlockVaultProvider,
      Provider<EvaluatePasswordStrengthUseCase> evaluateStrengthProvider,
      Provider<GetBiometricStatusUseCase> getBiometricStatusProvider,
      Provider<PrepareBiometricUnlockUseCase> prepareBiometricUnlockProvider,
      Provider<UnlockWithBiometricsUseCase> unlockWithBiometricsProvider) {
    this.createVaultProvider = createVaultProvider;
    this.unlockVaultProvider = unlockVaultProvider;
    this.evaluateStrengthProvider = evaluateStrengthProvider;
    this.getBiometricStatusProvider = getBiometricStatusProvider;
    this.prepareBiometricUnlockProvider = prepareBiometricUnlockProvider;
    this.unlockWithBiometricsProvider = unlockWithBiometricsProvider;
  }

  public LockViewModel get(User user) {
    return newInstance(user, createVaultProvider.get(), unlockVaultProvider.get(), evaluateStrengthProvider.get(), getBiometricStatusProvider.get(), prepareBiometricUnlockProvider.get(), unlockWithBiometricsProvider.get());
  }

  public static LockViewModel_Factory create(Provider<CreateVaultUseCase> createVaultProvider,
      Provider<UnlockVaultUseCase> unlockVaultProvider,
      Provider<EvaluatePasswordStrengthUseCase> evaluateStrengthProvider,
      Provider<GetBiometricStatusUseCase> getBiometricStatusProvider,
      Provider<PrepareBiometricUnlockUseCase> prepareBiometricUnlockProvider,
      Provider<UnlockWithBiometricsUseCase> unlockWithBiometricsProvider) {
    return new LockViewModel_Factory(createVaultProvider, unlockVaultProvider, evaluateStrengthProvider, getBiometricStatusProvider, prepareBiometricUnlockProvider, unlockWithBiometricsProvider);
  }

  public static LockViewModel newInstance(User user, CreateVaultUseCase createVault,
      UnlockVaultUseCase unlockVault, EvaluatePasswordStrengthUseCase evaluateStrength,
      GetBiometricStatusUseCase getBiometricStatus,
      PrepareBiometricUnlockUseCase prepareBiometricUnlock,
      UnlockWithBiometricsUseCase unlockWithBiometrics) {
    return new LockViewModel(user, createVault, unlockVault, evaluateStrength, getBiometricStatus, prepareBiometricUnlock, unlockWithBiometrics);
  }
}
