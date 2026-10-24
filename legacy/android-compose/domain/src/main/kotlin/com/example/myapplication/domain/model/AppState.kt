package com.example.myapplication.domain.model

import com.example.myapplication.domain.error.AppError

/** Which part of the app the user can reach right now. */
sealed interface AppState {
    data object Loading : AppState
    data object SignedOut : AppState
    data class NeedsSetup(val user: User) : AppState
    data class Locked(val user: User) : AppState
    data class Unlocked(val user: User) : AppState
    data class Failed(val error: AppError) : AppState
}

/** Whether a user's vault exists in the backend. */
sealed interface VaultStatus {
    data object Loading : VaultStatus
    data object Missing : VaultStatus
    data object Present : VaultStatus
    data class Failed(val error: AppError) : VaultStatus
}

data class BiometricStatus(val available: Boolean, val enabled: Boolean)
