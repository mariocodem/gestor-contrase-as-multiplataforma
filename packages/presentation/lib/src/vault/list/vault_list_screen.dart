import 'dart:async';

import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../common/dependencies.dart';
import '../../common/error_messages.dart';
import '../../common/messages.dart';
import '../../common/strings.dart';
import '../../navigation/app_router.dart';
import 'entry_list_item.dart';
import 'entry_row.dart';
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

  // Scrolling drives these two directly: a scroll tick reaches the header and the button and
  // nothing else, and neither rebuilds this screen.
  final _collapse = ValueNotifier(0.0);
  final _fabExpanded = ValueNotifier(true);
  late final StreamSubscription<String> _messages;

  @override
  void initState() {
    super.initState();
    _messages = context.read<VaultListCubit>().messages.listen((text) {
      if (mounted) showMessage(context, text);
    });
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    // Two positions for a moment while the list cross-fades out and back in.
    if (_scroll.positions.length != 1) return;
    final offset = _scroll.offset;
    _collapse.value = (offset / ShellHeader.collapseDistance).clamp(0.0, 1.0);
    _fabExpanded.value = offset <= 0;
  }

  @override
  void dispose() {
    _messages.cancel();
    _scroll.dispose();
    _collapse.dispose();
    _fabExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VaultListCubit>();
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const ShellDockSpacer(),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _fabExpanded,
        builder: (context, expanded, _) => _NewEntryButton(expanded: expanded, onPressed: () => context.push(Paths.newEntry)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: BlocConsumer<VaultListCubit, VaultListState>(
              listenWhen: (previous, current) => _content(previous) != _content(current),
              listener: (context, state) {
                // Whatever replaces the list starts from an open header.
                if (_content(state) != _Content.entries) {
                  _collapse.value = 0;
                  _fabExpanded.value = true;
                }
              },
              builder: (context, state) => AnimatedSwitcher(
                // Placeholders, list and empty states cross-fade; rows already on screen don't blink.
                duration: BovedaMotion.of(context, BovedaMotion.medium),
                reverseDuration: BovedaMotion.of(context, BovedaMotion.short),
                switchInCurve: const Interval(0.25, 1),
                child: KeyedSubtree(key: ValueKey(_content(state)), child: _body(context, state)),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ShellHeader(
              title: S.appTitle,
              contentWidth: listWidth,
              collapse: _collapse,
              subtitle: S.vaultStatus,
              actions: [
                IconButton(onPressed: cubit.lock, tooltip: S.lock, icon: const BovedaIcon(BovedaIcons.lock)),
              ],
              bottom: _ShellSearch(onChanged: cubit.onQueryChange),
            ),
          ),
        ],
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
    final top = ShellHeader.extentOf(context, hasBottom: true);
    Widget belowHeader(Widget child) => Padding(padding: EdgeInsets.only(top: top), child: child);
    return switch (_content(state)) {
      _Content.loading => Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: top + 8),
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: listWidth), child: const EntryRowPlaceholders()),
          ),
        ),
      _Content.error => belowHeader(
          EmptyState(
            icon: BovedaIcons.warning,
            title: S.vaultErrorTitle,
            body: errorMessage(state.error!),
            action: OutlinedButton(onPressed: cubit.retry, child: const Text(S.retry)),
          ),
        ),
      _Content.empty => RefreshIndicator(
          onRefresh: cubit.refresh,
          edgeOffset: top,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: belowHeader(
                  const EmptyState(icon: BovedaIcons.key, title: S.vaultEmptyTitle, body: S.vaultEmptyBody),
                ),
              ),
            ),
          ),
        ),
      _Content.noResults => belowHeader(
          EmptyState(
            icon: BovedaIcons.search,
            title: S.vaultNoResultsTitle,
            body: S.vaultNoResultsBody(state.query.trim()),
          ),
        ),
      _Content.entries => RefreshIndicator(
          onRefresh: cubit.refresh,
          edgeOffset: top,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: listWidth),
              child: _EntryList(
                items: state.items,
                query: state.query,
                controller: _scroll,
                topInset: top,
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

/// The search field docked under the title on the graphite shell. Only this reads the counts, so a
/// keystroke rebuilds the field and the rows, not the screen around them.
class _ShellSearch extends StatefulWidget {
  const _ShellSearch({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_ShellSearch> createState() => _ShellSearchState();
}

class _ShellSearchState extends State<_ShellSearch> {
  final _controller = TextEditingController();
  var _empty = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() => _empty = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    final theme = Theme.of(context);
    const noEdge = OutlineInputBorder(borderRadius: BovedaShapes.medium, borderSide: BorderSide.none);
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
          height: 48,
          child: BlocSelector<VaultListCubit, VaultListState, int>(
            selector: (state) => state.totalCount,
            builder: (context, total) => TextField(
              controller: _controller,
              onChanged: (value) {
                final emptied = value.isEmpty != _empty;
                _empty = value.isEmpty;
                widget.onChanged(value);
                if (emptied) setState(() {});
              },
              textInputAction: TextInputAction.search,
              autocorrect: false,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              style: theme.textTheme.bodyLarge?.copyWith(color: colors.onShell),
              cursorColor: colors.shellIndicator,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.shellField,
                hintText: total > 0 ? S.vaultSearchCount(total) : S.vaultSearch,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(color: colors.onShellVariant),
                prefixIcon: Center(
                  widthFactor: 1,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
                    child: BovedaIcon(BovedaIcons.search, size: 22, color: colors.onShellVariant),
                  ),
                ),
                suffixIcon: _empty
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _MatchCount(),
                          IconButton(
                            onPressed: _clear,
                            tooltip: S.vaultClearSearch,
                            icon: BovedaIcon(BovedaIcons.close, color: colors.onShell),
                          ),
                        ],
                      ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: noEdge,
                enabledBorder: noEdge,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BovedaShapes.medium,
                  borderSide: BorderSide(color: colors.shellIndicator, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// How many keys the search left on the board.
class _MatchCount extends StatelessWidget {
  const _MatchCount();

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    return BlocSelector<VaultListCubit, VaultListState, int>(
      selector: (state) => state.items.length,
      builder: (context, count) => Semantics(
        liveRegion: true,
        label: S.vaultMatches(count),
        excludeSemantics: true,
        child: Text('$count', style: context.secretType.small.copyWith(color: colors.onShellVariant)),
      ),
    );
  }
}

/// "Nueva", collapsing to its icon once the list scrolls.
class _NewEntryButton extends StatelessWidget {
  const _NewEntryButton({required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: expanded ? null : S.vaultNewDescription,
        isExtended: expanded,
        extendedPadding: expanded ? null : const EdgeInsets.all(12),
        icon: const BovedaIcon(BovedaIcons.add, semanticLabel: S.vaultNewDescription),
        label: AnimatedSize(
          duration: BovedaMotion.of(context, BovedaMotion.medium),
          curve: BovedaMotion.emphasizedDecelerate,
          child: expanded ? const Text(S.vaultNew) : const SizedBox.shrink(),
        ),
      );
}

/// The rows, built as they scroll into view. The first screenful rises into place when the vault
/// opens, all of it on one controller; filtering afterwards is instant, because finding the key is
/// the point. A row found by id keeps its element (and its "copied" state) while the list narrows.
class _EntryList extends StatefulWidget {
  const _EntryList({
    required this.items,
    required this.query,
    required this.controller,
    required this.topInset,
    required this.onOpen,
    required this.onCopyPassword,
  });

  final List<EntryListItem> items;
  final String query;
  final ScrollController controller;
  final double topInset;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onCopyPassword;

  @override
  State<_EntryList> createState() => _EntryListState();
}

class _EntryListState extends State<_EntryList> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(vsync: this, duration: BovedaMotion.entrance);
  late final _query = ValueNotifier(widget.query);

  // The same widget instance for an unchanged entry, so the framework skips its whole subtree when
  // the list rebuilds on a keystroke; only the text listening to [_query] changes.
  final _rows = <String, (EntryListItem, Widget)>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    playEntrance(context, _entrance);
  }

  @override
  void didUpdateWidget(_EntryList old) {
    super.didUpdateWidget(old);
    _query.value = widget.query;
  }

  @override
  void dispose() {
    _entrance.dispose();
    _query.dispose();
    super.dispose();
  }

  Widget _row(int index, EntryListItem item) {
    final cached = _rows[item.id];
    if (cached != null && cached.$1 == item) return cached.$2;
    final row = Stagger(
      key: ValueKey(item.id),
      animation: _entrance,
      index: index,
      child: EntryRow(
        item: item,
        query: _query,
        onTap: () => widget.onOpen(item.id),
        onCopyPassword: () => widget.onCopyPassword(item.id),
      ),
    );
    _rows[item.id] = (item, row);
    return row;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final indexOf = {for (final (index, item) in items.indexed) item.id: index};
    return ListView.builder(
      controller: widget.controller,
      physics: const AlwaysScrollableScrollPhysics(),
      // Room under the last row so the FAB never covers its copy button.
      padding: EdgeInsets.only(top: widget.topInset + 8, bottom: 96 + MediaQuery.paddingOf(context).bottom),
      itemCount: items.length,
      findChildIndexCallback: (key) => indexOf[(key as ValueKey<String>).value],
      itemBuilder: (context, index) => _row(index, items[index]),
    );
  }
}
