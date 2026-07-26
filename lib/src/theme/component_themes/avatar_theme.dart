import 'package:bc_ui/src/theme/theme_extensions.dart';
import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCAvatarSize { small, medium, large }

enum BCAvatarVariant { defaultVariant, soft }

enum BCAvatarColor { accent, defaultColor, success, warning, danger }

enum BCAvatarStatus { loading, loaded, error }

/// Avatar styling from heroui-native's avatar.css: sizes 40/48/64,
/// 32px continuous corners, `default` background or per-color soft
/// backgrounds, medium-weight fallback text in the soft foreground color.
abstract final class BCAvatarTheme {
  static double diameter(BCAvatarSize size) {
    switch (size) {
      case BCAvatarSize.small:
        return 40;
      case BCAvatarSize.medium:
        return 48;
      case BCAvatarSize.large:
        return 64;
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

  static ShapeBorder shape() => BCShapes.continuous(BCRadius.xxxxl);

  static Color backgroundColor({
    required BCAvatarVariant variant,
    required BCAvatarColor color,
    required BCThemeExtension bc,
  }) {
    switch (variant) {
      case BCAvatarVariant.defaultVariant:
        return bc.defaultColor;
      case BCAvatarVariant.soft:
        return switch (color) {
          BCAvatarColor.accent => bc.accentSoft,
          BCAvatarColor.defaultColor => bc.defaultColor,
          BCAvatarColor.success => bc.successSoft,
          BCAvatarColor.warning => bc.warningSoft,
          BCAvatarColor.danger => bc.dangerSoft,
        };
    }
  }

  static Color foregroundColor({
    required BCAvatarColor color,
    required BCThemeExtension bc,
  }) {
    return switch (color) {
      BCAvatarColor.accent => bc.accentSoftForeground,
      BCAvatarColor.defaultColor => bc.defaultSoftForeground,
      BCAvatarColor.success => bc.successSoftForeground,
      BCAvatarColor.warning => bc.warningSoftForeground,
      BCAvatarColor.danger => bc.dangerSoftForeground,
    };
  }

  static TextStyle fallbackTextStyle(BCAvatarSize size, Color foreground) {
    final base = switch (size) {
      BCAvatarSize.small => BCTypography.textXs,
      BCAvatarSize.medium => BCTypography.textSm,
      BCAvatarSize.large => BCTypography.textBase,
    };
    return base.copyWith(
      fontWeight: BCTypography.medium,
      color: foreground,
    );
  }

  static ShapeDecoration decoration({
    required BCAvatarVariant variant,
    required BCAvatarColor color,
    required BCThemeExtension bc,
  }) {
    return ShapeDecoration(
      color: backgroundColor(variant: variant, color: color, bc: bc),
      shape: shape(),
    );
  }
}
