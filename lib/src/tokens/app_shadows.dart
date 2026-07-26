import 'package:flutter/painting.dart';

/// A HeroUI shadow token: a list of layered outer shadows plus an optional
/// 1px inner hairline used where the CSS source specifies an inset shadow
/// (dark-mode overlays). The hairline is rendered as an inside-stroke border
/// by the consuming widget, which is visually identical to a 1px zero-blur
/// inset shadow.
class BCShadowSet {
  const BCShadowSet({this.shadows = const [], this.innerBorder});

  final List<BoxShadow> shadows;
  final BorderSide? innerBorder;

  static const BCShadowSet none = BCShadowSet();

  bool get isEmpty => shadows.isEmpty && innerBorder == null;

  static BCShadowSet? lerp(BCShadowSet? a, BCShadowSet? b, double t) {
    if (a == null && b == null) return null;
    return BCShadowSet(
      shadows: BoxShadow.lerpList(a?.shadows, b?.shadows, t) ?? const [],
      innerBorder: () {
        final sa = a?.innerBorder;
        final sb = b?.innerBorder;
        if (sa == null && sb == null) return null;
        return BorderSide.lerp(
          sa ?? sb!.copyWith(color: sb.color.withValues(alpha: 0)),
          sb ?? sa!.copyWith(color: sa.color.withValues(alpha: 0)),
          t,
        );
      }(),
    );
  }
}

/// Shadow values from heroui-native/src/styles/variables.css.
abstract final class BCShadows {
  /// Light `--surface-shadow` / `--field-shadow`.
  static const BCShadowSet surfaceLight = BCShadowSet(
    shadows: [
      BoxShadow(
        offset: Offset(0, 2),
        blurRadius: 4,
        color: Color(0x0A000000), // black 4%
      ),
      BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 2,
        color: Color(0x0F000000), // black 6%
      ),
      BoxShadow(
        offset: Offset.zero,
        blurRadius: 1,
        color: Color(0x0F000000), // black 6%
      ),
    ],
  );

  /// Light `--overlay-shadow`.
  static const BCShadowSet overlayLight = BCShadowSet(
    shadows: [
      BoxShadow(
        offset: Offset(0, 2),
        blurRadius: 8,
        color: Color(0x05000000), // black 2%
      ),
      BoxShadow(
        offset: Offset(0, -6),
        blurRadius: 12,
        color: Color(0x03000000), // black 1%
      ),
      BoxShadow(
        offset: Offset(0, 14),
        blurRadius: 28,
        color: Color(0x08000000), // black 3%
      ),
    ],
  );

  /// Dark surfaces/fields have no shadow.
  static const BCShadowSet surfaceDark = BCShadowSet.none;

  /// Dark `--overlay-shadow`: `inset 0 0 1px rgba(255,255,255,0.2)`.
  static const BCShadowSet overlayDark = BCShadowSet(
    innerBorder: BorderSide(
      color: Color(0x33FFFFFF),
      width: 1,
      strokeAlign: BorderSide.strokeAlignInside,
    ),
  );

  static const BCShadowSet fieldLight = surfaceLight;
  static const BCShadowSet fieldDark = BCShadowSet.none;
}
