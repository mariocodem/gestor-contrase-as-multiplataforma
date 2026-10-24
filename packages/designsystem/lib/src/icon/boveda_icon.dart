import 'package:flutter/widgets.dart';

/// One Material Symbols glyph as path data on the 960-unit grid (absolute M, L, Q and Z only).
@immutable
class BovedaIconData {
  const BovedaIconData(this.pathData);

  final String pathData;

  static const grid = 960.0;

  static final Map<String, Path> _parsed = {};

  /// The glyph at grid scale, parsed once per icon.
  Path get path => _parsed.putIfAbsent(pathData, () => _parse(pathData));

  static Path _parse(String data) {
    final path = Path();
    final tokens = RegExp(r'[MLQZ]|-?\d*\.?\d+').allMatches(data).map((m) => m.group(0)!).toList();
    var i = 0;
    var command = '';
    double next() => double.parse(tokens[i++]);
    while (i < tokens.length) {
      if (RegExp(r'^[MLQZ]$').hasMatch(tokens[i])) command = tokens[i++];
      switch (command) {
        case 'M':
          path.moveTo(next(), next());
          // Coordinates after a moveto are implicit linetos.
          command = 'L';
        case 'L':
          path.lineTo(next(), next());
        case 'Q':
          path.quadraticBezierTo(next(), next(), next(), next());
        case 'Z':
          path.close();
        default:
          throw FormatException('Unsupported path command', data);
      }
    }
    return path;
  }
}

/// Draws a [BovedaIconData] like [Icon] does: size and colour from the [IconTheme], decorative
/// unless [semanticLabel] is given.
class BovedaIcon extends StatelessWidget {
  const BovedaIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});

  final BovedaIconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? 24;
    final tint = color ?? theme.color ?? const Color(0xFF000000);
    final opacity = theme.opacity ?? 1;
    final glyph = SizedBox.square(
      dimension: side,
      child: CustomPaint(painter: _IconPainter(icon, opacity < 1 ? tint.withValues(alpha: tint.a * opacity) : tint)),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: glyph);
    return Semantics(label: semanticLabel, child: ExcludeSemantics(child: glyph));
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.color);

  final BovedaIconData icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / BovedaIconData.grid, size.height / BovedaIconData.grid);
    canvas.drawPath(icon.path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.icon != icon || old.color != color;
}
