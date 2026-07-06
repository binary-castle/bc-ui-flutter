import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/input_theme.dart';
import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:bc_ui/src/theme/component_themes/input_theme.dart'
    show BCTextFieldVariant;

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
        children: _withGap(children),
      ),
    );
  }

  List<Widget> _withGap(List<Widget> items) {
    if (items.isEmpty) return const [];

    final result = <Widget>[items.first];
    for (var i = 1; i < items.length; i++) {
      result
        ..add(const SizedBox(height: BCSpacing.xs))
        ..add(items[i]);
    }
    return result;
  }
}

class BCTextFieldLabel extends StatelessWidget {
  const BCTextFieldLabel(this.text, {super.key, this.isInvalid});

  final String text;
  final bool? isInvalid;

  @override
  Widget build(BuildContext context) {
    final scope = _BCTextFieldScope.of(context);
    final invalid = isInvalid ?? scope?.isInvalid ?? false;
    final required = scope?.isRequired ?? false;
    final colors = context.colors;
    final textTheme = context.text;

    final style = invalid
        ? BCInputTheme.labelInvalidStyle(textTheme, colors)
        : BCInputTheme.labelStyle(textTheme, colors);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text),
          if (required)
            TextSpan(
              text: ' *',
              style: style.copyWith(color: colors.error),
            ),
        ],
      ),
      style: style,
    );
  }
}

class BCTextFieldDescription extends StatelessWidget {
  const BCTextFieldDescription(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCInputTheme.descriptionStyle(context.text, context.colors),
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

    return Text(
      message,
      style: BCInputTheme.errorStyle(context.text, context.colors),
    );
  }
}

class BCTextFieldInput extends StatelessWidget {
  const BCTextFieldInput({
    super.key,
    this.controller,
    this.focusNode,
    this.variant = BCTextFieldVariant.primary,
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
  final BCTextFieldVariant variant;
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
    final colors = context.colors;
    final textTheme = context.text;

    final invalid = isInvalid ?? scope?.isInvalid ?? false;
    final disabled = isDisabled ?? scope?.isDisabled ?? false;

    final field = Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: BCInputTheme.cursorColor(colors, isInvalid: invalid),
          selectionColor: BCInputTheme.selectionColor(
            colors,
            isInvalid: invalid,
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: !disabled,
        readOnly: readOnly,
        autofocus: autofocus,
        obscureText: obscureText,
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
        style: textTheme.bodyLarge,
        decoration: BCInputTheme.decoration(
          colors: colors,
          textTheme: textTheme,
          variant: variant,
          isInvalid: invalid,
          isDisabled: disabled,
          hintText: hintText,
          prefix: prefix,
          suffix: suffix,
        ),
      ),
    );

    final input = variant == BCTextFieldVariant.primary
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BCRadius.md),
              boxShadow: BCInputTheme.fieldShadow(colors),
            ),
            child: field,
          )
        : field;

    if (!disabled) return input;

    return Opacity(
      opacity: BCInputTheme.disabledOpacity,
      child: IgnorePointer(child: input),
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
