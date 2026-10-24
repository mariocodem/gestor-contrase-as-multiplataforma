package com.example.myapplication.presentation.vault.list

import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import java.text.Normalizer

private val DIACRITICS = "\\p{Mn}+".toRegex()

/**
 * [text] with every match of [query] set in bold, matched the way the vault search matches
 * (ignoring case and accents), so a row found through its username shows why it is there.
 */
fun highlightMatches(text: String, query: String): AnnotatedString {
    val needle = query.trim().foldedForSearch()
    if (needle.isEmpty()) return AnnotatedString(text)
    // One folded character per original one keeps match positions valid in [text].
    val folded = buildString(text.length) {
        text.forEach { append(it.toString().foldedForSearch().firstOrNull() ?: '\u0000') }
    }
    return buildAnnotatedString {
        append(text)
        var from = 0
        while (true) {
            val at = folded.indexOf(needle, from)
            if (at < 0) break
            addStyle(SpanStyle(fontWeight = FontWeight.Bold), at, at + needle.length)
            from = at + needle.length
        }
    }
}

private fun String.foldedForSearch(): String =
    Normalizer.normalize(this, Normalizer.Form.NFD).replace(DIACRITICS, "").lowercase()
