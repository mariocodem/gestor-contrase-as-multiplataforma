package com.example.myapplication.data.crypto

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Test
import javax.crypto.AEADBadTagException

class VaultCryptoTest {
    // Far below the real cost; the tests only care about correctness.
    private val iterations = 1_000

    @Test
    fun wrappedKey_unwrapsWithTheSamePassword() {
        val salt = VaultCrypto.newSalt()
        val vaultKey = VaultCrypto.newVaultKey()
        val wrapped = VaultCrypto.wrapKey(VaultCrypto.deriveKey("correct horse".toCharArray(), salt, iterations), vaultKey)

        val unwrapped = VaultCrypto.unwrapKey(VaultCrypto.deriveKey("correct horse".toCharArray(), salt, iterations), wrapped)

        assertArrayEquals(vaultKey.encoded, unwrapped.encoded)
    }

    @Test
    fun wrappedKey_rejectsAWrongPassword() {
        val salt = VaultCrypto.newSalt()
        val wrapped = VaultCrypto.wrapKey(
            VaultCrypto.deriveKey("correct horse".toCharArray(), salt, iterations),
            VaultCrypto.newVaultKey(),
        )
        val wrongKey = VaultCrypto.deriveKey("battery staple".toCharArray(), salt, iterations)

        assertThrows(AEADBadTagException::class.java) { VaultCrypto.unwrapKey(wrongKey, wrapped) }
    }

    @Test
    fun encrypt_roundTripsAndUsesAFreshIvEachTime() {
        val key = VaultCrypto.newVaultKey()
        val plaintext = "contraseña-secreta".toByteArray()

        val first = VaultCrypto.encrypt(key, plaintext, aad = "entry-1".toByteArray())
        val second = VaultCrypto.encrypt(key, plaintext, aad = "entry-1".toByteArray())

        assertFalse(first.contentEquals(second))
        assertArrayEquals(plaintext, VaultCrypto.decrypt(key, first, aad = "entry-1".toByteArray()))
    }

    @Test
    fun decrypt_rejectsCiphertextMovedToAnotherEntry() {
        val key = VaultCrypto.newVaultKey()
        val ciphertext = VaultCrypto.encrypt(key, "secret".toByteArray(), aad = "entry-1".toByteArray())

        assertThrows(AEADBadTagException::class.java) {
            VaultCrypto.decrypt(key, ciphertext, aad = "entry-2".toByteArray())
        }
    }

    @Test
    fun decrypt_rejectsTamperedCiphertext() {
        val key = VaultCrypto.newVaultKey()
        val ciphertext = VaultCrypto.encrypt(key, "secret".toByteArray())
        ciphertext[ciphertext.size - 1] = (ciphertext.last().toInt() xor 1).toByte()

        assertThrows(AEADBadTagException::class.java) { VaultCrypto.decrypt(key, ciphertext) }
    }
}
