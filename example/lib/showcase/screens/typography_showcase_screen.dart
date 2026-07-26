import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class TypographyShowcaseScreen extends StatelessWidget {
  const TypographyShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Typography',
      variants: [
        UsageVariant(
          title: 'Headings',
          builder: (context) => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              BCText('Heading 1', type: BCTextType.h1),
              BCText('Heading 2', type: BCTextType.h2),
              BCText('Heading 3', type: BCTextType.h3),
              BCText('Heading 4', type: BCTextType.h4),
              BCText('Heading 5', type: BCTextType.h5),
              BCText('Heading 6', type: BCTextType.h6),
            ],
          ),
        ),
        UsageVariant(
          title: 'Body',
          builder: (context) => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              BCText(
                'Body — The quick brown fox jumps over the lazy dog.',
              ),
              BCText(
                'Body small — The quick brown fox jumps over the lazy dog.',
                type: BCTextType.bodySm,
              ),
              BCText(
                'Body xs — The quick brown fox jumps over the lazy dog.',
                type: BCTextType.bodyXs,
              ),
              BCText(
                'Muted — Secondary information goes here.',
                color: BCTextColor.muted,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Weights & code',
          builder: (context) => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              BCText('Normal weight', weight: BCTextWeight.normal),
              BCText('Medium weight', weight: BCTextWeight.medium),
              BCText('Semibold weight', weight: BCTextWeight.semibold),
              BCText('Bold weight', weight: BCTextWeight.bold),
              BCText('flutter pub add bc_ui', type: BCTextType.code),
            ],
          ),
        ),
      ],
    );
  }
}
