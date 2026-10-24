package com.example.myapplication.presentation

import androidx.compose.ui.text.font.FontWeight
import com.example.myapplication.presentation.vault.list.highlightMatches
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class SearchHighlightTest {
    private fun boldRanges(text: String, query: String) =
        highlightMatches(text, query).spanStyles.filter { it.item.fontWeight == FontWeight.Bold }.map { it.start until it.end }

    @Test
    fun marksWhyARowMatched() {
        assertEquals(listOf(4 until 6), boldRanges("ana@correo.es", "co"))
    }

    @Test
    fun ignoresCaseAndAccentsLikeTheSearch() {
        assertEquals(listOf(0 until 10), boldRanges("Telefónica", "TELEFONICA"))
    }

    @Test
    fun marksEveryOccurrenceAndNothingForABlankQuery() {
        assertEquals(listOf(0 until 1, 2 until 3), boldRanges("aba", "a"))
        assertTrue(boldRanges("Banco", "  ").isEmpty())
    }
}
