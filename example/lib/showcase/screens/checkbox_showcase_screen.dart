import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class CheckboxShowcaseScreen extends StatefulWidget {
  const CheckboxShowcaseScreen({super.key});

  @override
  State<CheckboxShowcaseScreen> createState() =>
      _CheckboxShowcaseScreenState();
}

class _CheckboxShowcaseScreenState extends State<CheckboxShowcaseScreen> {
  bool _basic = true;
  bool _secondary = false;
  bool _invalid = false;

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Checkbox',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => BCCheckbox(
            isSelected: _basic,
            onSelectedChange: (value) => setState(() => _basic = value),
          ),
        ),
        UsageVariant(
          title: 'Secondary',
          builder: (context) => BCCheckbox(
            variant: BCCheckboxVariant.secondary,
            isSelected: _secondary,
            onSelectedChange: (value) => setState(() => _secondary = value),
          ),
        ),
        UsageVariant(
          title: 'Invalid',
          builder: (context) => BCCheckbox(
            isInvalid: true,
            isSelected: _invalid,
            onSelectedChange: (value) => setState(() => _invalid = value),
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              BCCheckbox(isSelected: true, isDisabled: true),
              BCCheckbox(isSelected: false, isDisabled: true),
            ],
          ),
        ),
      ],
    );
  }
}
