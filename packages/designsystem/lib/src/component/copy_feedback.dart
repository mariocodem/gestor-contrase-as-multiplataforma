import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icon/boveda_icon.dart';
import '../icon/boveda_icons.dart';
import '../theme/motion.dart';

/// The brief "copied" acknowledgement next to whatever was copied: [confirm] shows it and it clears
/// itself; copying again restarts the hold. The snackbar says where the secret went; this says which
/// one, right under the thumb.
class CopyConfirmation extends ChangeNotifier {
  CopyConfirmation({this.hold = const Duration(milliseconds: 1600)});

  final Duration hold;
  Timer? _timer;
  bool _showing = false;

  bool get isShowing => _showing;

  void confirm() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _timer = Timer(hold, () {
      _showing = false;
      notifyListeners();
    });
    if (!_showing) {
      _showing = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// The copy icon, swapped for a check while [copied].
class CopyIcon extends StatelessWidget {
  const CopyIcon({super.key, required this.copied, this.semanticLabel});

  final bool copied;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticLabel,
        child: AnimatedSwitcher(
          duration: BovedaMotion.of(context, BovedaMotion.medium),
          reverseDuration: BovedaMotion.of(context, const Duration(milliseconds: 100)),
          switchInCurve: BovedaMotion.emphasizedDecelerate,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.6)),
            child: ScaleTransition(scale: Tween(begin: 0.4, end: 1.0).animate(animation), child: child),
          ),
          child: BovedaIcon(copied ? BovedaIcons.check : BovedaIcons.copy, key: ValueKey(copied)),
        ),
      );
}

/// Icon and label of a copy button; the label rolls up to [copiedLabel] while [copied].
class CopyButtonContent extends StatelessWidget {
  const CopyButtonContent({
    super.key,
    required this.copied,
    required this.label,
    required this.copiedLabel,
    this.style,
    this.gap = 8,
  });

  final bool copied;
  final String label;
  final String copiedLabel;
  final TextStyle? style;
  final double gap;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CopyIcon(copied: copied),
          SizedBox(width: gap),
          AnimatedSwitcher(
            duration: BovedaMotion.of(context, BovedaMotion.medium),
            reverseDuration: BovedaMotion.of(context, const Duration(milliseconds: 100)),
            switchInCurve: BovedaMotion.emphasizedDecelerate,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [...previous, ?current],
            ),
            transitionBuilder: (child, animation) {
              final entering = child.key == ValueKey(copied);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: Offset(0, entering ? 0.5 : -0.5), end: Offset.zero).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(copied ? copiedLabel : label, key: ValueKey(copied), style: style),
          ),
        ],
      );
}
