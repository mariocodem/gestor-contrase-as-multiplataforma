package com.example.myapplication.domain.repository

import com.example.myapplication.domain.model.VaultEntry
import com.example.myapplication.domain.model.VaultStatus
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow

/**
 * The encrypted vault. Implementations encrypt on the device; nothing readable leaves it.
 * Failures are thrown as [com.example.myapplication.domain.error.AppException].
 */
interface VaultRepository {
    fun observeStatus(userId: String): Flow<VaultStatus>

    /** Id of the user whose vault is unlocked in memory, or null while locked. */
    val unlockedUserId: StateFlow<String?>

    /** Creates the vault protected by [masterPassword] and leaves it unlocked. */
    suspend fun create(userId: String, masterPassword: CharArray)

    suspend fun unlock(userId: String, masterPassword: CharArray)

    /** Forgets the decrypted vault key. */
    fun lock()

    /** Decrypted entries of the unlocked vault, unordered; empty while locked. */
    fun observeEntries(): Flow<List<VaultEntry>>

    /**
     * The entries most recently decrypted in this session, so a screen can draw at once instead of
     * waiting for [observeEntries]; null before the first decryption and while locked.
     */
    val lastKnownEntries: List<VaultEntry>? get() = null

    /** Encrypts and stores [entry], assigning an id when it's new. Returns what was stored. */
    suspend fun save(entry: VaultEntry): VaultEntry

    suspend fun delete(id: String)
}
