package com.example.myapplication.designsystem.component

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.myapplication.designsystem.icon.BovedaIcons
import com.example.myapplication.designsystem.theme.BovedaMotion
import kotlinx.coroutines.delay

/**
 * The brief "copied" acknowledgement next to whatever was copied: [confirm] shows it and it clears
 * itself; copying again restarts the hold. The snackbar says where the secret went; this says which
 * one, right under the thumb.
 */
@Stable
class CopyConfirmation internal constructor() {
    var isShowing by mutableStateOf(false)
        private set

    internal var count by mutableIntStateOf(0)
        private set

    fun confirm() {
        isShowing = true
        count++
    }

    internal fun clear() {
        isShowing = false
    }
}

@Composable
fun rememberCopyConfirmation(holdMillis: Long = 1_600): CopyConfirmation {
    val confirmation = remember { CopyConfirmation() }
    val haptics = LocalHapticFeedback.current
    LaunchedEffect(confirmation.count) {
        if (!confirmation.isShowing) return@LaunchedEffect
        haptics.performHapticFeedback(HapticFeedbackType.Confirm)
        delay(holdMillis)
        confirmation.clear()
    }
    return confirmation
}

/** The copy icon, swapped for a check while [copied]. */
@Composable
fun CopyIcon(copied: Boolean, contentDescription: String?, modifier: Modifier = Modifier) {
    AnimatedContent(
        targetState = copied,
        transitionSpec = {
            (scaleIn(tween(BovedaMotion.MEDIUM, easing = BovedaMotion.EmphasizedDecelerate), initialScale = 0.4f) +
                fadeIn(tween(BovedaMotion.SHORT))) togetherWith
                (scaleOut(tween(100), targetScale = 0.4f) + fadeOut(tween(100)))
        },
        contentAlignment = Alignment.Center,
        label = "copy-icon",
        modifier = modifier.semantics { if (contentDescription != null) this.contentDescription = contentDescription },
    ) { showCheck ->
        Icon(painterResource(if (showCheck) BovedaIcons.Check else BovedaIcons.Copy), contentDescription = null)
    }
}

/** Icon and label of a copy button; the label rolls up to [copiedLabel] while [copied]. */
@Composable
fun RowScope.CopyButtonContent(
    copied: Boolean,
    label: String,
    copiedLabel: String,
    style: TextStyle = LocalTextStyle.current,
    gap: Dp = 8.dp,
) {
    CopyIcon(copied, contentDescription = null)
    Spacer(Modifier.width(gap))
    AnimatedContent(
        targetState = copied,
        transitionSpec = {
            (slideInVertically(tween(BovedaMotion.MEDIUM, easing = BovedaMotion.EmphasizedDecelerate)) { it / 2 } +
                fadeIn(tween(BovedaMotion.SHORT))) togetherWith
                (slideOutVertically(tween(100)) { -it / 2 } + fadeOut(tween(100))) using
                SizeTransform(clip = false)
        },
        label = "copy-label",
    ) { showCopied ->
        Text(if (showCopied) copiedLabel else label, style = style)
    }
}
