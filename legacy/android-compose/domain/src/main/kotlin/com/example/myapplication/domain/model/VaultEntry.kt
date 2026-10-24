package com.example.myapplication.domain.model

/** A decrypted vault item. Only ever lives in memory while the vault is unlocked. */
data class VaultEntry(
    val id: String = "",
    val title: String = "",
    val username: String = "",
    val password: String = "",
    val url: String = "",
    val notes: String = "",
    val updatedAt: Long = 0L,
) {
    val isNew: Boolean get() = id.isEmpty()
}
