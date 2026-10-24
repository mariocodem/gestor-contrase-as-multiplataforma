package com.example.myapplication.domain.usecase.auth

import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.AppException
import com.example.myapplication.domain.error.resultOf
import com.example.myapplication.domain.model.User
import com.example.myapplication.domain.repository.AuthRepository
import com.example.myapplication.domain.repository.VaultRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class ObserveCurrentUserUseCase @Inject constructor(private val auth: AuthRepository) {
    operator fun invoke(): Flow<User?> = auth.currentUser
}

class SignInUseCase @Inject constructor(private val auth: AuthRepository) {
    suspend operator fun invoke(email: String, password: String): Result<Unit> = resultOf {
        val trimmed = email.trim()
        if (trimmed.isEmpty() || password.isEmpty()) throw AppException(AppError.MissingCredentials)
        auth.signIn(trimmed, password)
    }
}

class RegisterUseCase @Inject constructor(private val auth: AuthRepository) {
    suspend operator fun invoke(email: String, password: String): Result<Unit> = resultOf {
        val trimmed = email.trim()
        if (trimmed.isEmpty() || password.isEmpty()) throw AppException(AppError.MissingCredentials)
        auth.register(trimmed, password)
    }
}

class SendPasswordResetUseCase @Inject constructor(private val auth: AuthRepository) {
    suspend operator fun invoke(email: String): Result<Unit> = resultOf {
        val trimmed = email.trim()
        if (trimmed.isEmpty()) throw AppException(AppError.MissingEmail)
        auth.sendPasswordReset(trimmed)
    }
}

/** Locks first, so no decrypted data outlives the account session. */
class SignOutUseCase @Inject constructor(
    private val auth: AuthRepository,
    private val vault: VaultRepository,
) {
    operator fun invoke() {
        vault.lock()
        auth.signOut()
    }
}
