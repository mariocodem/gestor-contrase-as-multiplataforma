package com.example.myapplication.presentation.vault.detail

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.domain.error.toAppError
import com.example.myapplication.domain.model.PasswordStrength
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.usecase.entry.DeleteEntryUseCase
import com.example.myapplication.domain.usecase.entry.ObserveEntryUseCase
import com.example.myapplication.domain.usecase.generator.EvaluatePasswordStrengthUseCase
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.SecretClipboard
import com.example.myapplication.presentation.common.UiText
import com.example.myapplication.presentation.common.secretCopiedMessage
import com.example.myapplication.presentation.navigation.ENTRY_ID_ARG
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
import javax.inject.Inject

sealed interface EntryDetailUiState {
    data object Loading : EntryDetailUiState
    data object Missing : EntryDetailUiState
    data class Loaded(val entry: VaultEntry, val strength: PasswordStrength, val passwordVisible: Boolean) : EntryDetailUiState
}

sealed interface EntryDetailEvent {
    data class Message(val text: UiText) : EntryDetailEvent
    data class Deleted(val title: String) : EntryDetailEvent
}

@HiltViewModel
class EntryDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val observeEntry: ObserveEntryUseCase,
    private val evaluateStrength: EvaluatePasswordStrengthUseCase,
    private val deleteEntry: DeleteEntryUseCase,
    private val clipboard: SecretClipboard,
) : ViewModel() {
    private val id: String = checkNotNull(savedStateHandle[ENTRY_ID_ARG])
    private val passwordVisible = MutableStateFlow(false)
    private val deleting = MutableStateFlow(false)
    private var lastEntry: VaultEntry? = null

    private val _events = Channel<EntryDetailEvent>(Channel.BUFFERED)
    val events: Flow<EntryDetailEvent> = _events.receiveAsFlow()

    val uiState: StateFlow<EntryDetailUiState> =
        combine(observeEntry(id), passwordVisible, deleting) { entry, visible, isDeleting ->
            // While leaving after a delete, keep showing the entry instead of flashing "missing".
            val shown = entry ?: lastEntry.takeIf { isDeleting }
            if (entry != null) lastEntry = entry
            if (shown == null) {
                EntryDetailUiState.Missing
            } else {
                EntryDetailUiState.Loaded(shown, evaluateStrength(shown.password), visible)
            }
        }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), initialState())

    private val entry: VaultEntry? get() = (uiState.value as? EntryDetailUiState.Loaded)?.entry

    /**
     * Opened from the list, the entry is already decrypted: showing it on the first frame skips a
     * blank page, and gives the key cap flying in from the list a place to land.
     */
    private fun initialState(): EntryDetailUiState =
        observeEntry.current(id)?.let { current ->
            lastEntry = current
            EntryDetailUiState.Loaded(current, evaluateStrength(current.password), passwordVisible = false)
        } ?: EntryDetailUiState.Loading

    fun togglePasswordVisible() = passwordVisible.update { !it }

    fun copyPassword() {
        val password = entry?.password?.takeIf { it.isNotEmpty() } ?: return
        clipboard.copySecret(R.string.clipboard_label_password, password)
        _events.trySend(EntryDetailEvent.Message(clipboard.secretCopiedMessage()))
    }

    fun copyUsername() {
        val username = entry?.username?.takeIf { it.isNotEmpty() } ?: return
        clipboard.copyPlain(R.string.clipboard_label_username, username)
        if (!clipboard.systemConfirmsCopies) _events.trySend(EntryDetailEvent.Message(UiText.Res(R.string.copied_username)))
    }

    fun delete() {
        val current = entry ?: return
        deleting.value = true
        viewModelScope.launch {
            deleteEntry(current.id)
                .onSuccess { _events.send(EntryDetailEvent.Deleted(current.title)) }
                .onFailure { e ->
                    deleting.value = false
                    _events.send(EntryDetailEvent.Message(UiText.Error(e.toAppError())))
                }
        }
    }
}
