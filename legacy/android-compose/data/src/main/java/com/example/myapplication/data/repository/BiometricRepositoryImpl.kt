package com.example.myapplication.data.repository

import com.example.myapplication.data.crypto.BiometricKeyStore
import com.example.myapplication.data.session.VaultSession
import com.example.myapplication.domain.error.AppError
import com.example.myapplication.domain.error.AppException
import com.example.myapplication.domain.model.BiometricStatus
import com.example.myapplication.domain.repository.BiometricRepository
import java.security.GeneralSecurityException
import javax.crypto.Cipher
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class BiometricRepositoryImpl @Inject constructor(
    private val keyStore: BiometricKeyStore,
    private val session: VaultSession,
) : BiometricRepository {

    override fun status(userId: String) =
        BiometricStatus(available = keyStore.isAvailable(), enabled = keyStore.isEnabled(userId))

    override fun enrollmentCipher(userId: String): Cipher = keyStore.cipherForEnrollment(userId)

    override fun enable(userId: String, authorizedCipher: Cipher) {
        val vault = session.current?.takeIf { it.uid == userId } ?: throw AppException(AppError.VaultLocked)
        keyStore.enable(userId, authorizedCipher, vault.key)
    }

    override fun unlockCipher(userId: String): Cipher? = keyStore.cipherForUnlock(userId)

    override fun unlock(userId: String, authorizedCipher: Cipher) {
        val key = try {
            keyStore.unlock(userId, authorizedCipher)
        } catch (e: GeneralSecurityException) {
            throw AppException(AppError.BiometricFailed, e)
        } catch (e: IllegalStateException) {
            throw AppException(AppError.BiometricFailed, e)
        }
        session.open(userId, key)
    }

    override fun disable(userId: String) = keyStore.disable(userId)
}
