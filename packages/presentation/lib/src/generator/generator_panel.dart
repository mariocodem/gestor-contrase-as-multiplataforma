import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _dragging = ValueNotifier(false);

  @override
  void dispose() {
    _dragging.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocSelector<GeneratorCubit, GeneratorState, bool>(
    selector: (state) => state.password != null,
    builder: (context, ready) {
      if (!ready) return const EntryRowPlaceholders(count: 2);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StampedTag(dragging: _dragging),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                for (final (i, action) in widget.actions.indexed) ...[if (i > 0) const SizedBox(width: 12), action],
              ],
            ),
          ),
          // "Generar otra" changes the password only: the controls stay as they are.
          BlocSelector<GeneratorCubit, GeneratorState, PasswordOptions>(
            selector: (state) => state.options,
            builder: (context, options) => _Controls(options: options, dragging: _dragging),
          ),
        ],
      );
    },
  );
}

/// The output, on its own plate: the one thing this screen makes.
class _StampedTag extends StatelessWidget {
  const _StampedTag({required this.dragging});

  final ValueNotifier<bool> dragging;

  @override
  Widget build(BuildContext context) => Plate(
    padding: const EdgeInsets.all(20),
    child: BlocSelector<GeneratorCubit, GeneratorState, GeneratedPassword?>(
      selector: (state) => state.password,
      builder: (context, generated) {
        if (generated == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: dragging,
              builder: (context, dragging, _) => TumblerText(
                text: generated.value,
                style: context.secretType.large,
                color: Theme.of(context).colorScheme.onSurface,
                animate: !dragging,
                liveRegion: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PasswordStrengthIndicator(strength: generated.strength, showWarning: false),
            ),
          ],
        );
      },
    ),
  );
}

class _Controls extends StatelessWidget {
  const _Controls({required this.options, required this.dragging});

  final PasswordOptions options;
  final ValueNotifier<bool> dragging;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<GeneratorCubit>();
    final onlyOneLeft = options.enabledSetCount == 1;
    Widget tile(String label, String sample, bool checked, ValueChanged<bool> onChanged) => Expanded(
      child: _CharacterSetTile(label: label, sample: sample, checked: checked, lockedOn: onlyOneLeft, onChanged: onChanged),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 4),
          child: Row(
            children: [
              Expanded(child: Text(S.generatorLength, style: theme.textTheme.titleSmall)),
              Text('${options.length}', style: context.secretType.large.copyWith(color: theme.colorScheme.onSurface)),
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
            padding: EdgeInsets.zero,
            semanticFormatterCallback: (value) => S.generatorLengthValue(value.round()),
            onChangeStart: (_) => dragging.value = true,
            onChanged: (value) {
              final length = value.round();
              if (length != options.length) HapticFeedback.selectionClick();
              cubit.onLengthChange(length);
            },
            onChangeEnd: (_) {
              dragging.value = false;
              cubit.onLengthChangeFinished();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(S.generatorCharacters, style: theme.textTheme.titleSmall),
        ),
        Row(
          children: [
            tile(S.generatorUppercase, S.generatorUppercaseSample, options.uppercase, cubit.onUppercaseChange),
            const SizedBox(width: 8),
            tile(S.generatorLowercase, S.generatorLowercaseSample, options.lowercase, cubit.onLowercaseChange),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            tile(S.generatorDigits, S.generatorDigitsSample, options.digits, cubit.onDigitsChange),
            const SizedBox(width: 8),
            tile(S.generatorSymbols, S.generatorSymbolsSample, options.symbols, cubit.onSymbolsChange),
          ],
        ),
        const SizedBox(height: 8),
        _AvoidAmbiguousRow(checked: options.avoidAmbiguous, onChanged: cubit.onAvoidAmbiguousChange),
        AnimatedSize(
          duration: BovedaMotion.of(context, BovedaMotion.medium),
          curve: BovedaMotion.emphasizedDecelerate,
          child: onlyOneLeft
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    S.generatorLastSet,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
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
  }
}

/// One set of characters, as a key you press in: edged in ink while it's in the password. [lockedOn]
/// keeps the last enabled set from being turned off.
class _CharacterSetTile extends StatelessWidget {
  const _CharacterSetTile({
    required this.label,
    required this.sample,
    required this.checked,
    required this.lockedOn,
    required this.onChanged,
  });

  final String label;
  final String sample;
  final bool checked;
  final bool lockedOn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = !(checked && lockedOn);
    final duration = BovedaMotion.of(context, BovedaMotion.short);
    return Semantics(
      toggled: checked,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? () => onChanged(!checked) : null,
      child: Stack(
        children: [
          PressSurface(
            borderRadius: BovedaShapes.medium,
            onTap: enabled
                ? () {
                    HapticFeedback.selectionClick();
                    onChanged(!checked);
                  }
                : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 68, minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 36, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      sample,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.secretType.small.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: duration,
                curve: BovedaMotion.standard,
                decoration: BoxDecoration(
                  borderRadius: BovedaShapes.medium,
                  color: Colors.transparent,
                  border: Border.all(color: checked ? scheme.primary : Colors.transparent, width: 1.5),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 12,
            top: 12,
            child: IgnorePointer(
              child: AnimatedScale(
                scale: checked ? 1 : 0,
                duration: duration,
                curve: BovedaMotion.seat,
                child: BovedaIcon(BovedaIcons.check, size: 18, color: scheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvoidAmbiguousRow extends StatelessWidget {
  const _AvoidAmbiguousRow({required this.checked, required this.onChanged});

  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: PressSurface(
        borderRadius: BovedaShapes.medium,
        pressedScale: 0.99,
        onTap: () => onChanged(!checked),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.generatorAvoidAmbiguous, style: theme.textTheme.titleSmall),
                      Text(
                        S.generatorAvoidAmbiguousSample,
                        style: context.secretType.small.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(value: checked, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
