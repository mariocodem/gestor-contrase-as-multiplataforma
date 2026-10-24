import 'package:flutter/material.dart';

/// Makes an entry's key cap one object across screens: it lifts off its row in the list and lands
/// in the detail header, and goes back to its hook on the way back.
class KeyCapHero extends StatelessWidget {
  const KeyCapHero({super.key, required this.entryId, required this.child});

  final String entryId;
  final Widget child;

  @override
  Widget build(BuildContext context) => Hero(
        tag: 'keycap-$entryId',
        // A straight flight rather than Material's arc; the route already eases it.
        createRectTween: (begin, end) => RectTween(begin: begin, end: end),
        child: child,
      );
}
