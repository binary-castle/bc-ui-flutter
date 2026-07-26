import 'package:bc_ui/src/theme/color_schemes.dart';
import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum BCSkeletonVariant { shimmer, pulse, none }

class BCSkeletonShimmerAnimation {
  const BCSkeletonShimmerAnimation({
    this.duration,
    this.speed,
    this.highlightColor,
    this.curve,
    this.disabled = false,
  });

  final Duration? duration;
  final double? speed;
  final Color? highlightColor;
  final Curve? curve;
  final bool disabled;
}

class BCSkeletonPulseAnimation {
  const BCSkeletonPulseAnimation({
    this.duration,
    this.minOpacity,
    this.maxOpacity,
    this.curve,
    this.disabled = false,
  });

  final Duration? duration;
  final double? minOpacity;
  final double? maxOpacity;
  final Curve? curve;
  final bool disabled;
}

class BCSkeletonAnimation {
  const BCSkeletonAnimation({
    this.shimmer,
    this.pulse,
    this.enteringDuration,
    this.exitingDuration,
    this.disableAll = false,
  });

  final BCSkeletonShimmerAnimation? shimmer;
  final BCSkeletonPulseAnimation? pulse;
  final Duration? enteringDuration;
  final Duration? exitingDuration;
  final bool disableAll;
}

abstract final class BCSkeletonTheme {
  static const shimmerDuration = Duration(milliseconds: 1500);
  static const pulseDuration = Duration(milliseconds: 1000);
  static const defaultSpeed = 1.0;
  static const defaultPulseMinOpacity = 0.5;
  static const defaultPulseMaxOpacity = 1.0;

  static BorderRadius get defaultBorderRadius =>
      BorderRadius.circular(BCRadius.md);

  /// heroui skeleton.css: `color-mix(in oklab, var(--color-muted) 30%,
  /// transparent)`. `onSurfaceVariant` maps to the muted token.
  static Color backgroundColor(ColorScheme colors) {
    return colors.onSurfaceVariant.withValues(alpha: 0.3);
  }

  static Color shimmerHighlightColor(ColorScheme colors, {Color? override}) {
    if (override != null) return override;

    final background = BCColorSchemes.background(colors.brightness);
    if (colors.brightness == Brightness.dark) {
      return Color.lerp(background, Colors.white, 0.1)!.withValues(alpha: 0.1);
    }

    return Color.lerp(background, Colors.black, 0.1)!.withValues(alpha: 0.75);
  }

  static Duration resolveShimmerDuration(BCSkeletonAnimation? animation) {
    final config = animation?.shimmer;
    final duration = config?.duration ?? shimmerDuration;
    final speed = config?.speed ?? defaultSpeed;

    if (speed <= 0) return duration;

    return Duration(milliseconds: (duration.inMilliseconds / speed).round());
  }

  static Duration resolvePulseDuration(BCSkeletonAnimation? animation) {
    return animation?.pulse?.duration ?? pulseDuration;
  }

  static Curve resolveShimmerCurve(BCSkeletonAnimation? animation) {
    return animation?.shimmer?.curve ?? Curves.linear;
  }

  static Curve resolvePulseCurve(BCSkeletonAnimation? animation) {
    return animation?.pulse?.curve ?? Curves.easeInOut;
  }

  static double resolvePulseMinOpacity(BCSkeletonAnimation? animation) {
    return animation?.pulse?.minOpacity ?? defaultPulseMinOpacity;
  }

  static double resolvePulseMaxOpacity(BCSkeletonAnimation? animation) {
    return animation?.pulse?.maxOpacity ?? defaultPulseMaxOpacity;
  }

  static Duration resolveEnteringDuration(BCSkeletonAnimation? animation) {
    return animation?.enteringDuration ?? BCDuration.normal;
  }

  static Duration resolveExitingDuration(BCSkeletonAnimation? animation) {
    return animation?.exitingDuration ?? BCDuration.normal;
  }

  static bool isAnimationDisabled({
    required BCSkeletonAnimation? animation,
    required BCSkeletonVariant variant,
    required bool isAnimatedStyleActive,
    required bool disableAnimations,
  }) {
    if (!isAnimatedStyleActive) return true;
    if (disableAnimations) return true;
    if (animation?.disableAll == true) return true;
    if (variant == BCSkeletonVariant.none) return true;

    if (variant == BCSkeletonVariant.shimmer) {
      return animation?.shimmer?.disabled == true;
    }

    if (variant == BCSkeletonVariant.pulse) {
      return animation?.pulse?.disabled == true;
    }

    return false;
  }
}
