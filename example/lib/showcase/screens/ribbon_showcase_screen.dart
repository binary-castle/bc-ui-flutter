import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class RibbonShowcaseScreen extends StatelessWidget {
  const RibbonShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Ribbon',
      variants: [
        UsageVariant(
          title: 'Forms',
          builder: (context) => const Column(
            spacing: 16,
            children: [
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: BCRibbon(
                      label: Text('Hot Sale'),
                      form: BCRibbonForm.tag,
                      color: BCRibbonColor.danger,
                      startContent: Icon(Icons.local_fire_department),
                      child: _ProductCard(name: 'Wireless buds', price: r'$79'),
                    ),
                  ),
                  Expanded(
                    child: BCRibbon(
                      label: Text('Nearby'),
                      form: BCRibbonForm.flag,
                      color: BCRibbonColor.success,
                      child: _ProductCard(name: 'Corner store', price: '0.8 km'),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: BCRibbon(
                      label: Text('Best Seller'),
                      form: BCRibbonForm.corner,
                      position: BCRibbonPosition.topEnd,
                      color: BCRibbonColor.warning,
                      child: _ProductCard(name: 'Sneakers', price: r'$89'),
                    ),
                  ),
                  Expanded(
                    child: BCRibbon(
                      label: Text('-30%'),
                      form: BCRibbonForm.bookmark,
                      position: BCRibbonPosition.topEnd,
                      color: BCRibbonColor.danger,
                      child: _ProductCard(name: 'Running shoes', price: r'$62'),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: BCRibbon(
                      label: Text('Free ship'),
                      form: BCRibbonForm.banner,
                      position: BCRibbonPosition.bottomStart,
                      color: BCRibbonColor.accent,
                      child: _ProductCard(name: 'Coffee grinder', price: r'$118'),
                    ),
                  ),
                  Expanded(
                    child: BCRibbon(
                      label: Text('SALE'),
                      form: BCRibbonForm.corner,
                      cornerOffset: 0,
                      color: BCRibbonColor.danger,
                      child: _ProductCard(name: 'Filled corner', price: r'$34'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Variants',
          builder: (context) => const Column(
            spacing: 16,
            children: [
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: BCRibbon(
                      label: Text('Solid'),
                      child: _ProductCard(name: 'Solid', price: r'$19'),
                    ),
                  ),
                  Expanded(
                    child: BCRibbon(
                      label: Text('Soft'),
                      variant: BCRibbonVariant.soft,
                      child: _ProductCard(name: 'Soft', price: r'$19'),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: BCRibbon(
                      label: Text('Outline'),
                      variant: BCRibbonVariant.outline,
                      child: _ProductCard(name: 'Outline', price: r'$19'),
                    ),
                  ),
                  Expanded(
                    child: BCRibbon(
                      label: Text('Soft flag'),
                      form: BCRibbonForm.flag,
                      variant: BCRibbonVariant.soft,
                      color: BCRibbonColor.success,
                      child: _ProductCard(name: 'Flag', price: r'$19'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Colors',
          builder: (context) => const Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              BCRibbon(label: Text('accent')),
              BCRibbon(label: Text('success'), color: BCRibbonColor.success),
              BCRibbon(label: Text('warning'), color: BCRibbonColor.warning),
              BCRibbon(label: Text('danger'), color: BCRibbonColor.danger),
              BCRibbon(
                label: Text('default'),
                color: BCRibbonColor.defaultColor,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Positions',
          builder: (context) => Column(
            spacing: 16,
            children: [
              for (final row in [
                [BCRibbonPosition.topStart, BCRibbonPosition.topEnd],
                [BCRibbonPosition.bottomStart, BCRibbonPosition.bottomEnd],
              ])
                Row(
                  spacing: 16,
                  children: [
                    for (final position in row)
                      Expanded(
                        child: BCRibbon.label(
                          position.name,
                          form: BCRibbonForm.corner,
                          position: position,
                          size: BCRibbonSize.sm,
                          child: const _ProductCard(
                            name: 'Corner band',
                            price: r'$9',
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Corner offset',
          builder: (context) => const Column(
            spacing: 16,
            children: [
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: BCRibbon(
                      label: Text('SALE'),
                      form: BCRibbonForm.corner,
                      cornerOffset: 0,
                      color: BCRibbonColor.warning,
                      child: _ProductCard(name: 'offset 0', price: r'$12'),
                    ),
                  ),
                  Expanded(
                    child: BCRibbon(
                      label: Text('SALE'),
                      form: BCRibbonForm.corner,
                      color: BCRibbonColor.warning,
                      child: _ProductCard(name: 'default', price: r'$12'),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: BCRibbon(
                      label: Text('SALE'),
                      form: BCRibbonForm.corner,
                      cornerOffset: 44,
                      color: BCRibbonColor.warning,
                      child: _ProductCard(name: 'offset 44', price: r'$12'),
                    ),
                  ),
                  Expanded(
                    child: BCRibbon(
                      label: Text('-50%'),
                      form: BCRibbonForm.corner,
                      position: BCRibbonPosition.bottomEnd,
                      cornerOffset: 0,
                      variant: BCRibbonVariant.soft,
                      color: BCRibbonColor.success,
                      child: _ProductCard(name: 'bottom end', price: r'$12'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Sizes',
          builder: (context) => Column(
            spacing: 16,
            children: [
              for (final size in BCRibbonSize.values)
                BCRibbon.label(
                  'Hot Sale',
                  size: size,
                  color: BCRibbonColor.danger,
                  child: _ProductCard(name: size.name, price: r'$45'),
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'On a product card',
          builder: (context) => const BCRibbon(
            label: Text('Best Seller'),
            form: BCRibbonForm.corner,
            position: BCRibbonPosition.topEnd,
            color: BCRibbonColor.danger,
            child: BCRibbon(
              label: Text('Nearby'),
              form: BCRibbonForm.tag,
              variant: BCRibbonVariant.outline,
              color: BCRibbonColor.success,
              startContent: Icon(Icons.near_me),
              child: _ProductCard(
                name: 'Espresso machine',
                price: r'$249',
                description: 'Ships tomorrow · 4.8 ★ (312)',
                tall: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Stand-in for a real product card: image block, name, price.
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    required this.price,
    this.description,
    this.tall = false,
  });

  final String name;
  final String price;
  final String? description;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return BCSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: tall ? 160 : 88,
            decoration: BoxDecoration(color: bc.backgroundSecondary),
            alignment: Alignment.center,
            child: Icon(Icons.image_outlined, color: bc.muted, size: 28),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BCTypography.textSm.copyWith(
                    color: bc.foreground,
                    fontWeight: BCTypography.medium,
                  ),
                ),
                Text(
                  price,
                  style: BCTypography.textBase.copyWith(
                    color: bc.foreground,
                    fontWeight: BCTypography.semiBold,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: BCTypography.textXs.copyWith(color: bc.muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
