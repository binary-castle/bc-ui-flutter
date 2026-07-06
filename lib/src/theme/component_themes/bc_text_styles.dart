import 'package:bc_ui/src/tokens/bc_typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class BCTextStyles {
  // Inter via google_fonts — call only after Flutter binding is initialized
  // (e.g. inside a root widget's build(), not in main() before runApp).
  static TextStyle Function({
    required FontWeight fontWeight,
    required double fontSize,
    required Color color,
  })
  get _font =>
      ({required fontWeight, required fontSize, required color}) =>
          GoogleFonts.inter(
            fontWeight: fontWeight,
            fontSize: fontSize,
            color: color,
          );

  static TextTheme build(ColorScheme colors) {
    return TextTheme(
      // Display
      displayLarge: _font(
        fontWeight: BCTypography.bold,
        fontSize: 57,
        color: colors.onSurface,
      ),

      displayMedium: _font(
        fontWeight: BCTypography.bold,
        fontSize: 45,
        color: colors.onSurface,
      ),

      displaySmall: _font(
        fontWeight: BCTypography.bold,
        fontSize: 36,
        color: colors.onSurface,
      ),

      // Headlines
      headlineLarge: _font(
        fontWeight: BCTypography.bold,
        fontSize: 32,
        color: colors.onSurface,
      ),

      headlineMedium: _font(
        fontWeight: BCTypography.semiBold,
        fontSize: 28,
        color: colors.onSurface,
      ),

      headlineSmall: _font(
        fontWeight: BCTypography.semiBold,
        fontSize: 24,
        color: colors.onSurface,
      ),

      // Titles
      titleLarge: _font(
        fontWeight: BCTypography.semiBold,
        fontSize: 22,
        color: colors.onSurface,
      ),

      titleMedium: _font(
        fontWeight: BCTypography.medium,
        fontSize: 16,
        color: colors.onSurface,
      ),

      titleSmall: _font(
        fontWeight: BCTypography.medium,
        fontSize: 14,
        color: colors.onSurface,
      ),

      // Body
      bodyLarge: _font(
        fontWeight: BCTypography.regular,
        fontSize: 16,
        color: colors.onSurface,
      ),

      bodyMedium: _font(
        fontWeight: BCTypography.regular,
        fontSize: 14,
        color: colors.onSurface,
      ),

      bodySmall: _font(
        fontWeight: BCTypography.regular,
        fontSize: 12,
        color: colors.onSurfaceVariant,
      ),

      // Labels
      labelLarge: _font(
        fontWeight: BCTypography.medium,
        fontSize: 14,
        color: colors.onSurface,
      ),

      labelMedium: _font(
        fontWeight: BCTypography.medium,
        fontSize: 12,
        color: colors.onSurface,
      ),

      labelSmall: _font(
        fontWeight: BCTypography.medium,
        fontSize: 11,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
