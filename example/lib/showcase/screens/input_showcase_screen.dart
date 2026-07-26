import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class InputShowcaseScreen extends StatelessWidget {
  const InputShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Input',
      variants: [
        UsageVariant(
          title: 'Variants',
          builder: (context) => const Column(
            spacing: 16,
            children: [
              BCInput(placeholder: 'Primary input'),
              BCInput(
                variant: BCInputVariant.secondary,
                placeholder: 'Secondary input',
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'States',
          builder: (context) => const Column(
            spacing: 16,
            children: [
              BCInput(placeholder: 'Focus me'),
              BCInput(placeholder: 'Invalid', isInvalid: true),
              BCInput(placeholder: 'Disabled', isDisabled: true),
            ],
          ),
        ),
        UsageVariant(
          title: 'Password',
          builder: (context) => const BCPasswordInput(
            placeholder: 'Enter password',
          ),
        ),
      ],
    );
  }
}
