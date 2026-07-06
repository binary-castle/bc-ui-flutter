import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:flutter/material.dart';

class BadgeShowcaseScreen extends StatelessWidget {
  const BadgeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: ListView(
        padding: const EdgeInsets.all(ShowcaseSpacing.lg),
        children: [
          const ShowcaseSectionTitle('Sizes'),
          const BCCard(
            child: Wrap(
              spacing: ShowcaseSpacing.sm,
              runSpacing: ShowcaseSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                BCBadge(label: 'Small', size: BCBadgeSize.small),
                BCBadge(label: 'Medium', size: BCBadgeSize.medium),
                BCBadge(label: 'Large', size: BCBadgeSize.large),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Variants'),
          const BCCard(
            child: Wrap(
              spacing: ShowcaseSpacing.sm,
              runSpacing: ShowcaseSpacing.sm,
              children: [
                BCBadge(label: 'Primary', variant: BCBadgeVariant.primary),
                BCBadge(
                  label: 'Secondary',
                  variant: BCBadgeVariant.secondary,
                ),
                BCBadge(label: 'Tertiary', variant: BCBadgeVariant.tertiary),
                BCBadge(label: 'Soft', variant: BCBadgeVariant.soft),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Colors'),
          const BCCard(
            child: Wrap(
              spacing: ShowcaseSpacing.sm,
              runSpacing: ShowcaseSpacing.sm,
              children: [
                BCBadge(label: 'Accent', color: BCBadgeColor.accent),
                BCBadge(label: 'Default', color: BCBadgeColor.defaultColor),
                BCBadge(label: 'Success', color: BCBadgeColor.success),
                BCBadge(label: 'Warning', color: BCBadgeColor.warning),
                BCBadge(label: 'Danger', color: BCBadgeColor.danger),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('With Icon'),
          BCCard(
            child: Wrap(
              spacing: ShowcaseSpacing.sm,
              runSpacing: ShowcaseSpacing.sm,
              children: [
                BCBadge(
                  variant: BCBadgeVariant.soft,
                  color: BCBadgeColor.success,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check, size: 14),
                      SizedBox(width: ShowcaseSpacing.xs),
                      BCBadgeLabel('Verified'),
                    ],
                  ),
                ),
                BCBadge(
                  variant: BCBadgeVariant.secondary,
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.local_offer_outlined, size: 14),
                      SizedBox(width: ShowcaseSpacing.xs),
                      BCBadgeLabel('Promo'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Color × Variant Matrix'),
          ..._colorVariantMatrix(),
        ],
      ),
    );
  }

  List<Widget> _colorVariantMatrix() {
    const colors = BCBadgeColor.values;
    const variants = BCBadgeVariant.values;

    return [
      for (final variant in variants) ...[
        BCCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_variantLabel(variant)),
              const SizedBox(height: ShowcaseSpacing.sm),
              Wrap(
                spacing: ShowcaseSpacing.sm,
                runSpacing: ShowcaseSpacing.sm,
                children: [
                  for (final color in colors)
                    BCBadge(
                      label: _colorLabel(color),
                      variant: variant,
                      color: color,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: ShowcaseSpacing.md),
      ],
    ];
  }

  static String _variantLabel(BCBadgeVariant variant) {
    return switch (variant) {
      BCBadgeVariant.primary => 'Primary',
      BCBadgeVariant.secondary => 'Secondary',
      BCBadgeVariant.tertiary => 'Tertiary',
      BCBadgeVariant.soft => 'Soft',
    };
  }

  static String _colorLabel(BCBadgeColor color) {
    return switch (color) {
      BCBadgeColor.accent => 'Accent',
      BCBadgeColor.defaultColor => 'Default',
      BCBadgeColor.success => 'Success',
      BCBadgeColor.warning => 'Warning',
      BCBadgeColor.danger => 'Danger',
    };
  }
}
