import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SurfaceShowcaseScreen extends StatelessWidget {
  const SurfaceShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Surface',
      variants: [
        UsageVariant(
          title: 'Variants',
          builder: (context) => Column(
            spacing: 12,
            children: [
              for (final variant in BCSurfaceVariant.values)
                BCSurface(
                  variant: variant,
                  width: double.infinity,
                  child: BCText(
                    variant.name,
                    type: BCTextType.bodySm,
                    color: BCTextColor.muted,
                  ),
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Nested',
          builder: (context) => BCSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                const BCText('Outer surface'),
                BCSurface(
                  variant: BCSurfaceVariant.secondary,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const BCText('Secondary surface'),
                      BCSurface(
                        variant: BCSurfaceVariant.tertiary,
                        width: double.infinity,
                        child: const BCText('Tertiary surface'),
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
