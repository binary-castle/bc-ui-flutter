import 'package:flutter/painting.dart';

/// HeroUI Native typography — Inter with tailwind v4's default text scale.
///
/// Each `TextStyle` pairs the tailwind font size with its line height
/// (expressed as Flutter's `height` multiplier) so text metrics match the
/// React Native library.
abstract final class BCTypography {
  static const String fontFamily = 'Inter';

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  /// tailwind `tracking-tight` (-0.025em) for the given font size.
  static double trackingTight(double fontSize) => fontSize * -0.025;

  // Font sizes (px)
  static const double sizeXs = 12;
  static const double sizeSm = 14;
  static const double sizeBase = 16;
  static const double sizeLg = 18;
  static const double sizeXl = 20;
  static const double size2xl = 24;
  static const double size3xl = 30;
  static const double size4xl = 36;

  // size / line-height pairs from tailwind's default scale
  static const TextStyle textXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeXs,
    height: 16 / 12,
  );
  static const TextStyle textSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeSm,
    height: 20 / 14,
  );
  static const TextStyle textBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeBase,
    height: 24 / 16,
  );
  static const TextStyle textLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeLg,
    height: 28 / 18,
  );
  static const TextStyle textXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeXl,
    height: 28 / 20,
  );
  static const TextStyle text2xl = TextStyle(
    fontFamily: fontFamily,
    fontSize: size2xl,
    height: 32 / 24,
  );
  static const TextStyle text3xl = TextStyle(
    fontFamily: fontFamily,
    fontSize: size3xl,
    height: 36 / 30,
  );
  static const TextStyle text4xl = TextStyle(
    fontFamily: fontFamily,
    fontSize: size4xl,
    height: 40 / 36,
  );
}
