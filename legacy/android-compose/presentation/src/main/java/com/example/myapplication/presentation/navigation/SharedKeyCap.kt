package com.example.myapplication.presentation.navigation

import androidx.compose.animation.AnimatedVisibilityScope
import androidx.compose.animation.BoundsTransform
import androidx.compose.animation.SharedTransitionScope
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Modifier
import com.example.myapplication.designsystem.theme.BovedaMotion

/** The layout shared elements travel in: the whole unlocked app. */
val LocalSharedTransitionScope = staticCompositionLocalOf<SharedTransitionScope?> { null }

/** The navigation transition of the destination being composed. */
val LocalNavAnimatedVisibilityScope = staticCompositionLocalOf<AnimatedVisibilityScope?> { null }

private data class KeyCapKey(val entryId: String)

private val KeyCapBoundsTransform = BoundsTransform { _, _ ->
    tween(380, easing = BovedaMotion.EmphasizedDecelerate)
}

/**
 * Makes the key cap of [entryId] one object across screens: it lifts off its row in the list and
 * lands in the detail header, and goes back to its hook on the way back (a predictive Back
 * gesture scrubs it). Outside a navigation transition it's a plain [Modifier].
 */
@Composable
fun keyCapSharedElement(entryId: String): Modifier {
    val shared = LocalSharedTransitionScope.current ?: return Modifier
    val animated = LocalNavAnimatedVisibilityScope.current ?: return Modifier
    return with(shared) {
        Modifier.sharedElement(
            sharedContentState = rememberSharedContentState(KeyCapKey(entryId)),
            animatedVisibilityScope = animated,
            boundsTransform = KeyCapBoundsTransform,
        )
    }
}
