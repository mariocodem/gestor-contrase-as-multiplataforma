import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/theme.dart';

const strengthLevels = 5;
const _segmentStaggerMs = 30;
const _segmentMs = 200;

/// Five segments; [level] 0 (very weak) to 4 (very strong), or -1 for nothing to rate yet.
///
/// The meter rises from the left when the password gets stronger and drains from the right when it
/// gets weaker, one segment after another, so the direction of a change reads at once.
class StrengthMeter extends StatefulWidget {
  const StrengthMeter({super.key, required this.level});

  final int level;

  @override
  State<StrengthMeter> createState() => _StrengthMeterState();
}

class _StrengthMeterState extends State<StrengthMeter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _segmentMs + (strengthLevels - 1) * _segmentStaggerMs),
  )..value = 1;
  List<Color>? _from;
  List<Color>? _to;
  bool _rising = true;

  List<Color> _targets(BuildContext context, int level) {
    final scale = context.bovedaColors.strength;
    final empty = Theme.of(context).colorScheme.surfaceContainerHighest;
    return [for (var i = 0; i < strengthLevels; i++) level >= 0 && i <= level ? scale[level] : empty];
  }

  List<Color> _current() => [for (var i = 0; i < strengthLevels; i++) _colorAt(i)];

  Color _colorAt(int index) {
    final to = _to![index];
    final from = _from?[index] ?? to;
    final order = _rising ? index : strengthLevels - 1 - index;
    final total = _controller.duration!.inMilliseconds;
    final start = order * _segmentStaggerMs / total;
    final end = (order * _segmentStaggerMs + _segmentMs) / total;
    final t = Interval(start, end, curve: BovedaMotion.standard).transform(_controller.value);
    return Color.lerp(from, to, t)!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Theme changes (light/dark) snap to the new palette.
    _to = _targets(context, widget.level);
    _from = null;
  }

  @override
  void didUpdateWidget(StrengthMeter old) {
    super.didUpdateWidget(old);
    if (old.level == widget.level) return;
    _from = _current();
    _to = _targets(context, widget.level);
    _rising = widget.level >= old.level;
    if (BovedaMotion.enabled(context)) {
      _controller.forward(from: 0);
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          height: 6,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              children: [
                for (var i = 0; i < strengthLevels; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: _colorAt(i), borderRadius: const BorderRadius.all(Radius.circular(3))),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

/// Meter plus its reading: the verdict in the level's colour, the entropy as a measurement, and
/// a plain-language line such as the estimated time to crack it.
class StrengthIndicator extends StatelessWidget {
  const StrengthIndicator({super.key, required this.level, required this.verdict, this.measurement, this.detail});

  final int level;
  final String verdict;
  final String? measurement;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = level >= 0 ? context.bovedaColors.strength[level] : theme.colorScheme.onSurfaceVariant;
    final muted = theme.colorScheme.onSurfaceVariant;
    return Semantics(
      container: true,
      label: [verdict, measurement, detail].whereType<String>().join('. '),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          StrengthMeter(level: level),
          const SizedBox(height: 8),
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: target),
            duration: BovedaMotion.of(context, BovedaMotion.medium),
            curve: BovedaMotion.standard,
            builder: (context, color, _) => Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: verdict),
                  if (measurement != null)
                    TextSpan(text: '  ·  $measurement', style: context.secretType.small.copyWith(color: muted)),
                ],
              ),
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
          ),
          if (detail != null) Text(detail!, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        ],
      ),
    );
  }
}
