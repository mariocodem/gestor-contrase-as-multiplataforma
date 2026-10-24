import 'dart:async';

import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:boveda_domain/boveda_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/dependencies.dart';
import '../../common/messages.dart';
import '../../common/sites.dart';
import '../../common/strength_text.dart';
import '../../common/strings.dart';
import '../../navigation/app_router.dart';
import '../key_cap_hero.dart';
import 'entry_detail_cubit.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => EntryDetailCubit(context.read<Dependencies>(), id),
        child: const _EntryDetailContent(),
      );
}

class _EntryDetailContent extends StatefulWidget {
  const _EntryDetailContent();

  @override
  State<_EntryDetailContent> createState() => _EntryDetailContentState();
}

class _EntryDetailContentState extends State<_EntryDetailContent> {
  final _passwordCopied = CopyConfirmation();
  late final StreamSubscription<EntryDetailEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = context.read<EntryDetailCubit>().events.listen((event) {
      if (!mounted) return;
      switch (event) {
        case DetailMessage(:final text):
          showMessage(context, text);
        case DetailDeleted(:final title):
          final messenger = ScaffoldMessenger.of(context);
          context.pop();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(S.detailDeleted(title))));
      }
    });
  }

  @override
  void dispose() {
    _events.cancel();
    _passwordCopied.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(VaultEntry entry) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const BovedaIcon(BovedaIcons.delete),
        title: Text(S.detailDeleteTitle(entry.title)),
        content: const Text(S.detailDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(S.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.detailDelete, style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await context.read<EntryDetailCubit>().delete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<EntryDetailCubit>();
    return BlocBuilder<EntryDetailCubit, EntryDetailState>(
      builder: (context, state) {
        final loaded = state is DetailLoaded ? state : null;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemBarsOver(theme.colorScheme.surface, theme.colorScheme.surface),
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.pop(),
                tooltip: S.back,
                icon: const BovedaIcon(BovedaIcons.arrowBack),
              ),
              actions: [
                if (loaded != null) ...[
                  IconButton(
                    onPressed: () => context.push(Paths.editEntry(loaded.entry.id)),
                    tooltip: S.detailEdit,
                    icon: const BovedaIcon(BovedaIcons.edit),
                  ),
                  PopupMenuButton<void>(
                    tooltip: S.more,
                    icon: const BovedaIcon(BovedaIcons.moreVert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => _confirmDelete(loaded.entry),
                        child: const Row(
                          children: [BovedaIcon(BovedaIcons.delete), SizedBox(width: 12), Text(S.detailDelete)],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            // The one thing people come here for, within thumb reach.
            bottomNavigationBar: loaded == null || loaded.entry.password.isEmpty
                ? null
                : Material(
                    color: theme.colorScheme.surface,
                    child: SafeArea(
                      top: false,
                      child: Center(
                        heightFactor: 1,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: readableWidth),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                onPressed: () {
                                  cubit.copyPassword();
                                  _passwordCopied.confirm();
                                },
                                child: ListenableBuilder(
                                  listenable: _passwordCopied,
                                  builder: (context, _) => CopyButtonContent(
                                    copied: _passwordCopied.isShowing,
                                    label: S.detailCopyPassword,
                                    copiedLabel: S.detailPasswordCopied,
                                    style: theme.textTheme.titleMedium,
                                    gap: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            body: switch (state) {
              DetailLoading() => const SizedBox.shrink(),
              DetailMissing() => EmptyState(
                  icon: BovedaIcons.key,
                  title: S.detailMissingTitle,
                  body: S.detailMissingBody,
                  action: TextButton(onPressed: () => context.pop(), child: const Text(S.back)),
                ),
              DetailLoaded() => _DetailBody(state: state),
            },
          ),
        );
      },
    );
  }
}

class _DetailBody extends StatefulWidget {
  const _DetailBody({required this.state});

  final DetailLoaded state;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  final _usernameCopied = CopyConfirmation();

  @override
  void dispose() {
    _usernameCopied.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<EntryDetailCubit>();
    final entry = widget.state.entry;
    final hairline = Divider(color: theme.colorScheme.outlineVariant);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: readableWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            _Header(entry: entry),
            const SizedBox(height: 20),
            Plate(
              child: Column(
                children: [
                  if (entry.username.isNotEmpty) ...[
                    _FieldRow(
                      label: S.detailUsername,
                      children: [
                        Expanded(child: Text(entry.username, style: theme.textTheme.bodyLarge)),
                        ListenableBuilder(
                          listenable: _usernameCopied,
                          builder: (context, _) => IconButton(
                            onPressed: () {
                              cubit.copyUsername();
                              _usernameCopied.confirm();
                            },
                            tooltip: S.detailCopyUsername,
                            icon: CopyIcon(copied: _usernameCopied.isShowing),
                          ),
                        ),
                      ],
                    ),
                    hairline,
                  ],
                  _FieldRow(
                    label: S.detailPassword,
                    children: entry.password.isEmpty
                        ? [
                            Expanded(
                              child: Text(
                                S.detailNoPassword,
                                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ]
                        : [
                            Expanded(
                              child: SecretText(
                                value: entry.password,
                                revealed: widget.state.passwordVisible,
                                hiddenDescription: S.detailHiddenPassword,
                              ),
                            ),
                            IconButton(
                              onPressed: cubit.togglePasswordVisible,
                              tooltip: widget.state.passwordVisible ? S.hidePassword : S.showPassword,
                              icon: BovedaIcon(
                                widget.state.passwordVisible ? BovedaIcons.visibilityOff : BovedaIcons.visibility,
                              ),
                            ),
                          ],
                  ),
                  if (entry.password.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: PasswordStrengthIndicator(strength: widget.state.strength),
                      ),
                    ),
                  if (entry.url.trim().isNotEmpty) ...[
                    hairline,
                    _FieldRow(
                      label: S.detailWebsite,
                      children: [
                        Expanded(child: Text(entry.url, style: theme.textTheme.bodyLarge)),
                        IconButton(
                          onPressed: () async {
                            final uri = Uri.tryParse(withScheme(entry.url.trim()));
                            if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                          },
                          tooltip: S.detailOpenWebsite,
                          icon: const BovedaIcon(BovedaIcons.openInNew),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (entry.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Plate(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(S.detailNotes),
                    const SizedBox(height: 4),
                    Text(entry.notes, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ],
            if (entry.updatedAt > 0)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: Text(
                  // The copy is Spanish only, so the date follows Spanish conventions everywhere.
                  S.detailUpdated(
                    DateFormat('d MMM y, HH:mm', 'es').format(DateTime.fromMillisecondsSinceEpoch(entry.updatedAt)),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.entry});

  final VaultEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final host = siteHost(entry.url);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          KeyCapHero(entryId: entry.id, child: KeyCap(label: entry.title, size: 60)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(header: true, child: Text(entry.title, style: theme.textTheme.headlineSmall)),
                if (host != null)
                  Text(host, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One field of the plate: a label above the value, with a trailing 48 dp action.
class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(label),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: children),
            ],
          ),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(text, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant));
  }
}
