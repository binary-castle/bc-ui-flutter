import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_duration.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_spacing.dart';
import '../tokens/bc_typography.dart';

enum BCProgressVariant { linear, circular }

enum BCProgressSize { sm, md, lg }

enum BCProgressColor { accent, success, warning, danger, foreground }

/// Determinate and indeterminate progress, linear or circular
/// (Material 3 "progress indicators", drawn from bc_ui tokens).
///
/// Pass [value] between 0 and 1 for determinate progress; leave it null and
/// the indicator animates indefinitely. For a plain indeterminate spinner
/// with no track, use [BCSpinner].
///
/// ```dart
/// BCProgress(value: 0.4, label: 'Uploading', showValueLabel: true);
/// BCProgress(variant: BCProgressVariant.circular); // indeterminate
/// ```
class BCProgress extends StatefulWidget {
  const BCProgress({
    super.key,
    this.value,
    this.variant = BCProgressVariant.linear,
    this.size = BCProgressSize.md,
    this.color = BCProgressColor.accent,
    this.label,
    this.showValueLabel = false,
    this.formatValue,
    this.trackColor,
    this.valueColor,
    this.thickness,
  }) : assert(
          value == null || (value >= 0 && value <= 1),
          'BCProgress.value must be between 0 and 1',
        );

  /// Progress in the 0–1 range, or null for indeterminate.
  final double? value;

  final BCProgressVariant variant;
  final BCProgressSize size;
  final BCProgressColor color;

  /// Caption above a linear bar / below a circular one.
  final String? label;

  /// Shows the percentage next to [label]. Ignored while indeterminate.
  final bool showValueLabel;

  /// Defaults to whole percent, e.g. `40%`.
  final String Function(double value)? formatValue;

  /// Defaults to the `default` token.
  final Color? trackColor;

  /// Overrides [color].
  final Color? valueColor;

  /// Bar height / ring stroke width. Defaults per [size].
  final double? thickness;

  @override
  State<BCProgress> createState() => _BCProgressState();
}

class _BCProgressState extends State<BCProgress>
    with SingleTickerProviderStateMixin {
  static const Duration _sweepDuration = Duration(milliseconds: 1600);

  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: _sweepDuration,
  );

  bool get _isIndeterminate => widget.value == null;

  @override
  void initState() {
    super.initState();
    if (_isIndeterminate) _sweep.repeat();
  }

  @override
  void didUpdateWidget(BCProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isIndeterminate && !_sweep.isAnimating) {
      _sweep.repeat();
    } else if (!_isIndeterminate && _sweep.isAnimating) {
      _sweep.stop();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  double get _thickness =>
      widget.thickness ??
      switch ((widget.variant, widget.size)) {
        (BCProgressVariant.linear, BCProgressSize.sm) => 4,
        (BCProgressVariant.linear, BCProgressSize.md) => 8,
        (BCProgressVariant.linear, BCProgressSize.lg) => 12,
        (BCProgressVariant.circular, BCProgressSize.sm) => 3,
        (BCProgressVariant.circular, BCProgressSize.md) => 4,
        (BCProgressVariant.circular, BCProgressSize.lg) => 5,
      };

  double get _diameter => switch (widget.size) {
        BCProgressSize.sm => 24,
        BCProgressSize.md => 36,
        BCProgressSize.lg => 56,
      };

  Color _valueColor(BCThemeExtension bc) =>
      widget.valueColor ??
      switch (widget.color) {
        BCProgressColor.accent => bc.accent,
        BCProgressColor.success => bc.success,
        BCProgressColor.warning => bc.warning,
        BCProgressColor.danger => bc.danger,
        BCProgressColor.foreground => bc.foreground,
      };

  String _valueText() {
    final value = widget.value ?? 0;
    if (widget.formatValue != null) return widget.formatValue!(value);
    return '${(value * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final track = widget.trackColor ?? bc.defaultColor;
    final fill = _valueColor(bc);

    final caption = _caption(bc);

    if (widget.variant == BCProgressVariant.circular) {
      final ring = SizedBox(
        width: _diameter,
        height: _diameter,
        child: _animatedValue(
          (value) => AnimatedBuilder(
            animation: _sweep,
            builder: (context, _) => CustomPaint(
              painter: _RingPainter(
                value: value,
                phase: _sweep.value,
                track: track,
                fill: fill,
                thickness: _thickness,
              ),
            ),
          ),
        ),
      );

      if (caption == null) return ring;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [ring, const SizedBox(height: BCSpacing.sm), caption],
      );
    }

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(BCRadius.full),
      child: SizedBox(
        height: _thickness,
        child: ColoredBox(
          color: track,
          child: _animatedValue(
            (value) => AnimatedBuilder(
              animation: _sweep,
              builder: (context, _) => CustomPaint(
                painter: _BarPainter(
                  value: value,
                  phase: _sweep.value,
                  fill: fill,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (caption == null) return bar;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [caption, const SizedBox(height: BCSpacing.sm), bar],
    );
  }

  /// Eases the painted value towards [BCProgress.value] so a jump from 20%
  /// to 60% sweeps instead of snapping. Indeterminate builds straight
  /// through, since its motion comes from the sweep controller.
  Widget _animatedValue(Widget Function(double? value) builder) {
    if (_isIndeterminate) return builder(null);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: widget.value),
      duration: BCDuration.normal,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => builder(value),
    );
  }

  /// Label row: caption on the start, percentage on the end.
  Widget? _caption(BCThemeExtension bc) {
    final showValue = widget.showValueLabel && !_isIndeterminate;
    if (widget.label == null && !showValue) return null;

    final style = BCTypography.textSm.copyWith(
      color: bc.muted,
      fontWeight: BCTypography.medium,
    );

    if (widget.variant == BCProgressVariant.circular) {
      return Text(
        widget.label ?? _valueText(),
        style: style,
        textAlign: TextAlign.center,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label ?? '', style: style),
        if (showValue)
          Text(
            _valueText(),
            style: style.copyWith(color: bc.foreground),
          ),
      ],
    );
  }
}

/// Linear bar. Determinate fills from the start; indeterminate sweeps a
/// segment across, head leading and tail catching up (Material's two-curve
/// motion, in one pass).
class _BarPainter extends CustomPainter {
  const _BarPainter({
    required this.value,
    required this.phase,
    required this.fill,
  });

  final double? value;
  final double phase;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = fill;

    double start, end;
    if (value != null) {
      start = 0;
      end = value!.clamp(0.0, 1.0);
    } else {
      const head = Interval(0, 0.65, curve: Curves.easeOutCubic);
      const tail = Interval(0.25, 1, curve: Curves.easeInCubic);
      end = head.transform(phase);
      start = tail.transform(phase);
    }
    if (end <= start) return;

    canvas.drawRect(
      Rect.fromLTRB(start * size.width, 0, end * size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.value != value || old.phase != phase || old.fill != fill;
}

/// Circular ring. Determinate draws an arc from 12 o'clock; indeterminate
/// rotates a 3/4 arc whose length breathes.
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.phase,
    required this.track,
    required this.fill,
    required this.thickness,
  });

  final double? value;
  final double phase;
  final Color track;
  final Color fill;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(thickness / 2);

    canvas.drawArc(
      inset,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness,
    );

    final arc = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    const top = -math.pi / 2;
    if (value != null) {
      if (value! <= 0) return;
      canvas.drawArc(inset, top, math.pi * 2 * value!.clamp(0.0, 1.0), false, arc);
      return;
    }

    // Indeterminate: spin twice per cycle while the sweep grows and shrinks.
    final rotation = phase * math.pi * 4;
    final grow = Curves.easeInOut.transform(
      phase < 0.5 ? phase * 2 : (1 - phase) * 2,
    );
    final sweep = math.pi * 0.2 + grow * math.pi * 1.3;
    canvas.drawArc(inset, top + rotation, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.phase != phase ||
      old.track != track ||
      old.fill != fill ||
      old.thickness != thickness;
}
