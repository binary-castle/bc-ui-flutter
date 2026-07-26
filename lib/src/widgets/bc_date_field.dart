import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_dialog.dart';
import 'bc_input.dart' show BCInputVariant;
import 'bc_pressable.dart';

/// A date-picker field styled like [BCInput], with a trailing calendar icon.
///
/// Tapping the field opens [BCDatePickerDialog] — a calendar built entirely
/// from bc_ui tokens (not Material's `showDatePicker`), so it matches the
/// design system in light and dark.
class BCDateField extends StatelessWidget {
  const BCDateField({
    super.key,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.placeholder = 'Select a date',
    this.variant = BCInputVariant.primary,
    this.isInvalid = false,
    this.isDisabled = false,
    this.formatDate,
    this.icon = const Icon(Icons.calendar_today_outlined),
  });

  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;

  /// Earliest selectable date. Defaults to Jan 1, 100 years ago.
  final DateTime? firstDate;

  /// Latest selectable date. Defaults to Dec 31, 100 years ahead.
  final DateTime? lastDate;

  final String placeholder;
  final BCInputVariant variant;
  final bool isInvalid;
  final bool isDisabled;

  /// Formats the selected value for display. Defaults to `MMMM d, y`
  /// (e.g. "July 26, 2026").
  final String Function(DateTime date)? formatDate;

  /// Trailing icon; defaults to a calendar glyph.
  final Widget icon;

  DateTime get _firstDate =>
      firstDate ?? DateTime(DateTime.now().year - 100, 1, 1);

  DateTime get _lastDate =>
      lastDate ?? DateTime(DateTime.now().year + 100, 12, 31);

  String _format(DateTime date) {
    if (formatDate != null) return formatDate!(date);
    return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _open(BuildContext context) async {
    final picked = await BCDatePickerDialog.show(
      context,
      initialDate: value,
      firstDate: _firstDate,
      lastDate: _lastDate,
    );
    if (picked != null) onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final hasValue = value != null;

    final side = isInvalid
        ? BorderSide(color: bc.danger, width: 2)
        : BorderSide.none;

    Widget field = Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: ShapeDecoration(
        color: variant == BCInputVariant.primary ? bc.field : bc.defaultColor,
        shape: BCShapes.continuous(BCRadius.field, side: side),
        shadows:
            variant == BCInputVariant.primary ? bc.fieldShadow.shadows : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasValue ? _format(value!) : placeholder,
              style: BCTypography.textBase.copyWith(
                color: hasValue ? bc.foreground : bc.fieldPlaceholder,
              ),
            ),
          ),
          IconTheme.merge(
            data: IconThemeData(color: bc.muted, size: 20),
            child: icon,
          ),
        ],
      ),
    );

    if (isDisabled) {
      field = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: field),
      );
    }

    return BCPressable(
      feedback: BCPressFeedback.scale,
      enabled: !isDisabled,
      onPressed: isDisabled ? null : () => _open(context),
      child: field,
    );
  }
}

/// The calendar dialog opened by [BCDateField]. Can also be used directly:
/// `final date = await BCDatePickerDialog.show(context, ...);`
class BCDatePickerDialog extends StatefulWidget {
  const BCDatePickerDialog({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return BCDialog.show<DateTime>(
      context,
      builder: (dialogContext) => BCDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  @override
  State<BCDatePickerDialog> createState() => _BCDatePickerDialogState();
}

class _BCDatePickerDialogState extends State<BCDatePickerDialog> {
  late DateTime _visibleMonth;
  DateTime? _selected;
  bool _yearView = false;
  ScrollController? _yearScroll;

  @override
  void initState() {
    super.initState();
    final initial = _clamp(widget.initialDate ?? DateTime.now());
    _selected = widget.initialDate == null ? null : _dateOnly(initial);
    _visibleMonth = DateTime(initial.year, initial.month);
  }

  @override
  void dispose() {
    _yearScroll?.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _clamp(DateTime d) {
    if (d.isBefore(widget.firstDate)) return widget.firstDate;
    if (d.isAfter(widget.lastDate)) return widget.lastDate;
    return d;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDisabledDay(DateTime d) =>
      d.isBefore(_dateOnly(widget.firstDate)) ||
      d.isAfter(_dateOnly(widget.lastDate));

  bool get _canGoPrev =>
      DateTime(_visibleMonth.year, _visibleMonth.month)
          .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));

  bool get _canGoNext =>
      DateTime(_visibleMonth.year, _visibleMonth.month)
          .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  void _selectDay(DateTime day) {
    setState(() => _selected = day);
    Navigator.of(context).pop(day);
  }

  @override
  Widget build(BuildContext context) {
    // Fit within the screen: the dialog adds 20px outer margins, so cap the
    // card so it never overflows on narrow phones.
    final maxCardWidth = MediaQuery.sizeOf(context).width - 40;
    final width = maxCardWidth < 340 ? maxCardWidth : 340.0;

    return BCDialogContent(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(context),
          const SizedBox(height: 12),
          if (_yearView)
            _yearGrid(context)
          else ...[
            _weekdayRow(context),
            const SizedBox(height: 4),
            _dayGrid(context),
          ],
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final bc = context.bcTheme;
    return Row(
      children: [
        Expanded(
          child: BCPressable(
            feedback: BCPressFeedback.scale,
            onPressed: () => setState(() => _yearView = !_yearView),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(
                  '${_monthNames[_visibleMonth.month - 1]} '
                  '${_visibleMonth.year}',
                  style: BCTypography.textBase.copyWith(
                    color: bc.foreground,
                    fontWeight: BCTypography.semiBold,
                  ),
                ),
                Icon(
                  _yearView
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: bc.muted,
                ),
              ],
            ),
          ),
        ),
        if (!_yearView) ...[
          _navButton(context, Icons.chevron_left,
              enabled: _canGoPrev, onPressed: () => _changeMonth(-1)),
          const SizedBox(width: 4),
          _navButton(context, Icons.chevron_right,
              enabled: _canGoNext, onPressed: () => _changeMonth(1)),
        ],
      ],
    );
  }

  Widget _navButton(
    BuildContext context,
    IconData icon, {
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    final bc = context.bcTheme;
    final shape = BCShapes.continuous(BCRadius.xxl);
    return Opacity(
      opacity: enabled ? 1 : bc.opacityDisabled,
      child: BCPressable(
        feedback: BCPressFeedback.highlight,
        shape: shape,
        highlightColor: bc.surfaceHover,
        highlightOpacityRange: (0, 1),
        enabled: enabled,
        background: DecoratedBox(
          decoration: ShapeDecoration(color: bc.defaultColor, shape: shape),
        ),
        onPressed: enabled ? onPressed : null,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(child: Icon(icon, size: 20, color: bc.foreground)),
        ),
      ),
    );
  }

  Widget _weekdayRow(BuildContext context) {
    final bc = context.bcTheme;
    return Row(
      children: [
        for (final label in _weekdayLabels)
          Expanded(
            child: Center(
              child: Text(
                label,
                style: BCTypography.textXs.copyWith(
                  color: bc.muted,
                  fontWeight: BCTypography.medium,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _dayGrid(BuildContext context) {
    final firstOfMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    // Leading blanks so the 1st lands under its weekday (Sunday start).
    final leading = firstOfMonth.weekday % 7;
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const Expanded(child: SizedBox.shrink()));
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(Expanded(
        child: _dayCell(
          context,
          DateTime(_visibleMonth.year, _visibleMonth.month, day),
        ),
      ));
    }
    while (cells.length % 7 != 0) {
      cells.add(const Expanded(child: SizedBox.shrink()));
    }

    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      rows.add(Row(children: cells.sublist(i, i + 7)));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _dayCell(BuildContext context, DateTime day) {
    final bc = context.bcTheme;
    final disabled = _isDisabledDay(day);
    final isSelected = _selected != null && _sameDay(day, _selected!);
    final isToday = _sameDay(day, DateTime.now());

    final Color textColor;
    if (disabled) {
      textColor = bc.muted;
    } else if (isSelected) {
      textColor = bc.accentForeground;
    } else if (isToday) {
      textColor = bc.accent;
    } else {
      textColor = bc.foreground;
    }

    final shape = BCShapes.continuous(BCRadius.xl);

    Widget cell = AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: isSelected ? bc.accent : const Color(0x00000000),
            shape: isToday && !isSelected
                ? BCShapes.continuous(
                    BCRadius.xl,
                    side: BorderSide(color: bc.accent),
                  )
                : shape,
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: BCTypography.textSm.copyWith(
                color: textColor,
                fontWeight:
                    isSelected || isToday ? BCTypography.medium : null,
              ),
            ),
          ),
        ),
      ),
    );

    if (disabled) {
      return Opacity(opacity: bc.opacityDisabled, child: cell);
    }

    return BCPressable(
      feedback: isSelected
          ? BCPressFeedback.scale
          : BCPressFeedback.scaleHighlight,
      shape: shape,
      highlightColor: bc.surfaceHover,
      highlightOpacityRange: (0, 1),
      onPressed: () => _selectDay(day),
      child: cell,
    );
  }

  Widget _yearGrid(BuildContext context) {
    final bc = context.bcTheme;
    final years = [
      for (var y = widget.firstDate.year; y <= widget.lastDate.year; y++) y,
    ];
    _yearScroll ??= ScrollController(
      initialScrollOffset: (years.indexOf(_visibleMonth.year) ~/ 3) * 48.0,
    );

    return SizedBox(
      height: 240,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        controller: _yearScroll,
        children: [
          for (final year in years)
            _yearCell(context, year, isSelected: year == _visibleMonth.year,
                bc: bc),
        ],
      ),
    );
  }

  Widget _yearCell(
    BuildContext context,
    int year, {
    required bool isSelected,
    required BCThemeExtension bc,
  }) {
    final shape = BCShapes.continuous(BCRadius.xl);
    return BCPressable(
      feedback: BCPressFeedback.scaleHighlight,
      shape: shape,
      highlightColor: bc.surfaceHover,
      highlightOpacityRange: (0, 1),
      background: isSelected
          ? DecoratedBox(
              decoration: ShapeDecoration(color: bc.accent, shape: shape),
            )
          : null,
      onPressed: () {
        setState(() {
          _visibleMonth = DateTime(year, _visibleMonth.month);
          _yearView = false;
        });
      },
      child: Center(
        child: Text(
          '$year',
          style: BCTypography.textSm.copyWith(
            color: isSelected ? bc.accentForeground : bc.foreground,
            fontWeight: isSelected ? BCTypography.medium : null,
          ),
        ),
      ),
    );
  }
}

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
