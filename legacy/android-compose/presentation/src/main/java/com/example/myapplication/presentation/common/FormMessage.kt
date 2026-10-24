package com.example.myapplication.presentation.common

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.myapplication.designsystem.theme.BovedaMotion

/**
 * An error or notice under a form. It opens its own line instead of shoving the buttons down in
 * one frame, keeps its text while closing, and is announced by TalkBack when it appears.
 */
@Composable
fun FormMessage(text: UiText?, color: Color, modifier: Modifier = Modifier, topPadding: Dp = 8.dp) {
    val last = remember { arrayOfNulls<UiText>(1) }
    if (text != null) last[0] = text
    AnimatedVisibility(
        visible = text != null,
        enter = expandVertically(tween(BovedaMotion.MEDIUM, easing = BovedaMotion.EmphasizedDecelerate)) +
            fadeIn(tween(BovedaMotion.MEDIUM, delayMillis = 50)),
        exit = shrinkVertically(tween(BovedaMotion.SHORT, easing = BovedaMotion.EmphasizedAccelerate)) + fadeOut(tween(100)),
        modifier = modifier.fillMaxWidth(),
    ) {
        last[0]?.let {
            Text(
                it.asString(),
                style = MaterialTheme.typography.bodyMedium,
                color = color,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = topPadding)
                    .semantics { liveRegion = LiveRegionMode.Polite },
            )
        }
    }
}
