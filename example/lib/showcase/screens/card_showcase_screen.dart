import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class CardShowcaseScreen extends StatelessWidget {
  const CardShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Card',
      variants: [
        UsageVariant(
          title: 'Variants',
          builder: (context) => Column(
            spacing: 12,
            children: [
              for (final variant in BCCardVariant.values)
                BCCard(
                  variant: variant,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BCCardTitle(variant.name),
                      const BCCardDescription('Card background variant'),
                    ],
                  ),
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Composition',
          builder: (context) => BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                const BCCardHeader(
                  child: Row(
                    children: [
                      Expanded(child: BCCardTitle('Monstera Deliciosa')),
                      BCChip(
                        variant: BCChipVariant.soft,
                        color: BCChipColor.success,
                        size: BCChipSize.sm,
                        child: Text('In stock'),
                      ),
                    ],
                  ),
                ),
                const BCCardBody(
                  child: BCCardDescription(
                    'Perfect for modern tropical spaces. Low maintenance '
                    'and air purifying.',
                  ),
                ),
                BCCardFooter(
                  child: Row(
                    spacing: 8,
                    children: [
                      BCButton(
                        size: BCButtonSize.sm,
                        onPressed: () {},
                        child: const Text('Buy now'),
                      ),
                      BCButton(
                        variant: BCButtonVariant.outline,
                        size: BCButtonSize.sm,
                        onPressed: () {},
                        child: const Text('Add to cart'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
