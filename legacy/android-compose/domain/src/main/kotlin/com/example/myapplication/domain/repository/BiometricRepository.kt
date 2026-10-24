package com.example.myapplication.domain.repository

import com.example.myapplication.domain.model.BiometricStatus
import javax.crypto.Cipher

/**
 * Optional fingerprint/face unlock. Each cipher handed out only works after the user passes a
 * strong biometric prompt, which the UI shows; [Cipher] is a JDK type, not an Android one.
 */
interface BiometricRepository {
    fun status(userId: String): BiometricStatus

    /** Cipher to authorize with a biometric prompt and then pass to [enable]. */
    fun enrollmentCipher(userId: String): Cipher

    /** Stores the unlocked vault's key, encrypted with [authorizedCipher], on this device only. */
    fun enable(userId: String, authorizedCipher: Cipher)

    /** Cipher to authorize and then pass to [unlock], or null when biometric unlock isn't set up. */
    fun unlockCipher(userId: String): Cipher?

    fun unlock(userId: String, authorizedCipher: Cipher)

    fun disable(userId: String)
}
