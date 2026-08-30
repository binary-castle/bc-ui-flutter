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
  static const shimmerHighlightAlphaLight = 0.55;
  static const shimmerHighlightAlphaDark = 0.12;

  /// A text placeholder takes one full line box per line, so a block of them
  /// occupies exactly the height the real text will and nothing shifts when
  /// it arrives. The painted bar is shorter than that box — close to the font
  /// size — which is what leaves the leading as a gap and keeps a stack of
  /// bars reading as prose rather than as slabs.
  static const textBarHeightFactor = 0.875;

  /// Only a wrapped paragraph gets a short final line; a single line fills
  /// its width.
  static const defaultLastLineFraction = 0.6;

  static BorderRadius get defaultBorderRadius =>
      BorderRadius.circular(BCRadius.md);

  /// heroui skeleton.css: `color-mix(in oklab, var(--color-muted) 30%,
  /// transparent)`. `onSurfaceVariant` maps to the muted token.
  static Color backgroundColor(ColorScheme colors) {
    return colors.onSurfaceVariant.withValues(alpha: 0.3);
  }

  /// The band has to read as *lighter* than the 30%-muted base in both
  /// themes, so it is white in both and only the strength changes. Deriving
  /// it from `background` left the light band ~2% lighter than the base and
  /// the dark band darker than it, so neither sweep was visible once the base
  /// stopped painting as the solid muted token.
  static Color shimmerHighlightColor(ColorScheme colors, {Color? override}) {
    if (override != null) return override;

    final alpha = colors.brightness == Brightness.dark
        ? shimmerHighlightAlphaDark
        : shimmerHighlightAlphaLight;

    return Colors.white.withValues(alpha: alpha);
  }

  /// The line box [style] paints into, at the reader's text size. Measured
  /// rather than derived: every type in the scale sets its own `height`, and
  /// a fallback multiplier would drift from it on a resync.
  static double textLineHeight(
    TextStyle style,
    TextScaler scaler,
    TextDirection direction,
  ) {
    return TextPainter(
      text: TextSpan(text: '', style: style),
      textDirection: direction,
      textScaler: scaler,
    ).preferredLineHeight;
  }

  static double textBarHeight(TextStyle style, TextScaler scaler) {
    final fontSize = style.fontSize ?? BCTypography.sizeBase;
    return scaler.scale(fontSize) * textBarHeightFactor;
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
