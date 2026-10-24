import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../common/messages.dart';
import '../common/strings.dart';

/// Window widths from which the navigation bar becomes a rail (Material's medium class).
const _railBreakpoint = 600.0;

enum _TopLevel {
  vault('/vault', S.navVault, BovedaIcons.key, BovedaIcons.keyFilled),
  generator('/generator', S.navGenerator, BovedaIcons.password, BovedaIcons.passwordFilled),
  settings('/settings', S.navSettings, BovedaIcons.settings, BovedaIcons.settingsFilled);

  const _TopLevel(this.path, this.label, this.icon, this.selectedIcon);

  final String path;
  final String label;
  final BovedaIconData icon;
  final BovedaIconData selectedIcon;
}

/// The unlocked part of the app: a navigation bar on phones, a rail on wider windows, and the
/// entry detail and editor pushed on top of the vault list. It exists only while the vault is
/// unlocked; locking removes it, and every screen state with it.
class UnlockedShell extends StatelessWidget {
  const UnlockedShell({super.key, required this.shell, required this.location});

  final StatefulNavigationShell shell;
  final String location;

  bool get _topLevel => _TopLevel.values.any((top) => top.path == location);

  void _select(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.bovedaColors;
    final rail = MediaQuery.sizeOf(context).width >= _railBreakpoint;

    if (!rail) {
      // On phones the bar gives pushed screens the whole height, sliding away as the entry slides in.
      final hideBar = !_topLevel;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemBarsOver(_topLevel ? colors.shell : theme.colorScheme.surface, hideBar ? theme.colorScheme.surface : colors.shell),
        child: Material(
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              Expanded(
                child: MediaQuery.removePadding(context: context, removeBottom: !hideBar, child: shell),
              ),
              _SlidingBar(
                hidden: hideBar,
                child: NavigationBar(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: _select,
                  destinations: [
                    for (final top in _TopLevel.values)
                      NavigationDestination(
                        icon: BovedaIcon(top.icon),
                        selectedIcon: BovedaIcon(top.selectedIcon),
                        label: top.label,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // The rail is graphite all the way up; one band under the status bar, in the colour of the
    // screen showing, keeps the clock legible over a light detail or editor.
    final band = _topLevel ? colors.shell : theme.colorScheme.surface;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemBarsOver(band, theme.colorScheme.surface),
      child: Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: band),
              duration: BovedaMotion.of(context, BovedaMotion.medium),
              builder: (context, color, _) => Container(height: MediaQuery.paddingOf(context).top, color: color),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: shell.currentIndex,
                      onDestinationSelected: _select,
                      destinations: [
                        for (final top in _TopLevel.values)
                          NavigationRailDestination(
                            icon: BovedaIcon(top.icon),
                            selectedIcon: BovedaIcon(top.selectedIcon),
                            label: Text(top.label),
                          ),
                      ],
                    ),
                    Expanded(child: shell),
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

/// The navigation bar sliding down out of the way (and back) as an entry opens and closes.
class _SlidingBar extends StatelessWidget {
  const _SlidingBar({required this.hidden, required this.child});

  final bool hidden;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRect(
        child: AnimatedAlign(
          alignment: Alignment.topCenter,
          heightFactor: hidden ? 0 : 1,
          duration: BovedaMotion.of(context, const Duration(milliseconds: 260)),
          curve: hidden ? BovedaMotion.emphasizedAccelerate : BovedaMotion.emphasizedDecelerate,
          child: ExcludeFocus(excluding: hidden, child: ExcludeSemantics(excluding: hidden, child: child)),
        ),
      );
}

/// Material's fade-through between sections: the old one fades out in 90 ms, then the new one fades
/// in and grows from 96 % over 210 ms. Every section stays alive underneath, keeping its state.
class FadeThroughBranches extends StatefulWidget {
  const FadeThroughBranches({super.key, required this.currentIndex, required this.children});

  final int currentIndex;
  final List<Widget> children;

  @override
  State<FadeThroughBranches> createState() => _FadeThroughBranchesState();
}

class _FadeThroughBranchesState extends State<FadeThroughBranches> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 300), value: 1);
  int? _previous;

  @override
  void didUpdateWidget(FadeThroughBranches old) {
    super.didUpdateWidget(old);
    if (old.currentIndex == widget.currentIndex) return;
    _previous = old.currentIndex;
    if (BovedaMotion.enabled(context)) {
      _controller.forward(from: 0).whenCompleteOrCancel(() {
        if (mounted) setState(() => _previous = null);
      });
    } else {
      _controller.value = 1;
      _previous = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fadeIn = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1));
    final grow = Tween(begin: 0.96, end: 1.0).animate(fadeIn);
    final fadeOut = ReverseAnimation(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3)));
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _branch(
            i,
            visible: i == widget.currentIndex || i == _previous,
            current: i == widget.currentIndex,
            // The same shape either way, so a section's navigator survives being switched away from.
            child: FadeTransition(
              opacity: i == widget.currentIndex ? fadeIn : fadeOut,
              child: ScaleTransition(
                scale: i == widget.currentIndex ? grow : const AlwaysStoppedAnimation(1.0),
                child: widget.children[i],
              ),
            ),
          ),
      ],
    );
  }

  Widget _branch(int index, {required bool visible, required bool current, required Widget child}) => Offstage(
        offstage: !visible,
        child: TickerMode(
          enabled: visible,
          child: IgnorePointer(ignoring: !current, child: ExcludeFocus(excluding: !current, child: child)),
        ),
      );
}
