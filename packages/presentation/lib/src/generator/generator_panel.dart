import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/strength_text.dart';
import '../common/strings.dart';
import 'generator_cubit.dart';

/// The generator's controls and output, shared by the Generator tab and the editor's sheet.
/// [actions] holds the primary action of the context (copy, or use in the entry).
class GeneratorPanel extends StatefulWidget {
  const GeneratorPanel({super.key, required this.actions});

  final List<Widget> actions;

  @override
  State<GeneratorPanel> createState() => _GeneratorPanelState();
}

class _GeneratorPanelState extends State<GeneratorPanel> {
  // While the length slider moves, every step is a new password; rolling each one would only flicker.
  var _dragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<GeneratorCubit>();
    return BlocBuilder<GeneratorCubit, GeneratorState>(
      builder: (context, state) {
        final generated = state.password;
        if (generated == null) return const EntryRowPlaceholders(count: 2);
        final options = state.options;
        final onlyOneLeft = options.enabledSetCount == 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The output, set like a stamped tag: mono, digits and symbols in their own colours.
            Plate(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TumblerText(
                    text: generated.value,
                    style: context.secretType.large,
                    color: theme.colorScheme.onSurface,
                    animate: !_dragging,
                    liveRegion: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: PasswordStrengthIndicator(strength: generated.strength, showWarning: false),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(children: [for (final (i, action) in widget.actions.indexed) ...[if (i > 0) const SizedBox(width: 12), action]]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28, bottom: 4),
              child: Row(
                children: [
                  Expanded(child: Text(S.generatorLength, style: theme.textTheme.titleSmall)),
                  Text('${options.length}', style: context.secretType.medium.copyWith(color: theme.colorScheme.onSurface)),
                ],
              ),
            ),
            Semantics(
              value: S.generatorLengthValue(options.length),
              child: Slider(
                value: options.length.toDouble(),
                min: PasswordOptions.minLength.toDouble(),
                max: PasswordOptions.maxLength.toDouble(),
                divisions: PasswordOptions.maxLength - PasswordOptions.minLength,
                semanticFormatterCallback: (value) => S.generatorLengthValue(value.round()),
                onChangeStart: (_) => setState(() => _dragging = true),
                onChanged: (value) => cubit.onLengthChange(value.round()),
                onChangeEnd: (_) {
                  setState(() => _dragging = false);
                  cubit.onLengthChangeFinished();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 4),
              child: Text(S.generatorCharacters, style: theme.textTheme.titleSmall),
            ),
            _OptionRow(S.generatorUppercase, S.generatorUppercaseSample, options.uppercase, onlyOneLeft, cubit.onUppercaseChange),
            _OptionRow(S.generatorLowercase, S.generatorLowercaseSample, options.lowercase, onlyOneLeft, cubit.onLowercaseChange),
            _OptionRow(S.generatorDigits, S.generatorDigitsSample, options.digits, onlyOneLeft, cubit.onDigitsChange),
            _OptionRow(S.generatorSymbols, S.generatorSymbolsSample, options.symbols, onlyOneLeft, cubit.onSymbolsChange),
            _OptionRow(
              S.generatorAvoidAmbiguous,
              S.generatorAvoidAmbiguousSample,
              options.avoidAmbiguous,
              false,
              cubit.onAvoidAmbiguousChange,
            ),
            AnimatedSize(
              duration: BovedaMotion.of(context, BovedaMotion.medium),
              curve: BovedaMotion.emphasizedDecelerate,
              child: onlyOneLeft
                  ? Text(S.generatorLastSet, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))
                  : const SizedBox(width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                S.generatorAssumption,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A switch row; [lockedOn] keeps the last enabled character set from being turned off.
class _OptionRow extends StatelessWidget {
  const _OptionRow(this.label, this.sample, this.checked, this.lockedOn, this.onChanged);

  final String label;
  final String sample;
  final bool checked;
  final bool lockedOn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = !(checked && lockedOn);
    return MergeSemantics(
      child: InkWell(
        onTap: enabled ? () => onChanged(!checked) : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodyLarge),
                    Text(sample, style: context.secretType.small.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(value: checked, onChanged: enabled ? onChanged : null),
            ],
          ),
        ),
      ),
    );
  }
}
