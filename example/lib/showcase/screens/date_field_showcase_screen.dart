import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class DateFieldShowcaseScreen extends StatefulWidget {
  const DateFieldShowcaseScreen({super.key});

  @override
  State<DateFieldShowcaseScreen> createState() =>
      _DateFieldShowcaseScreenState();
}

class _DateFieldShowcaseScreenState extends State<DateFieldShowcaseScreen> {
  DateTime? _basic;
  DateTime? _labelled;
  DateTime? _bounded;
  DateTime? _popover;
  DateTime? _sheet;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return ComponentShowcaseScaffold(
      title: 'DateField',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => BCDateField(
            value: _basic,
            onChanged: (date) => setState(() => _basic = date),
          ),
        ),
        UsageVariant(
          title: 'Presentations',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 28,
            children: [
              _Captioned(
                label: 'Dialog (default)',
                child: BCDateField(
                  value: _basic,
                  onChanged: (date) => setState(() => _basic = date),
                ),
              ),
              _Captioned(
                label: 'Popover',
                child: BCDateField(
                  presentation: BCPickerPresentation.popover,
                  value: _popover,
                  onChanged: (date) => setState(() => _popover = date),
                ),
              ),
              _Captioned(
                label: 'Bottom sheet',
                child: BCDateField(
                  presentation: BCPickerPresentation.bottomSheet,
                  value: _sheet,
                  onChanged: (date) => setState(() => _sheet = date),
                ),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'In a field',
          builder: (context) => BCTextField(
            children: [
              const BCTextFieldLabel('Date of birth'),
              _FieldSlot(
                child: BCDateField(
                  placeholder: 'MM / DD / YYYY',
                  value: _labelled,
                  onChanged: (date) => setState(() => _labelled = date),
                ),
              ),
              const BCTextFieldDescription('Used to verify your age.'),
            ],
          ),
        ),
        UsageVariant(
          title: 'Bounded range',
          builder: (context) => BCDateField(
            placeholder: 'Pick a day this month',
            firstDate: DateTime(now.year, now.month, 1),
            lastDate: DateTime(now.year, now.month + 1, 0),
            value: _bounded,
            onChanged: (date) => setState(() => _bounded = date),
          ),
        ),
        UsageVariant(
          title: 'States',
          builder: (context) => Column(
            spacing: 16,
            children: [
              BCDateField(
                value: DateTime(now.year, now.month, now.day),
                isInvalid: true,
                onChanged: (_) {},
              ),
              const BCDateField(
                placeholder: 'Disabled',
                isDisabled: true,
              ),
              const BCDateField(
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

/// BCTextFieldInput is for text; a date field drops straight into the stack.
class _FieldSlot extends StatelessWidget {
  const _FieldSlot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
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
