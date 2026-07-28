import 'package:flutter/material.dart' show Icons, Material, MaterialType;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../overlay/bc_overlay_anchor.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_duration.dart';
import '../tokens/bc_motion.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';
import '../tokens/bc_typography.dart';
import 'bc_button.dart';
import 'bc_dialog.dart';
import 'bc_input.dart' show BCInputVariant;
import 'bc_pressable.dart';
import 'field_parts/bc_description.dart';
import 'field_parts/bc_field_error.dart';
import 'field_parts/bc_label.dart';

/// How a [BCDateTimePicker] surfaces its wheels.
enum BCDateTimePickerPresentation {
  /// Anchored under the field, matching its width. Selection applies live.
  popover,

  /// Centered modal with Cancel / Confirm, so the value only commits on
  /// confirm.
  dialog,

  /// Slides up from the bottom edge. Selection applies live.
  bottomSheet,
}

/// Scrolling day + time wheels, in the style of iOS pickers but built from
/// bc_ui tokens.
///
/// This is the panel behind [BCDateTimePicker]; use it directly to embed the
/// wheels in a form or a sheet of your own.
///
/// ```dart
/// BCDateTimeWheel(
///   value: _when,
///   minuteInterval: 5,
///   onChanged: (value) => setState(() => _when = value),
/// );
/// ```
class BCDateTimeWheel extends StatefulWidget {
  const BCDateTimeWheel({
    super.key,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.use24HourFormat = false,
    this.minuteInterval = 1,
    this.formatDay,
    this.height = 220,
  }) : assert(
         minuteInterval >= 1 && minuteInterval <= 30,
         'minuteInterval must be between 1 and 30',
       );

  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;

  /// 24-hour wheels drop the AM/PM column and show `00`–`23`.
  final bool use24HourFormat;

  /// Minute step, e.g. 5 for `00, 05, 10 …`.
  final int minuteInterval;

  /// Day column label. Defaults to `Today` for the current date and
  /// `Wed, Jul 29` otherwise.
  final String Function(DateTime day)? formatDay;

  final double height;

  @override
  State<BCDateTimeWheel> createState() => _BCDateTimeWheelState();
}

class _BCDateTimeWheelState extends State<BCDateTimeWheel> {
  static const double _itemExtent = 44;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  late int _dayIndex;
  late int _hourIndex;
  late int _minuteIndex;
  late int _periodIndex;

  bool get _is24 => widget.use24HourFormat;

  List<int> get _minutes => [
    for (var m = 0; m < 60; m += widget.minuteInterval) m,
  ];

  int get _hourCount => _is24 ? 24 : 12;

  /// Days are counted in UTC so a daylight-saving shift can never make a
  /// day 23 or 25 hours long and skew the index.
  int _epochDay(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

  int get _dayCount =>
      _epochDay(widget.lastDate) - _epochDay(widget.firstDate) + 1;

  DateTime _dayForIndex(int index) => DateTime(
    widget.firstDate.year,
    widget.firstDate.month,
    widget.firstDate.day + index,
  );

  @override
  void initState() {
    super.initState();
    _syncFromValue();
    _dayController = FixedExtentScrollController(initialItem: _dayIndex);
    _hourController = FixedExtentScrollController(initialItem: _hourIndex);
    _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);
    _periodController = FixedExtentScrollController(initialItem: _periodIndex);
  }

  @override
  void didUpdateWidget(BCDateTimeWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) return;
    final previous = [_dayIndex, _hourIndex, _minuteIndex, _periodIndex];
    _syncFromValue();
    // Only nudge wheels the caller actually moved, so an external change
    // does not fight a spin in progress.
    _animateIfNeeded(_dayController, previous[0], _dayIndex);
    _animateIfNeeded(_hourController, previous[1], _hourIndex);
    _animateIfNeeded(_minuteController, previous[2], _minuteIndex);
    _animateIfNeeded(_periodController, previous[3], _periodIndex);
  }

  void _animateIfNeeded(
    FixedExtentScrollController controller,
    int from,
    int to,
  ) {
    if (from == to || !controller.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.jumpToItem(to);
      return;
    }
    controller.animateToItem(
      to,
      duration: BCDuration.fast,
      curve: Curves.easeOutCubic,
    );
  }

  void _syncFromValue() {
    final value = widget.value;
    _dayIndex = (_epochDay(value) - _epochDay(widget.firstDate)).clamp(
      0,
      _dayCount - 1,
    );

    if (_is24) {
      _hourIndex = value.hour;
      _periodIndex = 0;
    } else {
      final display = value.hour % 12 == 0 ? 12 : value.hour % 12;
      _hourIndex = display - 1; // wheel shows 1..12
      _periodIndex = value.hour >= 12 ? 1 : 0;
    }

    // Snap to the nearest step so an off-grid value still lands on a row.
    final minutes = _minutes;
    var nearest = 0;
    var best = 60;
    for (var i = 0; i < minutes.length; i++) {
      final distance = (minutes[i] - value.minute).abs();
      if (distance < best) {
        best = distance;
        nearest = i;
      }
    }
    _minuteIndex = nearest;
  }

  DateTime get _composed {
    final day = _dayForIndex(_dayIndex);
    final minute = _minutes[_minuteIndex];
    final int hour;
    if (_is24) {
      hour = _hourIndex;
    } else {
      final base = (_hourIndex + 1) % 12; // 12 -> 0
      hour = _periodIndex == 1 ? base + 12 : base;
    }
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  void _emit() {
    var next = _composed;
    if (next.isBefore(widget.firstDate)) next = widget.firstDate;
    if (next.isAfter(widget.lastDate)) next = widget.lastDate;
    widget.onChanged(next);
  }

  String _dayLabel(DateTime day) {
    if (widget.formatDay != null) return widget.formatDay!(day);
    final now = DateTime.now();
    if (day.year == now.year && day.month == now.month && day.day == now.day) {
      return 'Today';
    }
    return '${_weekdayNames[day.weekday - 1]}, '
        '${_shortMonthNames[day.month - 1]} ${day.day}';
  }

  @override
  void dispose() {
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Selection band behind the centre row.
          Center(
            child: Container(
              height: _itemExtent,
              margin: const EdgeInsets.symmetric(horizontal: BCSpacing.sm),
              decoration: ShapeDecoration(
                color: bc.defaultColor,
                shape: BCShapes.continuous(BCRadius.xl),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _wheel(
                  bc: bc,
                  controller: _dayController,
                  count: _dayCount,
                  selected: _dayIndex,
                  label: (i) => _dayLabel(_dayForIndex(i)),
                  onChanged: (i) {
                    _dayIndex = i;
                    _emit();
                  },
                ),
              ),
              Expanded(
                child: _wheel(
                  bc: bc,
                  controller: _hourController,
                  count: _hourCount,
                  selected: _hourIndex,
                  label: (i) => _is24
                      ? i.toString().padLeft(2, '0')
                      : (i + 1).toString().padLeft(2, '0'),
                  onChanged: (i) {
                    _hourIndex = i;
                    _emit();
                  },
                ),
              ),
              Expanded(
                child: _wheel(
                  bc: bc,
                  controller: _minuteController,
                  count: _minutes.length,
                  selected: _minuteIndex,
                  label: (i) => _minutes[i].toString().padLeft(2, '0'),
                  onChanged: (i) {
                    _minuteIndex = i;
                    _emit();
                  },
                ),
              ),
              if (!_is24)
                Expanded(
                  child: _wheel(
                    bc: bc,
                    controller: _periodController,
                    count: 2,
                    selected: _periodIndex,
                    label: (i) => i == 0 ? 'AM' : 'PM',
                    onChanged: (i) {
                      _periodIndex = i;
                      _emit();
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wheel({
    required BCThemeExtension bc,
    required FixedExtentScrollController controller,
    required int count,
    required int selected,
    required String Function(int index) label,
    required ValueChanged<int> onChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _itemExtent,
      perspective: 0.004,
      diameterRatio: 1.8,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) => setState(() => onChanged(index)),
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: count,
        builder: (context, index) {
          final distance = (index - selected).abs();
          final isSelected = distance == 0;
          return Center(
            child: Text(
              label(index),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: BCTypography.textLg.copyWith(
                color: isSelected
                    ? bc.accent
                    // Rows further from the centre recede.
                    : bc.foreground.withValues(alpha: distance == 1 ? 1 : 0.45),
                fontWeight: isSelected
                    ? BCTypography.semiBold
                    : BCTypography.medium,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A date **and** time field: a read-only input that opens day/hour/minute
/// wheels in a popover, a dialog or a bottom sheet.
///
/// Use it where a date alone is not enough — reminders, cutoffs, departure
/// times. For a calendar grid, use `BCDateField`; for time only,
/// `BCTimeField`.
///
/// ```dart
/// BCDateTimePicker(
///   label: 'Reminder',
///   isRequired: true,
///   description: 'Required to schedule the notification.',
///   value: _reminder,
///   minuteInterval: 5,
///   onChanged: (value) => setState(() => _reminder = value),
/// );
/// ```
class BCDateTimePicker extends StatefulWidget {
  const BCDateTimePicker({
    super.key,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.presentation = BCDateTimePickerPresentation.popover,
    this.use24HourFormat = false,
    this.minuteInterval = 1,
    this.placeholder = 'Choose a date & time',
    this.label,
    this.description,
    this.errorText,
    this.isRequired = false,
    this.isInvalid = false,
    this.isDisabled = false,
    this.variant = BCInputVariant.primary,
    this.formatDateTime,
    this.formatDay,
    this.icon = const Icon(Icons.calendar_today_outlined),
    this.wheelHeight = 220,
  });

  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;

  /// Earliest selectable moment. Defaults to the start of today.
  final DateTime? firstDate;

  /// Latest selectable moment. Defaults to five years out.
  final DateTime? lastDate;

  /// Popover and bottom sheet apply each spin immediately; the dialog waits
  /// for Confirm.
  final BCDateTimePickerPresentation presentation;

  final bool use24HourFormat;

  /// Minute step, e.g. 5 for `00, 05, 10 …`.
  final int minuteInterval;

  final String placeholder;

  /// Rendered above the field with `BCLabel`.
  final String? label;

  /// Muted helper text under the field. Replaced by [errorText] when set.
  final String? description;

  /// Error message under the field; also forces the invalid styling.
  final String? errorText;

  final bool isRequired;
  final bool isInvalid;
  final bool isDisabled;
  final BCInputVariant variant;

  /// Formats the value in the field. Defaults to `Jul 26, 2026, 9:00 AM`
  /// (or 24-hour when [use24HourFormat]).
  final String Function(DateTime value)? formatDateTime;

  /// Day column label inside the wheels. See [BCDateTimeWheel.formatDay].
  final String Function(DateTime day)? formatDay;

  final Widget icon;
  final double wheelHeight;

  bool get _invalid => isInvalid || errorText != null;

  @override
  State<BCDateTimePicker> createState() => _BCDateTimePickerState();
}

class _BCDateTimePickerState extends State<BCDateTimePicker> {
  final BCAnchoredOverlayController _overlay = BCAnchoredOverlayController();

  /// Mirrors the committed value while the wheels are open so the field can
  /// update live without the caller having to be controlled.
  DateTime? _draft;

  @override
  void dispose() {
    _overlay.dispose();
    super.dispose();
  }

  DateTime get _firstDate {
    if (widget.firstDate != null) return widget.firstDate!;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _lastDate {
    if (widget.lastDate != null) return widget.lastDate!;
    final now = DateTime.now();
    return DateTime(now.year + 5, now.month, now.day, 23, 59);
  }

  DateTime get _effectiveValue {
    final value = _draft ?? widget.value;
    if (value == null) return _initialCandidate();
    if (value.isBefore(_firstDate)) return _firstDate;
    if (value.isAfter(_lastDate)) return _lastDate;
    return value;
  }

  /// Where the wheels open when nothing is selected yet: the next slot on the
  /// minute grid, so the first spin starts somewhere sensible.
  DateTime _initialCandidate() {
    final now = DateTime.now();
    final step = widget.minuteInterval;
    final rounded = (now.minute / step).ceil() * step;
    var candidate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).add(Duration(minutes: rounded));
    if (candidate.isBefore(_firstDate)) candidate = _firstDate;
    if (candidate.isAfter(_lastDate)) candidate = _lastDate;
    return candidate;
  }

  String _format(DateTime value) {
    if (widget.formatDateTime != null) return widget.formatDateTime!(value);

    final month = _shortMonthNames[value.month - 1];
    if (widget.use24HourFormat) {
      final hh = value.hour.toString().padLeft(2, '0');
      final mm = value.minute.toString().padLeft(2, '0');
      return '$month ${value.day}, ${value.year}, $hh:$mm';
    }
    final display = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final mm = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$month ${value.day}, ${value.year}, $display:$mm $period';
  }

  Widget _wheel({required ValueChanged<DateTime> onChanged}) {
    return BCDateTimeWheel(
      value: _effectiveValue,
      firstDate: _firstDate,
      lastDate: _lastDate,
      use24HourFormat: widget.use24HourFormat,
      minuteInterval: widget.minuteInterval,
      formatDay: widget.formatDay,
      height: widget.wheelHeight,
      onChanged: onChanged,
    );
  }

  /// Panel chrome shared by the popover and the sheet.
  Widget _panel(BuildContext context, Widget child) {
    final bc = context.bcTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: BCSpacing.sm),
      decoration: ShapeDecoration(
        color: bc.overlay,
        shape: BCShapes.continuous(
          BCRadius.xxxl,
          side: bc.overlayShadow.innerBorder ?? BorderSide.none,
        ),
        shadows: bc.overlayShadow.shadows,
      ),
      child: child,
    );
  }

  void _open() {
    switch (widget.presentation) {
      case BCDateTimePickerPresentation.popover:
        _overlay.open();
      case BCDateTimePickerPresentation.dialog:
        _openDialog();
      case BCDateTimePickerPresentation.bottomSheet:
        _openSheet();
    }
  }

  /// Live selection: the field updates as the wheels settle.
  void _handleLiveChange(DateTime value) {
    setState(() => _draft = value);
    widget.onChanged?.call(value);
  }

  Future<void> _openDialog() async {
    var pending = _effectiveValue;

    final result = await BCDialog.show<DateTime>(
      context,
      builder: (dialogContext) => BCDialogContent(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: BCSpacing.sm),
              child: BCDialogTitle(widget.label ?? 'Select date & time'),
            ),
            StatefulBuilder(
              builder: (context, setSheetState) => BCDateTimeWheel(
                value: pending,
                firstDate: _firstDate,
                lastDate: _lastDate,
                use24HourFormat: widget.use24HourFormat,
                minuteInterval: widget.minuteInterval,
                formatDay: widget.formatDay,
                height: widget.wheelHeight,
                onChanged: (value) => setSheetState(() => pending = value),
              ),
            ),
            const SizedBox(height: BCSpacing.md),
            Row(
              children: [
                Expanded(
                  child: BCButton(
                    variant: BCButtonVariant.ghost,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: BCSpacing.sm),
                Expanded(
                  child: BCButton(
                    onPressed: () => Navigator.of(dialogContext).pop(pending),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _draft = result);
      widget.onChanged?.call(result);
    }
  }

  Future<void> _openSheet() {
    final bc = context.bcTheme;

    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: bc.backdrop,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        transitionDuration: BCDuration.normal,
        reverseTransitionDuration: BCDuration.fast,
        pageBuilder: (routeContext, animation, _) {
          // The sheet is its own route, outside any Scaffold: a transparent
          // Material supplies the DefaultTextStyle, otherwise the wheels are
          // drawn with Flutter's yellow "missing Material" underline.
          return Material(
            type: MaterialType.transparency,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewPaddingOf(routeContext).bottom,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    BCSpacing.sm,
                    BCSpacing.sm,
                    BCSpacing.sm,
                    BCSpacing.md,
                  ),
                  decoration: ShapeDecoration(
                    color: bc.overlay,
                    shape: BCShapes.continuousFrom(
                      const BorderRadius.vertical(
                        top: Radius.circular(BCRadius.xxxl),
                      ),
                      side: bc.overlayShadow.innerBorder ?? BorderSide.none,
                    ),
                    shadows: bc.overlayShadow.shadows,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Grab handle.
                      Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: BCSpacing.sm),
                        decoration: ShapeDecoration(
                          color: bc.separator,
                          shape: BCShapes.continuous(BCRadius.full),
                        ),
                      ),
                      _wheel(onChanged: _handleLiveChange),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: BCMotion.timingCurve,
            reverseCurve: BCMotion.timingCurve,
          );
          return SlideTransition(
            position: curved.drive(
              Tween(begin: const Offset(0, 1), end: Offset.zero),
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final value = _draft ?? widget.value;
    final hasValue = value != null;

    Widget field = Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: ShapeDecoration(
        color: widget.variant == BCInputVariant.primary
            ? bc.field
            : bc.defaultColor,
        shape: BCShapes.continuous(
          BCRadius.field,
          side: widget._invalid
              ? BorderSide(color: bc.danger, width: 2)
              : BorderSide.none,
        ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

    if (widget.presentation == BCDateTimePickerPresentation.popover) {
      field = BCAnchoredOverlay(
        controller: _overlay,
        matchAnchorWidth: true,
        overlayBuilder: (overlayContext) =>
            _panel(overlayContext, _wheel(onChanged: _handleLiveChange)),
        child: field,
      );
    }

    if (widget.isDisabled) {
      field = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: field),
      );
    }

    if (widget.label == null &&
        widget.description == null &&
        widget.errorText == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          BCLabel(
            widget.label!,
            isRequired: widget.isRequired,
            isInvalid: widget._invalid,
            isDisabled: widget.isDisabled,
          ),
          const SizedBox(height: BCSpacing.sm),
        ],
        field,
        if (widget.errorText != null) ...[
          const SizedBox(height: BCSpacing.sm),
          BCFieldError(widget.errorText!),
        ] else if (widget.description != null) ...[
          const SizedBox(height: BCSpacing.sm),
          BCDescription(widget.description!, isDisabled: widget.isDisabled),
        ],
      ],
    );
  }
}

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const _shortMonthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
