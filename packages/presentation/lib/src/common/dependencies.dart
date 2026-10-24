import 'package:boveda_domain/boveda_domain.dart';

import 'secret_clipboard.dart';

/// What the screens need from the rest of the app: the domain's repositories (behind use cases)
/// and a clipboard. The app's composition root builds one and provides it above [BovedaApp].
class Dependencies {
  Dependencies({
    required this.auth,
    required this.vault,
    required this.biometrics,
    required this.settings,
    required this.clipboard,
    PasswordGenerator? generator,
  }) : generator = generator ?? PasswordGenerator();

  final AuthRepository auth;
  final VaultRepository vault;
  final BiometricRepository biometrics;
  final SettingsRepository settings;
  final SecretClipboard clipboard;
  final PasswordGenerator generator;
  final estimator = const PasswordStrengthEstimator();

  // Use cases, built on demand: they hold no state.
  ObserveAppStateUseCase get observeAppState => ObserveAppStateUseCase(auth, vault);
  SignInUseCase get signIn => SignInUseCase(auth);
  RegisterUseCase get register => RegisterUseCase(auth);
  SendPasswordResetUseCase get sendPasswordReset => SendPasswordResetUseCase(auth);
  SignOutUseCase get signOut => SignOutUseCase(auth, vault);
  CreateVaultUseCase get createVault => CreateVaultUseCase(vault);
  UnlockVaultUseCase get unlockVault => UnlockVaultUseCase(vault);
  LockVaultUseCase get lockVault => LockVaultUseCase(vault);
  SyncVaultUseCase get syncVault => SyncVaultUseCase(vault);
  ObserveEntriesUseCase get observeEntries => ObserveEntriesUseCase(vault);
  ObserveEntryUseCase get observeEntry => ObserveEntryUseCase(vault);
  SearchEntriesUseCase get searchEntries => const SearchEntriesUseCase();
  SaveEntryUseCase get saveEntry => SaveEntryUseCase(vault);
  DeleteEntryUseCase get deleteEntry => DeleteEntryUseCase(vault);
  GeneratePasswordUseCase get generatePassword => GeneratePasswordUseCase(generator, estimator);
  EvaluatePasswordStrengthUseCase get evaluateStrength => EvaluatePasswordStrengthUseCase(estimator);
  ObserveSettingsUseCase get observeSettings => ObserveSettingsUseCase(settings);
  SetAutoLockTimeoutUseCase get setAutoLock => SetAutoLockTimeoutUseCase(settings);
  SetDynamicColorUseCase get setDynamicColor => SetDynamicColorUseCase(settings);
  SaveGeneratorOptionsUseCase get saveGeneratorOptions => SaveGeneratorOptionsUseCase(settings);
  GetBiometricStatusUseCase get biometricStatus => GetBiometricStatusUseCase(biometrics);
  EnableBiometricUnlockUseCase get enableBiometrics => EnableBiometricUnlockUseCase(biometrics);
  UnlockWithBiometricsUseCase get unlockWithBiometrics => UnlockWithBiometricsUseCase(biometrics);
  DisableBiometricUnlockUseCase get disableBiometrics => DisableBiometricUnlockUseCase(biometrics);
}
