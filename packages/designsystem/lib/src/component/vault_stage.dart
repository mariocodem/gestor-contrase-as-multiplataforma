import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/motion.dart';

const _groundLight = BoxDecoration(
  gradient: RadialGradient(
    center: Alignment(0, -0.6),
    radius: 1.2,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
  ),
);

const _groundDark = BoxDecoration(
  gradient: RadialGradient(
    center: Alignment(0, -0.6),
    radius: 1.2,
    colors: [Color(0xFF1C1C1C), Color(0xFF0A0A0A)],
  ),
);

/// The ground of the screens in front of the vault: a soft light from above, in either theme,
/// painted once into its own layer so nothing that moves above it repaints it.
class VaultStage extends StatelessWidget {
  const VaultStage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final icons = dark ? Brightness.light : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: icons,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness: icons,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [RepaintBoundary(child: DecoratedBox(decoration: dark ? _groundDark : _groundLight)), child],
      ),
    );
  }
}

/// A single thin ring around the padlock, with one short arc. The ring is painted once into its own
/// layer; every animation here only rotates that layer, and nothing runs while it is at rest.
///
/// It settles into place on arrival, turns while [working], spins open when [opening] turns true,
/// and each new [rejections] count kicks it back.
class VaultDial extends StatefulWidget {
  const VaultDial({
    super.key,
    required this.child,
    this.size = 128,
    this.working = false,
    this.opening = false,
    this.rejections = 0,
  });

  final Widget child;
  final double size;
  final bool working;
  final bool opening;
  final int rejections;

  @override
  State<VaultDial> createState() => _VaultDialState();
}

class _VaultDialState extends State<VaultDial> with SingleTickerProviderStateMixin {
  // In turns, unbounded: it keeps counting up while it works.
  late final AnimationController _turn = AnimationController.unbounded(vsync: this);
  var _arrived = false;

  bool get _animate => BovedaMotion.enabled(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_arrived) return;
    _arrived = true;
    if (!_animate) return;
    if (widget.working) {
      _spin();
    } else {
      _turn.value = -0.3;
      _turn.animateTo(0, duration: const Duration(milliseconds: 900), curve: BovedaMotion.emphasizedDecelerate);
    }
  }

  @override
  void didUpdateWidget(VaultDial old) {
    super.didUpdateWidget(old);
    if (!_animate) return;
    if (widget.opening && !old.opening) {
      _turn.animateTo(_turn.value + 0.5, duration: const Duration(milliseconds: 460), curve: BovedaMotion.emphasizedAccelerate);
    } else if (widget.rejections > old.rejections) {
      _turn.animateWith(
        SpringSimulation(
          SpringDescription.withDampingRatio(mass: 1, stiffness: 260, ratio: 0.38),
          _turn.value,
          _turn.value,
          -1.1,
        ),
      );
    } else if (widget.working != old.working) {
      widget.working ? _spin() : _settle();
    }
  }

  void _spin() {
    final from = _turn.value;
    _turn.repeat(min: from, max: from + 1, period: const Duration(milliseconds: 1400));
  }

  // Comes back to the top, the shortest way forward, instead of freezing where it was.
  void _settle() {
    _turn.animateTo(_turn.value.ceilToDouble(), duration: BovedaMotion.long, curve: BovedaMotion.emphasizedDecelerate);
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _turn,
              builder: (context, child) => Transform.rotate(angle: _turn.value * 2 * math.pi, child: child),
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size.square(widget.size),
                  painter: _RingPainter(track: scheme.outlineVariant, arc: scheme.onSurface),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.track, required this.arc});

  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = track,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2 - 0.35,
      0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2
        ..color = arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.track != track || old.arc != arc;
}
