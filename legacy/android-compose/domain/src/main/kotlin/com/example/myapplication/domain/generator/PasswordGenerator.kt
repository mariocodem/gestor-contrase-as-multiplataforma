package com.example.myapplication.domain.generator

import com.example.myapplication.domain.model.PasswordOptions
import java.security.SecureRandom
import javax.inject.Inject

/** Uniformly distributed random indexes: [SecureRandom] in the app, seeded in tests. */
fun interface RandomSource {
    fun nextInt(bound: Int): Int
}

class PasswordGenerator(private val random: RandomSource) {

    @Inject
    constructor() : this(SecureRandom().let { secure -> RandomSource(secure::nextInt) })

    /** A password with at least one character from every enabled set. */
    fun generate(options: PasswordOptions): String {
        val sets = characterSets(options)
        require(sets.isNotEmpty()) { "At least one character set must be enabled" }
        val length = options.length.coerceIn(PasswordOptions.MIN_LENGTH, PasswordOptions.MAX_LENGTH)
        val pool = sets.joinToString("")

        val chars = CharArray(length)
        sets.forEachIndexed { i, set -> chars[i] = set[random.nextInt(set.length)] }
        for (i in sets.size until length) chars[i] = pool[random.nextInt(pool.length)]
        // Fisher-Yates, so the guaranteed characters don't always sit at the start.
        for (i in length - 1 downTo 1) {
            val j = random.nextInt(i + 1)
            chars[i] = chars[j].also { chars[j] = chars[i] }
        }
        return String(chars)
    }

    companion object {
        const val UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        const val LOWERCASE = "abcdefghijklmnopqrstuvwxyz"
        const val DIGITS = "0123456789"
        const val SYMBOLS = "!@#\$%^&*()-_=+[]{};:,.?/"

        /** Easy to confuse with each other in many fonts, or to miss when typing by hand. */
        const val AMBIGUOUS = "IlOo01;:,."

        fun characterSets(options: PasswordOptions): List<String> =
            listOfNotNull(
                UPPERCASE.takeIf { options.uppercase },
                LOWERCASE.takeIf { options.lowercase },
                DIGITS.takeIf { options.digits },
                SYMBOLS.takeIf { options.symbols },
            ).map { set -> if (options.avoidAmbiguous) set.filterNot { it in AMBIGUOUS } else set }

        fun poolSize(options: PasswordOptions): Int = characterSets(options).sumOf { it.length }
    }
}
