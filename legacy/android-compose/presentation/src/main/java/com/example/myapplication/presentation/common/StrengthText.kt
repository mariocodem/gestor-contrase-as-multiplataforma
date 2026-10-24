package com.example.myapplication.presentation.common

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.example.myapplication.designsystem.component.StrengthIndicator
import com.example.myapplication.domain.model.PasswordStrength
import com.example.myapplication.domain.model.StrengthLevel
import com.example.myapplication.domain.model.StrengthWarning
import com.example.myapplication.presentation.R
import kotlin.math.roundToInt

private const val MINUTE = 60.0
private const val HOUR = 60 * MINUTE
private const val DAY = 24 * HOUR
private const val MONTH = 30 * DAY
private const val YEAR = 365 * DAY

fun StrengthLevel.verdict(): UiText = UiText.Res(
    when (this) {
        StrengthLevel.VERY_WEAK -> R.string.strength_very_weak
        StrengthLevel.WEAK -> R.string.strength_weak
        StrengthLevel.FAIR -> R.string.strength_fair
        StrengthLevel.STRONG -> R.string.strength_strong
        StrengthLevel.VERY_STRONG -> R.string.strength_very_strong
    },
)

/** "Adivinarla llevaría 3 días", rounded to the largest unit that reads naturally. */
fun crackTime(seconds: Double): UiText {
    if (seconds < 1) return UiText.Res(R.string.strength_instant)
    val duration = when {
        seconds < MINUTE -> UiText.Plural(R.plurals.duration_seconds, seconds.roundToInt())
        seconds < HOUR -> UiText.Plural(R.plurals.duration_minutes, (seconds / MINUTE).roundToInt())
        seconds < DAY -> UiText.Plural(R.plurals.duration_hours, (seconds / HOUR).roundToInt())
        seconds < MONTH -> UiText.Plural(R.plurals.duration_days, (seconds / DAY).roundToInt())
        seconds < YEAR -> UiText.Plural(R.plurals.duration_months, (seconds / MONTH).roundToInt().coerceAtMost(11))
        seconds < 100 * YEAR -> UiText.Plural(R.plurals.duration_years, (seconds / YEAR).roundToInt())
        seconds < 1e6 * YEAR -> UiText.Res(R.string.duration_centuries)
        else -> UiText.Res(R.string.duration_millions_of_years)
    }
    return UiText.Res(R.string.strength_crack_time, listOf(duration))
}

/** The one pattern most worth fixing, if any. */
fun PasswordStrength.topWarning(): UiText? {
    val ordered = listOf(
        StrengthWarning.COMMON_PASSWORD to R.string.warning_common_password,
        StrengthWarning.COMMON_WORD to R.string.warning_common_word,
        StrengthWarning.KEYBOARD_PATTERN to R.string.warning_keyboard,
        StrengthWarning.SEQUENCE to R.string.warning_sequence,
        StrengthWarning.REPEATS to R.string.warning_repeats,
        StrengthWarning.DATE to R.string.warning_date,
        StrengthWarning.SINGLE_CHARACTER_TYPE to R.string.warning_single_type,
        StrengthWarning.TOO_SHORT to R.string.warning_too_short,
    )
    return ordered.firstOrNull { (warning, _) -> warning in warnings }?.let { UiText.Res(it.second) }
}

/**
 * The design-system meter fed from a domain [strength]. Hand-typed passwords show their worst
 * pattern instead of the crack time, because that's what the user can act on; at the top rating
 * the crack time stands alone, so "very strong" never comes with a reason to doubt it.
 */
@Composable
fun PasswordStrengthIndicator(
    strength: PasswordStrength,
    modifier: Modifier = Modifier,
    showWarning: Boolean = true,
) {
    val warning = if (showWarning && strength.level != StrengthLevel.VERY_STRONG) strength.topWarning() else null
    StrengthIndicator(
        level = strength.level.ordinal,
        verdict = strength.level.verdict().asString(),
        measurement = UiText.Res(R.string.strength_bits, listOf(strength.entropyBits.roundToInt())).asString(),
        detail = (warning ?: crackTime(strength.crackTimeSeconds)).asString(),
        modifier = modifier,
    )
}
