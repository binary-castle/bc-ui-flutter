import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCButtonVariant { primary, secondary, outline, text, destructive }

enum BCButtonSize { small, medium, large }

abstract final class BCButtonTheme {
  static const _disabledOpacity = 0.5;

  static FilledButtonThemeData filled(ColorScheme colors, TextTheme textTheme) {
    return FilledButtonThemeData(
      style:
          style(
            variant: BCButtonVariant.primary,
            size: BCButtonSize.medium,
            colors: colors,
            textTheme: textTheme,
          ).copyWith(
            minimumSize: const WidgetStatePropertyAll(
              Size(double.infinity, BCSizes.buttonMd),
            ),
          ),
    );
  }

  static FilledButtonThemeData tonal(ColorScheme colors, TextTheme textTheme) {
    return FilledButtonThemeData(
      style: style(
        variant: BCButtonVariant.secondary,
        size: BCButtonSize.medium,
        colors: colors,
        textTheme: textTheme,
      ),
    );
  }

  static OutlinedButtonThemeData outlined(
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return OutlinedButtonThemeData(
      style: style(
        variant: BCButtonVariant.outline,
        size: BCButtonSize.medium,
        colors: colors,
        textTheme: textTheme,
      ),
    );
  }

  static TextButtonThemeData text(ColorScheme colors, TextTheme textTheme) {
    return TextButtonThemeData(
      style: style(
        variant: BCButtonVariant.text,
        size: BCButtonSize.medium,
        colors: colors,
        textTheme: textTheme,
      ),
    );
  }

  static ButtonStyle style({
    required BCButtonVariant variant,
    required BCButtonSize size,
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    final base = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, _height(size))),
      padding: WidgetStatePropertyAll(_padding(size)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BCRadius.xl),
        ),
      ),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    switch (variant) {
      case BCButtonVariant.primary:
        return base.merge(
          FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            disabledBackgroundColor: colors.primary.withValues(
              alpha: _disabledOpacity,
            ),
            disabledForegroundColor: colors.onPrimary.withValues(
              alpha: _disabledOpacity,
            ),
          ),
        );

      case BCButtonVariant.secondary:
        return base.merge(
          FilledButton.styleFrom(
            backgroundColor: colors.surfaceContainerHighest,
            foregroundColor: colors.primary,
            disabledBackgroundColor: colors.surfaceContainerHighest.withValues(
              alpha: _disabledOpacity,
            ),
            disabledForegroundColor: colors.primary.withValues(
              alpha: _disabledOpacity,
            ),
          ),
        );

      case BCButtonVariant.outline:
        return base.merge(
          OutlinedButton.styleFrom(
            foregroundColor: colors.onSurface,
            side: BorderSide(color: colors.outline),
            disabledForegroundColor: colors.onSurface.withValues(
              alpha: _disabledOpacity,
            ),
          ),
        );

      case BCButtonVariant.text:
        return base.merge(
          TextButton.styleFrom(
            foregroundColor: colors.onSurface,
            disabledForegroundColor: colors.onSurface.withValues(
              alpha: _disabledOpacity,
            ),
          ),
        );

      case BCButtonVariant.destructive:
        return base.merge(
          FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
            disabledBackgroundColor: colors.error.withValues(
              alpha: _disabledOpacity,
            ),
            disabledForegroundColor: colors.onError.withValues(
              alpha: _disabledOpacity,
            ),
          ),
        );
    }
  }

  static Color foregroundColor(BCButtonVariant variant, ColorScheme colors) {
    switch (variant) {
      case BCButtonVariant.primary:
        return colors.onPrimary;
      case BCButtonVariant.secondary:
        return colors.primary;
      case BCButtonVariant.outline:
      case BCButtonVariant.text:
        return colors.onSurface;
      case BCButtonVariant.destructive:
        return colors.onError;
    }
  }

  static double iconGap(BCButtonSize size) => BCSpacing.sm;

  static double _height(BCButtonSize size) {
    switch (size) {
      case BCButtonSize.small:
        return BCSizes.buttonSm;
      case BCButtonSize.medium:
        return BCSizes.buttonMd;
      case BCButtonSize.large:
        return BCSizes.buttonLg;
    }
  }

  static EdgeInsets _padding(BCButtonSize size) {
    switch (size) {
      case BCButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: BCSizes.buttonPaddingSm);
      case BCButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: BCSizes.buttonPaddingMd);
      case BCButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: BCSizes.buttonPaddingLg);
    }
  }
}
