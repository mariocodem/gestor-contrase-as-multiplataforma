package com.example.myapplication.designsystem.component

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Spacer
import androidx.compose.material3.LocalContentColor
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.clipRect
import androidx.compose.ui.graphics.takeOrElse
import androidx.compose.ui.layout.layout
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.text
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.TextMeasurer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Constraints
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.designsystem.theme.BovedaTheme
import kotlin.math.max
import kotlin.math.min

private const val MASK_DOT = '•'

/** How long one character takes to roll through its window. */
private const val WINDOW_MS = 180f

/** Settled: every character shows its target. */
private const val SETTLED = Float.MAX_VALUE

/**
 * Secret text that changes like the pin tumblers of a lock: when [text] changes, each character
 * rolls up through its own window, left to right, and characters that stay the same don't move.
 * Digits and symbols take their own colours, as in [colorByCharacterClass].
 *
 * The style must be monospaced: every character gets the same cell, so the grid wraps the way
 * the text would. [animate] false swaps instantly (while dragging a slider, for instance).
 * [contentDescription] replaces the text for accessibility, for a masked secret.
 */
@Composable
fun TumblerText(
    text: String,
    modifier: Modifier = Modifier,
    style: TextStyle = BovedaTheme.secret.medium,
    color: Color = Color.Unspecified,
    animate: Boolean = true,
    contentDescription: String? = null,
) {
    val base = color.takeOrElse { style.color.takeOrElse { LocalContentColor.current } }
    val digit = BovedaTheme.colors.secretDigit
    val symbol = BovedaTheme.colors.secretSymbol
    val measurer = rememberTextMeasurer(cacheSize = 0)
    val glyphs = remember(measurer, style, base, digit, symbol) {
        GlyphCache(measurer, style) { char ->
            when {
                char == MASK_DOT -> base
                char.isDigit() -> digit
                !char.isLetterOrDigit() && !char.isWhitespace() -> symbol
                else -> base
            }
        }
    }

    var from by remember { mutableStateOf(text) }
    var to by remember { mutableStateOf(text) }
    val elapsed = remember { Animatable(SETTLED) }
    val animateChange by rememberUpdatedState(animate)

    // Keyed on the text only, so toggling [animate] never cancels a roll halfway.
    LaunchedEffect(text) {
        if (text == to) return@LaunchedEffect
        if (!animateChange) {
            from = text
            to = text
            elapsed.snapTo(SETTLED)
            return@LaunchedEffect
        }
        from = to
        to = text
        elapsed.snapTo(0f)
        val duration = rollDuration(max(from.length, to.length))
        elapsed.animateTo(duration, tween(duration.toInt(), easing = LinearEasing))
        elapsed.snapTo(SETTLED)
    }

    Spacer(
        modifier
            .semantics {
                if (contentDescription != null) {
                    this.contentDescription = contentDescription
                } else {
                    this.text = AnnotatedString(text)
                }
            }
            .layout { measurable, constraints ->
                val cell = glyphs.cell
                val length = max(to.length, 1)
                val maxColumns = if (constraints.hasBoundedWidth) max(1, constraints.maxWidth / cell.width) else length
                val rows = (length + maxColumns - 1) / maxColumns
                val width = (min(length, maxColumns) * cell.width).coerceIn(constraints.minWidth, constraints.maxWidth)
                val height = (rows * cell.height).coerceIn(constraints.minHeight, constraints.maxHeight)
                val placeable = measurable.measure(Constraints.fixed(width, height))
                layout(width, height) { placeable.place(0, 0) }
            }
            .drawBehind { drawTumblers(glyphs, from, to, elapsed.value) },
    )
}

private fun rollDuration(length: Int): Float = WINDOW_MS + stagger(length) * (max(length, 1) - 1)

/** Short secrets ripple visibly; long ones keep the whole roll near a third of a second. */
private fun stagger(length: Int): Float = min(16f, 160f / max(length, 1))

private fun DrawScope.drawTumblers(glyphs: GlyphCache, from: String, to: String, elapsed: Float) {
    val cellWidth = glyphs.cell.width.toFloat()
    val cellHeight = glyphs.cell.height.toFloat()
    val columns = max(1, ((size.width + 0.5f) / cellWidth).toInt())
    val rows = max(1, ((size.height + 0.5f) / cellHeight).toInt())
    val count = max(from.length, to.length)
    val stagger = stagger(count)

    for (index in 0 until count) {
        val row = index / columns
        if (row >= rows) break
        val x = (index % columns) * cellWidth
        val y = row * cellHeight
        val old = from.getOrNull(index)
        val new = to.getOrNull(index)
        val progress = ((elapsed - index * stagger) / WINDOW_MS).coerceIn(0f, 1f)
        when {
            old == new || progress >= 1f -> new?.let { drawText(glyphs[it], topLeft = Offset(x, y)) }
            progress <= 0f -> old?.let { drawText(glyphs[it], topLeft = Offset(x, y)) }
            else -> {
                val eased = BovedaMotion.EmphasizedDecelerate.transform(progress)
                // Each cell is its own window: the old pin leaves upwards as the new one rises in.
                clipRect(x, y, x + cellWidth, y + cellHeight) {
                    old?.let { drawText(glyphs[it], topLeft = Offset(x, y - eased * cellHeight), alpha = 1f - eased) }
                    new?.let { drawText(glyphs[it], topLeft = Offset(x, y + (1f - eased) * cellHeight), alpha = eased) }
                }
            }
        }
    }
}

/** One measured layout per character, coloured by its class. */
private class GlyphCache(
    private val measurer: TextMeasurer,
    private val style: TextStyle,
    private val colorFor: (Char) -> Color,
) {
    private val layouts = HashMap<Char, TextLayoutResult>()

    operator fun get(char: Char): TextLayoutResult = layouts.getOrPut(char) {
        measurer.measure(char.toString(), style.copy(color = colorFor(char)), softWrap = false, maxLines = 1)
    }

    /** The mono advance and line height every character shares. */
    val cell = get('0').size
}

@Preview(showBackground = true)
@Composable
private fun TumblerTextPreview() {
    BovedaTheme { TumblerText("k7#Vq2!mZp9@Lw4x") }
}
