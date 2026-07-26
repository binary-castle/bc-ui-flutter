import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class PopoverShowcaseScreen extends StatelessWidget {
  const PopoverShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Popover',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => BCPopover(
            trigger: (context, controller) => BCButton(
              onPressed: controller.toggle,
              child: const Text('Show popover'),
            ),
            content: (context) => const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                BCPopoverTitle('Popover title'),
                BCPopoverDescription(
                  'Anchored to the trigger with a scale-from-anchor '
                  'entrance, flipping when space runs out.',
                ),
              ],
            ),
          ),
        ),
        UsageVariant(
          title: 'Placement top',
          builder: (context) => BCPopover(
            placement: BCOverlayPlacement.top,
            trigger: (context, controller) => BCButton(
              variant: BCButtonVariant.secondary,
              onPressed: controller.toggle,
              child: const Text('Opens upward'),
            ),
            content: (context) =>
                const BCPopoverDescription('Placed above the trigger.'),
          ),
        ),
      ],
    );
  }
}
