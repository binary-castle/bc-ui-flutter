import 'package:bc_ui/src/tokens/bc_colors.dart';
import 'package:flutter/material.dart';

abstract final class BCColorSchemes {
  /// HeroUI `background` — page canvas, distinct from card [ColorScheme.surface].
  static const backgroundLight = Color(0xFFF7F7F7);
  static const backgroundDark = Color(0xFF1E1E1E);

  /// HeroUI `surface-tertiary` — used by [BCCardVariant.tertiary].
  static const surfaceTertiaryLight = Color(0xFFEFEFEF);
  static const surfaceTertiaryDark = Color(0xFF27272A);

  static Color background(Brightness brightness) =>
      brightness == Brightness.light ? backgroundLight : backgroundDark;

  static Color surfaceTertiary(Brightness brightness) =>
      brightness == Brightness.light
      ? surfaceTertiaryLight
      : surfaceTertiaryDark;

  static const light = ColorScheme(
    brightness: Brightness.light,

    primary: BCColors.primary,
    onPrimary: Colors.white,

    secondary: BCColors.secondary,
    onSecondary: Colors.white,

    error: BCColors.error,
    onError: Colors.white,

    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF111827),

    outline: Color(0xFFE5E7EB),

    surfaceContainerHighest: Color(0xFFF3F4F6),

    onSurfaceVariant: Color(0xFF6B7280),

    inverseSurface: Color(0xFF1F2937),
    onInverseSurface: Colors.white,

    tertiary: Color(0xFF10B981),
    onTertiary: Colors.white,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,

    primary: BCColors.primary,
    onPrimary: Colors.black,

    secondary: BCColors.secondary,
    onSecondary: Colors.black,

    error: BCColors.error,
    onError: Colors.black,

    surface: Color(0xFF121212),
    onSurface: Colors.white,

    outline: Color(0xFF374151),

    surfaceContainerHighest: Color(0xFF1F2937),

    onSurfaceVariant: Color(0xFF9CA3AF),

    inverseSurface: Colors.white,
    onInverseSurface: Colors.black,

    tertiary: Color(0xFF34D399),
    onTertiary: Colors.black,
  );
}
