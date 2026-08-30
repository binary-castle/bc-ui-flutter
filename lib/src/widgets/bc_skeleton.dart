import 'dart:ui' show lerpDouble;

import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/skeleton_theme.dart';
import 'package:bc_ui/src/tokens/tokens.dart';
import 'package:bc_ui/src/widgets/bc_text.dart';
import 'package:flutter/material.dart';

export 'package:bc_ui/src/theme/component_themes/skeleton_theme.dart'
    show
        BCSkeletonAnimation,
        BCSkeletonPulseAnimation,
        BCSkeletonShimmerAnimation,
        BCSkeletonVariant;

/// HeroUI Native SkeletonGroup: cascades `isLoading`, `variant`, and
/// `animation` to descendant [BCSkeleton]s via an inherited scope
/// (skeleton-group.tsx passes the same values through context).
class BCSkeletonGroup extends StatelessWidget {
  const BCSkeletonGroup({
    super.key,
    required this.isLoading,
    this.variant = BCSkeletonVariant.shimmer,
    this.animation,
    required this.child,
  });

  final bool isLoading;
  final BCSkeletonVariant variant;
  final BCSkeletonAnimation? animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _BCSkeletonGroupScope(
      isLoading: isLoading,
      variant: variant,
      animation: animation,
      child: child,
    );
  }
}

class _BCSkeletonGroupScope extends InheritedWidget {
  const _BCSkeletonGroupScope({
    required this.isLoading,
    required this.variant,
    required this.animation,
    required super.child,
  });

  final bool isLoading;
  final BCSkeletonVariant variant;
  final BCSkeletonAnimation? animation;

  static _BCSkeletonGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BCSkeletonGroupScope>();

  @override
  bool updateShouldNotify(_BCSkeletonGroupScope oldWidget) =>
      isLoading != oldWidget.isLoading ||
      variant != oldWidget.variant ||
      animation != oldWidget.animation;
}

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
  }) : lines = 1,
       type = BCTextType.body,
       lastLineFraction = null,
       _isText = false;

  /// Placeholder for text that has not loaded yet.
  ///
  /// Each line takes the full line box of [type] at the reader's text size,
  /// so the block stands exactly as tall as the text will and nothing shifts
  /// when it arrives — which a hand-sized bar cannot promise. Give [child]
  /// the text itself and the swap costs no layout at all. Pass [width] where
  /// the parent leaves the width unbounded.
  const BCSkeleton.text({
    super.key,
    this.lines = 1,
    this.type = BCTextType.body,
    this.lastLineFraction,
    this.child,
    this.isLoading = true,
    this.variant = BCSkeletonVariant.shimmer,
    this.animation,
    this.isAnimatedStyleActive = true,
    this.width,
    this.borderRadius,
  }) : height = null,
       decoration = null,
       _isText = true,
       assert(lines > 0, 'lines must be at least 1'),
       assert(
         lastLineFraction == null ||
             (lastLineFraction > 0 && lastLineFraction <= 1),
         'lastLineFraction must be in (0, 1]',
       );

  final Widget? child;
  final bool isLoading;
  final BCSkeletonVariant variant;
  final BCSkeletonAnimation? animation;
  final bool isAnimatedStyleActive;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxDecoration? decoration;

  /// Lines to stand in for. `BCSkeleton.text` only.
  final int lines;

  /// Type scale the placeholder replaces, which sets its line box and bar
  /// height. `BCSkeleton.text` only.
  final BCTextType type;

  /// Width of the final line as a fraction of the block, applied only when
  /// [lines] is above 1. Defaults to
  /// [BCSkeletonTheme.defaultLastLineFraction]. `BCSkeleton.text` only.
  final double? lastLineFraction;

  final bool _isText;

  @override
  State<BCSkeleton> createState() => _BCSkeletonState();
}

class _BCSkeletonState extends State<BCSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  _BCSkeletonGroupScope? _group;

  /// Group values cascade to items; an item's own non-default props win
  /// for variant/animation, while the group drives isLoading.
  bool get _isLoading => _group?.isLoading ?? widget.isLoading;

  BCSkeletonVariant get _variant {
    if (_group == null) return widget.variant;
    return widget.variant != BCSkeletonVariant.shimmer
        ? widget.variant
        : _group!.variant;
  }

  BCSkeletonAnimation? get _animation =>
      widget.animation ?? _group?.animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _group = _BCSkeletonGroupScope.maybeOf(context);
    _syncAnimation();
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
      animation: _animation,
      variant: _variant,
      isAnimatedStyleActive: widget.isAnimatedStyleActive,
      disableAnimations: MediaQuery.disableAnimationsOf(context),
    );
  }

  void _syncAnimation() {
    _controller.stop();
    _controller.reset();

    if (!_isLoading || _isAnimationDisabled) return;

    switch (_variant) {
      case BCSkeletonVariant.shimmer:
        _controller.duration = BCSkeletonTheme.resolveShimmerDuration(
          _animation,
        );
        _controller.repeat();
      case BCSkeletonVariant.pulse:
        _controller.duration = BCSkeletonTheme.resolvePulseDuration(
          _animation,
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

  Widget _buildSkeleton(
    ColorScheme colors, {
    required double? width,
    required double? height,
  }) {
    final borderRadius = _borderRadius;
    final baseColor = _baseColor(colors);
    final highlightColor = BCSkeletonTheme.shimmerHighlightColor(
      colors,
      override: _animation?.shimmer?.highlightColor,
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
            variant: _variant,
            progress: _controller,
            shimmerCurve: BCSkeletonTheme.resolveShimmerCurve(
              _animation,
            ),
            pulseCurve: BCSkeletonTheme.resolvePulseCurve(_animation),
            pulseMinOpacity: BCSkeletonTheme.resolvePulseMinOpacity(
              _animation,
            ),
            pulseMaxOpacity: BCSkeletonTheme.resolvePulseMaxOpacity(
              _animation,
            ),
            screenWidth: screenWidth,
            textDirection: Directionality.of(context),
            isAnimationDisabled: _isAnimationDisabled,
          ),
          child: SizedBox(width: width, height: height),
        ),
      ),
    );
  }

  /// One bar per line, each sitting in the line box of its type. The bar
  /// is shorter than the box, so the type's own leading becomes the gap
  /// between lines and the block still measures what the text will.
  Widget _buildTextSkeleton(BuildContext context) {
    final colors = context.colors;
    final style = BCText.resolveStyle(context, type: widget.type);
    final scaler = MediaQuery.textScalerOf(context);
    // BCText renders `code` as a padded chip rather than a bare line, so its
    // box is the line plus that padding. The padding is fixed spacing and
    // does not scale with the text.
    final chipPadding = widget.type == BCTextType.code
        ? BCSpacing.unit(0.5) * 2
        : 0.0;
    final lineHeight =
        BCSkeletonTheme.textLineHeight(
          style,
          scaler,
          Directionality.of(context),
        ) +
        chipPadding;
    final barHeight = BCSkeletonTheme.textBarHeight(style, scaler);
    final lastLineFraction =
        widget.lastLineFraction ?? BCSkeletonTheme.defaultLastLineFraction;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(widget.lines, (index) {
        final isRagged = widget.lines > 1 && index == widget.lines - 1;

        return SizedBox(
          height: lineHeight,
          child: FractionallySizedBox(
            widthFactor: isRagged ? lastLineFraction : 1.0,
            alignment: AlignmentDirectional.centerStart,
            // The line box constrains height tightly; Center loosens it so
            // the bar keeps its own height and sits in the middle of the box.
            child: Center(
              child: _buildSkeleton(
                colors,
                width: double.infinity,
                height: barHeight,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enteringDuration = BCSkeletonTheme.resolveEnteringDuration(
      _animation,
    );
    final exitingDuration = BCSkeletonTheme.resolveExitingDuration(
      _animation,
    );

    return AnimatedSwitcher(
      duration: enteringDuration,
      reverseDuration: exitingDuration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _isLoading
          ? SizedBox(
              key: ValueKey('skeleton-${_variant.name}'),
              width: widget.width,
              height: widget.height,
              child: widget._isText
                  ? _buildTextSkeleton(context)
                  : _buildSkeleton(
                      context.colors,
                      width: widget.width,
                      height: widget.height,
                    ),
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

    // The pulse range scales the base alpha rather than replacing it:
    // baseColor is already a translucent 30% muted, and assigning
    // withValues(alpha:) outright would repaint it as the solid muted
    // foreground token, which is darker than every surface in the palette.
    var opacityScale = 1.0;
    if (variant == BCSkeletonVariant.pulse && !isAnimationDisabled) {
      final t = pulseCurve.transform(progress.value);
      opacityScale = lerpDouble(pulseMinOpacity, pulseMaxOpacity, t)!;
    }

    final fillPaint = Paint()
      ..color = baseColor.withValues(alpha: baseColor.a * opacityScale);
    canvas.drawRRect(rrect, fillPaint);

    if (variant != BCSkeletonVariant.shimmer || isAnimationDisabled) return;

    final shimmerProgress = shimmerCurve.transform(progress.value);
    final translateX = lerpDouble(-size.width, screenWidth, shimmerProgress)!;
    final shimmerRect = Rect.fromLTWH(translateX, 0, size.width, size.height);

    // The band fades to a transparent *highlight*, not Colors.transparent:
    // gradient stops interpolate unpremultiplied, so transparent black drags
    // the ramp toward grey and fringes the sweep darker than the base on
    // either side of its centre. Only alpha should vary across the band.
    final edgeColor = highlightColor.withValues(alpha: 0);
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [edgeColor, highlightColor, edgeColor],
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
