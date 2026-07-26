import 'package:flutter/animation.dart';

/// HeroUI Native animation constants, collected from the per-component
/// `*.constants.ts` / `*.animation.ts` files. Reanimated spring parameters
/// map 1:1 onto Flutter's [SpringDescription] (same physics model).
abstract final class BCMotion {
  /// Default timing used across components (e.g. Switch track color):
  /// 175ms cubic-bezier(0.25, 0.1, 0.25, 1).
  static const Duration timingDuration = Duration(milliseconds: 175);
  static const Curve timingCurve = Cubic(0.25, 0.1, 0.25, 1.0);

  // --- PressableFeedback ---

  /// Default press scale target. The effective scale is width-compensated:
  /// `1 - (1 - scale) * (scaleReferenceWidth / width)` so wide elements
  /// shrink by the same absolute amount as a 300px-wide one.
  static const double pressScale = 0.985;
  static const double pressScaleReferenceWidth = 300;
  static const Duration pressScaleDuration = Duration(milliseconds: 300);

  /// Reanimated's `Easing.out(Easing.ease)` is strongly front-loaded;
  /// easeOutCubic is the closest Flutter curve (plain easeOut is too flat
  /// early, making quick taps imperceptible).
  static const Curve pressScaleCurve = Curves.easeOutCubic;

  static const Duration highlightDuration = Duration(milliseconds: 200);
  static const double highlightPressedOpacity = 0.1;

  /// Highlight overlay color (theme-aware gray from
  /// pressable-feedback.animation.ts).
  static const Color highlightColorLight = Color(0xFF3F3F46);
  static const Color highlightColorDark = Color(0xFFD4D4D8);

  static const Duration rippleBaseDuration = Duration(milliseconds: 1000);
  static const Duration rippleMinDuration = Duration(milliseconds: 750);

  // --- Springs (mass, stiffness, damping) ---

  static final SpringDescription switchThumbSpring =
      SpringDescription(mass: 2, stiffness: 1600, damping: 120);

  static final SpringDescription accordionSpring =
      SpringDescription(mass: 4, stiffness: 1600, damping: 140);

  static final SpringDescription accordionIndicatorSpring =
      SpringDescription(mass: 4, stiffness: 1000, damping: 140);

  static final SpringDescription checkboxIndicatorSpring =
      SpringDescription(mass: 1, stiffness: 1200, damping: 120);

  static final SpringDescription sliderThumbSpring =
      SpringDescription(mass: 0.5, stiffness: 200, damping: 15);

  static final SpringDescription tabsIndicatorSpring =
      SpringDescription(mass: 1, stiffness: 1200, damping: 120);

  /// Switch track color transition (switch.animation.ts).
  static const Duration switchTrackDuration = Duration(milliseconds: 150);

  // --- Component timings ---

  static const Duration spinnerRotationDuration = Duration(milliseconds: 1000);
  static const Duration spinnerFadeInDuration = Duration(milliseconds: 200);
  static const Duration spinnerFadeOutDuration = Duration(milliseconds: 100);

  static const Duration skeletonShimmerDuration =
      Duration(milliseconds: 1500);
  static const Duration skeletonPulseDuration = Duration(milliseconds: 1000);

  /// Description / FieldError fade (150ms ease-out).
  static const Duration helperFadeDuration = Duration(milliseconds: 150);

  static const Duration scrollShadowDuration = Duration(milliseconds: 200);

  static const Duration accordionContentFadeDuration =
      Duration(milliseconds: 200);
}
