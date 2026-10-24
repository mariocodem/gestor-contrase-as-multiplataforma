import 'package:flutter/widgets.dart';

/// Material 3 easing and durations, named once so every screen moves alike. Feedback runs
/// 150–250 ms, the longest flight (the key cap) 380 ms, and nothing waits on an animation: the
/// vault is usable while it's still arriving. The system "Remove animations" / "Reduce motion"
/// setting turns every one of these into a cut (see [BovedaMotion.of]).
abstract final class BovedaMotion {
  /// Arrivals: quick start, long settle.
  static const emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);

  /// Departures and the snap of a shackle closing.
  static const emphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);

  /// Changes in place.
  static const standard = Cubic(0.2, 0, 0, 1);

  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const long = Duration(milliseconds: 400);

  /// False when the user asked the system for no animations.
  static bool enabled(BuildContext context) => !MediaQuery.disableAnimationsOf(context);

  /// [duration], or zero when animations are off.
  static Duration of(BuildContext context, Duration duration) => enabled(context) ? duration : Duration.zero;
}
