package com.example.myapplication.presentation.lock

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.domain.error.toAppError
import com.example.myapplication.domain.model.PasswordStrength
import com.example.myapplication.domain.model.User
import com.example.myapplication.domain.usecase.biometric.GetBiometricStatusUseCase
import com.example.myapplication.domain.usecase.biometric.PrepareBiometricUnlockUseCase
import com.example.myapplication.domain.usecase.biometric.UnlockWithBiometricsUseCase
import com.example.myapplication.domain.usecase.generator.EvaluatePasswordStrengthUseCase
import com.example.myapplication.domain.usecase.vault.CreateVaultUseCase
import com.example.myapplication.domain.usecase.vault.UnlockVaultUseCase
import com.example.myapplication.presentation.common.UiText
import dagger.assisted.Assisted
import dagger.assisted.AssistedFactory
import dagger.assisted.AssistedInject
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.crypto.Cipher

data class LockUiState(
    val password: String = "",
    val confirmation: String = "",
    val strength: PasswordStrength = PasswordStrength.EMPTY,
    val isWorking: Boolean = false,
    val error: UiText? = null,
    val biometricEnabled: Boolean = false,
    /** Failed attempts since the screen opened; each one shakes the emblem. */
    val rejections: Int = 0,
)

/** Creates the vault (first run) or unlocks it, with the master password or biometrics. */
@HiltViewModel(assistedFactory = LockViewModel.Factory::class)
class LockViewModel @AssistedInject constructor(
    @Assisted private val user: User,
    private val createVault: CreateVaultUseCase,
    private val unlockVault: UnlockVaultUseCase,
    private val evaluateStrength: EvaluatePasswordStrengthUseCase,
    private val getBiometricStatus: GetBiometricStatusUseCase,
    private val prepareBiometricUnlock: PrepareBiometricUnlockUseCase,
    private val unlockWithBiometrics: UnlockWithBiometricsUseCase,
) : ViewModel() {

    @AssistedFactory
    interface Factory {
        fun create(user: User): LockViewModel
    }

    private val _uiState = MutableStateFlow(LockUiState(biometricEnabled = biometricUsable()))
    val uiState: StateFlow<LockUiState> = _uiState.asStateFlow()

    fun onPasswordChange(value: String) =
        _uiState.update { it.copy(password = value, strength = evaluateStrength(value), error = null) }

    fun onConfirmationChange(value: String) = _uiState.update { it.copy(confirmation = value, error = null) }

    fun submit(isSetup: Boolean) {
        val state = _uiState.value
        if (state.isWorking) return
        _uiState.update { it.copy(isWorking = true, error = null) }
        viewModelScope.launch {
            val result = if (isSetup) {
                createVault(user.id, state.password, state.confirmation)
            } else {
                unlockVault(user.id, state.password)
            }
            result
                .onSuccess { forgetTypedSecrets() }
                .onFailure { e -> _uiState.update { it.copy(isWorking = false).rejected(UiText.Error(e.toAppError())) } }
        }
    }

    /** Cipher for the biometric prompt, or null (with the reason shown) when it can't be used. */
    fun biometricCipher(): Cipher? =
        prepareBiometricUnlock(user.id).fold(
            onSuccess = { cipher ->
                if (cipher == null) _uiState.update { it.copy(biometricEnabled = false) }
                cipher
            },
            onFailure = { e ->
                _uiState.update { it.copy(biometricEnabled = biometricUsable(), error = UiText.Error(e.toAppError())) }
                null
            },
        )

    fun onBiometricAuthenticated(cipher: Cipher) {
        unlockWithBiometrics(user.id, cipher)
            .onSuccess { forgetTypedSecrets() }
            .onFailure { e -> _uiState.update { it.rejected(UiText.Error(e.toAppError())) } }
    }

    fun onBiometricError(message: String) = _uiState.update { it.copy(error = UiText.Raw(message)) }

    /** The master password has done its job; don't keep it in memory. */
    private fun forgetTypedSecrets() {
        _uiState.value = LockUiState(biometricEnabled = biometricUsable())
    }

    private fun LockUiState.rejected(error: UiText) = copy(error = error, rejections = rejections + 1)

    private fun biometricUsable(): Boolean = getBiometricStatus(user.id).let { it.available && it.enabled }
}
