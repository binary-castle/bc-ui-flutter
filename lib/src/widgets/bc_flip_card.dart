import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A card that flips between [front] and [back] with a 3D rotation.
///
/// Uncontrolled by default (tap to flip). Pass [isFlipped] + [onFlip] to
/// control it externally (e.g. a "Show security code" button), in which case
/// tap-to-flip is disabled unless [flipOnTap] is left true.
class BCFlipCard extends StatefulWidget {
  const BCFlipCard({
    super.key,
    required this.front,
    required this.back,
    this.isFlipped,
    this.onFlip,
    this.flipOnTap = true,
    this.direction = Axis.horizontal,
    this.duration = const Duration(milliseconds: 450),
    this.curve = Curves.easeInOut,
  });

  final Widget front;
  final Widget back;

  /// When non-null the card is controlled: it reflects this value and never
  /// changes it itself — call [onFlip] / update this value to flip.
  final bool? isFlipped;

  final ValueChanged<bool>? onFlip;

  /// Whether tapping toggles the flip. Ignored while a tap would conflict
  /// with a controlled parent that sets [flipOnTap] false.
  final bool flipOnTap;

  /// Rotation axis: horizontal flips around Y, vertical around X.
  final Axis direction;

  final Duration duration;
  final Curve curve;

  @override
  State<BCFlipCard> createState() => _BCFlipCardState();
}

class _BCFlipCardState extends State<BCFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: (widget.isFlipped ?? false) ? 1 : 0,
  );
  late final Animation<double> _animation =
      CurvedAnimation(parent: _controller, curve: widget.curve);

  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _flipped = widget.isFlipped ?? false;
  }

  @override
  void didUpdateWidget(BCFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != null && widget.isFlipped != _flipped) {
      _flipped = widget.isFlipped!;
      _drive();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _drive() {
    if (_flipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (!widget.flipOnTap) return;
    if (widget.isFlipped != null) {
      // Controlled: let the parent decide the new state.
      widget.onFlip?.call(!_flipped);
      return;
    }
    setState(() => _flipped = !_flipped);
    _drive();
    widget.onFlip?.call(_flipped);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.flipOnTap ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * math.pi;
          final showFront = angle <= math.pi / 2;

          final transform = Matrix4.identity()..setEntry(3, 2, 0.001);
          if (widget.direction == Axis.horizontal) {
            transform.rotateY(angle);
          } else {
            transform.rotateX(angle);
          }

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: showFront
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    // Counter-rotate the back so its content isn't mirrored.
                    transform: widget.direction == Axis.horizontal
                        ? (Matrix4.identity()..rotateY(math.pi))
                        : (Matrix4.identity()..rotateX(math.pi)),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}
