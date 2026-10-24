import 'dart:async';

import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../common/dependencies.dart';
import '../../common/error_messages.dart';
import '../../common/messages.dart';
import '../../common/search_highlight.dart';
import '../../common/strings.dart';
import '../../navigation/app_router.dart';
import '../key_cap_hero.dart';
import 'vault_list_cubit.dart';

class VaultListScreen extends StatelessWidget {
  const VaultListScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => VaultListCubit(context.read<Dependencies>()),
        child: const _VaultListContent(),
      );
}

class _VaultListContent extends StatefulWidget {
  const _VaultListContent();

  @override
  State<_VaultListContent> createState() => _VaultListContentState();
}

class _VaultListContentState extends State<_VaultListContent> {
  final _scroll = ScrollController();
  var _fabExpanded = true;
  late final StreamSubscription<String> _messages;

  @override
  void initState() {
    super.initState();
    _messages = context.read<VaultListCubit>().messages.listen((text) {
      if (mounted) showMessage(context, text);
    });
    _scroll.addListener(() {
      final expanded = !_scroll.hasClients || _scroll.offset <= 0;
      if (expanded != _fabExpanded) setState(() => _fabExpanded = expanded);
    });
  }

  @override
  void dispose() {
    _messages.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VaultListCubit>();
    return BlocBuilder<VaultListCubit, VaultListState>(
      builder: (context, state) => Scaffold(
        appBar: ShellTopBar(
          title: S.appTitle,
          contentWidth: listWidth,
          actions: [
            IconButton(onPressed: cubit.lock, tooltip: S.lock, icon: const BovedaIcon(BovedaIcons.lock)),
          ],
          bottom: _ShellSearch(totalCount: state.totalCount, onChanged: cubit.onQueryChange),
        ),
        floatingActionButton: _NewEntryButton(expanded: _fabExpanded, onPressed: () => context.push(Paths.newEntry)),
        body: AnimatedSwitcher(
          // Placeholders, list and empty states cross-fade; rows already on screen don't blink.
          duration: BovedaMotion.of(context, BovedaMotion.medium),
          reverseDuration: BovedaMotion.of(context, BovedaMotion.short),
          switchInCurve: const Interval(0.25, 1),
          child: KeyedSubtree(key: ValueKey(_content(state)), child: _body(context, state)),
        ),
      ),
    );
  }

  _Content _content(VaultListState state) => switch (state) {
        VaultListState(isLoading: true) => _Content.loading,
        VaultListState(error: != null) => _Content.error,
        VaultListState(totalCount: 0) => _Content.empty,
        VaultListState(items: []) => _Content.noResults,
        _ => _Content.entries,
      };

  Widget _body(BuildContext context, VaultListState state) {
    final cubit = context.read<VaultListCubit>();
    return switch (_content(state)) {
      _Content.loading => const Align(
          alignment: Alignment.topCenter,
          child: Padding(padding: EdgeInsets.only(top: 8), child: EntryRowPlaceholders()),
        ),
      _Content.error => EmptyState(
          icon: BovedaIcons.warning,
          title: S.vaultErrorTitle,
          body: errorMessage(state.error!),
          action: OutlinedButton(onPressed: cubit.retry, child: const Text(S.retry)),
        ),
      _Content.empty => RefreshIndicator(
          onRefresh: cubit.refresh,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: const EmptyState(icon: BovedaIcons.key, title: S.vaultEmptyTitle, body: S.vaultEmptyBody),
              ),
            ),
          ),
        ),
      _Content.noResults => EmptyState(
          icon: BovedaIcons.search,
          title: S.vaultNoResultsTitle,
          body: S.vaultNoResultsBody(state.query.trim()),
        ),
      _Content.entries => RefreshIndicator(
          onRefresh: cubit.refresh,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: listWidth),
              child: _AnimatedEntryList(
                items: state.items,
                query: state.query,
                controller: _scroll,
                onOpen: (id) => context.push(Paths.entry(id)),
                onCopyPassword: cubit.copyPassword,
              ),
            ),
          ),
        ),
    };
  }
}

enum _Content { loading, error, empty, noResults, entries }

/// The search field docked under the title on the graphite shell.
class _ShellSearch extends StatefulWidget {
  const _ShellSearch({required this.totalCount, required this.onChanged});

  final int totalCount;
  final ValueChanged<String> onChanged;

  @override
  State<_ShellSearch> createState() => _ShellSearchState();
}

class _ShellSearchState extends State<_ShellSearch> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Theme(
        data: theme.copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: colors.shellIndicator,
            selectionColor: colors.shellIndicator.withValues(alpha: 0.35),
            selectionHandleColor: colors.shellIndicator,
          ),
        ),
        child: SizedBox(
          height: 56,
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              widget.onChanged(value);
              setState(() {});
            },
            textInputAction: TextInputAction.search,
            autocorrect: false,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            style: theme.textTheme.bodyLarge?.copyWith(color: colors.onShell),
            cursorColor: colors.shellIndicator,
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.shellField,
              hintText: widget.totalCount > 0 ? S.vaultSearchCount(widget.totalCount) : S.vaultSearch,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(color: colors.onShellVariant),
              prefixIcon: BovedaIcon(BovedaIcons.search, color: colors.onShellVariant),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clear,
                      tooltip: S.vaultClearSearch,
                      icon: BovedaIcon(BovedaIcons.close, color: colors.onShell),
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: const OutlineInputBorder(borderRadius: BovedaShapes.extraLarge, borderSide: BorderSide.none),
              enabledBorder: const OutlineInputBorder(borderRadius: BovedaShapes.extraLarge, borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(borderRadius: BovedaShapes.extraLarge, borderSide: BorderSide.none),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Nueva" in polished brass, collapsing to its icon once the list scrolls.
class _NewEntryButton extends StatelessWidget {
  const _NewEntryButton({required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: expanded ? null : S.vaultNewDescription,
        isExtended: expanded,
        extendedPadding: expanded ? null : const EdgeInsets.all(16),
        icon: const BovedaIcon(BovedaIcons.add, semanticLabel: S.vaultNewDescription),
        label: AnimatedSize(
          duration: BovedaMotion.of(context, BovedaMotion.medium),
          curve: BovedaMotion.emphasizedDecelerate,
          child: expanded ? const Text(S.vaultNew) : const SizedBox.shrink(),
        ),
      );
}

/// The rows, animated as a search narrows or widens them: rows that stay slide into their new
/// places as the others fold away, so the key you're after is easy to follow.
class _AnimatedEntryList extends StatefulWidget {
  const _AnimatedEntryList({
    required this.items,
    required this.query,
    required this.controller,
    required this.onOpen,
    required this.onCopyPassword,
  });

  final List<EntryListItem> items;
  final String query;
  final ScrollController controller;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onCopyPassword;

  @override
  State<_AnimatedEntryList> createState() => _AnimatedEntryListState();
}

class _AnimatedEntryListState extends State<_AnimatedEntryList> {
  final _listKey = GlobalKey<SliverAnimatedListState>();
  late List<EntryListItem> _shown = [...widget.items];

  @override
  void didUpdateWidget(_AnimatedEntryList old) {
    super.didUpdateWidget(old);
    final list = _listKey.currentState;
    if (list == null) {
      _shown = [...widget.items];
      return;
    }
    final animate = BovedaMotion.enabled(context);
    final incoming = {for (final item in widget.items) item.id};
    for (var i = _shown.length - 1; i >= 0; i--) {
      if (incoming.contains(_shown[i].id)) continue;
      final removed = _shown.removeAt(i);
      list.removeItem(
        i,
        (context, animation) => _transition(animation, _row(removed, query: old.query)),
        duration: animate ? const Duration(milliseconds: 150) : Duration.zero,
      );
    }
    for (var j = 0; j < widget.items.length; j++) {
      final item = widget.items[j];
      if (j < _shown.length && _shown[j].id == item.id) {
        _shown[j] = item;
        continue;
      }
      final from = _shown.indexWhere((shown) => shown.id == item.id);
      if (from >= 0) {
        // Moved (a renamed entry): it leaves its old place at once and arrives at the new one.
        _shown.removeAt(from);
        list.removeItem(from, (context, animation) => const SizedBox.shrink(), duration: Duration.zero);
      }
      _shown.insert(j, item);
      list.insertItem(j, duration: animate ? BovedaMotion.medium : Duration.zero);
    }
  }

  Widget _transition(Animation<double> animation, Widget child) => SizeTransition(
        sizeFactor: CurvedAnimation(parent: animation, curve: BovedaMotion.emphasizedDecelerate),
        child: FadeTransition(opacity: CurvedAnimation(parent: animation, curve: const Interval(0.25, 1)), child: child),
      );

  Widget _row(EntryListItem item, {required String query}) => _EntryRow(
        item: item,
        query: query,
        onTap: () => widget.onOpen(item.id),
        onCopyPassword: () => widget.onCopyPassword(item.id),
      );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return CustomScrollView(
      controller: widget.controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 4)),
        SliverAnimatedList(
          key: _listKey,
          initialItemCount: _shown.length,
          itemBuilder: (context, index, animation) =>
              _transition(animation, _row(_shown[index], query: widget.query)),
        ),
        // Room under the last row so the FAB never covers its copy button.
        SliverPadding(padding: EdgeInsets.only(bottom: 96 + bottomInset)),
      ],
    );
  }
}

class _EntryRow extends StatefulWidget {
  const _EntryRow({required this.item, required this.query, required this.onTap, required this.onCopyPassword});

  final EntryListItem item;
  final String query;
  final VoidCallback onTap;
  final VoidCallback onCopyPassword;

  @override
  State<_EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<_EntryRow> {
  final _copied = CopyConfirmation();

  @override
  void dispose() {
    _copied.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: widget.onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 4, top: 8, bottom: 8),
                child: Row(
                  children: [
                    KeyCapHero(entryId: item.id, child: KeyCap(label: item.title)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text.rich(
                            highlightMatches(item.title, widget.query),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge,
                          ),
                          if (item.subtitle.isNotEmpty)
                            Text.rich(
                              highlightMatches(item.subtitle, widget.query),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    if (item.hasPassword)
                      ListenableBuilder(
                        listenable: _copied,
                        builder: (context, _) => IconButton(
                          onPressed: () {
                            widget.onCopyPassword();
                            _copied.confirm();
                          },
                          tooltip: S.vaultCopyPasswordOf(item.title),
                          icon: CopyIcon(copied: _copied.isShowing),
                        ),
                      )
                    else
                      const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(indent: 72),
      ],
    );
  }
}
