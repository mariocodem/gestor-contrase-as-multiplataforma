package com.example.myapplication.presentation.vault.editor

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.domain.error.toAppError
import com.example.myapplication.domain.model.PasswordStrength
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.usecase.entry.ObserveEntryUseCase
import com.example.myapplication.domain.usecase.entry.SaveEntryUseCase
import com.example.myapplication.domain.usecase.generator.EvaluatePasswordStrengthUseCase
import com.example.myapplication.presentation.common.UiText
import com.example.myapplication.presentation.navigation.ENTRY_ID_ARG
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class EntryEditorUiState(
    val isNew: Boolean = true,
    val isLoading: Boolean = false,
    val draft: VaultEntry = VaultEntry(),
    val hasChanges: Boolean = false,
    val strength: PasswordStrength = PasswordStrength.EMPTY,
    val isSaving: Boolean = false,
    val error: UiText? = null,
) {
    val canSave: Boolean get() = hasChanges && draft.title.isNotBlank() && !isSaving && !isLoading
}

sealed interface EntryEditorEvent {
    data class Saved(val id: String, val wasNew: Boolean) : EntryEditorEvent
    data object Gone : EntryEditorEvent
}

@HiltViewModel
class EntryEditorViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val observeEntry: ObserveEntryUseCase,
    private val saveEntry: SaveEntryUseCase,
    private val evaluateStrength: EvaluatePasswordStrengthUseCase,
) : ViewModel() {
    private val id: String? = savedStateHandle[ENTRY_ID_ARG]
    private var original = VaultEntry()

    private val _uiState = MutableStateFlow(EntryEditorUiState(isNew = id == null, isLoading = id != null))
    val uiState: StateFlow<EntryEditorUiState> = _uiState.asStateFlow()

    private val _events = Channel<EntryEditorEvent>(Channel.BUFFERED)
    val events: Flow<EntryEditorEvent> = _events.receiveAsFlow()

    init {
        if (id != null) {
            viewModelScope.launch {
                val entry = observeEntry(id).first()
                if (entry == null) {
                    _events.send(EntryEditorEvent.Gone)
                } else {
                    original = entry
                    _uiState.update { it.copy(isLoading = false, draft = entry, strength = evaluateStrength(entry.password)) }
                }
            }
        }
    }

    fun onTitleChange(value: String) = edit { it.copy(title = value) }

    fun onUsernameChange(value: String) = edit { it.copy(username = value) }

    fun onPasswordChange(value: String) = edit { it.copy(password = value) }

    fun onUrlChange(value: String) = edit { it.copy(url = value) }

    fun onNotesChange(value: String) = edit { it.copy(notes = value) }

    fun save() {
        val state = _uiState.value
        if (!state.canSave) return
        _uiState.update { it.copy(isSaving = true, error = null) }
        viewModelScope.launch {
            saveEntry(state.draft)
                .onSuccess { saved -> _events.send(EntryEditorEvent.Saved(saved.id, wasNew = state.isNew)) }
                .onFailure { e -> _uiState.update { it.copy(isSaving = false, error = UiText.Error(e.toAppError())) } }
        }
    }

    private fun edit(transform: (VaultEntry) -> VaultEntry) = _uiState.update { state ->
        val draft = transform(state.draft)
        state.copy(
            draft = draft,
            hasChanges = draft != original,
            strength = if (draft.password != state.draft.password) evaluateStrength(draft.password) else state.strength,
            error = null,
        )
    }
}
