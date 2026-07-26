import 'package:bc_ui/src/tokens/bc_typography.dart';
import 'package:flutter/material.dart';

abstract final class BCTextStyles {
  static TextTheme build(
    ColorScheme colors, {
    String? fontFamily,
  }) {
    final family = fontFamily ?? BCTypography.fontFamily;

    TextStyle style({
      required FontWeight fontWeight,
      required double fontSize,
      required Color color,
    }) =>
        TextStyle(
          fontFamily: family,
          fontWeight: fontWeight,
          fontSize: fontSize,
          color: color,
        );

    return TextTheme(
      // Display
      displayLarge: style(
        fontWeight: BCTypography.bold,
        fontSize: 57,
        color: colors.onSurface,
      ),

      displayMedium: style(
        fontWeight: BCTypography.bold,
        fontSize: 45,
        color: colors.onSurface,
      ),

      displaySmall: style(
        fontWeight: BCTypography.bold,
        fontSize: 36,
        color: colors.onSurface,
      ),

      // Headlines
      headlineLarge: style(
        fontWeight: BCTypography.bold,
        fontSize: 32,
        color: colors.onSurface,
      ),

      headlineMedium: style(
        fontWeight: BCTypography.semiBold,
        fontSize: 28,
        color: colors.onSurface,
      ),

      headlineSmall: style(
        fontWeight: BCTypography.semiBold,
        fontSize: 24,
        color: colors.onSurface,
      ),

      // Titles
      titleLarge: style(
        fontWeight: BCTypography.semiBold,
        fontSize: 22,
        color: colors.onSurface,
      ),

      titleMedium: style(
        fontWeight: BCTypography.medium,
        fontSize: 16,
        color: colors.onSurface,
      ),

      titleSmall: style(
        fontWeight: BCTypography.medium,
        fontSize: 14,
        color: colors.onSurface,
      ),

      // Body
      bodyLarge: style(
        fontWeight: BCTypography.regular,
        fontSize: 16,
        color: colors.onSurface,
      ),

      bodyMedium: style(
        fontWeight: BCTypography.regular,
        fontSize: 14,
        color: colors.onSurface,
      ),

      bodySmall: style(
        fontWeight: BCTypography.regular,
        fontSize: 12,
        color: colors.onSurfaceVariant,
      ),

      // Labels
      labelLarge: style(
        fontWeight: BCTypography.medium,
        fontSize: 14,
        color: colors.onSurface,
      ),

      labelMedium: style(
        fontWeight: BCTypography.medium,
        fontSize: 12,
        color: colors.onSurface,
      ),

      labelSmall: style(
        fontWeight: BCTypography.medium,
        fontSize: 11,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
