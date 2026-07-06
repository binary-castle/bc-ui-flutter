import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCBadgeSize { small, medium, large }

enum BCBadgeVariant { primary, secondary, tertiary, soft }

enum BCBadgeColor { accent, defaultColor, success, warning, danger }

abstract final class BCBadgeTheme {
  static const _softAlpha = 0.15;

  static EdgeInsets padding(BCBadgeSize size) {
    switch (size) {
      case BCBadgeSize.small:
        return const EdgeInsets.symmetric(
          horizontal: BCSpacing.sm,
          vertical: BCSpacing.xxs,
        );
      case BCBadgeSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: BCSpacing.sm + BCSpacing.xs,
          vertical: BCSpacing.xs,
        );
      case BCBadgeSize.large:
        return const EdgeInsets.symmetric(
          horizontal: BCSpacing.md,
          vertical: BCSpacing.xs + BCSpacing.xxs,
        );
    }
  }

  static BorderRadius borderRadius(BCBadgeSize size) {
    switch (size) {
      case BCBadgeSize.small:
        return BorderRadius.circular(BCRadius.sm);
      case BCBadgeSize.medium:
        return BorderRadius.circular(BCRadius.lg);
      case BCBadgeSize.large:
        return BorderRadius.circular(BCRadius.xl);
    }
  }

  static TextStyle labelStyle(
    BCBadgeSize size,
    TextTheme textTheme,
    Color foreground,
  ) {
    final fontSize = switch (size) {
      BCBadgeSize.small => 12.0,
      BCBadgeSize.medium => 14.0,
      BCBadgeSize.large => 16.0,
    };

    return (textTheme.labelMedium ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: foreground,
      height: 1.2,
    );
  }

  static Color semanticColor(BCBadgeColor color, ColorScheme colors) {
    switch (color) {
      case BCBadgeColor.accent:
        return colors.primary;
      case BCBadgeColor.defaultColor:
        return colors.surfaceContainerHighest;
      case BCBadgeColor.success:
        return BCColors.success;
      case BCBadgeColor.warning:
        return BCColors.warning;
      case BCBadgeColor.danger:
        return colors.error;
    }
  }

  static Color primaryForeground(BCBadgeColor color, ColorScheme colors) {
    switch (color) {
      case BCBadgeColor.accent:
        return colors.onPrimary;
      case BCBadgeColor.defaultColor:
        return colors.onSurface;
      case BCBadgeColor.success:
        return colors.onSurface;
      case BCBadgeColor.warning:
        return colors.onSurface;
      case BCBadgeColor.danger:
        return colors.onError;
    }
  }

  static Color softForeground(BCBadgeColor color, ColorScheme colors) {
    switch (color) {
      case BCBadgeColor.accent:
        return colors.primary;
      case BCBadgeColor.defaultColor:
        return colors.onSurface;
      case BCBadgeColor.success:
        return BCColors.success;
      case BCBadgeColor.warning:
        return BCColors.warning;
      case BCBadgeColor.danger:
        return colors.error;
    }
  }

  static Color backgroundColor({
    required BCBadgeVariant variant,
    required BCBadgeColor color,
    required ColorScheme colors,
  }) {
    switch (variant) {
      case BCBadgeVariant.primary:
        return semanticColor(color, colors);
      case BCBadgeVariant.secondary:
        return colors.surfaceContainerHighest;
      case BCBadgeVariant.tertiary:
        return Colors.transparent;
      case BCBadgeVariant.soft:
        return semanticColor(color, colors).withValues(alpha: _softAlpha);
    }
  }

  static Color foregroundColor({
    required BCBadgeVariant variant,
    required BCBadgeColor color,
    required ColorScheme colors,
  }) {
    switch (variant) {
      case BCBadgeVariant.primary:
        return primaryForeground(color, colors);
      case BCBadgeVariant.secondary:
      case BCBadgeVariant.tertiary:
      case BCBadgeVariant.soft:
        return softForeground(color, colors);
    }
  }

  static BoxDecoration decoration({
    required BCBadgeVariant variant,
    required BCBadgeColor color,
    required BCBadgeSize size,
    required ColorScheme colors,
  }) {
    return BoxDecoration(
      color: backgroundColor(variant: variant, color: color, colors: colors),
      borderRadius: borderRadius(size),
    );
  }
}
