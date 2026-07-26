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
