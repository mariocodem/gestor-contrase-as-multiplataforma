package com.example.myapplication.domain.usecase.vault

import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.AppException
import com.example.myapplication.domain.error.resultOf
import com.example.myapplication.domain.repository.VaultRepository
import javax.inject.Inject

class CreateVaultUseCase @Inject constructor(private val vault: VaultRepository) {
    suspend operator fun invoke(userId: String, masterPassword: String, confirmation: String): Result<Unit> =
        resultOf {
            when {
                masterPassword.length < MIN_MASTER_PASSWORD_LENGTH -> throw AppException(AppError.MasterPasswordTooShort)
                masterPassword != confirmation -> throw AppException(AppError.MasterPasswordMismatch)
            }
            vault.create(userId, masterPassword.toCharArray())
        }

    companion object {
        const val MIN_MASTER_PASSWORD_LENGTH = 10
    }
}

class UnlockVaultUseCase @Inject constructor(private val vault: VaultRepository) {
    suspend operator fun invoke(userId: String, masterPassword: String): Result<Unit> = resultOf {
        if (masterPassword.isEmpty()) throw AppException(AppError.EmptyMasterPassword)
        vault.unlock(userId, masterPassword.toCharArray())
    }
}

class LockVaultUseCase @Inject constructor(private val vault: VaultRepository) {
    operator fun invoke() = vault.lock()
}
