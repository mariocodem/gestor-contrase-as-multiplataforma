package com.example.myapplication.domain.generator

import com.example.myapplication.domain.model.PasswordOptions
import com.example.myapplication.domain.model.StrengthLevel
import com.example.myapplication.domain.model.StrengthWarning
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.log2

class PasswordStrengthEstimatorTest {
    private val estimator = PasswordStrengthEstimator()

    @Test
    fun generatorSettings_areRatedByLengthTimesPoolEntropy() {
        val strength = estimator.estimate(PasswordOptions(length = 20))

        assertEquals(20 * log2(86.0), strength.entropyBits, 1e-9)
        assertEquals(StrengthLevel.VERY_STRONG, strength.level)
    }

    @Test
    fun shortDigitsOnlySettings_areWeak() {
        val options = PasswordOptions(length = 8, uppercase = false, lowercase = false, symbols = false)

        assertEquals(StrengthLevel.VERY_WEAK, estimator.estimate(options).level)
    }

    @Test
    fun commonPasswords_areVeryWeakEvenWithLeetOrSuffixes() {
        listOf("password", "P@ssw0rd", "qwerty123", "Contraseña2024!", "123456").forEach { password ->
            val strength = estimator.estimate(password)

            assertEquals(password, StrengthLevel.VERY_WEAK, strength.level)
            assertTrue(password, StrengthWarning.COMMON_PASSWORD in strength.warnings)
        }
    }

    @Test
    fun patterns_costMuchLessThanRandomCharacters() {
        val patterned = estimator.estimate("abcdefgh12345678")
        val random = estimator.estimate("q7Rk2mZp9xLw4nVb")

        assertTrue(StrengthWarning.SEQUENCE in patterned.warnings)
        assertTrue(patterned.entropyBits < random.entropyBits / 3)
        assertEquals(StrengthLevel.VERY_STRONG, random.level)
    }

    @Test
    fun repeatsDatesAndKeyboardRuns_areFlagged() {
        assertTrue(StrengthWarning.REPEATS in estimator.estimate("zzzzzzzzT!").warnings)
        assertTrue(StrengthWarning.DATE in estimator.estimate("Lucia1987!").warnings)
        assertTrue(StrengthWarning.KEYBOARD_PATTERN in estimator.estimate("Kasdfgh!9").warnings)
    }

    @Test
    fun crackTime_doublesWithEveryExtraBit() {
        val shorter = estimator.estimate(PasswordOptions(length = 10))
        val longer = estimator.estimate(PasswordOptions(length = 11))
        val bitsAdded = longer.entropyBits - shorter.entropyBits

        assertEquals(Math.pow(2.0, bitsAdded), longer.crackTimeSeconds / shorter.crackTimeSeconds, 1e-6)
    }

    @Test
    fun emptyPassword_hasNoStrength() {
        assertEquals(0.0, estimator.estimate("").entropyBits, 0.0)
    }
}
