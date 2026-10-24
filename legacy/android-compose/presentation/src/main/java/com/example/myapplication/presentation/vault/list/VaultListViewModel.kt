package com.example.myapplication.presentation.vault.list

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.toAppError
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.usecase.entry.ObserveEntriesUseCase
import com.example.myapplication.domain.usecase.entry.SearchEntriesUseCase
import com.example.myapplication.domain.usecase.vault.LockVaultUseCase
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.SecretClipboard
import com.example.myapplication.presentation.common.UiText
import com.example.myapplication.presentation.common.secretCopiedMessage
import com.example.myapplication.presentation.vault.siteHost
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import javax.inject.Inject

/** A row of the list. No secrets: the password is looked up only when the user copies it. */
data class EntryListItem(val id: String, val title: String, val subtitle: String, val hasPassword: Boolean)

data class VaultListUiState(
    val isLoading: Boolean = true,
    val items: List<EntryListItem> = emptyList(),
    val totalCount: Int = 0,
    val query: String = "",
    val error: AppError? = null,
)

private sealed interface EntriesResult {
    data object Loading : EntriesResult
    data class Loaded(val entries: List<VaultEntry>) : EntriesResult
    data class Failed(val error: AppError) : EntriesResult
}

@HiltViewModel
class VaultListViewModel @Inject constructor(
    observeEntries: ObserveEntriesUseCase,
    private val searchEntries: SearchEntriesUseCase,
    private val lockVault: LockVaultUseCase,
    private val clipboard: SecretClipboard,
) : ViewModel() {
    private val query = MutableStateFlow("")
    private val retries = MutableStateFlow(0)
    private val _messages = Channel<UiText>(Channel.BUFFERED)
    val messages: Flow<UiText> = _messages.receiveAsFlow()

    // Eagerly: this ViewModel lives only while the vault is unlocked, and coming back from an entry
    // must show the list as it is now (a new or deleted entry included) on the very first frame,
    // without reopening the Firestore listener and decrypting everything again.
    private val entries: StateFlow<EntriesResult> = retries
        .flatMapLatest {
            observeEntries()
                .map<List<VaultEntry>, EntriesResult> { EntriesResult.Loaded(it) }
                .catch { emit(EntriesResult.Failed(it.toAppError())) }
        }
        .stateIn(viewModelScope, SharingStarted.Eagerly, EntriesResult.Loading)

    val uiState: StateFlow<VaultListUiState> = combine(entries, query) { result, text ->
        val all = (result as? EntriesResult.Loaded)?.entries.orEmpty()
        VaultListUiState(
            isLoading = result is EntriesResult.Loading,
            items = searchEntries(all, text).map { it.toListItem() },
            totalCount = all.size,
            query = text,
            error = (result as? EntriesResult.Failed)?.error,
        )
    }.stateIn(viewModelScope, SharingStarted.Eagerly, VaultListUiState())

    fun onQueryChange(value: String) = query.update { value }

    fun retry() = retries.update { it + 1 }

    fun lock() = lockVault()

    fun copyPassword(id: String) {
        val entry = (entries.value as? EntriesResult.Loaded)?.entries?.find { it.id == id } ?: return
        if (entry.password.isEmpty()) return
        clipboard.copySecret(R.string.clipboard_label_password, entry.password)
        _messages.trySend(clipboard.secretCopiedMessage())
    }

    private fun VaultEntry.toListItem() = EntryListItem(
        id = id,
        title = title,
        subtitle = username.ifBlank { siteHost(url).orEmpty() },
        hasPassword = password.isNotEmpty(),
    )
}
