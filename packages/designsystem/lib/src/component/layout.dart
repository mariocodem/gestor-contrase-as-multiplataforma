import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icon/boveda_icon.dart';
import '../theme/theme.dart';

/// Widest a single column of forms or text should get on tablets and in landscape.
const readableWidth = 600.0;
const formWidth = 440.0;
const listWidth = 720.0;

/// Scrollable, vertically centred column with a readable width, for sign-in and lock forms.
class CenteredForm extends StatelessWidget {
  const CenteredForm({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: (constraints.maxHeight - 64).clamp(0, double.infinity)),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: formWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Empty and error states that say what happened and what to do next.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body, this.action});

  final BovedaIconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BovedaIcon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

/// Placeholder rows shaped like the real list while the vault decrypts.
class EntryRowPlaceholders extends StatefulWidget {
  const EntryRowPlaceholders({super.key, this.count = 6});

  final int count;

  @override
  State<EntryRowPlaceholders> createState() => _EntryRowPlaceholdersState();
}

class _EntryRowPlaceholdersState extends State<EntryRowPlaceholders> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700), lowerBound: 0.55, upperBound: 1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tone = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(height / 2)),
        );
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: _pulse,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.count; i++)
              SizedBox(
                height: 72,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(12)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [bar(140, 12), const SizedBox(height: 8), bar(96, 10)],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Group label for lists and settings: weight carries the rank, not colour.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Semantics(
        header: true,
        child: Text(text, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

/// A raised steel plate holding a secret: plate colour, 20 dp corners, no shadow.
class Plate extends StatelessWidget {
  const Plate({super.key, required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Material(
        color: context.bovedaColors.plate,
        shape: const RoundedRectangleBorder(borderRadius: BovedaShapes.large),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      );
}

/// The graphite shell behind a top-level screen's bar, edge to edge from under the status bar, with
/// what it holds kept to [contentWidth] and centred: on a wide window the title and the search line
/// up with the column below instead of starting at the rail.
class ShellTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellTopBar({super.key, required this.title, required this.contentWidth, this.actions = const [], this.bottom});

  final String title;
  final double contentWidth;
  final List<Widget> actions;
  final Widget? bottom;

  /// The docked search adds its field (56) and bottom padding (12).
  @override
  Size get preferredSize => Size.fromHeight(64 + (bottom == null ? 0 : 68));

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    final theme = Theme.of(context);
    final dark = ThemeData.estimateBrightnessForColor(colors.shell) == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(statusBarColor: Colors.transparent),
      child: Material(
        color: colors.shell,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: IconTheme.merge(
                data: IconThemeData(color: colors.onShell),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 64,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: Semantics(
                              header: true,
                              child: Text(title, style: theme.textTheme.titleLarge?.copyWith(color: colors.onShell)),
                            ),
                          ),
                          ...actions,
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                    ?bottom,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
