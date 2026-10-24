package com.example.myapplication.presentation.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.domain.error.toAppError
import com.example.myapplication.domain.model.AutoLockTimeout
import com.example.myapplication.domain.model.User
import com.example.myapplication.domain.usecase.auth.SignOutUseCase
import com.example.myapplication.domain.usecase.biometric.DisableBiometricUnlockUseCase
import com.example.myapplication.domain.usecase.biometric.EnableBiometricUnlockUseCase
import com.example.myapplication.domain.usecase.biometric.GetBiometricStatusUseCase
import com.example.myapplication.domain.usecase.biometric.PrepareBiometricEnrollmentUseCase
import com.example.myapplication.domain.usecase.settings.ObserveSettingsUseCase
import com.example.myapplication.domain.usecase.settings.SetAutoLockTimeoutUseCase
import com.example.myapplication.domain.usecase.settings.SetDynamicColorUseCase
import com.example.myapplication.domain.usecase.vault.LockVaultUseCase
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.UiText
import dagger.assisted.Assisted
import dagger.assisted.AssistedFactory
import dagger.assisted.AssistedInject
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.crypto.Cipher

data class SettingsUiState(
    val email: String? = null,
    val autoLock: AutoLockTimeout = AutoLockTimeout.MINUTE_1,
    val dynamicColor: Boolean = false,
    val biometricAvailable: Boolean = false,
    val biometricEnabled: Boolean = false,
)

@HiltViewModel(assistedFactory = SettingsViewModel.Factory::class)
class SettingsViewModel @AssistedInject constructor(
    @Assisted private val user: User,
    observeSettings: ObserveSettingsUseCase,
    private val setAutoLockTimeout: SetAutoLockTimeoutUseCase,
    private val setDynamicColorUseCase: SetDynamicColorUseCase,
    private val getBiometricStatus: GetBiometricStatusUseCase,
    private val prepareBiometricEnrollment: PrepareBiometricEnrollmentUseCase,
    private val enableBiometricUnlock: EnableBiometricUnlockUseCase,
    private val disableBiometricUnlock: DisableBiometricUnlockUseCase,
    private val lockVault: LockVaultUseCase,
    private val signOutUseCase: SignOutUseCase,
) : ViewModel() {

    @AssistedFactory
    interface Factory {
        fun create(user: User): SettingsViewModel
    }

    private val biometricChanges = MutableStateFlow(0)
    private val _messages = Channel<UiText>(Channel.BUFFERED)
    val messages: Flow<UiText> = _messages.receiveAsFlow()

    val uiState: StateFlow<SettingsUiState> = combine(observeSettings(), biometricChanges) { settings, _ ->
        val biometric = getBiometricStatus(user.id)
        SettingsUiState(
            email = user.email,
            autoLock = settings.autoLock,
            dynamicColor = settings.dynamicColor,
            biometricAvailable = biometric.available,
            biometricEnabled = biometric.enabled,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), SettingsUiState(email = user.email))

    fun setAutoLock(timeout: AutoLockTimeout) {
        viewModelScope.launch { setAutoLockTimeout(timeout) }
    }

    fun setDynamicColor(enabled: Boolean) {
        viewModelScope.launch { setDynamicColorUseCase(enabled) }
    }

    /** Step 1 of turning biometrics on; null (with the reason shown) when it can't start. */
    fun biometricEnrollmentCipher(): Cipher? =
        prepareBiometricEnrollment(user.id).getOrElse { e ->
            _messages.trySend(UiText.Error(e.toAppError()))
            null
        }

    fun onBiometricEnrolled(cipher: Cipher) {
        enableBiometricUnlock(user.id, cipher)
            .onSuccess { _messages.trySend(UiText.Res(R.string.settings_biometric_on)) }
            .onFailure { e -> _messages.trySend(UiText.Error(e.toAppError())) }
        biometricChanges.update { it + 1 }
    }

    fun disableBiometric() {
        disableBiometricUnlock(user.id)
        biometricChanges.update { it + 1 }
        _messages.trySend(UiText.Res(R.string.settings_biometric_off))
    }

    fun onBiometricError(message: String) {
        _messages.trySend(UiText.Raw(message))
    }

    fun lockNow() = lockVault()

    fun signOut() = signOutUseCase()
}
