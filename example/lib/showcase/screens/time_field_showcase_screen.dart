import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class TimeFieldShowcaseScreen extends StatefulWidget {
  const TimeFieldShowcaseScreen({super.key});

  @override
  State<TimeFieldShowcaseScreen> createState() =>
      _TimeFieldShowcaseScreenState();
}

class _TimeFieldShowcaseScreenState extends State<TimeFieldShowcaseScreen> {
  TimeOfDay? _basic;
  TimeOfDay? _twentyFour;
  TimeOfDay? _stepped;
  TimeOfDay? _popover;
  TimeOfDay? _sheet;

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'TimeField',
      variants: [
        UsageVariant(
          title: 'Basic (12h)',
          builder: (context) => BCTimeField(
            value: _basic,
            onChanged: (time) => setState(() => _basic = time),
          ),
        ),
        UsageVariant(
          title: 'Presentations',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 28,
            children: [
              _Captioned(
                label: 'Dialog (default, Cancel / Confirm)',
                child: BCTimeField(
                  value: _basic,
                  onChanged: (time) => setState(() => _basic = time),
                ),
              ),
              _Captioned(
                label: 'Popover (applies live)',
                child: BCTimeField(
                  presentation: BCPickerPresentation.popover,
                  value: _popover,
                  onChanged: (time) => setState(() => _popover = time),
                ),
              ),
              _Captioned(
                label: 'Bottom sheet (applies live)',
                child: BCTimeField(
                  presentation: BCPickerPresentation.bottomSheet,
                  value: _sheet,
                  onChanged: (time) => setState(() => _sheet = time),
                ),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: '24-hour',
          builder: (context) => BCTimeField(
            use24HourFormat: true,
            value: _twentyFour,
            onChanged: (time) => setState(() => _twentyFour = time),
          ),
        ),
        UsageVariant(
          title: '15-minute steps',
          builder: (context) => BCTimeField(
            minuteStep: 15,
            placeholder: 'Pick a slot',
            value: _stepped,
            onChanged: (time) => setState(() => _stepped = time),
          ),
        ),
        UsageVariant(
          title: 'In a field',
          builder: (context) => BCTextField(
            children: [
              const BCTextFieldLabel('Reminder time'),
              BCTimeField(
                placeholder: 'Choose a time',
                value: _basic,
                onChanged: (time) => setState(() => _basic = time),
              ),
              const BCTextFieldDescription('We\'ll notify you then.'),
            ],
          ),
        ),
        UsageVariant(
          title: 'States',
          builder: (context) => Column(
            spacing: 16,
            children: [
              BCTimeField(
                value: const TimeOfDay(hour: 9, minute: 30),
                isInvalid: true,
                onChanged: (_) {},
              ),
              const BCTimeField(
                placeholder: 'Disabled',
                isDisabled: true,
              ),
              const BCTimeField(
                variant: BCInputVariant.secondary,
                placeholder: 'Secondary variant',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Section caption above a picker.
class _Captioned extends StatelessWidget {
  const _Captioned({required this.label, required this.child});

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
