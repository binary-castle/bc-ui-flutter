import 'dart:ui' show lerpDouble;

import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/skeleton_theme.dart';
import 'package:flutter/material.dart';

export 'package:bc_ui/src/theme/component_themes/skeleton_theme.dart'
    show
        BCSkeletonAnimation,
        BCSkeletonPulseAnimation,
        BCSkeletonShimmerAnimation,
        BCSkeletonVariant;

class BCSkeleton extends StatefulWidget {
  const BCSkeleton({
    super.key,
    this.child,
    this.isLoading = true,
    this.variant = BCSkeletonVariant.shimmer,
    this.animation,
    this.isAnimatedStyleActive = true,
    this.width,
    this.height,
    this.borderRadius,
    this.decoration,
  });

  final Widget? child;
  final bool isLoading;
  final BCSkeletonVariant variant;
  final BCSkeletonAnimation? animation;
  final bool isAnimatedStyleActive;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxDecoration? decoration;

  @override
  State<BCSkeleton> createState() => _BCSkeletonState();
}

class _BCSkeletonState extends State<BCSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _dependenciesReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesReady) {
      _dependenciesReady = true;
      _syncAnimation();
    }
  }

  @override
  void didUpdateWidget(BCSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading ||
        oldWidget.variant != widget.variant ||
        oldWidget.animation != widget.animation ||
        oldWidget.isAnimatedStyleActive != widget.isAnimatedStyleActive) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isAnimationDisabled {
    return BCSkeletonTheme.isAnimationDisabled(
      animation: widget.animation,
      variant: widget.variant,
      isAnimatedStyleActive: widget.isAnimatedStyleActive,
      disableAnimations: MediaQuery.disableAnimationsOf(context),
    );
  }

  void _syncAnimation() {
    _controller.stop();
    _controller.reset();

    if (!widget.isLoading || _isAnimationDisabled) return;

    switch (widget.variant) {
      case BCSkeletonVariant.shimmer:
        _controller.duration = BCSkeletonTheme.resolveShimmerDuration(
          widget.animation,
        );
        _controller.repeat();
      case BCSkeletonVariant.pulse:
        _controller.duration = BCSkeletonTheme.resolvePulseDuration(
          widget.animation,
        );
        _controller.repeat(reverse: true);
      case BCSkeletonVariant.none:
        break;
    }
  }

  BorderRadiusGeometry get _borderRadius {
    return widget.borderRadius ??
        widget.decoration?.borderRadius ??
        BCSkeletonTheme.defaultBorderRadius;
  }

  Color _baseColor(ColorScheme colors) {
    return widget.decoration?.color ?? BCSkeletonTheme.backgroundColor(colors);
  }

  Widget _buildSkeleton(ColorScheme colors) {
    final borderRadius = _borderRadius;
    final baseColor = _baseColor(colors);
    final highlightColor = BCSkeletonTheme.shimmerHighlightColor(
      colors,
      override: widget.animation?.shimmer?.highlightColor,
    );
    final screenWidth = MediaQuery.sizeOf(context).width;

    return ClipRRect(
      borderRadius: borderRadius,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SkeletonPainter(
            baseColor: baseColor,
            highlightColor: highlightColor,
            borderRadius: borderRadius,
            variant: widget.variant,
            progress: _controller,
            shimmerCurve: BCSkeletonTheme.resolveShimmerCurve(
              widget.animation,
            ),
            pulseCurve: BCSkeletonTheme.resolvePulseCurve(widget.animation),
            pulseMinOpacity: BCSkeletonTheme.resolvePulseMinOpacity(
              widget.animation,
            ),
            pulseMaxOpacity: BCSkeletonTheme.resolvePulseMaxOpacity(
              widget.animation,
            ),
            screenWidth: screenWidth,
            textDirection: Directionality.of(context),
            isAnimationDisabled: _isAnimationDisabled,
          ),
          child: SizedBox(width: widget.width, height: widget.height),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enteringDuration = BCSkeletonTheme.resolveEnteringDuration(
      widget.animation,
    );
    final exitingDuration = BCSkeletonTheme.resolveExitingDuration(
      widget.animation,
    );

    return AnimatedSwitcher(
      duration: enteringDuration,
      reverseDuration: exitingDuration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: widget.isLoading
          ? SizedBox(
              key: ValueKey('skeleton-${widget.variant.name}'),
              width: widget.width,
              height: widget.height,
              child: _buildSkeleton(context.colors),
            )
          : KeyedSubtree(
              key: const ValueKey('content'),
              child: widget.child ?? const SizedBox.shrink(),
            ),
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({
    required this.baseColor,
    required this.highlightColor,
    required this.borderRadius,
    required this.variant,
    required this.progress,
    required this.shimmerCurve,
    required this.pulseCurve,
    required this.pulseMinOpacity,
    required this.pulseMaxOpacity,
    required this.screenWidth,
    required this.textDirection,
    required this.isAnimationDisabled,
  }) : super(repaint: progress);

  final Color baseColor;
  final Color highlightColor;
  final BorderRadiusGeometry borderRadius;
  final BCSkeletonVariant variant;
  final Animation<double> progress;
  final Curve shimmerCurve;
  final Curve pulseCurve;
  final double pulseMinOpacity;
  final double pulseMaxOpacity;
  final double screenWidth;
  final TextDirection textDirection;
  final bool isAnimationDisabled;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;
    final rrect = borderRadius.resolve(textDirection).toRRect(rect);

    var opacity = 1.0;
    if (variant == BCSkeletonVariant.pulse && !isAnimationDisabled) {
      final t = pulseCurve.transform(progress.value);
      opacity = lerpDouble(pulseMinOpacity, pulseMaxOpacity, t)!;
    }

    final fillPaint = Paint()..color = baseColor.withValues(alpha: opacity);
    canvas.drawRRect(rrect, fillPaint);

    if (variant != BCSkeletonVariant.shimmer || isAnimationDisabled) return;

    final shimmerProgress = shimmerCurve.transform(progress.value);
    final translateX = lerpDouble(-size.width, screenWidth, shimmerProgress)!;
    final shimmerRect = Rect.fromLTWH(translateX, 0, size.width, size.height);

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, highlightColor, Colors.transparent],
      ).createShader(shimmerRect);

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(shimmerRect, shimmerPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SkeletonPainter oldDelegate) {
    return baseColor != oldDelegate.baseColor ||
        highlightColor != oldDelegate.highlightColor ||
        borderRadius != oldDelegate.borderRadius ||
        variant != oldDelegate.variant ||
        shimmerCurve != oldDelegate.shimmerCurve ||
        pulseCurve != oldDelegate.pulseCurve ||
        pulseMinOpacity != oldDelegate.pulseMinOpacity ||
        pulseMaxOpacity != oldDelegate.pulseMaxOpacity ||
        screenWidth != oldDelegate.screenWidth ||
        textDirection != oldDelegate.textDirection ||
        isAnimationDisabled != oldDelegate.isAnimationDisabled;
  }
}
