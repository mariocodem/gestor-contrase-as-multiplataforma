package com.example.myapplication.domain.model

data class PasswordOptions(
    val length: Int = DEFAULT_LENGTH,
    val uppercase: Boolean = true,
    val lowercase: Boolean = true,
    val digits: Boolean = true,
    val symbols: Boolean = true,
    /** Leaves out characters that are easy to misread or mistype, such as O/0 and l/1. */
    val avoidAmbiguous: Boolean = false,
) {
    val enabledSetCount: Int get() = listOf(uppercase, lowercase, digits, symbols).count { it }

    companion object {
        const val MIN_LENGTH = 8
        const val MAX_LENGTH = 64
        const val DEFAULT_LENGTH = 20
    }
}
