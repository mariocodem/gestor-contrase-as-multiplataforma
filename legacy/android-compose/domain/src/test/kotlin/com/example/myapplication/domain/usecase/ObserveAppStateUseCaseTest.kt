package com.example.myapplication.domain.usecase

import app.cash.turbine.test
import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.fake.FakeAuthRepository
import com.example.myapplication.domain.fake.FakeVaultRepository
import com.example.myapplication.domain.model.AppState
import com.example.myapplication.domain.model.User
import com.example.myapplication.domain.model.VaultStatus
import com.example.myapplication.domain.usecase.vault.ObserveAppStateUseCase
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

class ObserveAppStateUseCaseTest {
    private val user = User(id = "u1", email = "ana@example.com")
    private val auth = FakeAuthRepository(user)
    private val vault = FakeVaultRepository()
    private val observeAppState = ObserveAppStateUseCase(auth, vault)

    @Test
    fun walksThroughSetupUnlockLockAndSignOut() = runTest {
        observeAppState().test {
            assertEquals(AppState.NeedsSetup(user), awaitItem())

            vault.create(user.id, "correct horse battery".toCharArray())
            assertEquals(AppState.Unlocked(user), awaitItem())

            vault.status.value = VaultStatus.Present
            vault.lock()
            assertEquals(AppState.Locked(user), awaitItem())

            auth.signOut()
            assertEquals(AppState.SignedOut, awaitItem())
        }
    }

    @Test
    fun aKeyUnlockedForAnotherUserDoesNotUnlockThisOne() = runTest {
        vault.status.value = VaultStatus.Present
        vault.unlock("someone-else", "correct horse battery".toCharArray())

        observeAppState().test {
            assertEquals(AppState.Locked(user), awaitItem())
        }
    }

    @Test
    fun backendFailuresSurfaceAsFailedState() = runTest {
        vault.status.value = VaultStatus.Failed(AppError.PermissionDenied)

        observeAppState().test {
            assertEquals(AppState.Failed(AppError.PermissionDenied), awaitItem())
        }
    }
}
