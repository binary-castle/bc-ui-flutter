import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bc_input.dart';
import 'field_parts/bc_description.dart';
import 'field_parts/bc_field_error.dart';
import 'field_parts/bc_label.dart';

export 'bc_input.dart' show BCInputVariant;

/// HeroUI Native TextField: a vertical stack (gap 6, text-field.css) of
/// Label / Input / Description / ErrorMessage parts that share invalid,
/// disabled, and required state through an inherited scope.
class BCTextField extends StatelessWidget {
  const BCTextField({
    super.key,
    required this.children,
    this.isDisabled = false,
    this.isInvalid = false,
    this.isRequired = false,
  });

  final List<Widget> children;
  final bool isDisabled;
  final bool isInvalid;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return _BCTextFieldScope(
      isDisabled: isDisabled,
      isInvalid: isInvalid,
      isRequired: isRequired,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: children,
      ),
    );
  }
}

class BCTextFieldLabel extends StatelessWidget {
  const BCTextFieldLabel(this.text, {super.key, this.isInvalid});

  final String text;
  final bool? isInvalid;

  @override
  Widget build(BuildContext context) {
    final scope = _BCTextFieldScope.of(context);
    return BCLabel(
      text,
      isRequired: scope?.isRequired ?? false,
      isInvalid: isInvalid ?? scope?.isInvalid ?? false,
      isDisabled: scope?.isDisabled ?? false,
      isInsideField: true,
    );
  }
}

class BCTextFieldDescription extends StatelessWidget {
  const BCTextFieldDescription(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scope = _BCTextFieldScope.of(context);
    return BCDescription(
      text,
      isDisabled: scope?.isDisabled ?? false,
      isInsideField: true,
    );
  }
}

class BCTextFieldError extends StatelessWidget {
  const BCTextFieldError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scope = _BCTextFieldScope.of(context);
    if (scope != null && !scope.isInvalid) {
      return const SizedBox.shrink();
    }
    return BCFieldError(message, isInsideField: true);
  }
}

class BCTextFieldInput extends StatelessWidget {
  const BCTextFieldInput({
    super.key,
    this.controller,
    this.focusNode,
    this.variant = BCInputVariant.primary,
    this.isInvalid,
    this.isDisabled,
    this.hintText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final BCInputVariant variant;
  final bool? isInvalid;
  final bool? isDisabled;
  final String? hintText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    final scope = _BCTextFieldScope.of(context);

    return BCInput(
      controller: controller,
      focusNode: focusNode,
      variant: variant,
      placeholder: hintText,
      isInvalid: isInvalid ?? scope?.isInvalid ?? false,
      isDisabled: isDisabled ?? scope?.isDisabled ?? false,
      obscureText: obscureText,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      prefix: prefix,
      suffix: suffix,
    );
  }
}

class _BCTextFieldScope extends InheritedWidget {
  const _BCTextFieldScope({
    required this.isDisabled,
    required this.isInvalid,
    required this.isRequired,
    required super.child,
  });

  final bool isDisabled;
  final bool isInvalid;
  final bool isRequired;

  static _BCTextFieldScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_BCTextFieldScope>();
  }

  @override
  bool updateShouldNotify(_BCTextFieldScope oldWidget) {
    return isDisabled != oldWidget.isDisabled ||
        isInvalid != oldWidget.isInvalid ||
        isRequired != oldWidget.isRequired;
  }
}
