import 'package:bc_ui/src/theme/color_schemes.dart';
import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCCardVariant { defaultVariant, secondary, tertiary, transparent }

abstract final class BCCardTheme {
  static const padding = EdgeInsets.all(BCSpacing.md);

  static BorderRadius get borderRadius => BorderRadius.circular(BCRadius.xl);

  static CardThemeData theme(ColorScheme colors) {
    return CardThemeData(
      elevation: 0,
      color: colors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BCRadius.lg),
      ),
    );
  }

  static Color backgroundColor(BCCardVariant variant, ColorScheme colors) {
    switch (variant) {
      case BCCardVariant.defaultVariant:
        return colors.surface;
      case BCCardVariant.secondary:
        return colors.surfaceContainerHighest;
      case BCCardVariant.tertiary:
        return BCColorSchemes.surfaceTertiary(colors.brightness);
      case BCCardVariant.transparent:
        return Colors.transparent;
    }
  }

  static BoxDecoration fillDecoration({
    required BCCardVariant variant,
    required ColorScheme colors,
  }) {
    return BoxDecoration(
      color: backgroundColor(variant, colors),
      borderRadius: borderRadius,
    );
  }

  static BoxDecoration shadowDecoration(ColorScheme colors) {
    return BoxDecoration(borderRadius: borderRadius, boxShadow: shadow(colors));
  }

  static List<BoxShadow> shadow(ColorScheme colors) {
    if (colors.brightness == Brightness.dark) return const [];

    // HeroUI surface-shadow
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 0.5,
        spreadRadius: 0,
      ),
    ];
  }

  static TextStyle titleStyle(TextTheme textTheme, ColorScheme colors) {
    return (textTheme.titleMedium ?? const TextStyle(fontSize: 18)).copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: colors.onSurface,
    );
  }

  static TextStyle descriptionStyle(TextTheme textTheme, ColorScheme colors) {
    return (textTheme.bodyLarge ?? const TextStyle(fontSize: 16)).copyWith(
      fontSize: 16,
      color: colors.onSurfaceVariant,
    );
  }
}
