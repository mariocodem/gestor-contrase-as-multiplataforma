package com.example.myapplication.domain.error

import kotlin.coroutines.cancellation.CancellationException

/** Everything that can go wrong, in terms the UI can explain. The data layer maps its exceptions to these. */
sealed interface AppError {
    // Connectivity and backend
    data object Network : AppError
    data object TooManyRequests : AppError
    data object PermissionDenied : AppError
    data object ServiceUnavailable : AppError

    // Account
    data object MissingCredentials : AppError
    data object MissingEmail : AppError
    data object InvalidEmail : AppError
    data object InvalidCredentials : AppError
    data object EmailAlreadyInUse : AppError
    data object WeakAccountPassword : AppError

    // Vault
    data object EmptyMasterPassword : AppError
    data object MasterPasswordTooShort : AppError
    data object MasterPasswordMismatch : AppError
    data object WrongMasterPassword : AppError
    data object VaultAlreadyExists : AppError
    data object VaultDataCorrupted : AppError
    data object VaultLocked : AppError
    data object EmptyTitle : AppError

    // Biometrics
    data object BiometricInvalidated : AppError
    data object BiometricFailed : AppError

    data class Unexpected(val detail: String?) : AppError
}

class AppException(val error: AppError, cause: Throwable? = null) : Exception(error.toString(), cause)

fun Throwable.toAppError(): AppError = (this as? AppException)?.error ?: AppError.Unexpected(message)

/** Like [runCatching], but never swallows coroutine cancellation and always fails with an [AppException]. */
inline fun <T> resultOf(block: () -> T): Result<T> =
    try {
        Result.success(block())
    } catch (e: CancellationException) {
        throw e
    } catch (e: AppException) {
        Result.failure(e)
    } catch (e: Exception) {
        Result.failure(AppException(AppError.Unexpected(e.message), e))
    }
