import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class DateTimePickerShowcaseScreen extends StatefulWidget {
  const DateTimePickerShowcaseScreen({super.key});

  @override
  State<DateTimePickerShowcaseScreen> createState() =>
      _DateTimePickerShowcaseScreenState();
}

class _DateTimePickerShowcaseScreenState
    extends State<DateTimePickerShowcaseScreen> {
  DateTime? _popover;
  DateTime? _dialog;
  DateTime? _sheet;
  DateTime? _departure = DateTime(2026, 7, 31);
  DateTime? _custom;
  DateTime? _reminder;

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'DateTimePicker',
      variants: [
        UsageVariant(
          title: 'Presentations',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 28,
            children: [
              _Labelled(
                label: 'Popover',
                child: BCDateTimePicker(
                  value: _popover,
                  onChanged: (value) => setState(() => _popover = value),
                ),
              ),
              _Labelled(
                label: 'Dialog',
                child: BCDateTimePicker(
                  presentation: BCDateTimePickerPresentation.dialog,
                  value: _dialog,
                  onChanged: (value) => setState(() => _dialog = value),
                ),
              ),
              _Labelled(
                label: 'Bottom sheet',
                child: BCDateTimePicker(
                  presentation: BCDateTimePickerPresentation.bottomSheet,
                  value: _sheet,
                  onChanged: (value) => setState(() => _sheet = value),
                ),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: '24-hour with interval',
          builder: (context) => BCDateTimePicker(
            label: 'Departure (24h, 5 min steps)',
            use24HourFormat: true,
            minuteInterval: 5,
            value: _departure,
            formatDateTime: (value) =>
                '${value.day} ${_months[value.month - 1]} ${value.year} at '
                '${value.hour.toString().padLeft(2, '0')}:'
                '${value.minute.toString().padLeft(2, '0')}',
            formatDay: (day) =>
                '${_weekdays[day.weekday - 1]} ${day.day} '
                '${_months[day.month - 1]}',
            onChanged: (value) => setState(() => _departure = value),
          ),
        ),
        UsageVariant(
          title: 'Custom format',
          builder: (context) => BCDateTimePicker(
            label: 'Custom format',
            value: _custom,
            formatDateTime: (value) =>
                '${_weekdays[value.weekday - 1]} '
                '${value.day}/${value.month} · '
                '${value.hour.toString().padLeft(2, '0')}h'
                '${value.minute.toString().padLeft(2, '0')}',
            onChanged: (value) => setState(() => _custom = value),
          ),
        ),
        UsageVariant(
          title: 'Field states',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 28,
            children: [
              BCDateTimePicker(
                label: 'Reminder',
                isRequired: true,
                description: 'Required to schedule the notification.',
                placeholder: 'Pick a reminder date & time',
                value: _reminder,
                onChanged: (value) => setState(() => _reminder = value),
              ),
              const BCDateTimePicker(
                label: 'Cutoff',
                errorText: 'Please select a valid cutoff date and time.',
              ),
              BCDateTimePicker(
                label: 'Disabled date & time',
                isDisabled: true,
                description:
                    'The date and time cannot be changed when the schedule '
                    'is locked.',
                value: DateTime(2026, 6, 1, 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Section caption above a picker, matching the reference layout.
class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: BCSpacing.sm),
          child: BCText(label, type: BCTextType.h6),
        ),
        child,
      ],
    );
  }
}

const _months = [
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

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
