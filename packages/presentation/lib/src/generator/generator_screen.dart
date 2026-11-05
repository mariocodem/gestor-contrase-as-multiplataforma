import 'dart:async';

import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/dependencies.dart';
import '../common/messages.dart';
import '../common/strings.dart';
import 'generator_cubit.dart';
import 'generator_panel.dart';

/// The Generator tab: make a password and copy it, e.g. for a sign-up form in another app.
class GeneratorScreen extends StatelessWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (context) => GeneratorCubit(context.read<Dependencies>()), child: const _GeneratorTab());
}

class _GeneratorTab extends StatefulWidget {
  const _GeneratorTab();

  @override
  State<_GeneratorTab> createState() => _GeneratorTabState();
}

class _GeneratorTabState extends State<_GeneratorTab> {
  final _copied = CopyConfirmation();
  late final StreamSubscription<String> _messages;

  @override
  void initState() {
    super.initState();
    _messages = context.read<GeneratorCubit>().messages.listen((text) {
      if (mounted) showMessage(context, text);
    });
  }

  @override
  void dispose() {
    _messages.cancel();
    _copied.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GeneratorCubit>();
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const ShellDockSpacer(),
      appBar: const ShellTopBar(title: S.generatorTitle, subtitle: S.generatorSubtitle, contentWidth: readableWidth),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: readableWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
            child: GeneratorPanel(
              actions: [
                Expanded(
                  child: BovedaButton(
                    size: BovedaButtonSize.large,
                    fullWidth: true,
                    onPressed: () {
                      cubit.copy();
                      _copied.confirm();
                    },
                    child: ListenableBuilder(
                      listenable: _copied,
                      builder: (context, _) =>
                          CopyButtonContent(copied: _copied.isShowing, label: S.generatorCopy, copiedLabel: S.generatorCopied),
                    ),
                  ),
                ),
                _RegenerateButton(onPressed: cubit.regenerate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The generator inside the entry editor: same controls, and the result goes into the entry
/// (popped as the sheet's result).
class GeneratorSheet extends StatelessWidget {
  const GeneratorSheet({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => GeneratorCubit(context.read<Dependencies>()),
    child: Builder(
      builder: (context) {
        final cubit = context.read<GeneratorCubit>();
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.paddingOf(context).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(S.generatorSheetTitle, style: Theme.of(context).textTheme.titleLarge),
              ),
              GeneratorPanel(
                actions: [
                  Expanded(
                    child: BovedaButton(
                      size: BovedaButtonSize.large,
                      fullWidth: true,
                      onPressed: () {
                        final value = cubit.state.password?.value;
                        if (value != null) Navigator.pop(context, value);
                      },
                      child: const Text(S.generatorUse),
                    ),
                  ),
                  _RegenerateButton(onPressed: cubit.regenerate),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// "Generar otra": the arrow takes one turn while the new password rolls in.
class _RegenerateButton extends StatefulWidget {
  const _RegenerateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_RegenerateButton> createState() => _RegenerateButtonState();
}

class _RegenerateButtonState extends State<_RegenerateButton> with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(vsync: this, duration: const Duration(milliseconds: 460));
  late final _angle = CurvedAnimation(parent: _turn, curve: BovedaMotion.emphasizedDecelerate);

  @override
  void dispose() {
    _angle.dispose();
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BovedaButton.icon(
    size: BovedaButtonSize.large,
    onPressed: () {
      widget.onPressed();
      if (BovedaMotion.enabled(context)) _turn.forward(from: 0);
    },
    child: RotationTransition(
      turns: _angle,
      child: const BovedaIcon(BovedaIcons.refresh, size: 20, semanticLabel: S.generatorRegenerate),
    ),
  );
}
