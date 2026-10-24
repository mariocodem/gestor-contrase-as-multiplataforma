package com.example.myapplication.presentation

import androidx.lifecycle.SavedStateHandle
import com.example.myapplication.domain.generator.PasswordStrengthEstimator
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.usecase.entry.DeleteEntryUseCase
import com.example.myapplication.domain.usecase.entry.ObserveEntryUseCase
import com.example.myapplication.domain.usecase.generator.EvaluatePasswordStrengthUseCase
import com.example.myapplication.presentation.navigation.ENTRY_ID_ARG
import com.example.myapplication.presentation.vault.detail.EntryDetailUiState
import com.example.myapplication.presentation.vault.detail.EntryDetailViewModel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

class EntryDetailViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val vault = FakeVaultRepository(listOf(VaultEntry(id = "e1", title = "Banco", username = "ana", password = "123456")))

    private fun detail(id: String) = EntryDetailViewModel(
        SavedStateHandle(mapOf(ENTRY_ID_ARG to id)),
        ObserveEntryUseCase(vault),
        EvaluatePasswordStrengthUseCase(PasswordStrengthEstimator()),
        DeleteEntryUseCase(vault),
        FakeClipboard(),
    )

    @Test
    fun anEntryAlreadyDecryptedShowsBeforeAnyoneCollects() {
        val state = detail("e1").uiState.value
        assertTrue(state is EntryDetailUiState.Loaded)
        assertEquals("Banco", (state as EntryDetailUiState.Loaded).entry.title)
    }

    @Test
    fun anUnknownEntryWaitsForTheVault() {
        assertEquals(EntryDetailUiState.Loading, detail("nope").uiState.value)
    }
}
