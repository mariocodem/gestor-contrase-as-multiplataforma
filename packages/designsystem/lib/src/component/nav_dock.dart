import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icon/boveda_icon.dart';
import '../theme/motion.dart';
import '../theme/theme.dart';

const _dockHeight = 68.0;
const _dockMargin = 12.0;

/// How much of a top-level screen's bottom the dock covers; zero where a rail stands in for it.
class DockInset extends InheritedWidget {
  const DockInset({super.key, required this.height, required super.child});

  final double height;

  /// What the dock takes up on a phone, the system's own bottom inset included.
  static double extent(BuildContext context) => _dockHeight + _dockMargin + MediaQuery.paddingOf(context).bottom;

  static double of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DockInset>()?.height ?? 0;

  @override
  bool updateShouldNotify(DockInset old) => old.height != height;
}

/// Goes in a top-level [Scaffold]'s `bottomNavigationBar`, with `extendBody` on. The dock floats
/// above the shell, and this tells the scaffold about it: the FAB and snackbars stand clear, and
/// lists get it as bottom padding, while the content still scrolls underneath.
class ShellDockSpacer extends StatelessWidget {
  const ShellDockSpacer({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(height: DockInset.of(context));
}

class NavDockItem {
  const NavDockItem({required this.label, required this.icon, required this.selectedIcon});

  final String label;
  final BovedaIconData icon;
  final BovedaIconData selectedIcon;
}

/// The floating navigation of a phone: a flat bar with a solid indicator that slides between the
/// places. It's drawn over the pages, so hiding it for a pushed screen is a pure transform:
/// no page lays out again, on any frame of the transition. No blur behind it, on purpose; a
/// backdrop filter would re-render everything beneath it on every frame of every scroll.
class NavDock extends StatelessWidget {
  const NavDock({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.hidden = false,
  });

  final List<NavDockItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return AnimatedSlide(
      offset: hidden ? const Offset(0, 1.4) : Offset.zero,
      duration: BovedaMotion.of(context, const Duration(milliseconds: 280)),
      curve: hidden ? BovedaMotion.emphasizedAccelerate : BovedaMotion.emphasizedDecelerate,
      child: ExcludeFocus(
        excluding: hidden,
        child: ExcludeSemantics(
          excluding: hidden,
          child: IgnorePointer(
            ignoring: hidden,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, _dockMargin + bottom),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: RepaintBoundary(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.shell,
                        borderRadius: BovedaShapes.extraLarge,
                        border: Border.all(color: colors.plateEdge),
                        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4))],
                      ),
                      child: SizedBox(
                        height: _dockHeight,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final slot = constraints.maxWidth / items.length;
                            return Stack(
                              children: [
                                AnimatedPositioned(
                                  left: selectedIndex * slot + 6,
                                  top: 6,
                                  bottom: 6,
                                  width: slot - 12,
                                  duration: BovedaMotion.of(context, const Duration(milliseconds: 320)),
                                  curve: BovedaMotion.seat,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: colors.shellIndicator,
                                      borderRadius: BovedaShapes.medium,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    for (final (index, item) in items.indexed)
                                      Expanded(
                                        child: _DockSlot(
                                          item: item,
                                          selected: index == selectedIndex,
                                          onTap: () {
                                            if (index != selectedIndex) HapticFeedback.selectionClick();
                                            onSelected(index);
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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

class _DockSlot extends StatelessWidget {
  const _DockSlot({required this.item, required this.selected, required this.onTap});

  final NavDockItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    final ink = selected ? colors.onShellIndicator : colors.onShellVariant;
    final duration = BovedaMotion.of(context, BovedaMotion.medium);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation.drive(Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: BovedaMotion.seat))),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: BovedaIcon(selected ? item.selectedIcon : item.icon, key: ValueKey(selected), size: 22, color: ink),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: duration,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: ink),
              child: Text(item.label, maxLines: 1, overflow: TextOverflow.fade, softWrap: false, textScaler: TextScaler.noScaling),
            ),
          ],
        ),
      ),
    );
  }
}
