import 'package:flutter/material.dart';

import '../icon/boveda_icon.dart';
import '../icon/boveda_icons.dart';
import '../theme/theme.dart';
import 'secret_text.dart';

/// Keeps a [TextEditingController] in step with a value owned elsewhere (a cubit's state), the way
/// Compose's value/onValueChange fields work: typing reports through `onChanged`, and an outside
/// change (a generated password, a reset form) replaces the text.
mixin _ControlledText<T extends StatefulWidget> on State<T> {
  late final TextEditingController controller = createController();

  TextEditingController createController();

  String get externalValue;

  void syncFromWidget() {
    if (controller.text == externalValue) return;
    controller.value = TextEditingValue(
      text: externalValue,
      selection: TextSelection.collapsed(offset: externalValue.length),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// A Material outlined text field with a value/onChanged API.
class BovedaTextField extends StatefulWidget {
  const BovedaTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.placeholder,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.autofillHints,
    this.minLines,
    this.maxLines = 1,
    this.focusNode,
    this.autofocus = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final String? placeholder;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final int? minLines;
  final int? maxLines;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<BovedaTextField> createState() => _BovedaTextFieldState();
}

class _BovedaTextFieldState extends State<BovedaTextField> with _ControlledText {
  @override
  TextEditingController createController() => TextEditingController(text: widget.value);

  @override
  String get externalValue => widget.value;

  @override
  void didUpdateWidget(BovedaTextField old) {
    super.didUpdateWidget(old);
    syncFromWidget();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.autocorrect,
        autofillHints: widget.autofillHints,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        decoration: InputDecoration(labelText: widget.label, hintText: widget.placeholder),
      );
}

/// A password input with a show/hide toggle. Shown in clear it uses the secret mono and colours
/// digits and symbols; [secretStyle] off keeps the regular face (account passwords at sign-in).
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.showLabel,
    required this.hideLabel,
    this.enabled = true,
    this.errorText,
    this.helperText,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.secretStyle = true,
    this.autofillHints,
    this.focusNode,
    this.autofocus = false,
    this.extraSuffix,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;

  /// Accessibility labels of the eye button.
  final String showLabel;
  final String hideLabel;
  final bool enabled;
  final String? errorText;
  final String? helperText;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final bool secretStyle;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget? extraSuffix;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> with _ControlledText {
  var _visible = false;

  @override
  TextEditingController createController() => SecretTextEditingController(text: widget.value);

  @override
  String get externalValue => widget.value;

  @override
  void didUpdateWidget(PasswordField old) {
    super.didUpdateWidget(old);
    syncFromWidget();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.bovedaColors;
    final secret = controller as SecretTextEditingController;
    final inClear = widget.secretStyle && _visible;
    secret
      ..digit = inClear ? colors.secretDigit : null
      ..symbol = inClear ? colors.secretSymbol : null;
    // Like a View that isn't focusable in touch mode: "Next" on the on-screen keyboard goes on to
    // the following field instead of stopping on the eye, which a hardware keyboard still reaches.
    final keyboardOnly = FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    return TextField(
      controller: controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      enabled: widget.enabled,
      obscureText: !_visible,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      style: inClear ? context.secretType.medium.copyWith(color: Theme.of(context).colorScheme.onSurface) : null,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        helperText: widget.helperText,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Focus(
              skipTraversal: !keyboardOnly,
              canRequestFocus: keyboardOnly,
              descendantsAreFocusable: keyboardOnly,
              child: IconButton(
                onPressed: () => setState(() => _visible = !_visible),
                tooltip: _visible ? widget.hideLabel : widget.showLabel,
                icon: BovedaIcon(_visible ? BovedaIcons.visibilityOff : BovedaIcons.visibility),
              ),
            ),
            ?widget.extraSuffix,
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
