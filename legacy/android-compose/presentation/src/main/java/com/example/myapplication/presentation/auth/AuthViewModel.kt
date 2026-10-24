package com.example.myapplication.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.domain.error.toAppError
import com.example.myapplication.domain.usecase.auth.RegisterUseCase
import com.example.myapplication.domain.usecase.auth.SendPasswordResetUseCase
import com.example.myapplication.domain.usecase.auth.SignInUseCase
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.UiText
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AuthUiState(
    val email: String = "",
    val password: String = "",
    val isRegistering: Boolean = false,
    val isWorking: Boolean = false,
    val error: UiText? = null,
    val info: UiText? = null,
)

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val signIn: SignInUseCase,
    private val register: RegisterUseCase,
    private val sendPasswordReset: SendPasswordResetUseCase,
) : ViewModel() {
    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    fun onEmailChange(value: String) = _uiState.update { it.copy(email = value, error = null, info = null) }

    fun onPasswordChange(value: String) = _uiState.update { it.copy(password = value, error = null, info = null) }

    fun toggleMode() = _uiState.update { it.copy(isRegistering = !it.isRegistering, error = null, info = null) }

    fun submit() {
        val state = _uiState.value
        if (state.isWorking) return
        launchWork {
            val result = if (state.isRegistering) register(state.email, state.password) else signIn(state.email, state.password)
            // On success the root screen moves on by itself once the account reports the user.
            result
                .onSuccess { _uiState.update { it.copy(password = "") } }
                .onFailure { e -> _uiState.update { it.copy(error = UiText.Error(e.toAppError())) } }
        }
    }

    fun requestPasswordReset() {
        if (_uiState.value.isWorking) return
        launchWork {
            sendPasswordReset(_uiState.value.email)
                .onSuccess { _uiState.update { it.copy(info = UiText.Res(R.string.auth_reset_sent)) } }
                .onFailure { e -> _uiState.update { it.copy(error = UiText.Error(e.toAppError())) } }
        }
    }

    private fun launchWork(block: suspend () -> Unit) {
        _uiState.update { it.copy(isWorking = true, error = null, info = null) }
        viewModelScope.launch {
            try {
                block()
            } finally {
                _uiState.update { it.copy(isWorking = false) }
            }
        }
    }
}
