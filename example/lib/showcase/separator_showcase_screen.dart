import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:flutter/material.dart';

class SeparatorShowcaseScreen extends StatelessWidget {
  const SeparatorShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Separator')),
      body: ListView(
        padding: const EdgeInsets.all(ShowcaseSpacing.lg),
        children: [
          const ShowcaseSectionTitle('In action'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BCCardTitle('BC UI'),
                const SizedBox(height: ShowcaseSpacing.xs),
                const BCCardDescription(
                  'Beautiful, fast and modern Flutter UI library.',
                ),
                const BCSeparator(
                  margin: EdgeInsets.symmetric(vertical: ShowcaseSpacing.md),
                ),
                SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      Text('Blog', style: _labelStyle(context)),
                      const BCSeparator(
                        orientation: BCSeparatorOrientation.vertical,
                        margin: EdgeInsets.symmetric(
                          horizontal: ShowcaseSpacing.md,
                        ),
                      ),
                      Text('Docs', style: _labelStyle(context)),
                      const BCSeparator(
                        orientation: BCSeparatorOrientation.vertical,
                        margin: EdgeInsets.symmetric(
                          horizontal: ShowcaseSpacing.md,
                        ),
                      ),
                      Text('Source', style: _labelStyle(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Variants'),
          const BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thin (default)'),
                BCSeparator(
                  margin: EdgeInsets.symmetric(vertical: ShowcaseSpacing.sm),
                ),
                Text('Thick'),
                BCSeparator(
                  variant: BCSeparatorVariant.thick,
                  margin: EdgeInsets.symmetric(vertical: ShowcaseSpacing.sm),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Orientation'),
          const BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Horizontal'),
                BCSeparator(
                  margin: EdgeInsets.symmetric(vertical: ShowcaseSpacing.sm),
                ),
                Text('Vertical'),
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Text('Left'),
                      BCSeparator(
                        orientation: BCSeparatorOrientation.vertical,
                        margin: EdgeInsets.symmetric(
                          horizontal: ShowcaseSpacing.md,
                        ),
                      ),
                      Text('Right'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Custom thickness'),
          const BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BCSeparator(
                  thickness: 1,
                  margin: EdgeInsets.symmetric(vertical: ShowcaseSpacing.sm),
                ),
                BCSeparator(
                  thickness: 2,
                  margin: EdgeInsets.symmetric(vertical: ShowcaseSpacing.sm),
                ),
                BCSeparator(
                  thickness: 5,
                  margin: EdgeInsets.symmetric(vertical: ShowcaseSpacing.sm),
                ),
                BCSeparator(
                  thickness: 10,
                  margin: EdgeInsets.symmetric(vertical: ShowcaseSpacing.sm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static TextStyle _labelStyle(BuildContext context) {
    return (context.text.bodyMedium ?? const TextStyle()).copyWith(
      color: context.colors.onSurfaceVariant,
    );
  }
}
