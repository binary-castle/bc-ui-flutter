import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class ButtonShowcaseScreen extends StatelessWidget {
  const ButtonShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Button',
      variants: [
        UsageVariant(
          title: 'Variants',
          builder: (context) => Column(
            spacing: 12,
            children: [
              for (final variant in BCButtonVariant.values)
                BCButton(
                  variant: variant,
                  fullWidth: true,
                  onPressed: () {},
                  child: Text(variant.name),
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Sizes',
          builder: (context) => Column(
            spacing: 12,
            children: [
              for (final size in BCButtonSize.values)
                BCButton(
                  size: size,
                  onPressed: () {},
                  child: Text('Button ${size.name}'),
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'With content',
          builder: (context) => Column(
            spacing: 12,
            children: [
              BCButton(
                onPressed: () {},
                startContent: const Icon(Icons.add),
                child: const Text('Start content'),
              ),
              BCButton(
                variant: BCButtonVariant.secondary,
                onPressed: () {},
                endContent: const Icon(Icons.arrow_forward),
                child: const Text('End content'),
              ),
              BCButton(
                isIconOnly: true,
                onPressed: () {},
                child: const Icon(Icons.favorite),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Feedback',
          builder: (context) => Column(
            spacing: 12,
            children: [
              BCButton(
                onPressed: () {},
                child: const Text('Scale + highlight'),
              ),
              BCButton(
                feedback: BCPressFeedback.scaleRipple,
                variant: BCButtonVariant.secondary,
                onPressed: () {},
                child: const Text('Scale + ripple'),
              ),
              BCButton(
                feedback: BCPressFeedback.scale,
                variant: BCButtonVariant.outline,
                onPressed: () {},
                child: const Text('Scale only'),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => Column(
            spacing: 12,
            children: [
              BCButton(
                isDisabled: true,
                onPressed: () {},
                child: const Text('Disabled primary'),
              ),
              BCButton(
                variant: BCButtonVariant.outline,
                isDisabled: true,
                onPressed: () {},
                child: const Text('Disabled outline'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
