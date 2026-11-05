import 'dart:async';

import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../common/dependencies.dart';
import '../../common/form_message.dart';
import '../../common/messages.dart';
import '../../common/strength_text.dart';
import '../../common/strings.dart';
import '../../generator/generator_screen.dart';
import '../../navigation/app_router.dart';
import 'entry_editor_cubit.dart';

/// Creates an entry ([id] null) or edits one.
class EntryEditorScreen extends StatelessWidget {
  const EntryEditorScreen({super.key, required this.id});

  final String? id;

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (context) => EntryEditorCubit(context.read<Dependencies>(), id), child: const _EditorContent());
}

class _EditorContent extends StatefulWidget {
  const _EditorContent();

  @override
  State<_EditorContent> createState() => _EditorContentState();
}

class _EditorContentState extends State<_EditorContent> {
  late final StreamSubscription<EntryEditorEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = context.read<EntryEditorCubit>().events.listen((event) {
      if (!mounted) return;
      switch (event) {
        case EditorSaved(:final id, wasNew: true):
          // Straight to the new entry, ready to copy into the sign-up form.
          final messenger = ScaffoldMessenger.of(context);
          context.pushReplacement(Paths.entry(id));
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text(S.editorSaved)));
        case EditorSaved(wasNew: false):
          final messenger = ScaffoldMessenger.of(context);
          context.pop();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text(S.editorUpdated)));
        case EditorGone():
          context.pop();
      }
    });
  }

  @override
  void dispose() {
    _events.cancel();
    super.dispose();
  }

  Future<void> _requestClose() async {
    final hasChanges = context.read<EntryEditorCubit>().state.hasChanges;
    if (!hasChanges || await _confirmDiscard()) {
      if (mounted) context.pop();
    }
  }

  Future<bool> _confirmDiscard() async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(S.editorDiscardTitle),
          content: const Text(S.editorDiscardBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(S.editorKeepEditing)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text(S.editorDiscard)),
          ],
        ),
      ) ??
      false;

  Future<void> _openGenerator() async {
    final cubit = context.read<EntryEditorCubit>();
    final password = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const GeneratorSheet(),
    );
    if (password != null) cubit.onPasswordChange(password);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<EntryEditorCubit>();
    return BlocBuilder<EntryEditorCubit, EntryEditorState>(
      // A keystroke rebuilds its own field (below), not the form.
      buildWhen: (a, b) =>
          a.isLoading != b.isLoading || a.hasChanges != b.hasChanges || a.canSave != b.canSave || a.error != b.error,
      builder: (context, state) {
        return PopScope(
          canPop: !state.hasChanges,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _requestClose();
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: systemBarsOver(theme.colorScheme.surface, theme.colorScheme.surface),
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(onPressed: _requestClose, tooltip: S.editorClose, icon: const BovedaIcon(BovedaIcons.close)),
                title: Text(state.isNew ? S.editorNewTitle : S.editorEditTitle),
                actions: [
                  BovedaButton(
                    size: BovedaButtonSize.small,
                    onPressed: state.canSave ? cubit.save : null,
                    child: const Text(S.editorSave),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              body: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: readableWidth),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      const _KeyPreview(),
                      const SizedBox(height: 20),
                      _Value(
                        pick: (draft) => draft.title,
                        builder: (value) => BovedaTextField(
                          value: value,
                          onChanged: cubit.onTitleChange,
                          label: S.editorName,
                          placeholder: S.editorNamePlaceholder,
                          enabled: !state.isLoading,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          autofocus: state.isNew,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Value(
                        pick: (draft) => draft.username,
                        builder: (value) => BovedaTextField(
                          value: value,
                          onChanged: cubit.onUsernameChange,
                          label: S.editorUsername,
                          enabled: !state.isLoading,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Value(
                        pick: (draft) => draft.password,
                        builder: (value) => PasswordField(
                          value: value,
                          onChanged: cubit.onPasswordChange,
                          label: S.editorPassword,
                          showLabel: S.showPassword,
                          hideLabel: S.hidePassword,
                          enabled: !state.isLoading,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const _EditorStrength(),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: BovedaButton(
                          type: BovedaButtonType.secondary,
                          onPressed: state.isLoading ? null : _openGenerator,
                          prefix: const BovedaIcon(BovedaIcons.password, size: 18),
                          child: const Text(S.editorGenerate),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Value(
                        pick: (draft) => draft.url,
                        builder: (value) => BovedaTextField(
                          value: value,
                          onChanged: cubit.onUrlChange,
                          label: S.editorWebsite,
                          placeholder: S.editorWebsitePlaceholder,
                          enabled: !state.isLoading,
                          keyboardType: TextInputType.url,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Value(
                        pick: (draft) => draft.notes,
                        builder: (value) => BovedaTextField(
                          value: value,
                          onChanged: cubit.onNotesChange,
                          label: S.editorNotes,
                          enabled: !state.isLoading,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          minLines: 3,
                          maxLines: null,
                        ),
                      ),
                      FormMessage(text: state.error, color: theme.colorScheme.error),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One field of the draft, rebuilt only when its own value changes.
class _Value extends StatelessWidget {
  const _Value({required this.pick, required this.builder});

  final String Function(VaultEntry draft) pick;
  final Widget Function(String value) builder;

  @override
  Widget build(BuildContext context) => BlocSelector<EntryEditorCubit, EntryEditorState, String>(
    selector: (state) => pick(state.draft),
    builder: (context, value) => builder(value),
  );
}

/// The entry's key, cut as its name is typed: the cap stamps a new initial and takes its hue.
class _KeyPreview extends StatelessWidget {
  const _KeyPreview();

  @override
  Widget build(BuildContext context) => Center(
    child: BlocSelector<EntryEditorCubit, EntryEditorState, String>(
      selector: (state) => state.draft.title,
      builder: (context, title) {
        final hue = keyCapColorFor(title, context.bovedaColors.keyCaps).cap;
        final initial = title.trim().isEmpty ? '' : String.fromCharCode(title.trim().runes.first).toUpperCase();
        return AnimatedSwitcher(
          duration: BovedaMotion.of(context, BovedaMotion.medium),
          reverseDuration: BovedaMotion.of(context, BovedaMotion.short),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation.drive(Tween(begin: 0.85, end: 1.0).chain(CurveTween(curve: BovedaMotion.seat))),
              child: child,
            ),
          ),
          child: KeyCap(key: ValueKey((initial, hue)), label: title, size: 64),
        );
      },
    ),
  );
}

/// The meter under the password, opening when there is something to rate.
class _EditorStrength extends StatelessWidget {
  const _EditorStrength();

  @override
  Widget build(BuildContext context) => BlocSelector<EntryEditorCubit, EntryEditorState, PasswordStrength?>(
    selector: (state) => state.draft.password.isEmpty ? null : state.strength,
    builder: (context, strength) => AnimatedSize(
      duration: BovedaMotion.of(context, BovedaMotion.medium),
      curve: BovedaMotion.emphasizedDecelerate,
      alignment: Alignment.topCenter,
      child: strength == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: PasswordStrengthIndicator(strength: strength),
              ),
            ),
    ),
  );
}
