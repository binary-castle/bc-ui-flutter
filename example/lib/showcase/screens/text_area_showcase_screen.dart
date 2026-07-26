import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class TextAreaShowcaseScreen extends StatelessWidget {
  const TextAreaShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'TextArea',
      variants: [
        UsageVariant(
          title: 'Default',
          builder: (context) => const BCTextArea(
            placeholder: 'Write your message…',
          ),
        ),
        UsageVariant(
          title: 'States',
          builder: (context) => const Column(
            spacing: 16,
            children: [
              BCTextArea(placeholder: 'Invalid', isInvalid: true),
              BCTextArea(placeholder: 'Disabled', isDisabled: true),
            ],
          ),
        ),
      ],
    );
  }
}
