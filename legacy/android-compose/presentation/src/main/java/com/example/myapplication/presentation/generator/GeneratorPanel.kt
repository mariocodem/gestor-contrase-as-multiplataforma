package com.example.myapplication.presentation.generator

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.selection.toggleable
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.unit.dp
import com.example.myapplication.designsystem.component.EntryRowPlaceholders
import com.example.myapplication.designsystem.component.TumblerText
import com.example.myapplication.designsystem.theme.BovedaMotion
import com.example.myapplication.designsystem.theme.BovedaTheme
import com.example.myapplication.domain.model.PasswordOptions
import com.example.myapplication.presentation.R
import com.example.myapplication.presentation.common.PasswordStrengthIndicator
import kotlin.math.roundToInt

/**
 * The generator's controls and output, shared by the Generator tab and the editor's sheet.
 * [actions] holds the primary action of the context (copy, or use in the entry).
 */
@Composable
fun GeneratorPanel(
    state: GeneratorUiState,
    viewModel: GeneratorViewModel,
    modifier: Modifier = Modifier,
    actions: @Composable RowScope.() -> Unit,
) {
    val generated = state.password
    if (generated == null) {
        EntryRowPlaceholders(count = 2, modifier = modifier)
        return
    }
    val options = state.options
    // While the length slider moves, every step is a new password; rolling each one would only flicker.
    var dragging by remember { mutableStateOf(false) }

    Column(modifier) {
        // The output, set like a stamped tag: mono, digits and symbols in their own colours.
        Surface(
            color = BovedaTheme.colors.plate,
            shape = MaterialTheme.shapes.large,
            modifier = Modifier.fillMaxWidth(),
        ) {
            Column(Modifier.padding(20.dp)) {
                TumblerText(
                    text = generated.value,
                    style = BovedaTheme.secret.large,
                    animate = !dragging,
                    modifier = Modifier.semantics { liveRegion = LiveRegionMode.Polite },
                )
                Spacer(Modifier.padding(top = 16.dp))
                PasswordStrengthIndicator(generated.strength, showWarning = false)
            }
        }
        Row(
            Modifier.fillMaxWidth().padding(top = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            content = actions,
        )

        Row(
            Modifier.fillMaxWidth().padding(top = 28.dp, bottom = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(stringResource(R.string.generator_length), style = MaterialTheme.typography.titleSmall, modifier = Modifier.weight(1f))
            Text(options.length.toString(), style = BovedaTheme.secret.medium)
        }
        val lengthDescription = stringResource(R.string.generator_length_value, options.length)
        Slider(
            value = options.length.toFloat(),
            onValueChange = {
                dragging = true
                viewModel.onLengthChange(it.roundToInt())
            },
            onValueChangeFinished = {
                dragging = false
                viewModel.onLengthChangeFinished()
            },
            valueRange = PasswordOptions.MIN_LENGTH.toFloat()..PasswordOptions.MAX_LENGTH.toFloat(),
            modifier = Modifier.semantics { stateDescription = lengthDescription },
        )

        Text(
            stringResource(R.string.generator_characters),
            style = MaterialTheme.typography.titleSmall,
            modifier = Modifier.padding(top = 20.dp, bottom = 4.dp),
        )
        val onlyOneLeft = options.enabledSetCount == 1
        OptionRow(R.string.generator_uppercase, R.string.generator_uppercase_sample, options.uppercase, onlyOneLeft, viewModel::onUppercaseChange)
        OptionRow(R.string.generator_lowercase, R.string.generator_lowercase_sample, options.lowercase, onlyOneLeft, viewModel::onLowercaseChange)
        OptionRow(R.string.generator_digits, R.string.generator_digits_sample, options.digits, onlyOneLeft, viewModel::onDigitsChange)
        OptionRow(R.string.generator_symbols, R.string.generator_symbols_sample, options.symbols, onlyOneLeft, viewModel::onSymbolsChange)
        OptionRow(
            R.string.generator_avoid_ambiguous,
            R.string.generator_avoid_ambiguous_sample,
            options.avoidAmbiguous,
            lockedOn = false,
            onChange = viewModel::onAvoidAmbiguousChange,
        )
        AnimatedVisibility(
            visible = onlyOneLeft,
            enter = expandVertically(tween(BovedaMotion.MEDIUM, easing = BovedaMotion.EmphasizedDecelerate)) + fadeIn(),
            exit = shrinkVertically(tween(BovedaMotion.SHORT)) + fadeOut(tween(100)),
        ) {
            Text(
                stringResource(R.string.generator_last_set),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        Text(
            stringResource(R.string.generator_assumption),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 16.dp),
        )
    }
}

/** A switch row; [lockedOn] keeps the last enabled character set from being turned off. */
@Composable
private fun OptionRow(label: Int, sample: Int, checked: Boolean, lockedOn: Boolean, onChange: (Boolean) -> Unit) {
    val enabled = !(checked && lockedOn)
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 56.dp)
            .toggleable(value = checked, enabled = enabled, role = Role.Switch, onValueChange = onChange),
    ) {
        Column(Modifier.weight(1f)) {
            Text(stringResource(label), style = MaterialTheme.typography.bodyLarge)
            Text(
                stringResource(sample),
                style = BovedaTheme.secret.small,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
        Spacer(Modifier.width(16.dp))
        Switch(checked = checked, onCheckedChange = null, enabled = enabled)
    }
}
