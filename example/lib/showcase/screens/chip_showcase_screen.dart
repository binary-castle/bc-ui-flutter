import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class ChipShowcaseScreen extends StatelessWidget {
  const ChipShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Chip',
      variants: [
        UsageVariant(
          title: 'Variants',
          builder: (context) => Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final variant in BCChipVariant.values)
                BCChip.label(variant.name, variant: variant),
            ],
          ),
        ),
        UsageVariant(
          title: 'Sizes',
          builder: (context) => Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final size in BCChipSize.values)
                BCChip.label(size.name, size: size),
            ],
          ),
        ),
        UsageVariant(
          title: 'Colors',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              for (final variant in BCChipVariant.values)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final color in BCChipColor.values)
                      BCChip.label(
                        color == BCChipColor.defaultColor
                            ? 'default'
                            : color.name,
                        variant: variant,
                        color: color,
                      ),
                  ],
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'With content',
          builder: (context) => Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              BCChip.label(
                'Verified',
                variant: BCChipVariant.soft,
                color: BCChipColor.success,
                startContent: const Icon(Icons.check_circle, size: 14),
              ),
              BCChip.label(
                'Trending',
                variant: BCChipVariant.soft,
                color: BCChipColor.warning,
                startContent: const Icon(Icons.trending_up, size: 14),
              ),
              BCChip.label(
                'Removable',
                variant: BCChipVariant.secondary,
                endContent: const Icon(Icons.close, size: 14),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
