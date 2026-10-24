import 'package:boveda_domain/boveda_domain.dart';

import 'strings.dart';

/// Every error names the problem and, where there is one, the way out.
String errorMessage(AppError error) => switch (error.code) {
      AppErrorCode.network => S.errorNetwork,
      AppErrorCode.tooManyRequests => S.errorTooManyRequests,
      AppErrorCode.sessionExpired => S.errorSessionExpired,
      AppErrorCode.serviceUnavailable => S.errorServiceUnavailable,
      AppErrorCode.missingCredentials => S.errorMissingCredentials,
      AppErrorCode.missingEmail => S.errorMissingEmail,
      AppErrorCode.invalidEmail => S.errorInvalidEmail,
      AppErrorCode.invalidCredentials => S.errorInvalidCredentials,
      AppErrorCode.emailAlreadyInUse => S.errorEmailInUse,
      AppErrorCode.weakAccountPassword => S.errorWeakAccountPassword,
      AppErrorCode.registrationClosed => S.errorRegistrationClosed,
      AppErrorCode.passwordResetUnavailable => S.errorResetUnavailable,
      AppErrorCode.emptyMasterPassword => S.errorEmptyMasterPassword,
      AppErrorCode.masterPasswordTooShort => S.errorMasterPasswordTooShort(CreateVaultUseCase.minMasterPasswordLength),
      AppErrorCode.masterPasswordMismatch => S.errorMasterPasswordMismatch,
      AppErrorCode.wrongMasterPassword => S.errorWrongMasterPassword,
      AppErrorCode.vaultAlreadyExists => S.errorVaultExists,
      AppErrorCode.vaultDataCorrupted => S.errorVaultCorrupted,
      AppErrorCode.vaultLocked => S.errorVaultLocked,
      AppErrorCode.emptyTitle => S.errorEmptyTitle,
      AppErrorCode.biometricInvalidated => S.errorBiometricInvalidated,
      AppErrorCode.biometricFailed => S.errorBiometricFailed,
      AppErrorCode.unexpected =>
        (error.detail == null || error.detail!.trim().isEmpty) ? S.errorUnexpectedGeneric : S.errorUnexpected(error.detail!),
    };
