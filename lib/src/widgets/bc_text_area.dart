import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bc_input.dart';

/// HeroUI Native TextArea (text-area.css): a 128px-tall multiline [BCInput]
/// with 8px vertical padding.
class BCTextArea extends StatelessWidget {
  const BCTextArea({
    super.key,
    this.controller,
    this.focusNode,
    this.variant = BCInputVariant.primary,
    this.placeholder,
    this.isInvalid = false,
    this.isDisabled = false,
    this.height = 128,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final BCInputVariant variant;
  final String? placeholder;
  final bool isInvalid;
  final bool isDisabled;
  final double height;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: BCInput(
        controller: controller,
        focusNode: focusNode,
        variant: variant,
        placeholder: placeholder,
        isInvalid: isInvalid,
        isDisabled: isDisabled,
        maxLines: null,
        minHeight: height,
        verticalPadding: 8,
        keyboardType: keyboardType ?? TextInputType.multiline,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textCapitalization: textCapitalization,
      ),
    );
  }
}
