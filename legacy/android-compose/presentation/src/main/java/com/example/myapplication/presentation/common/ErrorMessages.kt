package com.example.myapplication.presentation.common

import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.usecase.vault.CreateVaultUseCase
import com.example.myapplication.presentation.R

/** Every error names the problem and, where there is one, the way out. */
fun AppError.toUiText(): UiText = when (this) {
    AppError.Network -> UiText.Res(R.string.error_network)
    AppError.TooManyRequests -> UiText.Res(R.string.error_too_many_requests)
    AppError.PermissionDenied -> UiText.Res(R.string.error_permission_denied)
    AppError.ServiceUnavailable -> UiText.Res(R.string.error_service_unavailable)
    AppError.MissingCredentials -> UiText.Res(R.string.error_missing_credentials)
    AppError.MissingEmail -> UiText.Res(R.string.error_missing_email)
    AppError.InvalidEmail -> UiText.Res(R.string.error_invalid_email)
    AppError.InvalidCredentials -> UiText.Res(R.string.error_invalid_credentials)
    AppError.EmailAlreadyInUse -> UiText.Res(R.string.error_email_in_use)
    AppError.WeakAccountPassword -> UiText.Res(R.string.error_weak_account_password)
    AppError.EmptyMasterPassword -> UiText.Res(R.string.error_empty_master_password)
    AppError.MasterPasswordTooShort ->
        UiText.Res(R.string.error_master_password_too_short, listOf(CreateVaultUseCase.MIN_MASTER_PASSWORD_LENGTH))
    AppError.MasterPasswordMismatch -> UiText.Res(R.string.error_master_password_mismatch)
    AppError.WrongMasterPassword -> UiText.Res(R.string.error_wrong_master_password)
    AppError.VaultAlreadyExists -> UiText.Res(R.string.error_vault_exists)
    AppError.VaultDataCorrupted -> UiText.Res(R.string.error_vault_corrupted)
    AppError.VaultLocked -> UiText.Res(R.string.error_vault_locked)
    AppError.EmptyTitle -> UiText.Res(R.string.error_empty_title)
    AppError.BiometricInvalidated -> UiText.Res(R.string.error_biometric_invalidated)
    AppError.BiometricFailed -> UiText.Res(R.string.error_biometric_failed)
    is AppError.Unexpected -> detail.let { detail ->
        if (detail.isNullOrBlank()) UiText.Res(R.string.error_unexpected_generic) else UiText.Res(R.string.error_unexpected, listOf(detail))
    }
}
