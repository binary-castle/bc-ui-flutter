import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SkeletonShowcaseScreen extends StatefulWidget {
  const SkeletonShowcaseScreen({super.key});

  @override
  State<SkeletonShowcaseScreen> createState() =>
      _SkeletonShowcaseScreenState();
}

class _SkeletonShowcaseScreenState extends State<SkeletonShowcaseScreen> {
  bool _isLoading = true;

  Widget _skeletonRow() {
    return const Row(
      spacing: 12,
      children: [
        BCSkeleton(
          width: 48,
          height: 48,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        Expanded(
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BCSkeleton(width: double.infinity, height: 14),
              BCSkeleton(width: 160, height: 14),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Skeleton',
      variants: [
        UsageVariant(
          title: 'Shimmer',
          builder: (context) => _skeletonRow(),
        ),
        UsageVariant(
          title: 'Pulse',
          builder: (context) => const BCSkeleton(
            variant: BCSkeletonVariant.pulse,
            width: double.infinity,
            height: 96,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        UsageVariant(
          title: 'Text',
          builder: (context) => Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Every placeholder carries the text it stands in for, so the
              // toggle swaps the whole block at once and nothing moves: each
              // line already occupies the line box of its own type.
              BCSkeletonGroup(
                isLoading: _isLoading,
                child: const Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BCSkeleton.text(
                      type: BCTextType.h4,
                      child: BCText(
                        'Reading the room',
                        type: BCTextType.h4,
                      ),
                    ),
                    BCSkeleton.text(
                      lines: 3,
                      child: BCText(
                        'A text skeleton takes the line box of the type it '
                        'stands in for, so the paragraph it replaces lands '
                        'without shifting anything under it.',
                      ),
                    ),
                    BCSkeleton.text(
                      lines: 2,
                      type: BCTextType.bodySm,
                      child: BCText(
                        'Small print sits on a tighter line box, so its '
                        'placeholder is shorter and sits closer together.',
                        type: BCTextType.bodySm,
                      ),
                    ),
                  ],
                ),
              ),
              BCButton(
                variant: BCButtonVariant.secondary,
                onPressed: () => setState(() => _isLoading = !_isLoading),
                child: Text(_isLoading ? 'Show content' : 'Show skeleton'),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Group',
          builder: (context) => Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BCSkeletonGroup(
                isLoading: _isLoading,
                child: Column(
                  spacing: 12,
                  children: [
                    _skeletonRow(),
                    _skeletonRow(),
                  ],
                ),
              ),
              BCButton(
                variant: BCButtonVariant.secondary,
                onPressed: () => setState(() => _isLoading = !_isLoading),
                child: Text(_isLoading ? 'Show content' : 'Show skeleton'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
