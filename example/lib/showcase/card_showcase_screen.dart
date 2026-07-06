import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:flutter/material.dart';

class CardShowcaseScreen extends StatelessWidget {
  const CardShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cards')),
      body: ListView(
        padding: const EdgeInsets.all(ShowcaseSpacing.lg),
        children: [
          const ShowcaseSectionTitle('Variants'),
          BCCard(
            variant: BCCardVariant.defaultVariant,
            child: const BCCardBody(child: BCCardTitle('Default')),
          ),
          const SizedBox(height: ShowcaseSpacing.md),
          BCCard(
            variant: BCCardVariant.secondary,
            child: const BCCardBody(child: BCCardTitle('Secondary')),
          ),
          const SizedBox(height: ShowcaseSpacing.md),
          BCCard(
            variant: BCCardVariant.tertiary,
            child: const BCCardBody(child: BCCardTitle('Tertiary')),
          ),
          const SizedBox(height: ShowcaseSpacing.md),
          BCCard(
            variant: BCCardVariant.transparent,
            child: const BCCardBody(child: BCCardTitle('Transparent')),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('With Title + Description'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                BCCardBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BCCardTitle('Living room Sofa'),
                      SizedBox(height: ShowcaseSpacing.xs),
                      BCCardDescription(
                        'Perfect for modern tropical spaces, '
                        'baroque inspired design.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('With Header + Footer'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BCCardHeader(child: Icon(Icons.star, size: 28)),
                const SizedBox(height: ShowcaseSpacing.sm),
                const BCCardBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BCCardTitle('Living room Sofa'),
                      SizedBox(height: ShowcaseSpacing.xs),
                      BCCardDescription(
                        'Perfect for modern tropical spaces.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ShowcaseSpacing.md),
                BCCardFooter(
                  child: Row(
                    children: [
                      BCButton.primary(text: 'Buy now', onPressed: () {}),
                      const SizedBox(width: ShowcaseSpacing.sm),
                      BCButton.outline(
                        text: 'Add to cart',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Nested Surfaces'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BCCardBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BCCardTitle('Outer card'),
                      SizedBox(height: ShowcaseSpacing.xs),
                      BCCardDescription('Contains nested surface cards.'),
                    ],
                  ),
                ),
                const SizedBox(height: ShowcaseSpacing.md),
                BCCard(
                  variant: BCCardVariant.secondary,
                  child: const BCCardBody(
                    child: BCCardTitle('Secondary inner'),
                  ),
                ),
                const SizedBox(height: ShowcaseSpacing.sm),
                BCCard(
                  variant: BCCardVariant.tertiary,
                  child: const BCCardBody(
                    child: BCCardTitle('Tertiary inner'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
