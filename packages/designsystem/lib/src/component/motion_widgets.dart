import 'package:flutter/material.dart';

import '../icon/boveda_icon.dart';
import '../icon/boveda_icons.dart';
import '../theme/motion.dart';
import '../theme/theme.dart';

/// Starts a screen's entrance once, or skips to its end when the system asks for no animations.
/// Call from `didChangeDependencies`: it reads the media query.
void playEntrance(BuildContext context, AnimationController controller) {
  if (!controller.isDismissed) return;
  if (BovedaMotion.enabled(context)) {
    controller.forward();
  } else {
    controller.value = 1;
  }
}

/// One item of a sequence rising into place. Every item of a screen shares [animation], a single
/// controller, so a whole list arrives on one ticker; items past [maxStaggered] arrive with the last
/// one, and once it has played a row built by scrolling costs nothing.
class Stagger extends StatelessWidget {
  const Stagger({
    super.key,
    required this.animation,
    required this.index,
    required this.child,
    this.step = 0.07,
    this.span = 0.55,
    this.distance = 14,
    this.maxStaggered = 8,
  });

  final Animation<double> animation;
  final int index;
  final Widget child;
  final double step;
  final double span;
  final double distance;
  final int maxStaggered;

  @override
  Widget build(BuildContext context) {
    final start = (index.clamp(0, maxStaggered) * step).clamp(0.0, 1 - span);
    final arrival = animation.drive(CurveTween(curve: Interval(start, start + span, curve: BovedaMotion.emphasizedDecelerate)));
    return FadeTransition(
      opacity: arrival,
      child: AnimatedBuilder(
        animation: arrival,
        builder: (context, child) => Transform.translate(offset: Offset(0, (1 - arrival.value) * distance), child: child),
        child: child,
      ),
    );
  }
}

/// A tappable plate that gives under the thumb. The press waits for the gesture to be a tap, so
/// scrolling past doesn't dent every row, and it animates a transform only.
class PressSurface extends StatefulWidget {
  const PressSurface({
    super.key,
    required this.child,
    required this.onTap,
    this.color,
    this.borderRadius = BovedaShapes.large,
    this.pressedScale = 0.975,
    this.edge,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius borderRadius;
  final double pressedScale;
  final Color? edge;

  @override
  State<PressSurface> createState() => _PressSurfaceState();
}

class _PressSurfaceState extends State<PressSurface> {
  final _pressed = ValueNotifier(false);

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    final duration = BovedaMotion.of(context, BovedaMotion.press);
    return ValueListenableBuilder(
      valueListenable: _pressed,
      builder: (context, pressed, child) => AnimatedScale(
        scale: pressed ? widget.pressedScale : 1,
        duration: duration,
        curve: BovedaMotion.standard,
        child: child,
      ),
      child: Material(
        color: widget.color ?? colors.plate,
        shape: RoundedRectangleBorder(
          borderRadius: widget.borderRadius,
          side: BorderSide(color: widget.edge ?? colors.plateEdge),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) => _pressed.value = value,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}

/// The show/hide eye, turning over as it changes.
class EyeIcon extends StatelessWidget {
  const EyeIcon({super.key, required this.open});

  /// True while the secret shows, so the icon offers to hide it.
  final bool open;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: BovedaMotion.of(context, BovedaMotion.short),
        switchInCurve: BovedaMotion.standard,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween(begin: 0.7, end: 1.0).animate(animation), child: child),
        ),
        child: BovedaIcon(open ? BovedaIcons.visibilityOff : BovedaIcons.visibility, key: ValueKey(open)),
      );
}
