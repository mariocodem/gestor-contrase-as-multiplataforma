import 'package:boveda_designsystem/boveda_designsystem.dart';
import 'package:flutter/material.dart';

/// An error or notice under a form. It opens its own line instead of shoving the buttons down in
/// one frame, keeps its text while closing, and is announced by screen readers when it appears.
class FormMessage extends StatefulWidget {
  const FormMessage({super.key, required this.text, required this.color, this.topPadding = 8});

  final String? text;
  final Color color;
  final double topPadding;

  @override
  State<FormMessage> createState() => _FormMessageState();
}

class _FormMessageState extends State<FormMessage> {
  String? _last;

  @override
  Widget build(BuildContext context) {
    if (widget.text != null) _last = widget.text;
    final visible = widget.text != null;
    final last = _last;
    return AnimatedSize(
      duration: BovedaMotion.of(context, visible ? BovedaMotion.medium : BovedaMotion.short),
      curve: visible ? BovedaMotion.emphasizedDecelerate : BovedaMotion.emphasizedAccelerate,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: BovedaMotion.of(context, visible ? BovedaMotion.medium : const Duration(milliseconds: 100)),
        child: !visible || last == null
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: EdgeInsets.only(top: widget.topPadding),
                child: Semantics(
                  liveRegion: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(last, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color)),
                  ),
                ),
              ),
      ),
    );
  }
}
