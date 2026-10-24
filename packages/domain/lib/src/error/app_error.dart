/// What can go wrong, as the UI explains it. The data layer maps its exceptions to these.
enum AppErrorCode {
  // Connectivity and backend
  network,
  tooManyRequests,
  sessionExpired,
  serviceUnavailable,

  // Account
  missingCredentials,
  missingEmail,
  invalidEmail,
  invalidCredentials,
  emailAlreadyInUse,
  weakAccountPassword,
  registrationClosed,
  passwordResetUnavailable,

  // Vault
  emptyMasterPassword,
  masterPasswordTooShort,
  masterPasswordMismatch,
  wrongMasterPassword,
  vaultAlreadyExists,
  vaultDataCorrupted,
  vaultLocked,
  emptyTitle,

  // Biometrics
  biometricInvalidated,
  biometricFailed,

  unexpected,
}

/// One failure; only [AppError.unexpected] carries a [detail].
final class AppError {
  const AppError._(this.code, [this.detail]);

  const AppError.unexpected(String? detail) : this._(AppErrorCode.unexpected, detail);

  final AppErrorCode code;
  final String? detail;

  static const network = AppError._(AppErrorCode.network);
  static const tooManyRequests = AppError._(AppErrorCode.tooManyRequests);
  static const sessionExpired = AppError._(AppErrorCode.sessionExpired);
  static const serviceUnavailable = AppError._(AppErrorCode.serviceUnavailable);
  static const missingCredentials = AppError._(AppErrorCode.missingCredentials);
  static const missingEmail = AppError._(AppErrorCode.missingEmail);
  static const invalidEmail = AppError._(AppErrorCode.invalidEmail);
  static const invalidCredentials = AppError._(AppErrorCode.invalidCredentials);
  static const emailAlreadyInUse = AppError._(AppErrorCode.emailAlreadyInUse);
  static const weakAccountPassword = AppError._(AppErrorCode.weakAccountPassword);
  static const registrationClosed = AppError._(AppErrorCode.registrationClosed);
  static const passwordResetUnavailable = AppError._(AppErrorCode.passwordResetUnavailable);
  static const emptyMasterPassword = AppError._(AppErrorCode.emptyMasterPassword);
  static const masterPasswordTooShort = AppError._(AppErrorCode.masterPasswordTooShort);
  static const masterPasswordMismatch = AppError._(AppErrorCode.masterPasswordMismatch);
  static const wrongMasterPassword = AppError._(AppErrorCode.wrongMasterPassword);
  static const vaultAlreadyExists = AppError._(AppErrorCode.vaultAlreadyExists);
  static const vaultDataCorrupted = AppError._(AppErrorCode.vaultDataCorrupted);
  static const vaultLocked = AppError._(AppErrorCode.vaultLocked);
  static const emptyTitle = AppError._(AppErrorCode.emptyTitle);
  static const biometricInvalidated = AppError._(AppErrorCode.biometricInvalidated);
  static const biometricFailed = AppError._(AppErrorCode.biometricFailed);

  @override
  bool operator ==(Object other) => other is AppError && other.code == code && other.detail == detail;

  @override
  int get hashCode => Object.hash(code, detail);

  @override
  String toString() => detail == null ? 'AppError.${code.name}' : 'AppError.${code.name}($detail)';
}

class AppException implements Exception {
  const AppException(this.error, [this.cause]);

  final AppError error;
  final Object? cause;

  @override
  String toString() => 'AppException($error${cause == null ? '' : ', cause: $cause'})';
}

AppError toAppError(Object error) =>
    error is AppException ? error.error : AppError.unexpected(error.toString());
