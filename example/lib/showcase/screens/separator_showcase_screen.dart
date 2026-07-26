import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SeparatorShowcaseScreen extends StatelessWidget {
  const SeparatorShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Separator',
      variants: [
        UsageVariant(
          title: 'Horizontal',
          builder: (context) => const Column(
            spacing: 16,
            children: [
              BCText('Above'),
              BCSeparator(),
              BCText('Between'),
              BCSeparator(variant: BCSeparatorVariant.thick),
              BCText('Below'),
            ],
          ),
        ),
        UsageVariant(
          title: 'Vertical',
          builder: (context) => const SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                BCText('Left'),
                BCSeparator(
                  orientation: BCSeparatorOrientation.vertical,
                ),
                BCText('Middle'),
                BCSeparator(
                  orientation: BCSeparatorOrientation.vertical,
                  variant: BCSeparatorVariant.thick,
                ),
                BCText('Right'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
