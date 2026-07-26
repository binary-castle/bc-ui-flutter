import 'package:bc_ui/src/theme/color_schemes.dart';
import 'package:bc_ui/src/theme/component_themes/bc_app_bar_theme.dart';
import 'package:bc_ui/src/theme/component_themes/bc_text_styles.dart';
import 'package:bc_ui/src/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme({
  ColorScheme? colorScheme,
  BCThemeExtension? extension,
  String? fontFamily,
  TextTheme? textTheme,
}) {
  final colors = colorScheme ?? BCColorSchemes.light;
  final ext = extension ?? BCThemeExtension.light();
  final resolvedTextTheme =
      textTheme ?? BCTextStyles.build(colors, fontFamily: fontFamily);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colors,
    extensions: [ext],
    scaffoldBackgroundColor: ext.background,
    dividerColor: ext.border,
    appBarTheme: BCAppBarTheme.theme(colors),
    textTheme: resolvedTextTheme,
  );
}
