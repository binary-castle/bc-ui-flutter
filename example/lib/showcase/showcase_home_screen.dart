import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/avatar_showcase_screen.dart';
import 'package:example/showcase/badge_showcase_screen.dart';
import 'package:example/showcase/button_showcase_screen.dart';
import 'package:example/showcase/card_showcase_screen.dart';
import 'package:example/showcase/input_showcase_screen.dart';
import 'package:example/showcase/loading_showcase_screen.dart';
import 'package:example/showcase/separator_showcase_screen.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:example/showcase/skeleton_showcase_screen.dart';
import 'package:flutter/material.dart';

class ShowcaseHomeScreen extends StatelessWidget {
  const ShowcaseHomeScreen({super.key});

  static const _entries = [
    _ShowcaseEntry(
      title: 'Button',
      subtitle: 'Variants, sizes, and states',
      icon: Icons.smart_button_outlined,
      builder: _buttonShowcase,
    ),
    _ShowcaseEntry(
      title: 'Card',
      subtitle: 'Variants, layout, and nesting',
      icon: Icons.credit_card_outlined,
      builder: _cardShowcase,
    ),
    _ShowcaseEntry(
      title: 'Input',
      subtitle: 'Variants, labels, and states',
      icon: Icons.text_fields_outlined,
      builder: _inputShowcase,
    ),
    _ShowcaseEntry(
      title: 'Separator',
      subtitle: 'Variants, orientation, and thickness',
      icon: Icons.horizontal_rule,
      builder: _separatorShowcase,
    ),
    _ShowcaseEntry(
      title: 'Badge',
      subtitle: 'Sizes, variants, colors, and icons',
      icon: Icons.label_outline,
      builder: _badgeShowcase,
    ),
    _ShowcaseEntry(
      title: 'Avatar',
      subtitle: 'Image, initials, icon, and delayed fallback',
      icon: Icons.account_circle_outlined,
      builder: _avatarShowcase,
    ),
    _ShowcaseEntry(
      title: 'Loading',
      subtitle: 'Sizes, colors, and loading state',
      icon: Icons.autorenew,
      builder: _loadingShowcase,
    ),
    _ShowcaseEntry(
      title: 'Skeleton',
      subtitle: 'Shimmer, pulse, and loading placeholders',
      icon: Icons.view_day_outlined,
      builder: _skeletonShowcase,
    ),
  ];

  static Widget _buttonShowcase(BuildContext _) => const ButtonShowcaseScreen();

  static Widget _cardShowcase(BuildContext _) => const CardShowcaseScreen();

  static Widget _inputShowcase(BuildContext _) => const InputShowcaseScreen();

  static Widget _separatorShowcase(BuildContext _) =>
      const SeparatorShowcaseScreen();

  static Widget _badgeShowcase(BuildContext _) => const BadgeShowcaseScreen();

  static Widget _avatarShowcase(BuildContext _) =>
      const AvatarShowcaseScreen();

  static Widget _loadingShowcase(BuildContext _) =>
      const LoadingShowcaseScreen();

  static Widget _skeletonShowcase(BuildContext _) =>
      const SkeletonShowcaseScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BC UI Components')),
      body: ListView(
        padding: const EdgeInsets.all(ShowcaseSpacing.lg),
        children: [
          BCCard(
            child: Column(
              children: [
                for (var i = 0; i < _entries.length; i++) ...[
                  if (i > 0)
                    const BCSeparator(
                      margin: EdgeInsets.symmetric(vertical: ShowcaseSpacing.sm),
                    ),
                  _ShowcaseListTile(entry: _entries[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseEntry {
  const _ShowcaseEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

class _ShowcaseListTile extends StatelessWidget {
  const _ShowcaseListTile({required this.entry});

  final _ShowcaseEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(entry.icon),
        title: Text(entry.title),
        subtitle: Text(entry.subtitle),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: entry.builder),
          );
        },
      ),
    );
  }
}
