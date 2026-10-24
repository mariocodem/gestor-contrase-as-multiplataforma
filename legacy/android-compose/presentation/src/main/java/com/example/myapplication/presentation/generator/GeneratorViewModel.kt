package com.example.myapplication.presentation.generator

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.domain.model.GeneratedPassword
import com.example.myapplication.domain.model.PasswordOptions
import com.example.myapplication.domain.usecase.generator.GeneratePasswordUseCase
import com.example.myapplication.domain.usecase.settings.ObserveSettingsUseCase
import com.example.myapplication.domain.usecase.settings.SaveGeneratorOptionsUseCase
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.SecretClipboard
import com.example.myapplication.presentation.common.UiText
import com.example.myapplication.presentation.common.secretCopiedMessage
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class GeneratorUiState(
    val options: PasswordOptions = PasswordOptions(),
    /** Null until the saved options have loaded. */
    val password: GeneratedPassword? = null,
)

/** Every change to the options produces a fresh password at once; the options are remembered. */
@HiltViewModel
class GeneratorViewModel @Inject constructor(
    observeSettings: ObserveSettingsUseCase,
    private val saveOptions: SaveGeneratorOptionsUseCase,
    private val generatePassword: GeneratePasswordUseCase,
    private val clipboard: SecretClipboard,
) : ViewModel() {
    private val _uiState = MutableStateFlow(GeneratorUiState())
    val uiState: StateFlow<GeneratorUiState> = _uiState.asStateFlow()

    private val _messages = Channel<UiText>(Channel.BUFFERED)
    val messages: Flow<UiText> = _messages.receiveAsFlow()

    init {
        viewModelScope.launch {
            val options = observeSettings().first().generatorOptions
            _uiState.value = GeneratorUiState(options, generatePassword(options))
        }
    }

    /** Called continuously while dragging; saved once the drag ends. */
    fun onLengthChange(length: Int) {
        if (length != _uiState.value.options.length) apply(persist = false) { it.copy(length = length) }
    }

    fun onLengthChangeFinished() = persist(_uiState.value.options)

    fun onUppercaseChange(enabled: Boolean) = apply { it.copy(uppercase = enabled) }

    fun onLowercaseChange(enabled: Boolean) = apply { it.copy(lowercase = enabled) }

    fun onDigitsChange(enabled: Boolean) = apply { it.copy(digits = enabled) }

    fun onSymbolsChange(enabled: Boolean) = apply { it.copy(symbols = enabled) }

    fun onAvoidAmbiguousChange(enabled: Boolean) = apply { it.copy(avoidAmbiguous = enabled) }

    fun regenerate() {
        val options = _uiState.value.options
        _uiState.value = GeneratorUiState(options, generatePassword(options))
    }

    fun copy() {
        val value = _uiState.value.password?.value ?: return
        clipboard.copySecret(R.string.clipboard_label_password, value)
        _messages.trySend(clipboard.secretCopiedMessage())
    }

    private fun apply(persist: Boolean = true, transform: (PasswordOptions) -> PasswordOptions) {
        val options = transform(_uiState.value.options)
        // A password needs characters from somewhere; the UI also disables the last switch.
        if (options.enabledSetCount == 0) return
        _uiState.value = GeneratorUiState(options, generatePassword(options))
        if (persist) persist(options)
    }

    private fun persist(options: PasswordOptions) {
        viewModelScope.launch { saveOptions(options) }
    }
}
