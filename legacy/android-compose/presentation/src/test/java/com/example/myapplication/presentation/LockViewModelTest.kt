package com.example.myapplication.presentation

import com.example.myapplication.domain.generator.PasswordStrengthEstimator
import com.example.myapplication.domain.model.BiometricStatus
import com.example.myapplication.domain.model.User
import com.example.myapplication.domain.repository.BiometricRepository
import com.example.myapplication.domain.usecase.biometric.GetBiometricStatusUseCase
import com.example.myapplication.domain.usecase.biometric.PrepareBiometricUnlockUseCase
import com.example.myapplication.domain.usecase.biometric.UnlockWithBiometricsUseCase
import com.example.myapplication.domain.usecase.generator.EvaluatePasswordStrengthUseCase
import com.example.myapplication.domain.usecase.vault.CreateVaultUseCase
import com.example.myapplication.domain.usecase.vault.UnlockVaultUseCase
import com.example.myapplication.presentation.lock.LockViewModel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Rule
import org.junit.Test
import javax.crypto.Cipher

class LockViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val vault = FakeVaultRepository()

    private val noBiometrics = object : BiometricRepository {
        override fun status(userId: String) = BiometricStatus(available = false, enabled = false)
        override fun enrollmentCipher(userId: String): Cipher = error("unused")
        override fun enable(userId: String, authorizedCipher: Cipher) = Unit
        override fun unlockCipher(userId: String): Cipher? = null
        override fun unlock(userId: String, authorizedCipher: Cipher) = Unit
        override fun disable(userId: String) = Unit
    }

    private val viewModel = LockViewModel(
        User("u1", "ana@correo.es"),
        CreateVaultUseCase(vault),
        UnlockVaultUseCase(vault),
        EvaluatePasswordStrengthUseCase(PasswordStrengthEstimator()),
        GetBiometricStatusUseCase(noBiometrics),
        PrepareBiometricUnlockUseCase(noBiometrics),
        UnlockWithBiometricsUseCase(noBiometrics),
    )

    @Test
    fun everyFailedAttemptCountsAsANewRejection() {
        viewModel.submit(isSetup = false)
        viewModel.submit(isSetup = false)

        val state = viewModel.uiState.value
        assertEquals(2, state.rejections)
        assertNotNull(state.error)
        assertFalse(state.isWorking)
    }

    @Test
    fun typingClearsTheErrorButKeepsTheCount() {
        viewModel.submit(isSetup = false)
        viewModel.onPasswordChange("c")

        val state = viewModel.uiState.value
        assertEquals(1, state.rejections)
        assertNull(state.error)
    }

    @Test
    fun unlockingStartsTheNextLockScreenFromZero() {
        viewModel.submit(isSetup = false)
        viewModel.onPasswordChange("correcto-caballo-bateria")
        viewModel.submit(isSetup = false)

        assertEquals(0, viewModel.uiState.value.rejections)
    }
}
