package com.example.myapplication.data.mapper

import android.util.Log
import com.example.myapplication.data.crypto.VaultCrypto
import com.example.myapplication.data.remote.EncryptedEntryDto
import com.example.myapplication.domain.model.VaultEntry
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import javax.crypto.SecretKey
import javax.inject.Inject

/**
 * Turns entries into the ciphertext stored in Firestore and back. The plaintext is a small JSON
 * object whose field names match what earlier versions of the app wrote, so existing vaults
 * keep decrypting. The entry id is authenticated data: ciphertexts can't be swapped between entries.
 */
class EntryCodec @Inject constructor() {

    fun encode(entry: VaultEntry, key: SecretKey): ByteArray {
        val json = JSON.encodeToString(EntryPayload.serializer(), EntryPayload.from(entry))
        return VaultCrypto.encrypt(key, json.toByteArray(Charsets.UTF_8), aad = entry.id.toByteArray())
    }

    /** Null (and logged) when the entry can't be decrypted, so one bad document doesn't hide the rest. */
    fun decode(dto: EncryptedEntryDto, key: SecretKey): VaultEntry? =
        try {
            val plaintext = VaultCrypto.decrypt(key, dto.data, aad = dto.id.toByteArray())
            JSON.decodeFromString(EntryPayload.serializer(), String(plaintext, Charsets.UTF_8)).toEntry(dto.id)
        } catch (e: Exception) {
            Log.w(TAG, "Entry ${dto.id} could not be decrypted", e)
            null
        }

    @Serializable
    private data class EntryPayload(
        val title: String = "",
        val username: String = "",
        val password: String = "",
        val url: String = "",
        val notes: String = "",
        val updatedAt: Long = 0L,
    ) {
        fun toEntry(id: String) = VaultEntry(id, title, username, password, url, notes, updatedAt)

        companion object {
            fun from(entry: VaultEntry) =
                EntryPayload(entry.title, entry.username, entry.password, entry.url, entry.notes, entry.updatedAt)
        }
    }

    private companion object {
        const val TAG = "EntryCodec"
        val JSON = Json {
            ignoreUnknownKeys = true
            encodeDefaults = true
        }
    }
}
