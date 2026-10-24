import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/theme.dart';
import '../theme/typography.dart';

const _head = 0.84;

/// The ring hole's centre, as a fraction of the cap's height: the key hangs from here.
const _ringY = _head * 0.19;

/// Lets the lock screen fade in before the shackle drops, so the click is seen.
const _closeDelayMs = 220;

/// The cap colour of [label]: a hash of the trimmed, lower-cased label (Java's String.hashCode, as
/// the Android app computed it) modulo the number of hues, so an account keeps the same cap
/// everywhere and on every version of the app.
KeyCapColor keyCapColorFor(String label, List<KeyCapColor> caps) {
  var hash = 0;
  for (final unit in label.trim().toLowerCase().codeUnits) {
    hash = (31 * hash + unit) & 0xFFFFFFFF;
  }
  // floorMod of the signed 32-bit hash by a power of two keeps its low bits.
  return caps[hash % caps.length];
}

/// An account's identity: an anodized key cap with a punched ring hole and the stamped initial of
/// [label]. Decorative for accessibility; the label is always readable next to it.
class KeyCap extends StatelessWidget {
  const KeyCap({super.key, required this.label, this.size = 40});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = keyCapColorFor(label, context.bovedaColors.keyCaps);
    final trimmed = label.trim();
    final initial = trimmed.isEmpty ? '?' : String.fromCharCode(trimmed.runes.first).toUpperCase();
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _KeyCapPainter(color, initial)),
      ),
    );
  }
}

class _KeyCapPainter extends CustomPainter {
  _KeyCapPainter(this.color, this.initial);

  final KeyCapColor color;
  final String initial;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(keyCapPath(size), Paint()..color = color.cap);
    // Sized from the drawn cap, not from the system font size: the cap is an icon, and it keeps
    // its proportions while it travels between the list row and the detail header.
    final text = TextPainter(
      text: TextSpan(
        text: initial,
        style: TextStyle(
          fontFamily: uiFontFamily,
          package: 'boveda_designsystem',
          fontWeight: FontWeight.w700,
          fontSize: size.width * 0.40,
          color: color.stamp,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout();
    text.paint(canvas, Offset((size.width - text.width) / 2, size.height * _head * 0.58 - text.height / 2));
  }

  @override
  bool shouldRepaint(_KeyCapPainter old) => old.color != color || old.initial != initial;
}

/// Head with rounded corners, the stub of the blade below it, and a ring hole punched through.
Path keyCapPath(Size size) {
  final w = size.width;
  final h = size.height;
  final headHeight = h * _head;
  final body = Path()
    ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, headHeight), Radius.circular(w * 0.30)))
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.37, headHeight - w * 0.08, w * 0.26, h - headHeight + w * 0.08),
        Radius.circular(w * 0.05),
      ),
    );
  final hole = Path()..addOval(Rect.fromCircle(center: Offset(w / 2, h * _ringY), radius: w * 0.075));
  return Path.combine(PathOperation.difference, body, hole);
}

/// The app's mark: the same key cap in graphite with a brass padlock, for the sign-in and lock
/// screens. Decorative; those screens carry their own title.
class AppEmblem extends StatelessWidget {
  const AppEmblem({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) => _EmblemCanvas(size: size, shackle: 0);
}

/// [AppEmblem] acting out the vault's state. The shackle lifts when [locked] turns false and snaps
/// shut when it turns true; each new [rejections] count swings the key on its hook and rattles the
/// shackle, as a lock does when the wrong key is tried. [startOpen] begins with the shackle up, for
/// arriving from an unlocked vault, so the user sees it close.
class LockEmblem extends StatefulWidget {
  const LockEmblem({
    super.key,
    required this.locked,
    required this.rejections,
    this.size = 76,
    this.startOpen = false,
  });

  final bool locked;
  final int rejections;
  final double size;
  final bool startOpen;

  @override
  State<LockEmblem> createState() => _LockEmblemState();
}

class _LockEmblemState extends State<LockEmblem> with TickerProviderStateMixin {
  // Unbounded: the shackle dips below 0 for the click and the key swings past centre.
  late final AnimationController _shackle =
      AnimationController.unbounded(vsync: this, value: widget.startOpen || !widget.locked ? 1 : 0);
  late final AnimationController _swing = AnimationController.unbounded(vsync: this);
  late final AnimationController _click =
      AnimationController(vsync: this, duration: const Duration(milliseconds: _closeDelayMs + 240))
        ..addListener(() => _shackle.value = _clickCurve.transform(_click.value));
  Animatable<double> _clickCurve = ConstantTween(0);

  @override
  void initState() {
    super.initState();
    if (widget.locked && _shackle.value > 0) WidgetsBinding.instance.addPostFrameCallback((_) => _close());
  }

  @override
  void didUpdateWidget(LockEmblem old) {
    super.didUpdateWidget(old);
    if (old.locked != widget.locked) {
      widget.locked ? _close() : _open();
    }
    if (old.rejections != widget.rejections && widget.rejections > old.rejections) _reject();
  }

  bool get _animate => mounted && BovedaMotion.enabled(context);

  void _open() {
    _click.stop();
    if (!_animate) {
      _shackle.value = 1;
      return;
    }
    _shackle.animateTo(1, duration: const Duration(milliseconds: 220), curve: BovedaMotion.emphasizedDecelerate);
  }

  // Accelerates down, seats a hair too far, settles: the click of a closing padlock.
  void _close() {
    if (_shackle.value <= 0) return;
    if (!_animate) {
      _shackle.value = 0;
      return;
    }
    final from = _shackle.value;
    _clickCurve = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(from), weight: _closeDelayMs.toDouble()),
      TweenSequenceItem(
        tween: Tween(begin: from, end: -0.12).chain(CurveTween(curve: BovedaMotion.emphasizedAccelerate)),
        weight: 150,
      ),
      TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.0).chain(CurveTween(curve: BovedaMotion.standard)), weight: 90),
    ]);
    _click.forward(from: 0);
  }

  void _reject() {
    HapticFeedback.heavyImpact();
    if (!_animate) return;
    _click.stop();
    // A hanging key is a pendulum: a push, then a swing that dies out in under half a second.
    _swing.animateWith(
      SpringSimulation(SpringDescription.withDampingRatio(mass: 1, stiffness: 420, ratio: 0.32), 0, 0, 340),
    );
    _shackle
        .animateTo(0.2, duration: const Duration(milliseconds: 70), curve: BovedaMotion.emphasizedDecelerate)
        .whenComplete(() {
      if (mounted) {
        _shackle.animateTo(0, duration: const Duration(milliseconds: 130), curve: BovedaMotion.emphasizedAccelerate);
      }
    });
  }

  @override
  void dispose() {
    _click.dispose();
    _shackle.dispose();
    _swing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_shackle, _swing]),
        builder: (context, _) => Transform.rotate(
          angle: _swing.value * math.pi / 180,
          alignment: Alignment(0, _ringY * 2 - 1),
          child: _EmblemCanvas(size: widget.size, shackle: _shackle.value),
        ),
      );
}

class _EmblemCanvas extends StatelessWidget {
  const _EmblemCanvas({required this.size, required this.shackle});

  final double size;
  final double shackle;

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _EmblemPainter(colors.shell, colors.shellIndicator, shackle)),
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  _EmblemPainter(this.cap, this.lock, this.open);

  final Color cap;
  final Color lock;
  final double open;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(keyCapPath(size), Paint()..color = cap);
    _drawPadlock(canvas, size);
  }

  /// The Material Symbols lock, redrawn on its 960 grid so the shackle can move: [open] 0 is
  /// seated, 1 lifts it clear of the body on its long right leg. Below 0 it sinks slightly.
  void _drawPadlock(Canvas canvas, Size size) {
    final box = size.width * 0.40;
    final unit = box / 960;
    const stroke = 80.0;
    final lift = open * 110;
    final outline = Paint()
      ..color = lock
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.save();
    canvas.translate((size.width - box) / 2, (size.height - box) / 2 + size.height * 0.07);
    canvas.scale(unit);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(200, 360, 560, 480), const Radius.circular(40)), outline);
    canvas.drawCircle(const Offset(480, 600), 80, Paint()..color = lock);
    canvas.save();
    canvas.translate(0, -lift);
    canvas.drawArc(const Rect.fromLTWH(320, 80, 320, 320), math.pi, math.pi, false, outline);
    canvas.drawLine(
      const Offset(320, 240),
      const Offset(320, 320),
      Paint()
        ..color = lock
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
    // The long leg stays in the body however high the shackle rises.
    canvas.drawLine(Offset(640, 240 - lift), const Offset(640, 330), outline);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EmblemPainter old) => old.cap != cap || old.lock != lock || old.open != open;
}
