import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCSeparatorVariant { thin, thick }

enum BCSeparatorOrientation { horizontal, vertical }

abstract final class BCSeparatorTheme {
  static Color color(ColorScheme colors) => colors.outline;

  static double thickness({
    required BCSeparatorVariant variant,
    required BuildContext context,
    double? override,
  }) {
    if (override != null) return override;
    return switch (variant) {
      BCSeparatorVariant.thin => 1.0 / MediaQuery.devicePixelRatioOf(context),
      BCSeparatorVariant.thick => BCSizes.separatorThick,
    };
  }
}
