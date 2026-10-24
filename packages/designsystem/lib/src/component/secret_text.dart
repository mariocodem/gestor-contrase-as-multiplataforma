import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/theme.dart';

/// Always the same number of dots, so a hidden secret doesn't reveal its length.
const mask = '••••••••••';
const _maskDot = 0x2022;

/// How long one character takes to roll through its window.
const _windowMs = 180.0;

final _digitPattern = RegExp(r'\p{Nd}', unicode: true);
final _letterDigitOrSpace = RegExp(r'[\p{L}\p{Nd}\s]', unicode: true);

bool _isDigit(int unit) =>
    (unit >= 0x30 && unit <= 0x39) || (unit > 0x7F && _digitPattern.hasMatch(String.fromCharCode(unit)));

/// Neither a letter, a digit nor whitespace.
bool _isSymbol(int unit) => !_letterDigitOrSpace.hasMatch(String.fromCharCode(unit));

/// Digits and symbols take their own inks, so a password can be read back character by character.
TextSpan colorByCharacterClass(String text, {required Color digit, required Color symbol, TextStyle? style}) {
  final spans = <TextSpan>[];
  final run = StringBuffer();
  Color? runColor;
  var started = false;
  void flush() {
    if (run.isEmpty) return;
    spans.add(TextSpan(text: run.toString(), style: runColor == null ? null : TextStyle(color: runColor)));
    run.clear();
  }

  for (final unit in text.codeUnits) {
    final color = _isDigit(unit) ? digit : (_isSymbol(unit) ? symbol : null);
    if (started && color != runColor) flush();
    runColor = color;
    started = true;
    run.writeCharCode(unit);
  }
  flush();
  return TextSpan(style: style, children: spans);
}

/// A text controller for a secret shown in clear: digits and symbols in their own inks.
class SecretTextEditingController extends TextEditingController {
  SecretTextEditingController({super.text});

  Color? digit;
  Color? symbol;

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final digitInk = digit;
    final symbolInk = symbol;
    if (digitInk == null || symbolInk == null || (withComposing && value.isComposingRangeValid)) {
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }
    return colorByCharacterClass(text, digit: digitInk, symbol: symbolInk, style: style);
  }
}

/// A secret behind [mask]; revealing or hiding it rolls the characters like lock pins.
class SecretText extends StatelessWidget {
  const SecretText({
    super.key,
    required this.value,
    required this.revealed,
    required this.hiddenDescription,
    this.style,
    this.color,
  });

  final String value;
  final bool revealed;
  final String hiddenDescription;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) => TumblerText(
        text: revealed ? value : mask,
        style: style ?? context.secretType.medium,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        semanticsLabel: revealed ? null : hiddenDescription,
      );
}

/// Secret text that changes like the pin tumblers of a lock: when [text] changes, each character
/// rolls up through its own window, left to right, and characters that stay the same don't move.
/// Digits and symbols take their own colours, as in [colorByCharacterClass].
///
/// The style must be monospaced: every character gets the same cell, so the grid wraps the way the
/// text would. [animate] false swaps instantly (while dragging a slider, for instance).
/// [semanticsLabel] replaces the text for accessibility, for a masked secret.
class TumblerText extends StatefulWidget {
  const TumblerText({
    super.key,
    required this.text,
    this.style,
    this.color,
    this.animate = true,
    this.semanticsLabel,
    this.liveRegion = false,
  });

  final String text;
  final TextStyle? style;
  final Color? color;
  final bool animate;
  final String? semanticsLabel;
  final bool liveRegion;

  @override
  State<TumblerText> createState() => _TumblerTextState();
}

class _TumblerTextState extends State<TumblerText> with SingleTickerProviderStateMixin {
  late String _from = widget.text;
  late String _to = widget.text;
  late final AnimationController _roll = AnimationController(vsync: this);
  _GlyphCache? _glyphs;

  @override
  void didUpdateWidget(TumblerText old) {
    super.didUpdateWidget(old);
    if (widget.text == _to) return;
    if (!widget.animate || !BovedaMotion.enabled(context)) {
      _roll.stop();
      setState(() => _from = _to = widget.text);
      return;
    }
    setState(() {
      _from = _to;
      _to = widget.text;
    });
    final duration = _rollDuration(math.max(_from.length, _to.length));
    _roll
      ..duration = Duration(milliseconds: duration.round())
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _roll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.secretType.medium;
    final colors = context.bovedaColors;
    final base = widget.color ?? style.color ?? DefaultTextStyle.of(context).style.color ?? Theme.of(context).colorScheme.onSurface;
    final candidate = _GlyphCache(
      style: style,
      scaler: MediaQuery.textScalerOf(context),
      base: base,
      digit: colors.secretDigit,
      symbol: colors.secretSymbol,
    );
    // Keeps the laid-out glyphs while nothing about their look changed.
    final glyphs = _glyphs = _glyphs == candidate ? _glyphs! : candidate;
    return Semantics(
      label: widget.semanticsLabel ?? widget.text,
      liveRegion: widget.liveRegion,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = glyphs.cell;
          final length = math.max(_to.length, 1);
          final maxColumns =
              constraints.hasBoundedWidth ? math.max(1, (constraints.maxWidth / cell.width).floor()) : length;
          final columns = math.min(length, maxColumns);
          final rows = (length + maxColumns - 1) ~/ maxColumns;
          return SizedBox(
            width: columns * cell.width,
            height: rows * cell.height,
            child: AnimatedBuilder(
              animation: _roll,
              builder: (context, _) => CustomPaint(
                painter: _TumblerPainter(
                  glyphs: glyphs,
                  from: _from,
                  to: _to,
                  // Settled unless a roll is running: every character shows its target.
                  elapsed: _roll.isAnimating ? _roll.value * _rollDuration(math.max(_from.length, _to.length)) : double.infinity,
                  columns: maxColumns,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

double _rollDuration(int length) => _windowMs + _stagger(length) * (math.max(length, 1) - 1);

/// Short secrets ripple visibly; long ones keep the whole roll near a third of a second.
double _stagger(int length) => math.min(16, 160 / math.max(length, 1));

/// One laid-out painter per character, coloured by its class.
class _GlyphCache {
  _GlyphCache({required this.style, required this.scaler, required this.base, required this.digit, required this.symbol});

  final TextStyle style;
  final TextScaler scaler;
  final Color base;
  final Color digit;
  final Color symbol;
  final Map<int, TextPainter> _painters = {};

  TextPainter operator [](int unit) => _painters.putIfAbsent(unit, () {
        final color = unit == _maskDot
            ? base
            : _isDigit(unit)
                ? digit
                : (_isSymbol(unit) ? symbol : base);
        return TextPainter(
          text: TextSpan(text: String.fromCharCode(unit), style: style.copyWith(color: color)),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
          maxLines: 1,
        )..layout();
      });

  /// The mono advance and line height every character shares.
  late final Size cell = this['0'.codeUnitAt(0)].size;

  @override
  bool operator ==(Object other) =>
      other is _GlyphCache &&
      other.style == style &&
      other.scaler == scaler &&
      other.base == base &&
      other.digit == digit &&
      other.symbol == symbol;

  @override
  int get hashCode => Object.hash(style, scaler, base, digit, symbol);
}

class _TumblerPainter extends CustomPainter {
  _TumblerPainter({required this.glyphs, required this.from, required this.to, required this.elapsed, required this.columns});

  final _GlyphCache glyphs;
  final String from;
  final String to;
  final double elapsed;
  final int columns;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = glyphs.cell;
    final rows = math.max(1, ((size.height + 0.5) / cell.height).floor());
    final count = math.max(from.length, to.length);
    final stagger = _stagger(count);

    for (var index = 0; index < count; index++) {
      final row = index ~/ columns;
      if (row >= rows) break;
      final x = (index % columns) * cell.width;
      final y = row * cell.height;
      final old = index < from.length ? from.codeUnitAt(index) : null;
      final next = index < to.length ? to.codeUnitAt(index) : null;
      final progress = ((elapsed - index * stagger) / _windowMs).clamp(0.0, 1.0);
      if (old == next || progress >= 1) {
        if (next != null) glyphs[next].paint(canvas, Offset(x, y));
      } else if (progress <= 0) {
        if (old != null) glyphs[old].paint(canvas, Offset(x, y));
      } else {
        final eased = BovedaMotion.emphasizedDecelerate.transform(progress);
        // Each cell is its own window: the old pin leaves upwards as the new one rises in.
        final window = Rect.fromLTWH(x, y, cell.width, cell.height);
        canvas.save();
        canvas.clipRect(window);
        if (old != null) _paintFaded(canvas, glyphs[old], Offset(x, y - eased * cell.height), 1 - eased, window);
        if (next != null) _paintFaded(canvas, glyphs[next], Offset(x, y + (1 - eased) * cell.height), eased, window);
        canvas.restore();
      }
    }
  }

  void _paintFaded(Canvas canvas, TextPainter painter, Offset offset, double alpha, Rect window) {
    canvas.saveLayer(window, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
    painter.paint(canvas, offset);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TumblerPainter old) =>
      old.glyphs != glyphs || old.from != from || old.to != to || old.elapsed != elapsed || old.columns != columns;
}
