package com.example.myapplication.domain.usecase.vault

import com.example.myapplication.domain.model.AppState
import com.example.myapplication.domain.model.VaultStatus
import com.example.myapplication.domain.repository.AuthRepository
import com.example.myapplication.domain.repository.VaultRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOf
import javax.inject.Inject

/** Combines the account, the vault's existence and the in-memory key into the screen the user may see. */
class ObserveAppStateUseCase @Inject constructor(
    private val auth: AuthRepository,
    private val vault: VaultRepository,
) {
    operator fun invoke(): Flow<AppState> = auth.currentUser.flatMapLatest { user ->
        if (user == null) {
            flowOf(AppState.SignedOut)
        } else {
            combine(vault.observeStatus(user.id), vault.unlockedUserId) { status, unlockedId ->
                val unlocked = unlockedId == user.id
                when (status) {
                    VaultStatus.Loading -> AppState.Loading
                    // Right after creating the vault the key is ready before the backend confirms it.
                    VaultStatus.Missing -> if (unlocked) AppState.Unlocked(user) else AppState.NeedsSetup(user)
                    VaultStatus.Present -> if (unlocked) AppState.Unlocked(user) else AppState.Locked(user)
                    is VaultStatus.Failed -> AppState.Failed(status.error)
                }
            }
        }
    }.distinctUntilChanged()
}
