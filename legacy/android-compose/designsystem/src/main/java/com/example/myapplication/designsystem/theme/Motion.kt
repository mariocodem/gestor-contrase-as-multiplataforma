package com.example.myapplication.designsystem.theme

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.Easing

/**
 * Material 3 easing and durations, named once so every screen moves alike. Feedback runs
 * 150–250 ms, the longest flight (the key cap) 380 ms, and nothing waits on an animation: the
 * vault is usable while it's still arriving.
 * Compose follows the system "Remove animations" setting, which turns all of these into cuts.
 */
object BovedaMotion {
    /** Arrivals: quick start, long settle. */
    val EmphasizedDecelerate: Easing = CubicBezierEasing(0.05f, 0.7f, 0.1f, 1f)

    /** Departures and the snap of a shackle closing. */
    val EmphasizedAccelerate: Easing = CubicBezierEasing(0.3f, 0f, 0.8f, 0.15f)

    /** Changes in place. */
    val Standard: Easing = CubicBezierEasing(0.2f, 0f, 0f, 1f)

    const val SHORT = 150
    const val MEDIUM = 250
    const val LONG = 400
}
