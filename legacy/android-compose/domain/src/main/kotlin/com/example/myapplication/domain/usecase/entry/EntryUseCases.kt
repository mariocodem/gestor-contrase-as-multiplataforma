package com.example.myapplication.domain.usecase.entry

import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.AppException
import com.example.myapplication.domain.error.resultOf
import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.repository.VaultRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import java.text.Collator
import java.text.Normalizer
import java.util.Locale
import javax.inject.Inject

/** Entries sorted the way people read them: alphabetical, ignoring case and accents. */
class ObserveEntriesUseCase @Inject constructor(private val vault: VaultRepository) {
    operator fun invoke(): Flow<List<VaultEntry>> = vault.observeEntries().map { entries ->
        val collator = Collator.getInstance(Locale.getDefault()).apply { strength = Collator.PRIMARY }
        entries.sortedWith(compareBy(collator, VaultEntry::title).thenBy(collator, VaultEntry::username))
    }
}

/** A single entry, or null once it's gone (deleted here or on another device). */
class ObserveEntryUseCase @Inject constructor(private val vault: VaultRepository) {
    operator fun invoke(id: String): Flow<VaultEntry?> =
        vault.observeEntries().map { entries -> entries.find { it.id == id } }.distinctUntilChanged()

    /** The entry as already decrypted in this session, to show while [invoke] connects; null if unknown. */
    fun current(id: String): VaultEntry? = vault.lastKnownEntries?.find { it.id == id }
}

/** Matches title, username and site, so "telefonica" finds "Telefónica". */
class SearchEntriesUseCase @Inject constructor() {
    operator fun invoke(entries: List<VaultEntry>, query: String): List<VaultEntry> {
        val needle = query.normalizedForSearch()
        if (needle.isEmpty()) return entries
        return entries.filter { entry ->
            listOf(entry.title, entry.username, entry.url).any { it.normalizedForSearch().contains(needle) }
        }
    }

    private fun String.normalizedForSearch(): String =
        Normalizer.normalize(trim(), Normalizer.Form.NFD).replace(DIACRITICS, "").lowercase()

    private companion object {
        val DIACRITICS = "\\p{Mn}+".toRegex()
    }
}

class SaveEntryUseCase @Inject constructor(private val vault: VaultRepository) {
    /** Trims the free-text fields (never the password) and rejects an entry without a name. */
    suspend operator fun invoke(entry: VaultEntry): Result<VaultEntry> = resultOf {
        val cleaned = entry.copy(title = entry.title.trim(), username = entry.username.trim(), url = entry.url.trim())
        if (cleaned.title.isEmpty()) throw AppException(AppError.EmptyTitle)
        vault.save(cleaned)
    }
}

class DeleteEntryUseCase @Inject constructor(private val vault: VaultRepository) {
    suspend operator fun invoke(id: String): Result<Unit> = resultOf { vault.delete(id) }
}
