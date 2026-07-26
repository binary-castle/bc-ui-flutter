import 'package:bc_ui/src/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

extension BCContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;

  /// The HeroUI Native semantic token set. Requires the app theme to be
  /// built with [BCTheme.light]/[BCTheme.dark].
  BCThemeExtension get bcTheme => theme.extension<BCThemeExtension>()!;
}
