package com.example.myapplication.data.mapper

import com.example.myapplication.data.crypto.VaultCrypto
import com.example.myapplication.data.remote.EncryptedEntryDto
import com.example.myapplication.domain.model.VaultEntry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class EntryCodecTest {
    private val codec = EntryCodec()
    private val key = VaultCrypto.newVaultKey()

    @Test
    fun roundTripsEveryField() {
        val entry = VaultEntry("abc", "Banco", "ana", "pä55\"wörd/\\", "https://banco.es", "PIN: 1234\nsegunda línea", 1_700_000_000_000)

        assertEquals(entry, codec.decode(EncryptedEntryDto("abc", codec.encode(entry, key)), key))
    }

    @Test
    fun readsEntriesWrittenByTheOriginalOrgJsonFormat() {
        // What JSONObject produced before: escaped slashes, every field present.
        val legacy = """{"title":"Correo","username":"ana@correo.es","password":"a\/b","url":"","notes":"","updatedAt":42}"""
        val data = VaultCrypto.encrypt(key, legacy.toByteArray(), aad = "doc-1".toByteArray())

        val entry = codec.decode(EncryptedEntryDto("doc-1", data), key)

        assertEquals(VaultEntry("doc-1", "Correo", "ana@correo.es", "a/b", "", "", 42), entry)
    }

    @Test
    fun refusesCiphertextCopiedFromAnotherEntry() {
        val data = codec.encode(VaultEntry(id = "doc-1", title = "Banco"), key)

        assertNull(codec.decode(EncryptedEntryDto("doc-2", data), key))
    }
}
