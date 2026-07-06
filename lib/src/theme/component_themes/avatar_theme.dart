import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCAvatarSize { small, medium, large }

enum BCAvatarVariant { defaultVariant, soft }

enum BCAvatarColor { accent, defaultColor, success, warning, danger }

enum BCAvatarStatus { loading, loaded, error }

abstract final class BCAvatarTheme {
  static const _softAlpha = 0.15;

  static double diameter(BCAvatarSize size) {
    switch (size) {
      case BCAvatarSize.small:
        return BCSizes.avatarSm;
      case BCAvatarSize.medium:
        return BCSizes.avatarMd;
      case BCAvatarSize.large:
        return BCSizes.avatarLg;
    }
  }

  static double iconSize(BCAvatarSize size) {
    switch (size) {
      case BCAvatarSize.small:
        return 16;
      case BCAvatarSize.medium:
        return 18;
      case BCAvatarSize.large:
        return 24;
    }
  }

  static Color semanticColor(BCAvatarColor color, ColorScheme colors) {
    switch (color) {
      case BCAvatarColor.accent:
        return colors.primary;
      case BCAvatarColor.defaultColor:
        return colors.onSurface;
      case BCAvatarColor.success:
        return BCColors.success;
      case BCAvatarColor.warning:
        return BCColors.warning;
      case BCAvatarColor.danger:
        return colors.error;
    }
  }

  static Color backgroundColor({
    required BCAvatarVariant variant,
    required BCAvatarColor color,
    required ColorScheme colors,
  }) {
    switch (variant) {
      case BCAvatarVariant.defaultVariant:
        return colors.surfaceContainerHighest;
      case BCAvatarVariant.soft:
        return semanticColor(color, colors).withValues(alpha: _softAlpha);
    }
  }

  static Color foregroundColor({
    required BCAvatarColor color,
    required ColorScheme colors,
  }) {
    return semanticColor(color, colors);
  }

  static TextStyle fallbackTextStyle(
    BCAvatarSize size,
    TextTheme textTheme,
    Color foreground,
  ) {
    final fontSize = switch (size) {
      BCAvatarSize.small => 14.0,
      BCAvatarSize.medium => 16.0,
      BCAvatarSize.large => 20.0,
    };

    return (textTheme.labelLarge ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: foreground,
    );
  }

  static BoxDecoration decoration({
    required BCAvatarVariant variant,
    required BCAvatarColor color,
    required ColorScheme colors,
  }) {
    return BoxDecoration(
      color: backgroundColor(variant: variant, color: color, colors: colors),
      shape: BoxShape.circle,
    );
  }
}
