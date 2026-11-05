import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icon/boveda_icon.dart';
import '../theme/motion.dart';
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

/// Empty and error states that say what happened and what to do next. The icon seats itself in its
/// well as the state appears.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body, this.action});

  final BovedaIconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.bovedaColors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.72, end: 1),
              duration: BovedaMotion.of(context, BovedaMotion.long),
              curve: BovedaMotion.seat,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.plate,
                  borderRadius: BovedaShapes.large,
                  border: Border.all(color: colors.plateEdge),
                ),
                child: SizedBox.square(
                  dimension: 72,
                  child: Center(child: BovedaIcon(icon, size: 28, color: theme.colorScheme.onSurfaceVariant)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
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
    final colors = context.bovedaColors;
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: colors.plate, borderRadius: BovedaShapes.large),
                  child: SizedBox(
                    height: 72,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(13)),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [bar(140, 12), const SizedBox(height: 8), bar(96, 10)],
                          ),
                        ],
                      ),
                    ),
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

/// A plate holding a secret: plate colour, 12 dp corners, a hairline edge, no shadow.
class Plate extends StatelessWidget {
  const Plate({super.key, required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    return Material(
      color: colors.plate,
      shape: RoundedRectangleBorder(borderRadius: BovedaShapes.large, side: BorderSide(color: colors.plateEdge)),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

const _titleRowExpanded = 84.0;
const _titleRowCollapsed = 56.0;
const _dockedBottom = 60.0;

/// The flat panel at the top of a place, closed by a hairline. What it holds keeps to [contentWidth],
/// centred, so on a wide window the title and search line up with the column below instead of
/// starting at the rail.
///
/// With [collapse] (0 open, 1 collapsed), it tightens as the list scrolls: only this panel lays out
/// again, and only inside that short range, while the list below it just scrolls.
class ShellHeader extends StatelessWidget {
  const ShellHeader({
    super.key,
    required this.title,
    required this.contentWidth,
    this.subtitle,
    this.actions = const [],
    this.bottom,
    this.collapse,
  });

  final String title;
  final String? subtitle;
  final double contentWidth;
  final List<Widget> actions;

  /// Docked under the title, 60 dp tall: the search field with its padding.
  final Widget? bottom;
  final ValueListenable<double>? collapse;

  /// The panel's open height, for whatever scrolls beneath it.
  static double extentOf(BuildContext context, {required bool hasBottom}) =>
      MediaQuery.paddingOf(context).top + _titleRowExpanded + (hasBottom ? _dockedBottom : 8);

  /// How far a list scrolls to close the panel.
  static const collapseDistance = _titleRowExpanded - _titleRowCollapsed;

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    final theme = Theme.of(context);
    final dark = ThemeData.estimateBrightnessForColor(colors.shell) == Brightness.dark;
    final titleRow = Row(
      children: [
        const SizedBox(width: 20),
        Expanded(
          child: Semantics(
            header: true,
            child: _Heading(title: title, subtitle: subtitle, collapse: collapse ?? const AlwaysStoppedAnimation(0.0)),
          ),
        ),
        ...actions,
        const SizedBox(width: 8),
      ],
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(statusBarColor: Colors.transparent),
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.shell,
            border: Border(bottom: BorderSide(color: colors.plateEdge)),
          ),
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: IconTheme.merge(
                  data: IconThemeData(color: colors.onShell),
                  child: DefaultTextStyle.merge(
                    style: theme.textTheme.titleLarge?.copyWith(color: colors.onShell),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (collapse == null)
                          SizedBox(height: _titleRowExpanded, child: titleRow)
                        else
                          ValueListenableBuilder<double>(
                            valueListenable: collapse!,
                            builder: (context, t, child) =>
                                SizedBox(height: _titleRowExpanded - t * collapseDistance, child: child),
                            child: titleRow,
                          ),
                        if (bottom != null) bottom! else const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The large title with its status line; as the panel closes, the line fades and the title shrinks
/// by transform, so its text is laid out once.
class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.subtitle, required this.collapse});

  final String title;
  final String? subtitle;
  final ValueListenable<double> collapse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.bovedaColors;
    return ValueListenableBuilder(
      valueListenable: collapse,
      builder: (context, t, _) {
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            maxHeight: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1 - t * 0.26,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(color: colors.onShell),
                  ),
                ),
                if (subtitle != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    heightFactor: 1 - t,
                    child: Opacity(
                      opacity: (1 - t * 1.6).clamp(0, 1),
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: colors.onShellVariant),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A [ShellHeader] as a scaffold's app bar, for places whose panel doesn't collapse.
class ShellTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellTopBar({super.key, required this.title, required this.contentWidth, this.subtitle, this.actions = const []});

  final String title;
  final String? subtitle;
  final double contentWidth;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(_titleRowExpanded + 8);

  @override
  Widget build(BuildContext context) =>
      ShellHeader(title: title, subtitle: subtitle, contentWidth: contentWidth, actions: actions);
}
