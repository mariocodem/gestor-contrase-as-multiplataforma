package com.example.myapplication.domain.usecase

import app.cash.turbine.test
import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.toAppError
import com.example.myapplication.domain.fake.FakeVaultRepository
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.usecase.entry.ObserveEntriesUseCase
import com.example.myapplication.domain.usecase.entry.SaveEntryUseCase
import com.example.myapplication.domain.usecase.entry.SearchEntriesUseCase
import com.example.myapplication.domain.usecase.vault.CreateVaultUseCase
import com.example.myapplication.domain.usecase.vault.UnlockVaultUseCase
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class VaultAndEntryUseCasesTest {
    private val vault = FakeVaultRepository()

    @Test
    fun createVault_validatesLengthAndConfirmationBeforeTouchingTheVault() = runTest {
        val create = CreateVaultUseCase(vault)

        assertEquals(AppError.MasterPasswordTooShort, create("u1", "short", "short").exceptionOrNull()?.toAppError())
        assertEquals(
            AppError.MasterPasswordMismatch,
            create("u1", "long enough secret", "long enough secrets").exceptionOrNull()?.toAppError(),
        )
        assertNull(vault.createdWith)

        assertEquals(true, create("u1", "long enough secret", "long enough secret").isSuccess)
        assertEquals("long enough secret", vault.createdWith)
    }

    @Test
    fun unlockVault_reportsAWrongMasterPassword() = runTest {
        val unlock = UnlockVaultUseCase(vault)

        assertEquals(AppError.WrongMasterPassword, unlock("u1", "nope").exceptionOrNull()?.toAppError())
        assertEquals(AppError.EmptyMasterPassword, unlock("u1", "").exceptionOrNull()?.toAppError())
        assertEquals(true, unlock("u1", "correct horse battery").isSuccess)
    }

    @Test
    fun saveEntry_requiresANameAndTrimsEverythingButThePassword() = runTest {
        val save = SaveEntryUseCase(vault)

        assertEquals(AppError.EmptyTitle, save(VaultEntry(title = "   ")).exceptionOrNull()?.toAppError())

        val saved = save(VaultEntry(title = "  Banco ", username = " ana ", password = " p4ss ", url = " banco.es "))
            .getOrThrow()
        assertEquals(VaultEntry(id = saved.id, title = "Banco", username = "ana", password = " p4ss ", url = "banco.es"), saved)
    }

    @Test
    fun observeEntries_sortsIgnoringCaseAndAccents() = runTest {
        vault.unlock("u1", "correct horse battery".toCharArray())
        listOf("zeta", "Ábaco", "banco", "Álgebra").forEach { vault.save(VaultEntry(title = it)) }

        ObserveEntriesUseCase(vault)().test {
            assertEquals(listOf("Ábaco", "Álgebra", "banco", "zeta"), awaitItem().map { it.title })
        }
    }

    @Test
    fun searchEntries_matchesTitleUsernameAndSiteWithoutAccents() {
        val entries = listOf(
            VaultEntry(id = "1", title = "Telefónica", username = "ana"),
            VaultEntry(id = "2", title = "Correo", username = "ana@correo.es"),
            VaultEntry(id = "3", title = "Banco", url = "https://banco.example"),
        )
        val search = SearchEntriesUseCase()

        assertEquals(listOf("1"), search(entries, "telefonica").map { it.id })
        assertEquals(listOf("1", "2"), search(entries, " ANA ").map { it.id })
        assertEquals(listOf("3"), search(entries, "example").map { it.id })
        assertEquals(entries, search(entries, ""))
    }
}
