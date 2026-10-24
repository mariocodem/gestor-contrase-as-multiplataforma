package com.example.myapplication.designsystem.component

import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.takeOrElse
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.input.OffsetMapping
import androidx.compose.ui.text.input.TransformedText
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.withStyle
import com.example.myapplication.designsystem.theme.BovedaTheme

/** Always the same number of dots, so a hidden secret doesn't reveal its length. */
const val MASK = "••••••••••"

/** Digits and symbols take their own inks, so a password can be read back character by character. */
@Composable
fun rememberCharacterClassColors(): (String) -> AnnotatedString {
    val digit = BovedaTheme.colors.secretDigit
    val symbol = BovedaTheme.colors.secretSymbol
    return remember(digit, symbol) { { text -> colorByCharacterClass(text, digit, symbol) } }
}

fun colorByCharacterClass(text: String, digit: Color, symbol: Color): AnnotatedString = buildAnnotatedString {
    for (char in text) {
        val color = when {
            char.isDigit() -> digit
            !char.isLetterOrDigit() && !char.isWhitespace() -> symbol
            else -> Color.Unspecified
        }
        withStyle(SpanStyle(color = color)) { append(char) }
    }
}

/** A secret behind [MASK]; revealing or hiding it rolls the characters like lock pins. */
@Composable
fun SecretText(
    value: String,
    revealed: Boolean,
    hiddenDescription: String,
    modifier: Modifier = Modifier,
    style: TextStyle = BovedaTheme.secret.medium,
    color: Color = LocalTextStyle.current.color.takeOrElse { MaterialTheme.colorScheme.onSurface },
) {
    TumblerText(
        text = if (revealed) value else MASK,
        modifier = modifier,
        style = style,
        color = color,
        contentDescription = if (revealed) null else hiddenDescription,
    )
}

/** Visual transformation for text fields showing a secret in clear. */
class CharacterClassTransformation(private val digit: Color, private val symbol: Color) : VisualTransformation {
    override fun filter(text: AnnotatedString): TransformedText =
        TransformedText(colorByCharacterClass(text.text, digit, symbol), OffsetMapping.Identity)

    override fun equals(other: Any?): Boolean =
        other is CharacterClassTransformation && other.digit == digit && other.symbol == symbol

    override fun hashCode(): Int = 31 * digit.hashCode() + symbol.hashCode()
}
