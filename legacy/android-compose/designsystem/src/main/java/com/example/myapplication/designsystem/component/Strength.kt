package com.example.myapplication.designsystem.component

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.designsystem.theme.BovedaTheme

const val STRENGTH_LEVELS = 5

/** Five segments; [level] 0 (very weak) to 4 (very strong), or -1 for nothing to rate yet. */
@Composable
fun StrengthMeter(level: Int, modifier: Modifier = Modifier) {
    val colors = BovedaTheme.colors.strength
    val empty = MaterialTheme.colorScheme.surfaceContainerHighest
    // The meter rises from the left when the password gets stronger and drains from the right
    // when it gets weaker, one segment after another, so the direction of a change reads at once.
    val previous = remember { intArrayOf(level) }
    val rising = level >= previous[0]
    SideEffect { previous[0] = level }
    Row(
        modifier = modifier.fillMaxWidth().height(6.dp).clearAndSetSemantics { },
        horizontalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        repeat(STRENGTH_LEVELS) { index ->
            val target = if (level >= 0 && index <= level) colors[level] else empty
            val order = if (rising) index else STRENGTH_LEVELS - 1 - index
            val color by animateColorAsState(
                target,
                tween(BovedaMotion.SHORT + 50, delayMillis = order * SEGMENT_STAGGER_MS, easing = BovedaMotion.Standard),
                label = "strength",
            )
            Box(Modifier.weight(1f).fillMaxHeight().clip(RoundedCornerShape(3.dp)).background(color))
        }
    }
}

private const val SEGMENT_STAGGER_MS = 30

/**
 * Meter plus its reading: the verdict in the level's colour, the entropy as a measurement, and
 * a plain-language line such as the estimated time to crack it.
 */
@Composable
fun StrengthIndicator(
    level: Int,
    verdict: String,
    modifier: Modifier = Modifier,
    measurement: String? = null,
    detail: String? = null,
) {
    val target = if (level >= 0) BovedaTheme.colors.strength[level] else MaterialTheme.colorScheme.onSurfaceVariant
    val color by animateColorAsState(target, tween(BovedaMotion.MEDIUM, easing = BovedaMotion.Standard), label = "verdict")
    Column(
        modifier.semantics(mergeDescendants = true) {
            contentDescription = listOfNotNull(verdict, measurement, detail).joinToString(". ")
        },
    ) {
        StrengthMeter(level)
        Spacer(Modifier.height(8.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(verdict, style = MaterialTheme.typography.labelLarge, color = color)
            if (measurement != null) {
                Text(
                    "  ·  $measurement",
                    style = BovedaTheme.secret.small,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
        if (detail != null) {
            Text(detail, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun StrengthIndicatorPreview() {
    BovedaTheme {
        StrengthIndicator(level = 4, verdict = "Muy fuerte", measurement = "128 bits", detail = "Descifrarla llevaría siglos")
    }
}
