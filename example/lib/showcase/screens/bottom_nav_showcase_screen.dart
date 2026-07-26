import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class BottomNavShowcaseScreen extends StatelessWidget {
  const BottomNavShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'BottomNav',
      variants: [
        UsageVariant(
          title: 'Standard',
          builder: (context) => const _NavCanvas(
            variant: BCBottomNavVariant.standard,
          ),
        ),
        UsageVariant(
          title: 'Floating',
          builder: (context) => const _NavCanvas(
            variant: BCBottomNavVariant.floating,
          ),
        ),
        UsageVariant(
          title: 'With badges',
          builder: (context) => const _NavCanvas(
            variant: BCBottomNavVariant.standard,
            withBadges: true,
          ),
        ),
        UsageVariant(
          title: 'Icons only',
          builder: (context) => const _NavCanvas(
            variant: BCBottomNavVariant.floating,
            labels: BCBottomNavLabels.none,
          ),
        ),
        UsageVariant(
          title: 'Labels when selected',
          builder: (context) => const _NavCanvas(
            variant: BCBottomNavVariant.standard,
            labels: BCBottomNavLabels.selected,
          ),
        ),
      ],
    );
  }
}

/// A mini phone-screen canvas with content + a live bottom nav pinned to it.
class _NavCanvas extends StatefulWidget {
  const _NavCanvas({
    required this.variant,
    this.labels = BCBottomNavLabels.all,
    this.withBadges = false,
  });

  final BCBottomNavVariant variant;
  final BCBottomNavLabels labels;
  final bool withBadges;

  @override
  State<_NavCanvas> createState() => _NavCanvasState();
}

class _NavCanvasState extends State<_NavCanvas> {
  int _index = 0;

  static const _labels = ['Home', 'Search', 'Inbox', 'Profile'];

  List<BCBottomNavItem> get _items => [
        const BCBottomNavItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BCBottomNavItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BCBottomNavItem(
          icon: const Icon(Icons.mail_outline),
          activeIcon: const Icon(Icons.mail),
          label: 'Inbox',
          badgeCount: widget.withBadges ? 5 : null,
        ),
        BCBottomNavItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: 'Profile',
          showDot: widget.withBadges,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(BCRadius.xxxl),
      child: SizedBox(
        height: 520,
        child: ColoredBox(
          color: bc.background,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: BCText(
                    _labels[_index],
                    type: BCTextType.h3,
                    color: BCTextColor.muted,
                  ),
                ),
              ),
              BCBottomNav(
                items: _items,
                currentIndex: _index,
                variant: widget.variant,
                labels: widget.labels,
                onTap: (i) => setState(() => _index = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
