import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class RadioGroupShowcaseScreen extends StatefulWidget {
  const RadioGroupShowcaseScreen({super.key});

  @override
  State<RadioGroupShowcaseScreen> createState() =>
      _RadioGroupShowcaseScreenState();
}

class _RadioGroupShowcaseScreenState extends State<RadioGroupShowcaseScreen> {
  String _plan = 'pro';
  String _invalidChoice = '';

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'RadioGroup',
      variants: [
        UsageVariant(
          title: 'Default',
          builder: (context) => BCRadioGroup<String>(
            value: _plan,
            onValueChange: (value) => setState(() => _plan = value),
            children: const [
              BCRadio(
                value: 'free',
                label: 'Free',
                description: 'Basic features for personal use',
              ),
              BCRadio(
                value: 'pro',
                label: 'Pro',
                description: 'Advanced features for professionals',
              ),
              BCRadio(
                value: 'team',
                label: 'Team',
                description: 'Collaboration for organizations',
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Invalid',
          builder: (context) => BCRadioGroup<String>(
            value: _invalidChoice.isEmpty ? null : _invalidChoice,
            onValueChange: (value) =>
                setState(() => _invalidChoice = value),
            children: const [
              BCRadio(
                value: 'a',
                label: 'Option A',
                isInvalid: true,
              ),
              BCRadio(
                value: 'b',
                label: 'Option B',
                isInvalid: true,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const BCRadioGroup<String>(
            value: 'one',
            onValueChange: null,
            isDisabled: true,
            children: [
              BCRadio(value: 'one', label: 'Selected but disabled'),
              BCRadio(value: 'two', label: 'Unselected and disabled'),
            ],
          ),
        ),
      ],
    );
  }
}
