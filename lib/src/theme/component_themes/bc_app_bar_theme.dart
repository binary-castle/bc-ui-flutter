import 'package:flutter/material.dart';

abstract final class BCAppBarTheme {
  static AppBarTheme theme(ColorScheme colors) {
    return AppBarTheme(
      elevation: 0,

      centerTitle: false,

      backgroundColor: colors.surface,

      foregroundColor: colors.onSurface,
    );
  }
}
