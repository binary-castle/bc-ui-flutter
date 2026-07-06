import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:flutter/material.dart';

class SkeletonShowcaseScreen extends StatefulWidget {
  const SkeletonShowcaseScreen({super.key});

  @override
  State<SkeletonShowcaseScreen> createState() => _SkeletonShowcaseScreenState();
}

class _SkeletonShowcaseScreenState extends State<SkeletonShowcaseScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Skeleton')),
      body: ListView(
        padding: const EdgeInsets.all(ShowcaseSpacing.lg),
        children: [
          const ShowcaseSectionTitle('Variants'),
          const BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BCSkeleton(
                  variant: BCSkeletonVariant.shimmer,
                  width: double.infinity,
                  height: 16,
                ),
                SizedBox(height: ShowcaseSpacing.sm),
                BCSkeleton(
                  variant: BCSkeletonVariant.pulse,
                  width: double.infinity,
                  height: 16,
                ),
                SizedBox(height: ShowcaseSpacing.sm),
                BCSkeleton(
                  variant: BCSkeletonVariant.none,
                  width: double.infinity,
                  height: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Shape Variations'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BCSkeleton(width: double.infinity, height: 16),
                const SizedBox(height: ShowcaseSpacing.sm),
                const BCSkeleton(width: 240, height: 16),
                const SizedBox(height: ShowcaseSpacing.sm),
                const BCSkeleton(width: 120, height: 16),
                const SizedBox(height: ShowcaseSpacing.md),
                BCSkeleton(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(ShowcaseRadius.full),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Custom Animation'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BCSkeleton(
                  width: double.infinity,
                  height: 64,
                  variant: BCSkeletonVariant.shimmer,
                  animation: BCSkeletonAnimation(
                    shimmer: BCSkeletonShimmerAnimation(
                      duration: Duration(milliseconds: 2000),
                      speed: 2,
                    ),
                  ),
                ),
                const SizedBox(height: ShowcaseSpacing.md),
                const BCSkeleton(
                  width: double.infinity,
                  height: 64,
                  variant: BCSkeletonVariant.pulse,
                  animation: BCSkeletonAnimation(
                    pulse: BCSkeletonPulseAnimation(
                      duration: Duration(milliseconds: 500),
                      minOpacity: 0.1,
                      maxOpacity: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: ShowcaseSpacing.md),
                BCSkeleton(
                  width: double.infinity,
                  height: 64,
                  variant: BCSkeletonVariant.shimmer,
                  animation: BCSkeletonAnimation(
                    shimmer: BCSkeletonShimmerAnimation(
                      highlightColor: colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Loading Toggle'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('isLoading'),
                    const Spacer(),
                    Switch(
                      value: _isLoading,
                      onChanged: (value) => setState(() => _isLoading = value),
                    ),
                  ],
                ),
                const SizedBox(height: ShowcaseSpacing.md),
                BCSkeleton(
                  isLoading: _isLoading,
                  width: double.infinity,
                  height: 120,
                  borderRadius: BorderRadius.circular(ShowcaseRadius.lg),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(ShowcaseRadius.lg),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Loaded content'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Profile Card Example'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BCSkeleton(
                      isLoading: _isLoading,
                      width: 40,
                      height: 40,
                      borderRadius: BorderRadius.circular(ShowcaseRadius.full),
                      child: BCAvatar.withInitials('JD'),
                    ),
                    const SizedBox(width: ShowcaseSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BCSkeleton(
                            isLoading: _isLoading,
                            width: 128,
                            height: 12,
                            child: Text(
                              'John Doe',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(height: ShowcaseSpacing.xs),
                          BCSkeleton(
                            isLoading: _isLoading,
                            width: 96,
                            height: 12,
                            child: Text(
                              '@johndoe',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ShowcaseSpacing.md),
                BCSkeleton(
                  isLoading: _isLoading,
                  width: double.infinity,
                  height: 160,
                  borderRadius: BorderRadius.circular(ShowcaseRadius.lg),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(ShowcaseRadius.lg),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined, size: 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
