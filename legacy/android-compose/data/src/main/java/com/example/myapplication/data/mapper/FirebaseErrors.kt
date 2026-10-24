package com.example.myapplication.data.mapper

import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.AppException
import com.google.firebase.FirebaseNetworkException
import com.google.firebase.FirebaseTooManyRequestsException
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException
import com.google.firebase.auth.FirebaseAuthInvalidUserException
import com.google.firebase.auth.FirebaseAuthUserCollisionException
import com.google.firebase.auth.FirebaseAuthWeakPasswordException
import com.google.firebase.firestore.FirebaseFirestoreException
import kotlin.coroutines.cancellation.CancellationException

/** Firebase and platform failures in domain terms, so no Firebase type leaks past the data layer. */
internal fun Throwable.toAppException(): AppException {
    val error = when (this) {
        is AppException -> return this
        is FirebaseNetworkException -> AppError.Network
        is FirebaseTooManyRequestsException -> AppError.TooManyRequests
        // Checked before its parent class, FirebaseAuthInvalidCredentialsException.
        is FirebaseAuthWeakPasswordException -> AppError.WeakAccountPassword
        is FirebaseAuthUserCollisionException -> AppError.EmailAlreadyInUse
        is FirebaseAuthInvalidCredentialsException ->
            if (errorCode == "ERROR_INVALID_EMAIL") AppError.InvalidEmail else AppError.InvalidCredentials
        is FirebaseAuthInvalidUserException -> AppError.InvalidCredentials
        is FirebaseFirestoreException -> when (code) {
            FirebaseFirestoreException.Code.PERMISSION_DENIED -> AppError.PermissionDenied
            FirebaseFirestoreException.Code.UNAVAILABLE -> AppError.ServiceUnavailable
            else -> AppError.Unexpected("Firestore: ${code.name}")
        }
        else -> AppError.Unexpected(localizedMessage)
    }
    return AppException(error, this)
}

/** Runs a backend call, rethrowing cancellation untouched and everything else as [AppException]. */
internal inline fun <T> backendCall(block: () -> T): T =
    try {
        block()
    } catch (e: CancellationException) {
        throw e
    } catch (e: Exception) {
        throw e.toAppException()
    }
