import 'package:bc_ui/src/theme/color_schemes.dart';
import 'package:bc_ui/src/theme/dark_theme.dart';
import 'package:bc_ui/src/theme/light_theme.dart';
import 'package:flutter/material.dart';

class BCThemeOverrides {
  const BCThemeOverrides({this.primary, this.secondary, this.error});

  final Color? primary;
  final Color? secondary;
  final Color? error;
}

abstract final class BCTheme {
  static ThemeData light({BCThemeOverrides? overrides}) {
    _assertBindingInitialized();
    return buildLightTheme(
      colorScheme: _colorScheme(BCColorSchemes.light, overrides),
    );
  }

  static ThemeData dark({BCThemeOverrides? overrides}) {
    _assertBindingInitialized();
    return buildDarkTheme(
      colorScheme: _colorScheme(BCColorSchemes.dark, overrides),
    );
  }

  static void _assertBindingInitialized() {
    assert(() {
      try {
        WidgetsBinding.instance;
        return true;
      } on Object {
        throw FlutterError(
          'BCTheme must be built after Flutter binding is initialized.\n'
          'Build theme inside a root widget\'s build() method, or call '
          'WidgetsFlutterBinding.ensureInitialized() before BCTheme.light() '
          'or BCTheme.dark().',
        );
      }
    }());
  }

  static ColorScheme _colorScheme(
    ColorScheme base,
    BCThemeOverrides? overrides,
  ) {
    if (overrides == null) return base;
    return base.copyWith(
      primary: overrides.primary,
      secondary: overrides.secondary,
      error: overrides.error,
    );
  }
}
