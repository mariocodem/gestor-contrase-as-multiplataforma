package com.example.myapplication.data.crypto

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG
import androidx.core.content.edit
import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.AppException
import dagger.hilt.android.qualifiers.ApplicationContext
import java.security.KeyStore
import java.util.Base64
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec
import javax.inject.Inject
import javax.inject.Singleton

/**
 * The vault key encrypted with an Android Keystore key that can only be used right after a
 * strong biometric check. The result lives in private SharedPreferences on this device only
 * (never in Firestore).
 */
@Singleton
class BiometricKeyStore @Inject constructor(@ApplicationContext context: Context) {
    private val appContext = context.applicationContext
    private val prefs = appContext.getSharedPreferences("biometric_unlock", Context.MODE_PRIVATE)
    private val keyStore by lazy { KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) } }

    fun isAvailable(): Boolean =
        BiometricManager.from(appContext).canAuthenticate(BIOMETRIC_STRONG) == BiometricManager.BIOMETRIC_SUCCESS

    fun isEnabled(uid: String): Boolean = prefs.contains(prefKey(uid))

    fun cipherForEnrollment(uid: String): Cipher =
        Cipher.getInstance(TRANSFORMATION).apply { init(Cipher.ENCRYPT_MODE, createKey(uid)) }

    fun enable(uid: String, authenticatedCipher: Cipher, vaultKey: SecretKey) {
        val encrypted = authenticatedCipher.iv + authenticatedCipher.doFinal(vaultKey.encoded)
        prefs.edit { putString(prefKey(uid), Base64.getEncoder().encodeToString(encrypted)) }
    }

    /** Null when biometric unlock isn't set up; throws when the enrolled biometrics changed. */
    fun cipherForUnlock(uid: String): Cipher? {
        val stored = load(uid) ?: return null
        val key = keyStore.getKey(alias(uid), null) as? SecretKey
        if (key == null) {
            disable(uid)
            return null
        }
        return try {
            Cipher.getInstance(TRANSFORMATION).apply {
                init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(TAG_BITS, stored, 0, IV_BYTES))
            }
        } catch (e: KeyPermanentlyInvalidatedException) {
            disable(uid)
            throw AppException(AppError.BiometricInvalidated, e)
        }
    }

    fun unlock(uid: String, authenticatedCipher: Cipher): SecretKey {
        val stored = checkNotNull(load(uid)) { "Biometric unlock is not enabled" }
        val raw = authenticatedCipher.doFinal(stored, IV_BYTES, stored.size - IV_BYTES)
        return SecretKeySpec(raw, "AES").also { raw.fill(0) }
    }

    fun disable(uid: String) {
        prefs.edit { remove(prefKey(uid)) }
        if (keyStore.containsAlias(alias(uid))) keyStore.deleteEntry(alias(uid))
    }

    private fun load(uid: String): ByteArray? =
        prefs.getString(prefKey(uid), null)?.let { Base64.getDecoder().decode(it) }

    private fun createKey(uid: String): SecretKey {
        val spec = KeyGenParameterSpec.Builder(
            alias(uid),
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .setUserAuthenticationRequired(true)
            .setInvalidatedByBiometricEnrollment(true)
            .apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    setUserAuthenticationParameters(0, KeyProperties.AUTH_BIOMETRIC_STRONG)
                } else {
                    @Suppress("DEPRECATION")
                    setUserAuthenticationValidityDurationSeconds(-1)
                }
            }
            .build()
        return KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE).run {
            init(spec)
            generateKey()
        }
    }

    private fun alias(uid: String) = "vault_biometric_$uid"
    private fun prefKey(uid: String) = "vault_key_$uid"

    private companion object {
        const val ANDROID_KEYSTORE = "AndroidKeyStore"
        const val TRANSFORMATION = "AES/GCM/NoPadding"
        const val IV_BYTES = 12
        const val TAG_BITS = 128
    }
}
