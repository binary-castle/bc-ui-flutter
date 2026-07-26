import 'package:flutter/material.dart';

import '../extensions/context_extension.dart';
import 'bc_input.dart';
import 'bc_pressable.dart';

/// A [BCInput] preset for passwords with a visibility toggle suffix.
///
/// heroui-native has no dedicated PasswordInput — this mirrors its
/// InputGroup-with-suffix pattern as a convenience widget.
class BCPasswordInput extends StatefulWidget {
  const BCPasswordInput({
    super.key,
    this.controller,
    this.focusNode,
    this.variant = BCInputVariant.primary,
    this.placeholder,
    this.isInvalid = false,
    this.isDisabled = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final BCInputVariant variant;
  final String? placeholder;
  final bool isInvalid;
  final bool isDisabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  State<BCPasswordInput> createState() => _BCPasswordInputState();
}

class _BCPasswordInputState extends State<BCPasswordInput> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return BCInput(
      controller: widget.controller,
      focusNode: widget.focusNode,
      variant: widget.variant,
      placeholder: widget.placeholder,
      isInvalid: widget.isInvalid,
      isDisabled: widget.isDisabled,
      obscureText: _obscured,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autocorrect: false,
      enableSuggestions: false,
      suffix: BCPressable(
        feedback: BCPressFeedback.none,
        onPressed: () => setState(() => _obscured = !_obscured),
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: bc.muted,
          ),
        ),
      ),
    );
  }
}
