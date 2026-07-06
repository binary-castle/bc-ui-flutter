import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCTextFieldVariant { primary, secondary }

abstract final class BCInputTheme {
  static const disabledOpacity = 0.5;
  static const _disabledOpacity = disabledOpacity;
  static const _borderWidth = 1.0;
  static const _focusedBorderWidth = 1.5;

  static InputDecorationTheme theme(ColorScheme colors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: BCSizes.inputPaddingH,
        vertical: BCSpacing.md,
      ),
      constraints: const BoxConstraints(minHeight: BCSizes.inputMd),
      border: _border(colors, isInvalid: false),
      enabledBorder: _border(colors, isInvalid: false),
      focusedBorder: _border(colors, isInvalid: false, focused: true),
      errorBorder: _border(colors, isInvalid: true),
      focusedErrorBorder: _border(colors, isInvalid: true, focused: true),
      disabledBorder: _border(colors, isInvalid: false),
      hintStyle: TextStyle(color: colors.onSurfaceVariant),
    );
  }

  static InputDecoration decoration({
    required ColorScheme colors,
    required TextTheme textTheme,
    required BCTextFieldVariant variant,
    bool isInvalid = false,
    bool isDisabled = false,
    String? hintText,
    Widget? prefix,
    Widget? suffix,
  }) {
    final borderColor = _borderColor(colors, isInvalid: isInvalid);
    final focusedBorderColor = _focusedBorderColor(
      colors,
      isInvalid: isInvalid,
    );

    return InputDecoration(
      filled: true,
      fillColor: fillColor(variant, colors),
      hintText: hintText,
      hintStyle: TextStyle(color: colors.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: BCSizes.inputPaddingH,
        vertical: BCSpacing.md,
      ),
      constraints: const BoxConstraints(minHeight: BCSizes.inputMd),
      prefixIcon: prefix,
      suffixIcon: suffix,
      border: _outlineBorder(borderColor),
      enabledBorder: _outlineBorder(borderColor),
      focusedBorder: _outlineBorder(
        focusedBorderColor,
        width: _focusedBorderWidth,
      ),
      errorBorder: _outlineBorder(colors.error),
      focusedErrorBorder: _outlineBorder(
        colors.error,
        width: _focusedBorderWidth,
      ),
      disabledBorder: _outlineBorder(
        borderColor.withValues(alpha: _disabledOpacity),
      ),
    );
  }

  static Color fillColor(BCTextFieldVariant variant, ColorScheme colors) {
    switch (variant) {
      case BCTextFieldVariant.primary:
        return colors.surfaceContainerHighest;
      case BCTextFieldVariant.secondary:
        return colors.surface;
    }
  }

  static List<BoxShadow> fieldShadow(ColorScheme colors) {
    if (colors.brightness == Brightness.dark) return const [];

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static TextStyle labelStyle(TextTheme textTheme, ColorScheme colors) {
    return (textTheme.labelLarge ?? const TextStyle(fontSize: 14)).copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle labelInvalidStyle(TextTheme textTheme, ColorScheme colors) {
    return labelStyle(textTheme, colors).copyWith(color: colors.error);
  }

  static TextStyle descriptionStyle(TextTheme textTheme, ColorScheme colors) {
    return (textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
      color: colors.onSurfaceVariant,
    );
  }

  static TextStyle errorStyle(TextTheme textTheme, ColorScheme colors) {
    return (textTheme.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
      color: colors.error,
    );
  }

  static Color cursorColor(ColorScheme colors, {required bool isInvalid}) {
    return isInvalid ? colors.error : colors.primary;
  }

  static Color selectionColor(ColorScheme colors, {required bool isInvalid}) {
    final base = isInvalid ? colors.error : colors.primary;
    return base.withValues(alpha: 0.25);
  }

  static OutlineInputBorder _border(
    ColorScheme colors, {
    required bool isInvalid,
    bool focused = false,
  }) {
    final color = focused
        ? _focusedBorderColor(colors, isInvalid: isInvalid)
        : _borderColor(colors, isInvalid: isInvalid);

    return _outlineBorder(
      color,
      width: focused ? _focusedBorderWidth : _borderWidth,
    );
  }

  static Color _borderColor(ColorScheme colors, {required bool isInvalid}) {
    if (isInvalid) return colors.error;
    return colors.outline.withValues(alpha: 0.6);
  }

  static Color _focusedBorderColor(
    ColorScheme colors, {
    required bool isInvalid,
  }) {
    if (isInvalid) return colors.error;
    return colors.primary;
  }

  static OutlineInputBorder _outlineBorder(
    Color color, {
    double width = _borderWidth,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(BCRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
