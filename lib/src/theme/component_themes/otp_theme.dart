import 'package:bc_ui/src/theme/theme_extensions.dart';
import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCInputOTPVariant { primary, secondary }

/// InputOTP styling from heroui-native's input-otp.css: 44×48 slots with
/// 14px continuous corners, field background + field shadow (primary),
/// a 2px accent outline on the active slot (danger when invalid),
/// semibold text-lg glyphs.
abstract final class BCInputOTPTheme {
  static const slotHeight = 48.0;
  static const slotWidth = 44.0;
  static const slotGap = 8.0;
  static const radius = BCRadius.field;
  static const activeOutlineWidth = 2.0;
  static const caretWidth = 2.0;
  static const caretHeight = 18.0;
  static const separatorHeight = 2.0;
  static const separatorWidth = 8.0;
  static const caretBlink = Duration(milliseconds: 500);

  static Color fillColor(BCInputOTPVariant variant, BCThemeExtension bc) {
    return switch (variant) {
      BCInputOTPVariant.primary => bc.field,
      BCInputOTPVariant.secondary => bc.defaultColor,
    };
  }

  static TextStyle valueTextStyle(BCThemeExtension bc) {
    return BCTypography.textLg.copyWith(
      fontWeight: BCTypography.semiBold,
      color: bc.foreground,
    );
  }

  static TextStyle placeholderTextStyle(BCThemeExtension bc) {
    return BCTypography.textLg.copyWith(
      fontWeight: BCTypography.semiBold,
      color: bc.fieldPlaceholder.withValues(alpha: 0.5),
    );
  }

  static Color caretColor(BCThemeExtension bc) => bc.fieldPlaceholder;

  static Color separatorColor(BCThemeExtension bc) =>
      bc.separator.withValues(alpha: 0.5);

  static ShapeDecoration slotDecoration({
    required BCThemeExtension bc,
    required BCInputOTPVariant variant,
    required bool isActive,
    required bool isInvalid,
  }) {
    final BorderSide side;
    if (isInvalid) {
      side = BorderSide(color: bc.danger, width: activeOutlineWidth);
    } else if (isActive) {
      side = BorderSide(color: bc.accent, width: activeOutlineWidth);
    } else {
      side = BorderSide.none;
    }

    return ShapeDecoration(
      color: fillColor(variant, bc),
      shape: BCShapes.continuous(radius, side: side),
      shadows: variant == BCInputOTPVariant.primary
          ? bc.fieldShadow.shadows
          : null,
    );
  }
}
