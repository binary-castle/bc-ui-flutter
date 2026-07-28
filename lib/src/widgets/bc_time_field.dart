import 'package:flutter/material.dart' show DayPeriod, Icons, TimeOfDay;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../overlay/bc_overlay_anchor.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_button.dart';
import 'bc_dialog.dart';
import 'bc_input.dart' show BCInputVariant;
import 'bc_picker_presentation.dart';
import 'bc_pressable.dart';

/// A time-picker field styled like [BCInput], with a trailing clock icon.
///
/// Tapping the field opens [BCTimePickerDialog] — a scroll-wheel picker built
/// entirely from bc_ui tokens, matching the design system in light and dark.
class BCTimeField extends StatefulWidget {
  const BCTimeField({
    super.key,
    this.value,
    this.onChanged,
    this.placeholder = 'Select a time',
    this.variant = BCInputVariant.primary,
    this.isInvalid = false,
    this.isDisabled = false,
    this.use24HourFormat = false,
    this.minuteStep = 1,
    this.formatTime,
    this.presentation = BCPickerPresentation.dialog,
    this.icon = const Icon(Icons.access_time),
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay>? onChanged;
  final String placeholder;
  final BCInputVariant variant;
  final bool isInvalid;
  final bool isDisabled;

  /// 24-hour wheel (no AM/PM) when true; 12-hour with AM/PM otherwise.
  final bool use24HourFormat;

  /// Minute increment shown on the wheel (e.g. 5 → 00, 05, 10 …).
  final int minuteStep;

  /// Formats the selected value for display. Defaults to `h:mm AM/PM`
  /// (or `HH:mm` in 24-hour mode).
  final String Function(TimeOfDay time)? formatTime;

  /// Where the wheels appear: a dialog with Cancel / Confirm (default), a
  /// popover anchored to the field, or a bottom sheet. Popover and sheet
  /// apply each spin live.
  final BCPickerPresentation presentation;

  /// Trailing icon; defaults to a clock glyph.
  final Widget icon;

  @override
  State<BCTimeField> createState() => _BCTimeFieldState();
}

class _BCTimeFieldState extends State<BCTimeField> {
  final BCAnchoredOverlayController _overlay = BCAnchoredOverlayController();

  @override
  void dispose() {
    _overlay.dispose();
    super.dispose();
  }

  String _format(TimeOfDay time) {
    if (widget.formatTime != null) return widget.formatTime!(time);
    final minute = time.minute.toString().padLeft(2, '0');
    if (widget.use24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:$minute';
    }
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$minute $period';
  }

  Widget _wheels() => BCTimeWheel(
    initialTime: widget.value,
    use24HourFormat: widget.use24HourFormat,
    minuteStep: widget.minuteStep,
    onChanged: (time) => widget.onChanged?.call(time),
  );

  Future<void> _open() async {
    switch (widget.presentation) {
      case BCPickerPresentation.dialog:
        final picked = await BCTimePickerDialog.show(
          context,
          initialTime: widget.value,
          use24HourFormat: widget.use24HourFormat,
          minuteStep: widget.minuteStep,
        );
        if (picked != null) widget.onChanged?.call(picked);
      case BCPickerPresentation.popover:
        _overlay.open();
      case BCPickerPresentation.bottomSheet:
        await showBCPickerSheet<void>(context, builder: (_) => _wheels());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final value = widget.value;
    final hasValue = value != null;

    final side = widget.isInvalid
        ? BorderSide(color: bc.danger, width: 2)
        : BorderSide.none;

    Widget field = Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: ShapeDecoration(
        color: widget.variant == BCInputVariant.primary
            ? bc.field
            : bc.defaultColor,
        shape: BCShapes.continuous(BCRadius.field, side: side),
        shadows: widget.variant == BCInputVariant.primary
            ? bc.fieldShadow.shadows
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasValue ? _format(value) : widget.placeholder,
              style: BCTypography.textBase.copyWith(
                color: hasValue ? bc.foreground : bc.fieldPlaceholder,
              ),
            ),
          ),
          IconTheme.merge(
            data: IconThemeData(color: bc.muted, size: 20),
            child: widget.icon,
          ),
        ],
      ),
    );

    field = BCPressable(
      feedback: BCPressFeedback.scale,
      enabled: !widget.isDisabled,
      onPressed: widget.isDisabled ? null : _open,
      child: field,
    );

    if (widget.presentation == BCPickerPresentation.popover) {
      field = BCAnchoredOverlay(
        controller: _overlay,
        matchAnchorWidth: true,
        overlayBuilder: (_) => BCPickerPanel(child: _wheels()),
        child: field,
      );
    }

    if (widget.isDisabled) {
      field = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: field),
      );
    }

    return field;
  }
}

/// Hour / minute (and AM/PM) scroll wheels.
///
/// This is the panel behind [BCTimeField] in every presentation; use it
/// directly to embed time selection in a form or a sheet of your own.
class BCTimeWheel extends StatefulWidget {
  const BCTimeWheel({
    super.key,
    this.initialTime,
    this.use24HourFormat = false,
    this.minuteStep = 1,
    required this.onChanged,
  });

  final TimeOfDay? initialTime;
  final bool use24HourFormat;

  /// Minute increment shown on the wheel (e.g. 5 → 00, 05, 10 …).
  final int minuteStep;

  /// Fires as each wheel settles.
  final ValueChanged<TimeOfDay> onChanged;

  @override
  State<BCTimeWheel> createState() => _BCTimeWheelState();
}

class _BCTimeWheelState extends State<BCTimeWheel> {
  static const double _itemExtent = 44;
  static const double _wheelHeight = 220;

  late final List<int> _hours;
  late final List<int> _minutes;

  late int _hourIndex;
  late int _minuteIndex;
  int _periodIndex = 0; // 0 = AM, 1 = PM

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final FixedExtentScrollController _periodController;

  bool get _is24 => widget.use24HourFormat;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTime ?? TimeOfDay.now();

    _hours = _is24
        ? List.generate(24, (i) => i)
        : List.generate(12, (i) => i + 1);

    final step = widget.minuteStep.clamp(1, 30);
    _minutes = [for (var m = 0; m < 60; m += step) m];

    if (_is24) {
      _hourIndex = initial.hour;
    } else {
      final display = initial.hourOfPeriod == 0 ? 12 : initial.hourOfPeriod;
      _hourIndex = _hours.indexOf(display);
      _periodIndex = initial.period == DayPeriod.pm ? 1 : 0;
    }

    // Snap the initial minute to the nearest step.
    var nearest = 0;
    var best = 60;
    for (var i = 0; i < _minutes.length; i++) {
      final d = (_minutes[i] - initial.minute).abs();
      if (d < best) {
        best = d;
        nearest = i;
      }
    }
    _minuteIndex = nearest;

    _hourController = FixedExtentScrollController(initialItem: _hourIndex);
    _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);
    _periodController = FixedExtentScrollController(initialItem: _periodIndex);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  TimeOfDay get _result {
    final minute = _minutes[_minuteIndex];
    if (_is24) {
      return TimeOfDay(hour: _hours[_hourIndex], minute: minute);
    }
    final display = _hours[_hourIndex]; // 1..12
    final base = display % 12; // 12 -> 0
    final hour = _periodIndex == 1 ? base + 12 : base;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return SizedBox(
      height: _wheelHeight,
      child: Stack(
        children: [
          // Center selection band.
          Center(
            child: Container(
              height: _itemExtent,
              decoration: ShapeDecoration(
                color: bc.defaultColor,
                shape: BCShapes.continuous(BCRadius.xl),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _wheel(
                  controller: _hourController,
                  count: _hours.length,
                  selected: _hourIndex,
                  label: (i) => _is24
                      ? _hours[i].toString().padLeft(2, '0')
                      : _hours[i].toString(),
                  onChanged: (i) => _update(() => _hourIndex = i),
                  bc: bc,
                ),
              ),
              Text(
                ':',
                style: BCTypography.textXl.copyWith(
                  color: bc.foreground,
                  fontWeight: BCTypography.semiBold,
                ),
              ),
              Expanded(
                child: _wheel(
                  controller: _minuteController,
                  count: _minutes.length,
                  selected: _minuteIndex,
                  label: (i) => _minutes[i].toString().padLeft(2, '0'),
                  onChanged: (i) => _update(() => _minuteIndex = i),
                  bc: bc,
                ),
              ),
              if (!_is24)
                Expanded(
                  child: _wheel(
                    controller: _periodController,
                    count: 2,
                    selected: _periodIndex,
                    label: (i) => i == 0 ? 'AM' : 'PM',
                    onChanged: (i) => _update(() => _periodIndex = i),
                    bc: bc,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Applies a wheel move and reports the composed time.
  void _update(VoidCallback apply) {
    setState(apply);
    widget.onChanged(_result);
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required int selected,
    required String Function(int index) label,
    required ValueChanged<int> onChanged,
    required BCThemeExtension bc,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _itemExtent,
      perspective: 0.004,
      diameterRatio: 1.6,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: count,
        builder: (context, index) {
          final isSelected = index == selected;
          return Center(
            child: Text(
              label(index),
              style: BCTypography.textLg.copyWith(
                color: isSelected ? bc.foreground : bc.muted,
                fontWeight: isSelected
                    ? BCTypography.semiBold
                    : BCTypography.regular,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The time wheels in a modal dialog, with Cancel / Confirm. Kept as a
/// standalone entry point:
/// `final time = await BCTimePickerDialog.show(context, ...);`
class BCTimePickerDialog extends StatefulWidget {
  const BCTimePickerDialog({
    super.key,
    this.initialTime,
    this.use24HourFormat = false,
    this.minuteStep = 1,
  });

  final TimeOfDay? initialTime;
  final bool use24HourFormat;
  final int minuteStep;

  static Future<TimeOfDay?> show(
    BuildContext context, {
    TimeOfDay? initialTime,
    bool use24HourFormat = false,
    int minuteStep = 1,
  }) {
    return BCDialog.show<TimeOfDay>(
      context,
      builder: (dialogContext) => BCTimePickerDialog(
        initialTime: initialTime,
        use24HourFormat: use24HourFormat,
        minuteStep: minuteStep,
      ),
    );
  }

  @override
  State<BCTimePickerDialog> createState() => _BCTimePickerDialogState();
}

class _BCTimePickerDialogState extends State<BCTimePickerDialog> {
  late TimeOfDay _pending = widget.initialTime ?? TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return BCDialogContent(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Select time',
              style: BCTypography.textLg.copyWith(
                color: bc.foreground,
                fontWeight: BCTypography.medium,
              ),
            ),
          ),
          BCTimeWheel(
            initialTime: widget.initialTime,
            use24HourFormat: widget.use24HourFormat,
            minuteStep: widget.minuteStep,
            onChanged: (time) => _pending = time,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BCButton(
                  variant: BCButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BCButton(
                  onPressed: () => Navigator.of(context).pop(_pending),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
