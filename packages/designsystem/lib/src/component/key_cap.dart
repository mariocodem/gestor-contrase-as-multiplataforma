import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

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
    canvas.save();
    canvas.scale(size.width / _unit, size.height / _unit);
    _paintCap(canvas, color.cap);
    // Sized from the drawn cap, not from the system font size: the cap is an icon, and it keeps
    // its proportions while it travels between the list row and the detail header.
    final stamp = _stampFor(initial, color.stamp);
    stamp.paint(canvas, Offset((_unit - stamp.width) / 2, _unit * _head * 0.58 - stamp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_KeyCapPainter old) => old.color != color || old.initial != initial;
}

// Everything below is drawn on a 100-unit grid and scaled, so a list of keys (and a key in flight,
// which changes size every frame) shares one path, one paint per hue and one layout per stamp.
const _unit = 100.0;

/// Head with rounded corners, the stub of the blade below it, and a ring hole punched through.
final Path _capPath = () {
  const headHeight = _unit * _head;
  final body = Path()
    ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, _unit, headHeight), const Radius.circular(_unit * 0.30)))
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(_unit * 0.37, headHeight - _unit * 0.08, _unit * 0.26, _unit - headHeight + _unit * 0.08),
        const Radius.circular(_unit * 0.05),
      ),
    );
  final hole = Path()..addOval(Rect.fromCircle(center: const Offset(_unit / 2, _unit * _ringY), radius: _unit * 0.075));
  return Path.combine(PathOperation.difference, body, hole);
}();

final _stamps = <(String, Color), TextPainter>{};

void _paintCap(Canvas canvas, Color cap) => canvas.drawPath(_capPath, Paint()..color = cap);

TextPainter _stampFor(String initial, Color color) {
  if (_stamps.length > 128) {
    for (final stamp in _stamps.values) {
      stamp.dispose();
    }
    _stamps.clear();
  }
  return _stamps.putIfAbsent(
    (initial, color),
    () => TextPainter(
      text: TextSpan(
        text: initial,
        style: TextStyle(
          fontFamily: uiFontFamily,
          package: 'boveda_designsystem',
          fontWeight: FontWeight.w700,
          fontSize: _unit * 0.40,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout(),
  );
}

/// The app's mark: a padlock drawn in a single line. Decorative; its screens carry their own title.
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
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_shackle, _swing]),
          builder: (context, _) => Transform.rotate(
            angle: _swing.value * math.pi / 180,
            alignment: Alignment(0, _ringY * 2 - 1),
            child: _EmblemCanvas(size: widget.size, shackle: _shackle.value),
          ),
        ),
      );
}

class _EmblemCanvas extends StatelessWidget {
  const _EmblemCanvas({required this.size, required this.shackle});

  final double size;
  final double shackle;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _EmblemPainter(Theme.of(context).colorScheme.onSurface, shackle)),
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  _EmblemPainter(this.ink, this.open);

  final Color ink;
  final double open;

  /// The Material Symbols lock, redrawn on its 960 grid so the shackle can move: [open] 0 is
  /// seated, 1 lifts it clear of the body on its long right leg. Below 0 it sinks slightly.
  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 960;
    const stroke = 56.0;
    final lift = open * 110;
    final outline = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.save();
    canvas.scale(unit);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(200, 400, 560, 460), const Radius.circular(72)), outline);
    canvas.drawCircle(const Offset(480, 630), 44, Paint()..color = ink);
    canvas.save();
    canvas.translate(0, -lift);
    canvas.drawArc(const Rect.fromLTWH(320, 110, 320, 320), math.pi, math.pi, false, outline);
    canvas.drawLine(
      const Offset(320, 270),
      const Offset(320, 360),
      Paint()
        ..color = ink
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
    // The long leg stays in the body however high the shackle rises.
    canvas.drawLine(Offset(640, 270 - lift), const Offset(640, 372), outline);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EmblemPainter old) => old.ink != ink || old.open != open;
}
