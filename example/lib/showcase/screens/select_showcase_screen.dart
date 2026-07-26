import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SelectShowcaseScreen extends StatefulWidget {
  const SelectShowcaseScreen({super.key});

  @override
  State<SelectShowcaseScreen> createState() => _SelectShowcaseScreenState();
}

class _SelectShowcaseScreenState extends State<SelectShowcaseScreen> {
  String? _country;
  String? _plan;

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Select',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => BCSelect<String>(
            placeholder: 'Select a country',
            items: const [
              BCSelectItem(value: 'bd', label: 'Bangladesh'),
              BCSelectItem(value: 'us', label: 'United States'),
              BCSelectItem(value: 'jp', label: 'Japan'),
              BCSelectItem(value: 'de', label: 'Germany'),
            ],
            value: _country,
            onValueChange: (value) => setState(() => _country = value),
          ),
        ),
        UsageVariant(
          title: 'With descriptions',
          builder: (context) => BCSelect<String>(
            placeholder: 'Choose a plan',
            listLabel: 'Plans',
            items: const [
              BCSelectItem(
                value: 'free',
                label: 'Free',
                description: 'For personal projects',
              ),
              BCSelectItem(
                value: 'pro',
                label: 'Pro',
                description: 'For professionals',
              ),
              BCSelectItem(
                value: 'team',
                label: 'Team',
                description: 'For organizations',
              ),
            ],
            value: _plan,
            onValueChange: (value) => setState(() => _plan = value),
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const BCSelect<String>(
            placeholder: 'Disabled select',
            isDisabled: true,
            items: [BCSelectItem(value: 'x', label: 'X')],
          ),
        ),
      ],
    );
  }
}
