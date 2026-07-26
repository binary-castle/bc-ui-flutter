import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_motion.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_typography.dart';

/// HeroUI Native Slider (slider.css): 20px-tall `default` track with 12px
/// radius, accent fill, and a 28×20 accent thumb container holding an
/// accent-foreground knob. The thumb snaps with a soft spring
/// (mass 0.5, stiffness 200, damping 15).
class BCSlider extends StatefulWidget {
  const BCSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.minValue = 0,
    this.maxValue = 1,
    this.step,
    this.label,
    this.showOutput = false,
    this.formatOutput,
    this.isDisabled = false,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double minValue;
  final double maxValue;
  final double? step;

  /// Optional label shown above the track next to the output.
  final String? label;

  /// Shows the current value above the track (slider__output).
  final bool showOutput;
  final String Function(double value)? formatOutput;
  final bool isDisabled;

  static const double _trackHeight = 20;
  static const double _thumbWidth = 28;
  static const double _thumbHeight = 20;

  @override
  State<BCSlider> createState() => _BCSliderState();
}

class _BCSliderState extends State<BCSlider>
    with SingleTickerProviderStateMixin {
  /// Normalized [0, 1] thumb position.
  late final AnimationController _position = AnimationController(
    vsync: this,
    value: _normalize(widget.value),
  );
  bool _dragging = false;

  double _normalize(double value) {
    final range = widget.maxValue - widget.minValue;
    if (range <= 0) return 0;
    return ((value - widget.minValue) / range).clamp(0.0, 1.0);
  }

  double _denormalize(double t) =>
      widget.minValue + t * (widget.maxValue - widget.minValue);

  double _applyStep(double value) {
    final step = widget.step;
    if (step == null || step <= 0) return value;
    final steps = ((value - widget.minValue) / step).round();
    return (widget.minValue + steps * step)
        .clamp(widget.minValue, widget.maxValue);
  }

  @override
  void didUpdateWidget(BCSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && widget.value != oldWidget.value) {
      _springTo(_normalize(widget.value));
    }
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _springTo(double target) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _position.value = target;
      return;
    }
    _position.animateWith(
      SpringSimulation(
        BCMotion.sliderThumbSpring,
        _position.value,
        target,
        0,
        snapToEnd: true,
      ),
    );
  }

  void _updateFromDx(double dx, double width) {
    final usable = width - BCSlider._thumbWidth;
    if (usable <= 0) return;
    final t = ((dx - BCSlider._thumbWidth / 2) / usable).clamp(0.0, 1.0);
    _position.value = t;
    widget.onChanged?.call(_applyStep(_denormalize(t)));
  }

  void _endDrag() {
    _dragging = false;
    final stepped = _applyStep(_denormalize(_position.value));
    _springTo(_normalize(stepped));
    widget.onChangeEnd?.call(stepped);
  }

  String _outputText() {
    final value = _applyStep(_denormalize(_position.value));
    if (widget.formatOutput != null) return widget.formatOutput!(value);
    if (widget.step != null && widget.step! >= 1) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final outputStyle = BCTypography.textSm.copyWith(
      color: bc.muted,
      fontWeight: BCTypography.medium,
    );

    Widget slider = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: widget.isDisabled
              ? null
              : (details) {
                  _dragging = true;
                  _position.stop();
                  _updateFromDx(details.localPosition.dx, width);
                },
          onHorizontalDragUpdate: widget.isDisabled
              ? null
              : (details) => _updateFromDx(details.localPosition.dx, width),
          onHorizontalDragEnd: widget.isDisabled ? null : (_) => _endDrag(),
          onTapUp: widget.isDisabled
              ? null
              : (details) {
                  _updateFromDx(details.localPosition.dx, width);
                  _endDrag();
                },
          child: SizedBox(
            height: BCSlider._trackHeight,
            child: AnimatedBuilder(
              animation: _position,
              builder: (context, _) {
                final t = _position.value.clamp(0.0, 1.0);
                final thumbLeft = t * (width - BCSlider._thumbWidth);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Track
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: bc.defaultColor,
                          borderRadius: BorderRadius.circular(BCRadius.xl),
                        ),
                      ),
                    ),
                    // Fill
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: thumbLeft + BCSlider._thumbWidth,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: bc.accent,
                          borderRadius: BorderRadius.circular(BCRadius.xl),
                        ),
                      ),
                    ),
                    // Thumb: accent container with knob
                    Positioned(
                      left: thumbLeft,
                      top: 0,
                      child: Container(
                        width: BCSlider._thumbWidth,
                        height: BCSlider._thumbHeight,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: bc.accent,
                          borderRadius: BorderRadius.circular(BCRadius.xl),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: bc.accentForeground,
                            borderRadius:
                                BorderRadius.circular(BCRadius.xl - 2),
                            boxShadow: bc.fieldShadow.shadows,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    slider = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (widget.label != null || widget.showOutput)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label ?? '', style: outputStyle),
              if (widget.showOutput)
                AnimatedBuilder(
                  animation: _position,
                  builder: (context, _) =>
                      Text(_outputText(), style: outputStyle),
                ),
            ],
          ),
        slider,
      ],
    );

    if (widget.isDisabled) {
      slider = Opacity(opacity: bc.opacityDisabled, child: slider);
    }

    return slider;
  }
}
