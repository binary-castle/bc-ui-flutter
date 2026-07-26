import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_motion.dart';

enum BCSpinnerSize { sm, md, lg }

enum BCSpinnerColor { defaultColor, success, warning, danger }

/// HeroUI Native Spinner: a gradient ring rotating 360° every 1000ms
/// (linear). Sizes 16/24/32; `default` color resolves to accent
/// (spinner.tsx colorMap).
class BCSpinner extends StatefulWidget {
  const BCSpinner({
    super.key,
    this.size = BCSpinnerSize.md,
    this.color = BCSpinnerColor.defaultColor,
    this.customColor,
    this.isLoading = true,
  });

  final BCSpinnerSize size;
  final BCSpinnerColor color;

  /// Overrides [color] with an arbitrary color.
  final Color? customColor;

  /// When false the spinner fades out (200ms in / 100ms out).
  final bool isLoading;

  @override
  State<BCSpinner> createState() => _BCSpinnerState();
}

class _BCSpinnerState extends State<BCSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: BCMotion.spinnerRotationDuration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _dimension => switch (widget.size) {
        BCSpinnerSize.sm => 16,
        BCSpinnerSize.md => 24,
        BCSpinnerSize.lg => 32,
      };

  Color _resolveColor(BuildContext context) {
    if (widget.customColor != null) return widget.customColor!;
    final bc = context.bcTheme;
    return switch (widget.color) {
      BCSpinnerColor.defaultColor => bc.accent,
      BCSpinnerColor.success => bc.success,
      BCSpinnerColor.warning => bc.warning,
      BCSpinnerColor.danger => bc.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(context);

    return AnimatedSwitcher(
      duration: BCMotion.spinnerFadeInDuration,
      reverseDuration: BCMotion.spinnerFadeOutDuration,
      child: !widget.isLoading
          ? SizedBox(
              key: const ValueKey('spinner-hidden'),
              width: _dimension,
              height: _dimension,
            )
          : SizedBox(
              key: const ValueKey('spinner'),
              width: _dimension,
              height: _dimension,
              child: RepaintBoundary(
                child: RotationTransition(
                  turns: _controller,
                  child: CustomPaint(
                    painter: _SpinnerPainter(color: color),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Draws the mingcute-loading ring: a circular stroke whose opacity sweeps
/// from full color down to transparent around the circle.
class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 3 / 24;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: const GradientRotation(-math.pi / 2),
        colors: [
          color,
          color.withValues(alpha: 0.55),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.6, 1],
      ).createShader(rect);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + 0.15,
      math.pi * 2 - 0.3,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) =>
      oldDelegate.color != color;
}
