import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:flutter/material.dart';

class AvatarShowcaseScreen extends StatelessWidget {
  const AvatarShowcaseScreen({super.key});

  static const _sampleImageUrl = 'https://i.pravatar.cc/150?img=12';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avatars')),
      body: ListView(
        padding: const EdgeInsets.all(ShowcaseSpacing.lg),
        children: [
          const ShowcaseSectionTitle('Sizes'),
          BCCard(
            child: Row(
              children: [
                BCAvatar.withInitials('SM', size: BCAvatarSize.small),
                const SizedBox(width: ShowcaseSpacing.md),
                BCAvatar.withInitials('MD', size: BCAvatarSize.medium),
                const SizedBox(width: ShowcaseSpacing.md),
                BCAvatar.withInitials('LG', size: BCAvatarSize.large),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Variants'),
          BCCard(
            child: Row(
              children: [
                BCAvatar.withInitials(
                  'DF',
                  variant: BCAvatarVariant.defaultVariant,
                ),
                const SizedBox(width: ShowcaseSpacing.md),
                BCAvatar.withInitials('SF', variant: BCAvatarVariant.soft),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Colors'),
          BCCard(
            child: Wrap(
              spacing: ShowcaseSpacing.md,
              runSpacing: ShowcaseSpacing.md,
              children: [
                for (final color in BCAvatarColor.values)
                  BCAvatar.withInitials(
                    _colorInitials(color),
                    color: color,
                    variant: BCAvatarVariant.soft,
                  ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Image'),
          BCCard(
            child: BCAvatar(
              children: [
                BCAvatarImage.network(_sampleImageUrl),
                const BCAvatarFallback(initials: 'IM'),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Initials Fallback'),
          BCCard(child: BCAvatar.withInitials('JD')),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Icon Fallback'),
          const BCCard(
            child: BCAvatar(children: [BCAvatarFallback()]),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Delayed Fallback'),
          BCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BCCardDescription(
                  'Fallback appears after 600ms while the image loads.',
                ),
                const SizedBox(height: ShowcaseSpacing.md),
                BCAvatar(
                  children: [
                    BCAvatarImage.network(_sampleImageUrl),
                    const BCAvatarFallback(initials: 'DL', delayMs: 600),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Broken Image'),
          BCCard(
            child: BCAvatar(
              children: [
                BCAvatarImage.network('https://example.invalid/avatar.png'),
                const BCAvatarFallback(initials: 'ER'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _colorInitials(BCAvatarColor color) {
    return switch (color) {
      BCAvatarColor.accent => 'AC',
      BCAvatarColor.defaultColor => 'DF',
      BCAvatarColor.success => 'OK',
      BCAvatarColor.warning => 'WN',
      BCAvatarColor.danger => 'ER',
    };
  }
}
