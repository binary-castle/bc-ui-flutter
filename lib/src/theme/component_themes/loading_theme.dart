import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCLoadingSize { small, medium, large }

enum BCLoadingColor { defaultColor, success, warning, danger }

abstract final class BCLoadingTheme {
  static double size(BCLoadingSize size) {
    switch (size) {
      case BCLoadingSize.small:
        return BCSizes.spinnerSm;
      case BCLoadingSize.medium:
        return BCSizes.spinnerMd;
      case BCLoadingSize.large:
        return BCSizes.spinnerLg;
    }
  }

  static double strokeWidth(BCLoadingSize size) {
    switch (size) {
      case BCLoadingSize.small:
        return 2;
      case BCLoadingSize.medium:
        return 2.5;
      case BCLoadingSize.large:
        return 3;
    }
  }

  static Color resolveColor({
    BCLoadingColor? semanticColor,
    Color? customColor,
    required ColorScheme colors,
  }) {
    if (customColor != null) return customColor;

    switch (semanticColor ?? BCLoadingColor.defaultColor) {
      case BCLoadingColor.defaultColor:
        return colors.primary;
      case BCLoadingColor.success:
        return BCColors.success;
      case BCLoadingColor.warning:
        return BCColors.warning;
      case BCLoadingColor.danger:
        return colors.error;
    }
  }
}
