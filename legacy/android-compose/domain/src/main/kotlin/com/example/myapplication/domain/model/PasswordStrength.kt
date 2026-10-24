package com.example.myapplication.domain.model

enum class StrengthLevel { VERY_WEAK, WEAK, FAIR, STRONG, VERY_STRONG }

/** Patterns that make a hand-picked password easier to guess than its length suggests. */
enum class StrengthWarning {
    TOO_SHORT,
    COMMON_PASSWORD,
    COMMON_WORD,
    DATE,
    REPEATS,
    SEQUENCE,
    KEYBOARD_PATTERN,
    SINGLE_CHARACTER_TYPE,
}

data class PasswordStrength(
    val entropyBits: Double,
    val level: StrengthLevel,
    /** Average time an offline attacker needs to guess it, in seconds. */
    val crackTimeSeconds: Double,
    val warnings: Set<StrengthWarning> = emptySet(),
) {
    companion object {
        val EMPTY = PasswordStrength(entropyBits = 0.0, level = StrengthLevel.VERY_WEAK, crackTimeSeconds = 0.0)
    }
}

data class GeneratedPassword(val value: String, val strength: PasswordStrength)
