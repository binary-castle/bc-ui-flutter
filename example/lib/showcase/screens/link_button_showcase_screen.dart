import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class LinkButtonShowcaseScreen extends StatelessWidget {
  const LinkButtonShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'LinkButton & CloseButton',
      variants: [
        UsageVariant(
          title: 'Link button',
          builder: (context) => Column(
            spacing: 16,
            children: [
              BCLinkButton.label('Learn more', onPressed: () {}),
              BCLinkButton.label(
                'Continue',
                onPressed: () {},
                endContent: const Icon(Icons.arrow_forward, size: 16),
              ),
              BCLinkButton.label('Disabled link', isDisabled: true),
            ],
          ),
        ),
        UsageVariant(
          title: 'Close button',
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              BCCloseButton(onPressed: () {}),
              const BCCloseButton(isDisabled: true),
            ],
          ),
        ),
      ],
    );
  }
}
