import 'package:bc_ui/src/theme/color_schemes.dart';
import 'package:bc_ui/src/theme/dark_theme.dart';
import 'package:bc_ui/src/theme/light_theme.dart';
import 'package:bc_ui/src/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class BCThemeOverrides {
  const BCThemeOverrides({
    this.accent,
    this.fontFamily,
    this.textTheme,
  });

  /// Overrides HeroUI's `accent` token. Accent-derived tokens (hover, soft,
  /// soft-foreground, focus) are recomputed automatically.
  final Color? accent;

  /// Replaces the default bundled Inter family. Declare the font in your app's
  /// `pubspec.yaml` when using a custom family.
  final String? fontFamily;

  /// Full typography override; takes precedence over [fontFamily].
  final TextTheme? textTheme;
}

abstract final class BCTheme {
  static ThemeData light({BCThemeOverrides? overrides}) {
    final ext = BCThemeExtension.light(accent: overrides?.accent);
    final colorScheme = _colorScheme(BCColorSchemes.light, ext);
    return buildLightTheme(
      colorScheme: colorScheme,
      extension: ext,
      fontFamily: overrides?.fontFamily,
      textTheme: overrides?.textTheme,
    );
  }

  static ThemeData dark({BCThemeOverrides? overrides}) {
    final ext = BCThemeExtension.dark(accent: overrides?.accent);
    final colorScheme = _colorScheme(BCColorSchemes.dark, ext);
    return buildDarkTheme(
      colorScheme: colorScheme,
      extension: ext,
      fontFamily: overrides?.fontFamily,
      textTheme: overrides?.textTheme,
    );
  }

  static ColorScheme _colorScheme(ColorScheme base, BCThemeExtension ext) {
    return base.copyWith(primary: ext.accent, onPrimary: ext.accentForeground);
  }
}
