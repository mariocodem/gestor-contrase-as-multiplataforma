import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Material motion's shared X axis into and out of an entry; iPhone keeps its own push, which owns
/// the edge-swipe back gesture.
const bovedaPageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: SharedAxisPageTransitionsBuilder(),
    TargetPlatform.fuchsia: SharedAxisPageTransitionsBuilder(),
    TargetPlatform.linux: SharedAxisPageTransitionsBuilder(),
    TargetPlatform.windows: SharedAxisPageTransitionsBuilder(),
    TargetPlatform.macOS: SharedAxisPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

/// Over a 300 ms route: the page slides an eighth of the width for 260 ms and fades in from 60 ms
/// to 220 ms; the page it covers slides the other way and fades out in the first 90 ms.
class SharedAxisPageTransitionsBuilder extends PageTransitionsBuilder {
  const SharedAxisPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!BovedaMotion.enabled(context)) return child;
    final slideIn = Tween(begin: const Offset(1 / 8, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: animation, curve: const Interval(0, 260 / 300, curve: BovedaMotion.standard)),
    );
    final fadeIn = CurvedAnimation(parent: animation, curve: const Interval(60 / 300, 220 / 300));
    final slideOut = Tween(begin: Offset.zero, end: const Offset(-1 / 8, 0)).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: const Interval(0, 260 / 300, curve: BovedaMotion.standard)),
    );
    final fadeOut = ReverseAnimation(CurvedAnimation(parent: secondaryAnimation, curve: const Interval(0, 90 / 300)));
    return SlideTransition(
      position: slideOut,
      child: FadeTransition(
        opacity: fadeOut,
        child: SlideTransition(position: slideIn, child: FadeTransition(opacity: fadeIn, child: child)),
      ),
    );
  }
}
