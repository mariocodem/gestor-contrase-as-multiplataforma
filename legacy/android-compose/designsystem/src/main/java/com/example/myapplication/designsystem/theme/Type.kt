package com.example.myapplication.designsystem.theme

import androidx.compose.material3.Typography
import androidx.compose.runtime.Immutable
import androidx.compose.ui.text.ExperimentalTextApi
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.sp
import com.example.myapplication.designsystem.R

// Atkinson Hyperlegible was drawn to keep similar letters apart (I l 1, O 0), which is exactly
// what reading and retyping a password needs. One family for the UI, its mono for secrets.
@OptIn(ExperimentalTextApi::class)
private fun variable(resId: Int, weight: FontWeight) =
    Font(resId, weight, variationSettings = FontVariation.Settings(FontVariation.weight(weight.weight)))

private val weights = listOf(FontWeight.Normal, FontWeight.Medium, FontWeight.SemiBold, FontWeight.Bold)

val AtkinsonNext = FontFamily(weights.map { variable(R.font.atkinson_hyperlegible_next, it) })
val AtkinsonMono = FontFamily(weights.map { variable(R.font.atkinson_hyperlegible_mono, it) })

private fun style(size: Int, line: Int, weight: FontWeight, tracking: TextUnit = 0.sp) = TextStyle(
    fontFamily = AtkinsonNext,
    fontWeight = weight,
    fontSize = size.sp,
    lineHeight = line.sp,
    letterSpacing = tracking,
)

// A tight scale (about 1.15 per step); rank comes from weight more than from size.
internal val BovedaTypography = Typography(
    displayLarge = style(48, 56, FontWeight.SemiBold),
    displayMedium = style(40, 48, FontWeight.SemiBold),
    displaySmall = style(34, 42, FontWeight.SemiBold),
    headlineLarge = style(30, 38, FontWeight.SemiBold),
    headlineMedium = style(26, 34, FontWeight.SemiBold),
    headlineSmall = style(23, 30, FontWeight.SemiBold),
    titleLarge = style(20, 28, FontWeight.SemiBold),
    titleMedium = style(16, 24, FontWeight.SemiBold, 0.1.sp),
    titleSmall = style(14, 20, FontWeight.SemiBold, 0.1.sp),
    bodyLarge = style(16, 24, FontWeight.Normal, 0.15.sp),
    bodyMedium = style(14, 20, FontWeight.Normal, 0.15.sp),
    bodySmall = style(12, 16, FontWeight.Normal, 0.2.sp),
    labelLarge = style(14, 20, FontWeight.SemiBold, 0.1.sp),
    labelMedium = style(12, 16, FontWeight.SemiBold, 0.3.sp),
    labelSmall = style(11, 16, FontWeight.SemiBold, 0.3.sp),
)

/** Styles for secrets and numbers people compare character by character. */
@Immutable
data class SecretTypography(
    val large: TextStyle = TextStyle(fontFamily = AtkinsonMono, fontWeight = FontWeight.Medium, fontSize = 24.sp, lineHeight = 34.sp),
    val medium: TextStyle = TextStyle(fontFamily = AtkinsonMono, fontWeight = FontWeight.Medium, fontSize = 17.sp, lineHeight = 24.sp),
    val small: TextStyle = TextStyle(fontFamily = AtkinsonMono, fontWeight = FontWeight.Medium, fontSize = 13.sp, lineHeight = 18.sp),
)
