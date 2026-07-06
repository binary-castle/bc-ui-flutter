import 'package:bc_ui/src/theme/color_schemes.dart';
import 'package:bc_ui/src/theme/component_themes/bc_app_bar_theme.dart';
import 'package:bc_ui/src/theme/component_themes/bc_text_styles.dart';
import 'package:bc_ui/src/theme/component_themes/button_theme.dart';
import 'package:bc_ui/src/theme/component_themes/card_theme.dart';
import 'package:bc_ui/src/theme/component_themes/input_theme.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme({ColorScheme? colorScheme}) {
  final colors = colorScheme ?? BCColorSchemes.light;
  final textTheme = BCTextStyles.build(colors);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colors,
    scaffoldBackgroundColor: BCColorSchemes.backgroundLight,
    appBarTheme: BCAppBarTheme.theme(colors),
    cardTheme: BCCardTheme.theme(colors),
    filledButtonTheme: BCButtonTheme.filled(colors, textTheme),
    outlinedButtonTheme: BCButtonTheme.outlined(colors, textTheme),
    textButtonTheme: BCButtonTheme.text(colors, textTheme),
    inputDecorationTheme: BCInputTheme.theme(colors),
    textTheme: textTheme,
  );
}
