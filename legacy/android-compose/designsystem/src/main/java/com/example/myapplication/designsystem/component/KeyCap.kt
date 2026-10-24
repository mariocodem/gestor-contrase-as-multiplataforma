package com.example.myapplication.designsystem.component

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.keyframes
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.CompositingStrategy
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.graphics.drawscope.withTransform
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.myapplication.designsystem.theme.AtkinsonNext
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.designsystem.theme.BovedaTheme
import com.example.myapplication.designsystem.theme.KeyCapColor
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.launch

private const val HEAD = 0.84f

/** The ring hole's centre, as a fraction of the cap's height: the key hangs from here. */
private const val RING_Y = HEAD * 0.19f

/** Lets the lock screen fade in before the shackle drops, so the click is seen. */
private const val CLOSE_DELAY_MS = 220

/**
 * An account's identity: an anodized key cap with a punched ring hole and the stamped initial of
 * [label]. The hue is derived from the label, so an account wears the same cap on every screen.
 * Decorative for accessibility; the label is always readable next to it.
 */
@Composable
fun KeyCap(label: String, modifier: Modifier = Modifier, size: Dp = 40.dp) {
    val color = keyCapColorFor(label)
    val initial = remember(label) { label.trim().firstOrNull()?.uppercase() ?: "?" }
    val measurer = rememberTextMeasurer()

    Canvas(modifier.size(size).graphicsLayer(compositingStrategy = CompositingStrategy.Offscreen)) {
        drawKeyCap(color.cap)
        // Sized from the drawn cap, not from the system font size: the cap is an icon, and it keeps
        // its proportions while it travels between the list row and the detail header.
        val style = TextStyle(
            fontFamily = AtkinsonNext,
            fontWeight = FontWeight.Bold,
            fontSize = (this.size.width * 0.40f).toSp(),
            color = color.stamp,
        )
        val text = measurer.measure(initial, style)
        drawText(
            text,
            topLeft = Offset((this.size.width - text.size.width) / 2f, this.size.height * HEAD * 0.58f - text.size.height / 2f),
        )
    }
}

/**
 * The app's mark: the same key cap in graphite with a brass padlock, for the sign-in and lock
 * screens. Decorative; those screens carry their own title.
 */
@Composable
fun AppEmblem(modifier: Modifier = Modifier, size: Dp = 76.dp) {
    EmblemCanvas(modifier, size, shackle = { 0f })
}

/**
 * [AppEmblem] acting out the vault's state. The shackle lifts when [locked] turns false and snaps
 * shut when it turns true; each new [rejections] count swings the key on its hook and rattles the
 * shackle, as a lock does when the wrong key is tried. [startOpen] begins with the shackle up, for
 * arriving from an unlocked vault, so the user sees it close.
 */
@Composable
fun LockEmblem(
    locked: Boolean,
    rejections: Int,
    modifier: Modifier = Modifier,
    size: Dp = 76.dp,
    startOpen: Boolean = false,
) {
    val shackle = remember { Animatable(if (startOpen || !locked) 1f else 0f) }
    val swing = remember { Animatable(0f) }
    val haptics = LocalHapticFeedback.current
    // Only new rejections swing the key, not one already counted before a rotation.
    val rejectionsAtStart = remember { rejections }

    LaunchedEffect(locked) {
        if (!locked) {
            shackle.animateTo(1f, tween(220, easing = BovedaMotion.EmphasizedDecelerate))
        } else if (shackle.value > 0f) {
            // Accelerates down, seats a hair too far, settles: the click of a closing padlock.
            shackle.animateTo(
                0f,
                keyframes {
                    delayMillis = CLOSE_DELAY_MS
                    durationMillis = 240
                    shackle.value at 0 using BovedaMotion.EmphasizedAccelerate
                    -0.12f at 150 using BovedaMotion.Standard
                },
            )
        }
    }

    LaunchedEffect(rejections) {
        if (rejections == rejectionsAtStart) return@LaunchedEffect
        haptics.performHapticFeedback(HapticFeedbackType.Reject)
        coroutineScope {
            // A hanging key is a pendulum: a push, then a swing that dies out in under half a second.
            launch { swing.animateTo(0f, spring(dampingRatio = 0.32f, stiffness = 420f), initialVelocity = 340f) }
            launch {
                shackle.animateTo(0.2f, tween(70, easing = BovedaMotion.EmphasizedDecelerate))
                shackle.animateTo(0f, tween(130, easing = BovedaMotion.EmphasizedAccelerate))
            }
        }
    }

    EmblemCanvas(
        modifier.graphicsLayer {
            rotationZ = swing.value
            transformOrigin = TransformOrigin(0.5f, RING_Y)
        },
        size,
        shackle = { shackle.value },
    )
}

@Composable
private fun EmblemCanvas(modifier: Modifier, size: Dp, shackle: () -> Float) {
    val colors = BovedaTheme.colors
    Canvas(modifier.size(size).graphicsLayer(compositingStrategy = CompositingStrategy.Offscreen)) {
        drawKeyCap(colors.shell)
        drawPadlock(colors.shellIndicator, open = shackle())
    }
}

@Composable
fun keyCapColorFor(label: String): KeyCapColor {
    val caps = BovedaTheme.colors.keyCaps
    return caps[Math.floorMod(label.trim().lowercase().hashCode(), caps.size)]
}

/** Head with rounded corners, the stub of the blade below it, and a ring hole punched through. */
private fun DrawScope.drawKeyCap(color: Color) {
    val w = size.width
    val h = size.height
    val headHeight = h * HEAD
    drawRoundRect(color, size = Size(w, headHeight), cornerRadius = CornerRadius(w * 0.30f))
    drawRoundRect(
        color,
        topLeft = Offset(w * 0.37f, headHeight - w * 0.08f),
        size = Size(w * 0.26f, h - headHeight + w * 0.08f),
        cornerRadius = CornerRadius(w * 0.05f),
    )
    drawCircle(Color.Black, radius = w * 0.075f, center = Offset(w / 2f, h * RING_Y), blendMode = BlendMode.Clear)
}

/**
 * The Material Symbols lock, redrawn on its 960 grid so the shackle can move: [open] 0 is seated,
 * 1 lifts it clear of the body on its long right leg. Below 0 it sinks slightly, for the click.
 */
private fun DrawScope.drawPadlock(color: Color, open: Float) {
    val box = size.width * 0.40f
    val unit = box / 960f
    val stroke = 80f
    val lift = open * 110f
    withTransform({
        translate((size.width - box) / 2f, (size.height - box) / 2f + size.height * 0.07f)
        scale(unit, unit, pivot = Offset.Zero)
    }) {
        drawRoundRect(color, Offset(200f, 360f), Size(560f, 480f), CornerRadius(40f), style = Stroke(stroke))
        drawCircle(color, radius = 80f, center = Offset(480f, 600f))
        translate(top = -lift) {
            drawArc(color, 180f, 180f, useCenter = false, topLeft = Offset(320f, 80f), size = Size(320f, 320f), style = Stroke(stroke))
            drawLine(color, Offset(320f, 240f), Offset(320f, 320f), strokeWidth = stroke, cap = StrokeCap.Round)
        }
        // The long leg stays in the body however high the shackle rises.
        drawLine(color, Offset(640f, 240f - lift), Offset(640f, 330f), strokeWidth = stroke)
    }
}

@Preview
@Composable
private fun KeyCapPreview() {
    BovedaTheme { KeyCap("Banco Santander", size = 72.dp) }
}

@Preview
@Composable
private fun AppEmblemPreview() {
    BovedaTheme { AppEmblem() }
}

@Preview
@Composable
private fun LockEmblemOpenPreview() {
    BovedaTheme { LockEmblem(locked = false, rejections = 0) }
}
