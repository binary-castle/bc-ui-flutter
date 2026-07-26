import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_motion.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_typography.dart';

/// A start/end pair for [BCRangeSlider].
@immutable
class BCRange {
  const BCRange(this.start, this.end);

  final double start;
  final double end;

  BCRange copyWith({double? start, double? end}) =>
      BCRange(start ?? this.start, end ?? this.end);

  @override
  bool operator ==(Object other) =>
      other is BCRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'BCRange($start, $end)';
}

/// Two-thumb slider for choosing a range — price filters, date windows,
/// thresholds. Shares [BCSlider]'s metrics and spring so the two read as one
/// family.
///
/// ```dart
/// BCRangeSlider(
///   values: range,
///   minValue: 0,
///   maxValue: 500,
///   step: 10,
///   label: 'Price',
///   showOutput: true,
///   formatOutput: (v) => '\$${v.round()}',
///   onChanged: (value) => setState(() => range = value),
/// );
/// ```
class BCRangeSlider extends StatefulWidget {
  const BCRangeSlider({
    super.key,
    required this.values,
    this.onChanged,
    this.onChangeEnd,
    this.minValue = 0,
    this.maxValue = 1,
    this.step,
    this.minSeparation,
    this.label,
    this.showOutput = false,
    this.formatOutput,
    this.isDisabled = false,
  });

  final BCRange values;
  final ValueChanged<BCRange>? onChanged;
  final ValueChanged<BCRange>? onChangeEnd;
  final double minValue;
  final double maxValue;
  final double? step;

  /// Smallest allowed gap between the thumbs. Defaults to [step], else 0.
  final double? minSeparation;

  /// Optional label shown above the track next to the output.
  final String? label;

  /// Shows the current range above the track.
  final bool showOutput;

  /// Formats each end of the range; the two are joined with an en dash.
  final String Function(double value)? formatOutput;

  final bool isDisabled;

  static const double _trackHeight = 20;
  static const double _thumbWidth = 28;

  @override
  State<BCRangeSlider> createState() => _BCRangeSliderState();
}

enum _Thumb { start, end }

class _BCRangeSliderState extends State<BCRangeSlider>
    with TickerProviderStateMixin {
  late final AnimationController _start = AnimationController(
    vsync: this,
    value: _normalize(widget.values.start),
  );
  late final AnimationController _end = AnimationController(
    vsync: this,
    value: _normalize(widget.values.end),
  );

  _Thumb? _dragging;

  double _normalize(double value) {
    final range = widget.maxValue - widget.minValue;
    if (range <= 0) return 0;
    return ((value - widget.minValue) / range).clamp(0.0, 1.0);
  }

  double _denormalize(double t) =>
      widget.minValue + t * (widget.maxValue - widget.minValue);

  double _applyStep(double value) {
    final step = widget.step;
    if (step == null || step <= 0) {
      return value.clamp(widget.minValue, widget.maxValue);
    }
    final steps = ((value - widget.minValue) / step).round();
    return (widget.minValue + steps * step)
        .clamp(widget.minValue, widget.maxValue);
  }

  double get _separation =>
      widget.minSeparation ?? (widget.step ?? 0);

  @override
  void didUpdateWidget(BCRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_dragging != null || widget.values == oldWidget.values) return;
    _springTo(_start, _normalize(widget.values.start));
    _springTo(_end, _normalize(widget.values.end));
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _springTo(AnimationController controller, double target) {
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.value = target;
      return;
    }
    controller.animateWith(
      SpringSimulation(
        BCMotion.sliderThumbSpring,
        controller.value,
        target,
        0,
        snapToEnd: true,
      ),
    );
  }

  /// Normalized position for a touch, in the same coordinate space the thumbs
  /// are laid out in.
  double _positionFor(double dx, double width) {
    final usable = width - BCRangeSlider._thumbWidth;
    if (usable <= 0) return 0;
    return ((dx - BCRangeSlider._thumbWidth / 2) / usable).clamp(0.0, 1.0);
  }

  BCRange _currentRange() => BCRange(
        _applyStep(_denormalize(_start.value)),
        _applyStep(_denormalize(_end.value)),
      );

  void _beginDrag(double dx, double width) {
    final t = _positionFor(dx, width);
    // Grab whichever thumb is closer; ties go to the one that can still move.
    final startGap = (t - _start.value).abs();
    final endGap = (t - _end.value).abs();
    _dragging = startGap == endGap
        ? (t < _start.value ? _Thumb.start : _Thumb.end)
        : (startGap < endGap ? _Thumb.start : _Thumb.end);
    _start.stop();
    _end.stop();
    _update(dx, width);
  }

  void _update(double dx, double width) {
    final t = _positionFor(dx, width);
    final gap = widget.maxValue - widget.minValue <= 0
        ? 0.0
        : _separation / (widget.maxValue - widget.minValue);

    if (_dragging == _Thumb.start) {
      _start.value = t.clamp(0.0, (_end.value - gap).clamp(0.0, 1.0));
    } else {
      _end.value = t.clamp((_start.value + gap).clamp(0.0, 1.0), 1.0);
    }
    widget.onChanged?.call(_currentRange());
  }

  void _endDrag() {
    _dragging = null;
    final range = _currentRange();
    _springTo(_start, _normalize(range.start));
    _springTo(_end, _normalize(range.end));
    widget.onChangeEnd?.call(range);
  }

  String _format(double value) {
    if (widget.formatOutput != null) return widget.formatOutput!(value);
    if (widget.step != null && widget.step! >= 1) return value.round().toString();
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
              : (details) => _beginDrag(details.localPosition.dx, width),
          onHorizontalDragUpdate: widget.isDisabled
              ? null
              : (details) => _update(details.localPosition.dx, width),
          onHorizontalDragEnd: widget.isDisabled ? null : (_) => _endDrag(),
          onTapUp: widget.isDisabled
              ? null
              : (details) {
                  _beginDrag(details.localPosition.dx, width);
                  _endDrag();
                },
          child: SizedBox(
            height: BCRangeSlider._trackHeight,
            child: AnimatedBuilder(
              animation: Listenable.merge([_start, _end]),
              builder: (context, _) {
                final usable = width - BCRangeSlider._thumbWidth;
                final startLeft = _start.value.clamp(0.0, 1.0) * usable;
                final endLeft = _end.value.clamp(0.0, 1.0) * usable;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: bc.defaultColor,
                          borderRadius: BorderRadius.circular(BCRadius.xl),
                        ),
                      ),
                    ),
                    // Selected span between the thumbs.
                    Positioned(
                      left: startLeft,
                      top: 0,
                      bottom: 0,
                      width: (endLeft - startLeft) + BCRangeSlider._thumbWidth,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: bc.accent,
                          borderRadius: BorderRadius.circular(BCRadius.xl),
                        ),
                      ),
                    ),
                    _thumb(bc, startLeft),
                    _thumb(bc, endLeft),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (widget.isDisabled) {
      slider = Opacity(opacity: bc.opacityDisabled, child: slider);
    }

    if (widget.label == null && !widget.showOutput) return slider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label ?? '', style: outputStyle),
              if (widget.showOutput)
                AnimatedBuilder(
                  animation: Listenable.merge([_start, _end]),
                  builder: (context, _) {
                    final range = _currentRange();
                    return Text(
                      '${_format(range.start)} – ${_format(range.end)}',
                      style: outputStyle.copyWith(color: bc.foreground),
                    );
                  },
                ),
            ],
          ),
        ),
        slider,
      ],
    );
  }

  Widget _thumb(BCThemeExtension bc, double left) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: BCRangeSlider._thumbWidth,
        height: BCRangeSlider._trackHeight,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bc.accent,
          borderRadius: BorderRadius.circular(BCRadius.xl),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bc.accentForeground,
            borderRadius: BorderRadius.circular(BCRadius.lg),
          ),
        ),
      ),
    );
  }
}
