import 'package:bc_ui/src/tokens/bc_colors.dart';
import 'package:flutter/material.dart';

/// Material [ColorScheme]s derived from the HeroUI Native token palettes so
/// that plain Material widgets blend in with bc_ui components.
abstract final class BCColorSchemes {
  static const backgroundLight = BCColorsLight.background;
  static const backgroundDark = BCColorsDark.background;

  static Color background(Brightness brightness) =>
      brightness == Brightness.light ? backgroundLight : backgroundDark;

  static const light = ColorScheme(
    brightness: Brightness.light,

    primary: BCColorsLight.accent,
    onPrimary: BCColorsLight.accentForeground,

    secondary: BCColorsLight.defaultColor,
    onSecondary: BCColorsLight.defaultForeground,

    error: BCColorsLight.danger,
    onError: BCColorsLight.dangerForeground,

    surface: BCColorsLight.surface,
    onSurface: BCColorsLight.foreground,

    outline: BCColorsLight.border,
    outlineVariant: BCColorsLight.separator,

    surfaceContainerHighest: BCColorsLight.surfaceTertiary,

    onSurfaceVariant: BCColorsLight.muted,

    inverseSurface: BCColorsLight.backgroundInverse,
    onInverseSurface: BCColorsLight.background,

    tertiary: BCColorsLight.success,
    onTertiary: BCColorsLight.successForeground,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,

    primary: BCColorsDark.accent,
    onPrimary: BCColorsDark.accentForeground,

    secondary: BCColorsDark.defaultColor,
    onSecondary: BCColorsDark.defaultForeground,

    error: BCColorsDark.danger,
    onError: BCColorsDark.dangerForeground,

    surface: BCColorsDark.surface,
    onSurface: BCColorsDark.foreground,

    outline: BCColorsDark.border,
    outlineVariant: BCColorsDark.separator,

    surfaceContainerHighest: BCColorsDark.surfaceTertiary,

    onSurfaceVariant: BCColorsDark.muted,

    inverseSurface: BCColorsDark.backgroundInverse,
    onInverseSurface: BCColorsDark.background,

    tertiary: BCColorsDark.success,
    onTertiary: BCColorsDark.successForeground,
  );
}
