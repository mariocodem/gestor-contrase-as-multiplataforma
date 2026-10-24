package com.example.myapplication.domain.generator

import com.example.myapplication.domain.model.PasswordOptions
import com.example.myapplication.domain.model.PasswordStrength
import com.example.myapplication.domain.model.StrengthLevel
import com.example.myapplication.domain.model.StrengthWarning
import javax.inject.Inject
import kotlin.math.log2
import kotlin.math.pow

/**
 * Entropy-based strength. Generated passwords are rated by their generator settings (what an
 * attacker who knows them faces); hand-picked ones get a rough estimate that charges almost
 * nothing for the patterns guessers try first: common passwords and words, dates, repeats,
 * sequences and keyboard runs.
 */
class PasswordStrengthEstimator @Inject constructor() {

    fun estimate(options: PasswordOptions): PasswordStrength {
        val pool = PasswordGenerator.poolSize(options)
        if (pool == 0) return PasswordStrength.EMPTY
        val length = options.length.coerceIn(PasswordOptions.MIN_LENGTH, PasswordOptions.MAX_LENGTH)
        return strengthOf(length * log2(pool.toDouble()), emptySet())
    }

    fun estimate(password: String): PasswordStrength {
        if (password.isEmpty()) return PasswordStrength.EMPTY
        val lower = password.lowercase()
        val unleet = lower.map { LEET[it] ?: it }.joinToString("")
        val pool = characterPool(password)
        val warnings = mutableSetOf<StrengthWarning>()
        if (password.length < RECOMMENDED_LENGTH) warnings += StrengthWarning.TOO_SHORT
        if (pool.classes == 1 && password.length < LONG_ENOUGH) {
            warnings += StrengthWarning.SINGLE_CHARACTER_TYPE
        }

        val variants = listOf(lower, unleet).flatMap { listOf(it, it.trimEnd { c -> !c.isLetter() }) }
        if (variants.any { it.isNotEmpty() && it in COMMON_PASSWORDS }) {
            warnings += StrengthWarning.COMMON_PASSWORD
            return strengthOf(COMMON_PASSWORD_BITS, warnings)
        }

        val cost = DoubleArray(lower.length) { log2(pool.size.toDouble()) }
        if (chargeWords(lower, unleet, cost)) warnings += StrengthWarning.COMMON_WORD
        if (chargeDates(lower, cost)) warnings += StrengthWarning.DATE
        if (chargeRuns(lower, cost) { a, b, _ -> a == b }) warnings += StrengthWarning.REPEATS
        if (chargeRuns(lower, cost, ::continuesSequence)) warnings += StrengthWarning.SEQUENCE
        if (chargeKeyboardRuns(lower, cost)) warnings += StrengthWarning.KEYBOARD_PATTERN
        return strengthOf(cost.sum(), warnings)
    }

    private fun strengthOf(bits: Double, warnings: Set<StrengthWarning>): PasswordStrength {
        val level = when {
            StrengthWarning.COMMON_PASSWORD in warnings -> StrengthLevel.VERY_WEAK
            bits < 28 -> StrengthLevel.VERY_WEAK
            bits < 36 -> StrengthLevel.WEAK
            bits < 60 -> StrengthLevel.FAIR
            bits < 80 -> StrengthLevel.STRONG
            else -> StrengthLevel.VERY_STRONG
        }
        // On average the attacker finds it after trying half of the possibilities.
        val seconds = 2.0.pow(bits - 1) / GUESSES_PER_SECOND
        return PasswordStrength(bits, level, seconds, warnings)
    }

    private class Pool(val size: Int, val classes: Int)

    private fun characterPool(password: String): Pool {
        val sizes = listOf(
            26.takeIf { password.any { it in 'a'..'z' } },
            26.takeIf { password.any { it in 'A'..'Z' } },
            10.takeIf { password.any { it in '0'..'9' } },
            33.takeIf { password.any { it.code in 32..126 && !it.isLetterOrDigit() } },
            // Accented letters, ñ, emoji: a rough allowance, attackers try the common ones first.
            40.takeIf { password.any { it.code > 126 } },
        ).filterNotNull()
        return Pool(size = sizes.sum(), classes = sizes.size)
    }

    /** Each common word costs [WORD_BITS] in total instead of per character. */
    private fun chargeWords(lower: String, unleet: String, cost: DoubleArray): Boolean {
        val covered = BooleanArray(cost.size)
        var found = false
        for (word in COMMON_WORDS) {
            for (text in listOf(lower, unleet)) {
                var start = text.indexOf(word)
                while (start >= 0) {
                    val range = start until start + word.length
                    if (range.none { covered[it] }) {
                        range.forEach { covered[it] = true; cost[it] = 0.0 }
                        cost[start] = WORD_BITS
                        found = true
                    }
                    start = text.indexOf(word, start + 1)
                }
            }
        }
        return found
    }

    private fun chargeDates(lower: String, cost: DoubleArray): Boolean {
        var found = false
        for (match in YEAR.findAll(lower)) {
            match.range.forEach { cost[it] = 0.0 }
            cost[match.range.first] = DATE_BITS
            found = true
        }
        return found
    }

    /** Runs of 3+ characters where each continues the previous: the run costs about one character. */
    private fun chargeRuns(text: String, cost: DoubleArray, continues: (Char, Char, Int) -> Boolean): Boolean {
        var found = false
        var start = 0
        var step = 0
        for (i in 1..text.length) {
            val delta = if (i < text.length) text[i] - text[i - 1] else 0
            val pairContinues = i < text.length && continues(text[i], text[i - 1], delta)
            if (pairContinues && (i - start == 1 || delta == step)) {
                if (i - start == 1) step = delta
                continue
            }
            if (i - start >= 3) {
                for (j in start + 1 until i) cost[j] = minOf(cost[j], PATTERN_BITS)
                found = true
            }
            // A pair that breaks the step ("abcb") can still open the next run.
            if (pairContinues) {
                start = i - 1
                step = delta
            } else {
                start = i
            }
        }
        return found
    }

    private fun continuesSequence(current: Char, previous: Char, delta: Int): Boolean =
        (delta == 1 || delta == -1) &&
            ((current.isLetter() && previous.isLetter()) || (current.isDigit() && previous.isDigit()))

    private fun chargeKeyboardRuns(lower: String, cost: DoubleArray): Boolean {
        var found = false
        for (row in KEYBOARD_ROWS) {
            for (i in lower.indices) {
                val at = row.indexOf(lower[i])
                if (at < 0) continue
                var length = 1
                while (i + length < lower.length && at + length < row.length && row[at + length] == lower[i + length]) {
                    length++
                }
                if (length >= 4) {
                    for (j in i + 1 until i + length) cost[j] = minOf(cost[j], PATTERN_BITS)
                    found = true
                }
            }
        }
        return found
    }

    companion object {
        /** A GPU rig against a fast, unsalted hash: the worst realistic case for a leaked password. */
        const val GUESSES_PER_SECOND = 1e10

        const val RECOMMENDED_LENGTH = 12
        private const val LONG_ENOUGH = 20
        private const val COMMON_PASSWORD_BITS = 10.0
        private const val WORD_BITS = 9.0
        private const val DATE_BITS = 7.0
        private const val PATTERN_BITS = 1.0

        private val YEAR = Regex("(?<!\\d)(19|20)\\d\\d(?!\\d)")

        private val LEET = mapOf(
            '0' to 'o', '1' to 'i', '3' to 'e', '4' to 'a', '5' to 's', '7' to 't', '@' to 'a', '$' to 's',
        )

        private val KEYBOARD_ROWS = listOf("qwertyuiop", "asdfghjklñ", "zxcvbnm", "1234567890").flatMap {
            listOf(it, it.reversed())
        }

        private val COMMON_PASSWORDS = setOf(
            "123456", "123456789", "12345678", "12345", "1234567", "1234567890", "111111", "000000",
            "123123", "654321", "666666", "121212", "112233", "abc123", "123abc", "qwerty", "qwerty123",
            "qwertyuiop", "asdfgh", "asdfghjkl", "zxcvbnm", "password", "password1", "password123",
            "iloveyou", "admin", "welcome", "monkey", "dragon", "letmein", "football", "baseball",
            "sunshine", "princess", "master", "shadow", "superman", "batman", "starwars", "trustno1",
            "login", "secret", "contraseña", "contrasena", "clave", "secreto", "teamo", "tequiero",
            "hola", "amor", "españa", "espana", "barcelona", "madrid", "realmadrid", "futbol", "mexico",
            "argentina", "colombia", "chile", "peru", "pokemon", "minecraft",
        )

        private val COMMON_WORDS = listOf(
            "contraseña", "contrasena", "password", "barcelona", "realmadrid", "princess", "football",
            "sunshine", "superman", "starwars", "iloveyou", "argentina", "colombia", "pokemon",
            "minecraft", "familia", "invierno", "welcome", "letmein", "secreto", "tequiero", "monkey",
            "dragon", "master", "shadow", "batman", "futbol", "madrid", "españa", "espana", "mexico",
            "verano", "summer", "winter", "secret", "google", "admin", "teamo", "qwerty", "clave",
            "login", "hola", "amor", "love", "casa", "perro", "gato", "dios",
        ).sortedByDescending { it.length }
    }
}
