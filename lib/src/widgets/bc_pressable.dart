import 'dart:math' as math;

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart' show InkWell, Material, MaterialType;
import 'package:flutter/widgets.dart';

import '../tokens/bc_motion.dart';

/// Which press feedback a [BCPressable] renders.
///
/// The heroui-native styles (default): `scaleHighlight`, `scaleRipple`,
/// `scale`, and `highlight` (color overlay only, used by list rows that
/// shouldn't scale). `material` uses Flutter's standard [InkWell] ripple
/// instead, for apps that prefer Material feedback. `none` disables all
/// feedback.
enum BCPressFeedback {
  scaleHighlight,
  scaleRipple,
  scale,
  highlight,
  material,
  none,
}

/// Port of HeroUI Native's PressableFeedback engine.
///
/// Layers, matching pressable-feedback.animation.ts:
/// - **scale**: shrinks to 0.985 on press, width-compensated so wide elements
///   shrink by the same absolute amount as a 300px-wide element
///   (300ms ease-out).
/// - **highlight**: a shape-clipped color overlay fading between
///   [highlightOpacityRange] (default 0 → 0.1 over 200ms).
/// - **ripple**: an expanding circle from the touch point with radius
///   `diagonal * 1.25` (progress 0→1 on press, 1→2 fade on release).
class BCPressable extends StatefulWidget {
  const BCPressable({
    super.key,
    required this.child,
    this.background,
    this.onPressed,
    this.onLongPress,
    this.feedback = BCPressFeedback.scaleHighlight,
    this.shape,
    this.highlightColor,
    this.highlightOpacityRange,
    this.scaleTarget = BCMotion.pressScale,
    this.ignoreScaleCoefficient = false,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;

  /// Painted behind the highlight/ripple layers, which in turn sit behind
  /// [child]. Put the component's background decoration here so press
  /// highlights never cover the content (heroui renders its Highlight
  /// between background and children the same way).
  final Widget? background;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final BCPressFeedback feedback;

  /// Shape used to clip the highlight/ripple layers. When null the layers
  /// fill the child's rect unclipped.
  final ShapeBorder? shape;

  /// Highlight overlay color. Defaults to HeroUI's theme-aware gray; pass a
  /// component's `*-hover` token to reproduce CSS hover-style highlights.
  final Color? highlightColor;

  /// (unpressed, pressed) highlight opacity. Defaults to (0, 0.1).
  final (double, double)? highlightOpacityRange;

  final double scaleTarget;

  /// Disables the 300/width scale compensation.
  final bool ignoreScaleCoefficient;

  final bool enabled;
  final HitTestBehavior behavior;

  @override
  State<BCPressable> createState() => _BCPressableState();
}

class _BCPressableState extends State<BCPressable>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _highlightController;

  // Ripple progress runs 0 -> 1 while pressed (expand) and 1 -> 2 on release
  // (fade), matching the two-stage interpolation in heroui.
  late final AnimationController _rippleController;
  Offset _rippleCenter = Offset.zero;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: BCMotion.pressScaleDuration,
    );
    _highlightController = AnimationController(
      vsync: this,
      duration: BCMotion.highlightDuration,
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: BCMotion.rippleBaseDuration,
      upperBound: 2,
    );
  }

  bool get _hasScale =>
      widget.feedback == BCPressFeedback.scale ||
      widget.feedback == BCPressFeedback.scaleHighlight ||
      widget.feedback == BCPressFeedback.scaleRipple;

  bool get _hasHighlight =>
      widget.feedback == BCPressFeedback.scaleHighlight ||
      widget.feedback == BCPressFeedback.highlight;

  bool get _hasRipple => widget.feedback == BCPressFeedback.scaleRipple;

  bool get _interactive => widget.enabled && widget.onPressed != null;

  @override
  void dispose() {
    _scaleController.dispose();
    _highlightController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  double _adjustedScale() {
    final width = context.size?.width ?? 0;
    final coefficient = widget.ignoreScaleCoefficient || width <= 0
        ? 1.0
        : BCMotion.pressScaleReferenceWidth / width;
    return 1 - (1 - widget.scaleTarget) * coefficient;
  }

  /// Ensures a quick tap still produces visible feedback: the release
  /// animation waits until the press has been shown at least this long.
  static const Duration _minPressHold = Duration(milliseconds: 150);

  /// Width-compensated scale target, captured on pointer-down (reading
  /// `context.size` is only legal in event handlers, not during build).
  double _pressTargetScale = 1;

  DateTime? _pressStart;
  Offset? _pointerDownPosition;
  bool _visualPressed = false;
  int _pressGeneration = 0;

  /// Press visuals start on the raw pointer-down — before Flutter's gesture
  /// arena has decided between tap and scroll — so feedback appears the
  /// instant the finger touches, like React Native's Pressable. If the touch
  /// turns into a scroll ([_handlePointerMove] past slop) the press is
  /// released without firing [BCPressable.onPressed].
  void _handlePointerDown(PointerDownEvent event) {
    if (!_interactive) return;
    _pointerDownPosition = event.position;
    _visualPressed = true;
    _pressIn(event.localPosition);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final down = _pointerDownPosition;
    if (!_visualPressed || down == null) return;
    if ((event.position - down).distance > kTouchSlop) {
      _visualPressed = false;
      _release();
    }
  }

  void _handlePointerEnd() {
    if (!_visualPressed) return;
    _visualPressed = false;
    _release();
  }

  void _pressIn(Offset localPosition) {
    if (!_interactive) return;
    _pressGeneration++;
    _pressStart = DateTime.now();
    _pressTargetScale = _adjustedScale();
    if (_hasScale) {
      _scaleController.animateTo(
        1,
        duration: BCMotion.pressScaleDuration,
        curve: BCMotion.pressScaleCurve,
      );
    }
    if (_hasHighlight) {
      _highlightController.animateTo(1, curve: Curves.linear);
    }
    if (_hasRipple) {
      _rippleCenter = localPosition;
      _rippleController
        ..value = 0
        ..animateTo(1, curve: Curves.linear);
    }
  }

  Future<void> _release() async {
    final generation = _pressGeneration;
    final start = _pressStart;
    _pressStart = null;
    if (start != null) {
      final elapsed = DateTime.now().difference(start);
      if (elapsed < _minPressHold) {
        await Future<void>.delayed(_minPressHold - elapsed);
      }
    }
    // A newer press started while we were waiting — it owns the visuals now.
    if (!mounted || generation != _pressGeneration) return;
    if (_hasScale) {
      _scaleController.animateBack(
        0,
        duration: BCMotion.pressScaleDuration,
        curve: BCMotion.pressScaleCurve,
      );
    }
    if (_hasHighlight) {
      _highlightController.animateBack(0, curve: Curves.linear);
    }
    if (_hasRipple && _rippleController.value > 0) {
      _rippleController.animateTo(2, curve: Curves.linear);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result = widget.child;

    if (widget.feedback == BCPressFeedback.material) {
      // Standard Material ripple. The splash paints above the background
      // (and content — it is translucent) so it stays visible over opaque
      // backgrounds.
      Widget stack = Stack(
        children: [
          if (widget.background != null)
            Positioned.fill(child: widget.background!),
          result,
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                customBorder: widget.shape,
                onTap: _interactive ? widget.onPressed : null,
                onLongPress: widget.onLongPress == null || !widget.enabled
                    ? null
                    : widget.onLongPress,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      );
      if (widget.shape != null) {
        stack = ClipPath(
          clipper: ShapeBorderClipper(shape: widget.shape!),
          child: stack,
        );
      }
      return stack;
    }

    if (widget.background != null || _hasHighlight || _hasRipple) {
      // Layer order mirrors heroui's PressableFeedback: background first,
      // highlight/ripple above it, content on top — so a full-opacity
      // hover-color highlight never covers the label.
      result = Stack(
        children: [
          if (widget.background != null)
            Positioned.fill(child: widget.background!),
          if (_hasHighlight)
            Positioned.fill(
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: _highlightController.drive(
                    Tween(
                      begin: widget.highlightOpacityRange?.$1 ?? 0,
                      end: widget.highlightOpacityRange?.$2 ??
                          BCMotion.highlightPressedOpacity,
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: widget.shape ?? const RoundedRectangleBorder(),
                      color: widget.highlightColor ?? _defaultHighlightColor(),
                    ),
                  ),
                ),
              ),
            ),
          if (_hasRipple)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, _) => CustomPaint(
                    painter: _RipplePainter(
                      progress: _rippleController.value,
                      center: _rippleCenter,
                      color: widget.highlightColor ??
                          _defaultHighlightColor(),
                    ),
                  ),
                ),
              ),
            ),
          result,
        ],
      );
      if (widget.shape != null) {
        result = ClipPath(
          clipper: ShapeBorderClipper(shape: widget.shape!),
          child: result,
        );
      }
    }

    if (_hasScale) {
      result = ScaleTransition(
        scale: _scaleController.drive(
          _DeferredScaleTween(this),
        ),
        child: result,
      );
    }

    // Listener drives the press visuals from raw pointer events (instant
    // feedback); GestureDetector still owns the tap/long-press semantics.
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: (_) => _handlePointerEnd(),
      onPointerCancel: (_) => _handlePointerEnd(),
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: _interactive ? widget.onPressed : null,
        onLongPress: widget.onLongPress == null || !widget.enabled
            ? null
            : () {
                _handlePointerEnd();
                widget.onLongPress!();
              },
        child: result,
      ),
    );
  }

  Color _defaultHighlightColor() {
    final brightness = MediaQuery.maybePlatformBrightnessOf(context) ??
        Brightness.light;
    return brightness == Brightness.dark
        ? BCMotion.highlightColorDark
        : BCMotion.highlightColorLight;
  }
}

/// Maps controller progress to the scale target captured at press time.
class _DeferredScaleTween extends Animatable<double> {
  _DeferredScaleTween(this._state);

  final _BCPressableState _state;

  @override
  double transform(double t) {
    if (t == 0) return 1;
    return 1 + (_state._pressTargetScale - 1) * t;
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.progress,
    required this.center,
    required this.color,
  });

  final double progress;
  final Offset center;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 2) return;
    final radius = math.sqrt(
          size.width * size.width + size.height * size.height,
        ) *
        1.25;
    // opacity: [0, 0.1, 0] and scale: [0, 1, 1] over progress 0..2
    final opacity = progress <= 1
        ? BCMotion.highlightPressedOpacity * progress
        : BCMotion.highlightPressedOpacity * (2 - progress);
    final scale = progress <= 1 ? progress : 1.0;
    if (opacity <= 0 || scale <= 0) return;
    canvas.drawCircle(
      center,
      radius * scale,
      Paint()..color = color.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.center != center ||
      oldDelegate.color != color;
}
