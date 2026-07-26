import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class RatingShowcaseScreen extends StatefulWidget {
  const RatingShowcaseScreen({super.key});

  @override
  State<RatingShowcaseScreen> createState() => _RatingShowcaseScreenState();
}

class _RatingShowcaseScreenState extends State<RatingShowcaseScreen> {
  double _basic = 3;
  double _maxValue = 6;

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Rating',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              BCRating(
                value: _basic,
                onChanged: (v) => setState(() => _basic = v),
              ),
              BCText(
                'Rating: ${_basic.toInt()}',
                color: BCTextColor.muted,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Sizes',
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              for (final entry in const [
                ('Small', BCRatingSize.sm),
                ('Medium', BCRatingSize.md),
                ('Large', BCRatingSize.lg),
              ])
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    BCText(entry.$1, color: BCTextColor.muted),
                    BCRating(value: 4, size: entry.$2),
                  ],
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Read-only fractional',
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              for (final v in const [1.5, 2.3, 3.7, 4.2, 4.8])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    BCRating(value: v),
                    BCText(v.toString(), color: BCTextColor.muted),
                  ],
                ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Max value',
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              BCRating(
                value: _maxValue,
                max: 10,
                size: BCRatingSize.sm,
                onChanged: (v) => setState(() => _maxValue = v),
              ),
              BCText(
                '${_maxValue.toInt()} / 10',
                color: BCTextColor.muted,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Custom icon',
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              BCRating(
                value: 3,
                icon: Icons.favorite,
                color: context.bcTheme.danger,
              ),
              BCRating(
                value: 3.5,
                icon: Icons.favorite,
                color: context.bcTheme.danger,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
