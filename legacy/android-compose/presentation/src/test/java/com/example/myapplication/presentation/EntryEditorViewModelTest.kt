package com.example.myapplication.presentation

import androidx.lifecycle.SavedStateHandle
import app.cash.turbine.test
import com.example.myapplication.domain.generator.PasswordStrengthEstimator
import com.example.myapplication.domain.model.StrengthLevel
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.usecase.entry.ObserveEntryUseCase
import com.example.myapplication.domain.usecase.entry.SaveEntryUseCase
import com.example.myapplication.domain.usecase.generator.EvaluatePasswordStrengthUseCase
import com.example.myapplication.presentation.navigation.ENTRY_ID_ARG
import com.example.myapplication.presentation.vault.editor.EntryEditorEvent
import com.example.myapplication.presentation.vault.editor.EntryEditorViewModel
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

class EntryEditorViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val existing = VaultEntry(id = "e1", title = "Banco", username = "ana", password = "123456")
    private val vault = FakeVaultRepository(listOf(existing))

    private fun editor(id: String?) = EntryEditorViewModel(
        SavedStateHandle(if (id == null) emptyMap() else mapOf(ENTRY_ID_ARG to id)),
        ObserveEntryUseCase(vault),
        SaveEntryUseCase(vault),
        EvaluatePasswordStrengthUseCase(PasswordStrengthEstimator()),
    )

    @Test
    fun newEntryNeedsANameBeforeItCanBeSaved() {
        val viewModel = editor(id = null)
        viewModel.onPasswordChange("x")
        assertFalse(viewModel.uiState.value.canSave)

        viewModel.onTitleChange("Correo")
        assertTrue(viewModel.uiState.value.canSave)
    }

    @Test
    fun savingANewEntryReportsItsIdAndThatItWasNew() = runTest {
        val viewModel = editor(id = null)
        viewModel.onTitleChange("Correo")
        viewModel.onPasswordChange("s3creto-largo!")

        viewModel.events.test {
            viewModel.save()

            val saved = awaitItem() as EntryEditorEvent.Saved
            assertTrue(saved.wasNew)
            assertEquals("Correo", vault.entries.value.single { it.id == saved.id }.title)
        }
    }

    @Test
    fun editingLoadsTheEntryAndRatesItsPassword() {
        val viewModel = editor(id = "e1")
        val state = viewModel.uiState.value

        assertFalse(state.isNew)
        assertEquals(existing, state.draft)
        assertFalse(state.hasChanges)
        assertEquals(StrengthLevel.VERY_WEAK, state.strength.level)

        viewModel.onPasswordChange("q7Rk2mZp9xLw4nVb!")
        assertTrue(viewModel.uiState.value.hasChanges)
        assertEquals(StrengthLevel.VERY_STRONG, viewModel.uiState.value.strength.level)
    }

    @Test
    fun editingAnEntryThatNoLongerExistsCloses() = runTest {
        val viewModel = editor(id = "gone")

        viewModel.events.test {
            assertEquals(EntryEditorEvent.Gone, awaitItem())
        }
    }
}
