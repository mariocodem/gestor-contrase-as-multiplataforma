import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../common/search_highlight.dart';
import '../../common/strings.dart';
import '../key_cap_hero.dart';
import 'entry_list_item.dart';

/// One entry of the list, on its own plate: its key cap, title, subtitle and a button to copy the
/// password.
class EntryRow extends StatefulWidget {
  const EntryRow({
    super.key,
    required this.item,
    required this.query,
    required this.onTap,
    required this.onCopyPassword,
  });

  final EntryListItem item;

  /// What the search is matching: only the row's text follows it, so a keystroke leaves the cap and
  /// the copy button alone.
  final ValueListenable<String> query;
  final VoidCallback onTap;
  final VoidCallback onCopyPassword;

  @override
  State<EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<EntryRow> {
  final _copied = CopyConfirmation();

  @override
  void dispose() {
    _copied.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: PressSurface(
        onTap: widget.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8, top: 8, bottom: 8),
            child: Row(
              children: [
                KeyCapHero(entryId: item.id, child: KeyCap(label: item.title, size: 44)),
                const SizedBox(width: 14),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: widget.query,
                    builder: (context, query, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          highlightMatches(item.title, query),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (item.subtitle.isNotEmpty)
                          Text.rich(
                            highlightMatches(item.subtitle, query),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                      ],
                    ),
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
                      color: _copied.isShowing ? scheme.primary : scheme.onSurfaceVariant,
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
    );
  }
}
