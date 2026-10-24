package com.example.myapplication.presentation

import app.cash.turbine.test
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.usecase.entry.ObserveEntriesUseCase
import com.example.myapplication.domain.usecase.entry.SearchEntriesUseCase
import com.example.myapplication.domain.usecase.vault.LockVaultUseCase
import com.example.myapplication.presentation.vault.list.EntryListItem
import com.example.myapplication.presentation.vault.list.VaultListViewModel
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

class VaultListViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private val vault = FakeVaultRepository(
        listOf(
            VaultEntry(id = "1", title = "Telefónica", username = "ana", password = "a"),
            VaultEntry(id = "2", title = "banco", url = "https://www.banco.es/login", password = "b"),
            VaultEntry(id = "3", title = "Correo", username = "ana@correo.es"),
        ),
    )
    private val clipboard = FakeClipboard()
    // Lazy: the ViewModel must be created after the rule has installed the test Main dispatcher.
    private val viewModel by lazy {
        VaultListViewModel(
            ObserveEntriesUseCase(vault),
            SearchEntriesUseCase(),
            LockVaultUseCase(vault),
            clipboard,
        )
    }

    @Test
    fun listsEntriesSortedWithoutExposingPasswords() = runTest {
        viewModel.uiState.test {
            val state = expectMostRecentItem()
            assertEquals(
                listOf(
                    EntryListItem("2", "banco", "banco.es", hasPassword = true),
                    EntryListItem("3", "Correo", "ana@correo.es", hasPassword = false),
                    EntryListItem("1", "Telefónica", "ana", hasPassword = true),
                ),
                state.items,
            )
            assertEquals(3, state.totalCount)
        }
    }

    @Test
    fun searchFiltersButKeepsTheTotal() = runTest {
        viewModel.uiState.test {
            viewModel.onQueryChange("telefonica")
            val state = expectMostRecentItem()
            assertEquals(listOf("1"), state.items.map { it.id })
            assertEquals(3, state.totalCount)
        }
    }

    @Test
    fun copyingFromTheListUsesTheStoredPassword() = runTest {
        // copyPassword reads the loaded list, which only flows while someone observes the state.
        backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) { viewModel.uiState.collect {} }
        viewModel.messages.test {
            viewModel.copyPassword("2")

            assertEquals(listOf("b"), clipboard.secrets)
            awaitItem()
        }
    }

}
