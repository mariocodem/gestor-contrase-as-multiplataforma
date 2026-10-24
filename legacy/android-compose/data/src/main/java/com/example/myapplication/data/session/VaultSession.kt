package com.example.myapplication.data.session

import com.example.myapplication.domain.model.VaultEntry
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.crypto.SecretKey
import javax.inject.Inject
import javax.inject.Singleton

class UnlockedVault(val uid: String, val key: SecretKey)

/** The decrypted vault key, and what it last decrypted, held in memory only while the vault is unlocked. */
@Singleton
class VaultSession @Inject constructor() {
    private val _vault = MutableStateFlow<UnlockedVault?>(null)
    val vault: StateFlow<UnlockedVault?> = _vault.asStateFlow()

    private val _userId = MutableStateFlow<String?>(null)
    val userId: StateFlow<String?> = _userId.asStateFlow()

    val current: UnlockedVault? get() = _vault.value

    @Volatile
    private var decrypted: Pair<UnlockedVault, List<VaultEntry>>? = null

    fun open(uid: String, key: SecretKey) {
        decrypted = null
        _vault.value = UnlockedVault(uid, key)
        _userId.value = uid
    }

    fun close() {
        decrypted = null
        _userId.value = null
        _vault.value = null
    }

    /** Keeps [entries] as the latest decryption of [vault], unless that vault has been closed since. */
    fun rememberEntries(vault: UnlockedVault, entries: List<VaultEntry>) {
        if (_vault.value === vault) decrypted = vault to entries
    }

    /** The entries last decrypted with [vault]'s key, or null if none yet or it's no longer open. */
    fun entriesOf(vault: UnlockedVault): List<VaultEntry>? = decrypted?.takeIf { it.first === vault }?.second
}
