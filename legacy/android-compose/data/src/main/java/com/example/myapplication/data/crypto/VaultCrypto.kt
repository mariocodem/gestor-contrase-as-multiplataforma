package com.example.myapplication.data.crypto

import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec

/**
 * Client-side encryption for the vault. Nothing readable ever reaches Firestore:
 *
 * - A random 256-bit *vault key* encrypts every entry with AES-256-GCM.
 * - The vault key is stored in Firestore wrapped (encrypted) with a key derived from the
 *   master password via PBKDF2-HMAC-SHA256. A wrong password fails the GCM tag check.
 *
 * Every ciphertext is laid out as `iv (12 bytes) || ciphertext || tag (16 bytes)`.
 */
object VaultCrypto {
    /** OWASP's 2023 recommendation for PBKDF2-HMAC-SHA256. Stored per vault so it can change. */
    const val DEFAULT_ITERATIONS = 600_000

    private const val KEY_BITS = 256
    private const val SALT_BYTES = 16
    private const val IV_BYTES = 12
    private const val TAG_BITS = 128
    private const val TRANSFORMATION = "AES/GCM/NoPadding"
    private val WRAP_AAD = "vault-key".toByteArray()

    private val random = SecureRandom()

    fun newSalt(): ByteArray = ByteArray(SALT_BYTES).also { random.nextBytes(it) }

    fun deriveKey(password: CharArray, salt: ByteArray, iterations: Int): SecretKey {
        val spec = PBEKeySpec(password, salt, iterations, KEY_BITS)
        try {
            val raw = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).encoded
            return SecretKeySpec(raw, "AES").also { raw.fill(0) }
        } finally {
            spec.clearPassword()
        }
    }

    fun newVaultKey(): SecretKey =
        KeyGenerator.getInstance("AES").run {
            init(KEY_BITS, random)
            generateKey()
        }

    fun encrypt(key: SecretKey, plaintext: ByteArray, aad: ByteArray? = null): ByteArray {
        val iv = ByteArray(IV_BYTES).also { random.nextBytes(it) }
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, key, GCMParameterSpec(TAG_BITS, iv))
        if (aad != null) cipher.updateAAD(aad)
        return iv + cipher.doFinal(plaintext)
    }

    /** Throws [javax.crypto.AEADBadTagException] if the key or [aad] is wrong or the data was tampered with. */
    fun decrypt(key: SecretKey, data: ByteArray, aad: ByteArray? = null): ByteArray {
        require(data.size > IV_BYTES) { "Ciphertext too short" }
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(TAG_BITS, data, 0, IV_BYTES))
        if (aad != null) cipher.updateAAD(aad)
        return cipher.doFinal(data, IV_BYTES, data.size - IV_BYTES)
    }

    fun wrapKey(wrappingKey: SecretKey, key: SecretKey): ByteArray =
        encrypt(wrappingKey, key.encoded, WRAP_AAD)

    fun unwrapKey(wrappingKey: SecretKey, wrapped: ByteArray): SecretKey {
        val raw = decrypt(wrappingKey, wrapped, WRAP_AAD)
        return SecretKeySpec(raw, "AES").also { raw.fill(0) }
    }
}
