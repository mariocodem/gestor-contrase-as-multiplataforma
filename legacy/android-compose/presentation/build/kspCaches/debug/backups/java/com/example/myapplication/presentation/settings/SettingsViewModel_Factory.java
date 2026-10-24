package com.example.myapplication.presentation.settings;

import com.example.myapplication.domain.model.User;
import com.example.myapplication.domain.usecase.auth.SignOutUseCase;
import com.example.myapplication.domain.usecase.biometric.DisableBiometricUnlockUseCase;
import com.example.myapplication.domain.usecase.biometric.EnableBiometricUnlockUseCase;
import com.example.myapplication.domain.usecase.biometric.GetBiometricStatusUseCase;
import com.example.myapplication.domain.usecase.biometric.PrepareBiometricEnrollmentUseCase;
import com.example.myapplication.domain.usecase.settings.ObserveSettingsUseCase;
import com.example.myapplication.domain.usecase.settings.SetAutoLockTimeoutUseCase;
import com.example.myapplication.domain.usecase.settings.SetDynamicColorUseCase;
import com.example.myapplication.domain.usecase.vault.LockVaultUseCase;
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
public final class SettingsViewModel_Factory {
  private final Provider<ObserveSettingsUseCase> observeSettingsProvider;

  private final Provider<SetAutoLockTimeoutUseCase> setAutoLockTimeoutProvider;

  private final Provider<SetDynamicColorUseCase> setDynamicColorUseCaseProvider;

  private final Provider<GetBiometricStatusUseCase> getBiometricStatusProvider;

  private final Provider<PrepareBiometricEnrollmentUseCase> prepareBiometricEnrollmentProvider;

  private final Provider<EnableBiometricUnlockUseCase> enableBiometricUnlockProvider;

  private final Provider<DisableBiometricUnlockUseCase> disableBiometricUnlockProvider;

  private final Provider<LockVaultUseCase> lockVaultProvider;

  private final Provider<SignOutUseCase> signOutUseCaseProvider;

  private SettingsViewModel_Factory(Provider<ObserveSettingsUseCase> observeSettingsProvider,
      Provider<SetAutoLockTimeoutUseCase> setAutoLockTimeoutProvider,
      Provider<SetDynamicColorUseCase> setDynamicColorUseCaseProvider,
      Provider<GetBiometricStatusUseCase> getBiometricStatusProvider,
      Provider<PrepareBiometricEnrollmentUseCase> prepareBiometricEnrollmentProvider,
      Provider<EnableBiometricUnlockUseCase> enableBiometricUnlockProvider,
      Provider<DisableBiometricUnlockUseCase> disableBiometricUnlockProvider,
      Provider<LockVaultUseCase> lockVaultProvider,
      Provider<SignOutUseCase> signOutUseCaseProvider) {
    this.observeSettingsProvider = observeSettingsProvider;
    this.setAutoLockTimeoutProvider = setAutoLockTimeoutProvider;
    this.setDynamicColorUseCaseProvider = setDynamicColorUseCaseProvider;
    this.getBiometricStatusProvider = getBiometricStatusProvider;
    this.prepareBiometricEnrollmentProvider = prepareBiometricEnrollmentProvider;
    this.enableBiometricUnlockProvider = enableBiometricUnlockProvider;
    this.disableBiometricUnlockProvider = disableBiometricUnlockProvider;
    this.lockVaultProvider = lockVaultProvider;
    this.signOutUseCaseProvider = signOutUseCaseProvider;
  }

  public SettingsViewModel get(User user) {
    return newInstance(user, observeSettingsProvider.get(), setAutoLockTimeoutProvider.get(), setDynamicColorUseCaseProvider.get(), getBiometricStatusProvider.get(), prepareBiometricEnrollmentProvider.get(), enableBiometricUnlockProvider.get(), disableBiometricUnlockProvider.get(), lockVaultProvider.get(), signOutUseCaseProvider.get());
  }

  public static SettingsViewModel_Factory create(
      Provider<ObserveSettingsUseCase> observeSettingsProvider,
      Provider<SetAutoLockTimeoutUseCase> setAutoLockTimeoutProvider,
      Provider<SetDynamicColorUseCase> setDynamicColorUseCaseProvider,
      Provider<GetBiometricStatusUseCase> getBiometricStatusProvider,
      Provider<PrepareBiometricEnrollmentUseCase> prepareBiometricEnrollmentProvider,
      Provider<EnableBiometricUnlockUseCase> enableBiometricUnlockProvider,
      Provider<DisableBiometricUnlockUseCase> disableBiometricUnlockProvider,
      Provider<LockVaultUseCase> lockVaultProvider,
      Provider<SignOutUseCase> signOutUseCaseProvider) {
    return new SettingsViewModel_Factory(observeSettingsProvider, setAutoLockTimeoutProvider, setDynamicColorUseCaseProvider, getBiometricStatusProvider, prepareBiometricEnrollmentProvider, enableBiometricUnlockProvider, disableBiometricUnlockProvider, lockVaultProvider, signOutUseCaseProvider);
  }

  public static SettingsViewModel newInstance(User user, ObserveSettingsUseCase observeSettings,
      SetAutoLockTimeoutUseCase setAutoLockTimeout, SetDynamicColorUseCase setDynamicColorUseCase,
      GetBiometricStatusUseCase getBiometricStatus,
      PrepareBiometricEnrollmentUseCase prepareBiometricEnrollment,
      EnableBiometricUnlockUseCase enableBiometricUnlock,
      DisableBiometricUnlockUseCase disableBiometricUnlock, LockVaultUseCase lockVault,
      SignOutUseCase signOutUseCase) {
    return new SettingsViewModel(user, observeSettings, setAutoLockTimeout, setDynamicColorUseCase, getBiometricStatus, prepareBiometricEnrollment, enableBiometricUnlock, disableBiometricUnlock, lockVault, signOutUseCase);
  }
}
