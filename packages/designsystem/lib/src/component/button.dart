import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/motion.dart';
import '../theme/theme.dart';

enum BovedaButtonType { primary, secondary, tertiary, error, warning }

enum BovedaButtonSize {
  small(height: 32, padding: 10, radius: 6, fontSize: 14, spinner: 16),
  medium(height: 40, padding: 14, radius: 6, fontSize: 14, spinner: 16),
  large(height: 48, padding: 18, radius: 8, fontSize: 16, spinner: 20);

  const BovedaButtonSize({
    required this.height,
    required this.padding,
    required this.radius,
    required this.fontSize,
    required this.spinner,
  });

  final double height;
  final double padding;
  final double radius;
  final double fontSize;
  final double spinner;
}

const _disabledInk = Color(0xFF8F8F8F);

/// One flat button style for every type and size: solid fills, a hairline where a surface needs an
/// edge, and a colour change of 150 ms under the finger. No gradients, no ripple. The Material
/// buttons in the theme use it too, so a plain [TextButton] in a dialog matches.
ButtonStyle bovedaButtonStyle(
  ColorScheme scheme,
  BovedaColors colors,
  TextTheme text, {
  BovedaButtonType type = BovedaButtonType.primary,
  BovedaButtonSize size = BovedaButtonSize.medium,
  bool iconOnly = false,
}) {
  final dark = scheme.brightness == Brightness.dark;
  final wash = dark ? const Color(0x17FFFFFF) : const Color(0x14000000);
  final (Color fill, Color ink, Color pressed, Color? edge) = switch (type) {
    BovedaButtonType.primary => (scheme.primary, scheme.onPrimary, Color.lerp(scheme.primary, scheme.onPrimary, 0.15)!, null),
    BovedaButtonType.secondary => (colors.plate, scheme.onSurface, Color.alphaBlend(wash, colors.plate), colors.plateEdge),
    BovedaButtonType.tertiary => (Colors.transparent, scheme.onSurface, wash, null),
    BovedaButtonType.error => (
        dark ? const Color(0xFFE2162A) : const Color(0xFFEA001D),
        Colors.white,
        dark ? const Color(0xFFFF565F) : const Color(0xFFAE292F),
        null,
      ),
    BovedaButtonType.warning => (const Color(0xFFFF9300), const Color(0xFF0A0A0A), const Color(0xFFD27504), null),
  };
  final flat = type == BovedaButtonType.tertiary;
  final disabledFill = flat ? Colors.transparent : (dark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F2F2));
  final disabledEdge = dark ? const Color(0xFF2E2E2E) : const Color(0xFFEBEBEB);
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return disabledFill;
      if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) return pressed;
      return fill;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.disabled) ? _disabledInk : ink),
    iconColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.disabled) ? _disabledInk : ink),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    shadowColor: const WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    elevation: const WidgetStatePropertyAll(0),
    side: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) return BorderSide(color: scheme.tertiary, width: 2);
      if (states.contains(WidgetState.disabled)) return flat ? BorderSide.none : BorderSide(color: disabledEdge);
      return edge == null ? BorderSide.none : BorderSide(color: edge);
    }),
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.radius))),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: iconOnly ? 0 : size.padding)),
    minimumSize: WidgetStatePropertyAll(Size(iconOnly ? size.height : 48, size.height)),
    textStyle: WidgetStatePropertyAll(text.labelLarge?.copyWith(fontSize: size.fontSize, color: null)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    animationDuration: const Duration(milliseconds: 150),
    splashFactory: NoSplash.splashFactory,
  );
}

/// The app's button. [loading] shows the spinner and takes the disabled look; [onPressed] null
/// disables it. An icon-only button is square: use [BovedaButton.icon], which needs a label inside
/// its child for screen readers.
class BovedaButton extends StatefulWidget {
  const BovedaButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.type = BovedaButtonType.primary,
    this.size = BovedaButtonSize.medium,
    this.prefix,
    this.suffix,
    this.loading = false,
    this.fullWidth = false,
  }) : iconOnly = false;

  const BovedaButton.icon({
    super.key,
    required this.child,
    required this.onPressed,
    this.type = BovedaButtonType.secondary,
    this.size = BovedaButtonSize.medium,
    this.loading = false,
  })  : iconOnly = true,
        prefix = null,
        suffix = null,
        fullWidth = false;

  final Widget child;
  final VoidCallback? onPressed;
  final BovedaButtonType type;
  final BovedaButtonSize size;
  final Widget? prefix;
  final Widget? suffix;
  final bool loading;
  final bool fullWidth;
  final bool iconOnly;

  @override
  State<BovedaButton> createState() => _BovedaButtonState();
}

class _BovedaButtonState extends State<BovedaButton> {
  final _pressed = ValueNotifier(false);

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = widget.onPressed != null && !widget.loading;
    final spinner = BovedaSpinner(size: widget.size.spinner);
    final button = FilledButton(
      onPressed: enabled ? widget.onPressed : null,
      style: bovedaButtonStyle(
        theme.colorScheme,
        context.bovedaColors,
        theme.textTheme,
        type: widget.type,
        size: widget.size,
        iconOnly: widget.iconOnly,
      ),
      child: widget.iconOnly
          ? (widget.loading ? spinner : widget.child)
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading) ...[spinner, const SizedBox(width: 8)] else if (widget.prefix != null) ...[
                  widget.prefix!,
                  const SizedBox(width: 8),
                ],
                Flexible(child: widget.child),
                if (!widget.loading && widget.suffix != null) ...[const SizedBox(width: 8), widget.suffix!],
              ],
            ),
    );
    return Listener(
      onPointerDown: enabled ? (_) => _pressed.value = true : null,
      onPointerUp: (_) => _pressed.value = false,
      onPointerCancel: (_) => _pressed.value = false,
      child: ValueListenableBuilder(
        valueListenable: _pressed,
        builder: (context, pressed, child) => AnimatedScale(
          scale: pressed ? 0.98 : 1,
          duration: BovedaMotion.of(context, BovedaMotion.press),
          curve: BovedaMotion.standard,
          child: child,
        ),
        child: widget.fullWidth ? SizedBox(width: double.infinity, child: button) : button,
      ),
    );
  }
}

/// Twelve bars fading round a circle. One controller, painted straight into its own layer: nothing
/// rebuilds while it turns.
class BovedaSpinner extends StatefulWidget {
  const BovedaSpinner({super.key, this.size = 20, this.color = _disabledInk});

  final double size;
  final Color color;

  @override
  State<BovedaSpinner> createState() => _BovedaSpinnerState();
}

class _BovedaSpinnerState extends State<BovedaSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (BovedaMotion.enabled(context)) {
      if (!_turn.isAnimating) _turn.repeat();
    } else {
      _turn.stop();
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(size: Size.square(widget.size), painter: _SpinnerPainter(_turn, widget.color)),
        ),
      );
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter(this.turn, this.color) : super(repaint: turn);

  final Animation<double> turn;
  final Color color;

  static const _bars = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.24, -size.height * 0.04, size.width * 0.24, size.height * 0.08),
      Radius.circular(size.height * 0.04),
    );
    final paint = Paint();
    canvas.translate(size.width / 2, size.height / 2);
    for (var i = 0; i < _bars; i++) {
      final age = (turn.value - i / _bars) % 1;
      paint.color = color.withValues(alpha: color.a * (1 - age * 0.85));
      canvas.drawRRect(bar, paint);
      canvas.rotate(2 * math.pi / _bars);
    }
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.turn != turn || old.color != color;
}

class BovedaSegment<T> {
  const BovedaSegment({required this.value, required this.label});

  final T value;
  final String label;
}

/// A choice among a few options, with an indicator that slides to the one selected.
class BovedaSegmented<T> extends StatelessWidget {
  const BovedaSegmented({super.key, required this.segments, required this.selected, required this.onChanged});

  final List<BovedaSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.bovedaColors;
    final scheme = theme.colorScheme;
    final index = segments.indexWhere((segment) => segment.value == selected);
    final duration = BovedaMotion.of(context, BovedaMotion.medium);
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BovedaShapes.medium),
      child: SizedBox(
        height: 40,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / segments.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  left: index * slot + 3,
                  top: 3,
                  bottom: 3,
                  width: slot - 6,
                  duration: duration,
                  curve: BovedaMotion.standard,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.plate,
                      borderRadius: BovedaShapes.small,
                      border: Border.all(color: colors.plateEdge),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final segment in segments)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: segment.value == selected,
                          label: segment.label,
                          excludeSemantics: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onChanged(segment.value),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: duration,
                                style: theme.textTheme.labelLarge!.copyWith(
                                  color: segment.value == selected ? scheme.onSurface : scheme.onSurfaceVariant,
                                ),
                                child: Text(segment.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
