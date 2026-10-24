package com.example.myapplication.domain.generator

import com.example.myapplication.domain.model.PasswordOptions
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.random.Random

class PasswordGeneratorTest {
    private val generator = PasswordGenerator()

    @Test
    fun generate_respectsLengthAndIncludesEveryEnabledSet() {
        repeat(200) {
            val password = generator.generate(PasswordOptions(length = 8))

            assertEquals(8, password.length)
            assertTrue(password.any(Char::isUpperCase))
            assertTrue(password.any(Char::isLowerCase))
            assertTrue(password.any(Char::isDigit))
            assertTrue(password.any { !it.isLetterOrDigit() })
        }
    }

    @Test
    fun generate_onlyUsesEnabledSets() {
        val password = generator.generate(PasswordOptions(length = 64, uppercase = false, symbols = false))

        assertTrue(password.all { it.isLowerCase() || it.isDigit() })
    }

    @Test
    fun generate_avoidsAmbiguousCharactersWhenAsked() {
        repeat(100) {
            val password = generator.generate(PasswordOptions(length = 64, avoidAmbiguous = true))

            assertTrue(password.none { it in PasswordGenerator.AMBIGUOUS })
        }
    }

    @Test
    fun generate_clampsLengthToTheSupportedRange() {
        assertEquals(PasswordOptions.MIN_LENGTH, generator.generate(PasswordOptions(length = 2)).length)
        assertEquals(PasswordOptions.MAX_LENGTH, generator.generate(PasswordOptions(length = 500)).length)
    }

    @Test
    fun generate_isDeterministicForAGivenRandomSource() {
        val first = PasswordGenerator(Random(42)::nextInt).generate(PasswordOptions())
        val second = PasswordGenerator(Random(42)::nextInt).generate(PasswordOptions())

        assertEquals(first, second)
    }

    @Test
    fun poolSize_shrinksWhenAmbiguousCharactersAreExcluded() {
        assertEquals(26 + 26 + 10 + 24, PasswordGenerator.poolSize(PasswordOptions()))
        assertEquals(24 + 24 + 8 + 20, PasswordGenerator.poolSize(PasswordOptions(avoidAmbiguous = true)))
    }
}
