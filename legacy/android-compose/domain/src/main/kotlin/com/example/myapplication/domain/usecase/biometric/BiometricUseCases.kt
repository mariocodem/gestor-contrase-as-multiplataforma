package com.example.myapplication.domain.usecase.biometric

import com.example.myapplication.domain.error.resultOf
import com.example.myapplication.domain.model.BiometricStatus
import com.example.myapplication.domain.repository.BiometricRepository
import javax.crypto.Cipher
import javax.inject.Inject

class GetBiometricStatusUseCase @Inject constructor(private val biometrics: BiometricRepository) {
    operator fun invoke(userId: String): BiometricStatus = biometrics.status(userId)
}

/** Step 1 of turning biometric unlock on: a cipher for the UI to authorize with a prompt. */
class PrepareBiometricEnrollmentUseCase @Inject constructor(private val biometrics: BiometricRepository) {
    operator fun invoke(userId: String): Result<Cipher> = resultOf { biometrics.enrollmentCipher(userId) }
}

/** Step 2: the prompt succeeded, so remember the vault key behind the authorized cipher. */
class EnableBiometricUnlockUseCase @Inject constructor(private val biometrics: BiometricRepository) {
    operator fun invoke(userId: String, authorizedCipher: Cipher): Result<Unit> =
        resultOf { biometrics.enable(userId, authorizedCipher) }
}

/** Null inside the result means biometric unlock isn't set up for this user. */
class PrepareBiometricUnlockUseCase @Inject constructor(private val biometrics: BiometricRepository) {
    operator fun invoke(userId: String): Result<Cipher?> = resultOf { biometrics.unlockCipher(userId) }
}

class UnlockWithBiometricsUseCase @Inject constructor(private val biometrics: BiometricRepository) {
    operator fun invoke(userId: String, authorizedCipher: Cipher): Result<Unit> =
        resultOf { biometrics.unlock(userId, authorizedCipher) }
}

class DisableBiometricUnlockUseCase @Inject constructor(private val biometrics: BiometricRepository) {
    operator fun invoke(userId: String) = biometrics.disable(userId)
}
