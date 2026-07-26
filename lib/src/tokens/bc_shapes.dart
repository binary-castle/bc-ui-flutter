import 'package:flutter/painting.dart';

/// Corner shape helpers. HeroUI Native sets `borderCurve: 'continuous'`
/// (iOS squircle) on most rounded components; [RoundedSuperellipseBorder]
/// is Flutter's exact equivalent of Apple's continuous corner curve.
///
/// Keep all continuous-corner construction behind these helpers so the
/// implementation can be swapped in one place if ever needed.
abstract final class BCShapes {
  static ShapeBorder continuous(double radius, {BorderSide side = BorderSide.none}) {
    return RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(radius),
      side: side,
    );
  }

  static ShapeBorder continuousFrom(
    BorderRadius borderRadius, {
    BorderSide side = BorderSide.none,
  }) {
    return RoundedSuperellipseBorder(borderRadius: borderRadius, side: side);
  }
}
