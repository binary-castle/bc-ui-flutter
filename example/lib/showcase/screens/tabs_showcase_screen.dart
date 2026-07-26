import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class TabsShowcaseScreen extends StatefulWidget {
  const TabsShowcaseScreen({super.key});

  @override
  State<TabsShowcaseScreen> createState() => _TabsShowcaseScreenState();
}

class _TabsShowcaseScreenState extends State<TabsShowcaseScreen> {
  String _primary = 'music';
  String _secondary = 'overview';

  final _swipeTabs = BCTabsController<String>(
    values: const ['music', 'podcasts', 'audiobooks'],
  );

  @override
  void dispose() {
    _swipeTabs.dispose();
    super.dispose();
  }

  static const _items = [
    BCTabItem(value: 'music', label: 'Music'),
    BCTabItem(value: 'podcasts', label: 'Podcasts'),
    BCTabItem(value: 'audiobooks', label: 'Books'),
  ];

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Tabs',
      variants: [
        UsageVariant(
          title: 'Primary',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              BCTabs<String>(
                items: _items,
                value: _primary,
                onValueChange: (value) => setState(() => _primary = value),
              ),
              BCText(
                'Selected: $_primary',
                type: BCTextType.bodySm,
                color: BCTextColor.muted,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Secondary',
          builder: (context) => BCTabs<String>(
            variant: BCTabsVariant.secondary,
            items: const [
              BCTabItem(value: 'overview', label: 'Overview'),
              BCTabItem(value: 'activity', label: 'Activity'),
              BCTabItem(value: 'settings', label: 'Settings'),
            ],
            value: _secondary,
            onValueChange: (value) => setState(() => _secondary = value),
          ),
        ),
        UsageVariant(
          title: 'Swipeable',
          builder: (context) => _SwipeableTabs(controller: _swipeTabs),
        ),
        UsageVariant(
          title: 'Full width',
          builder: (context) => BCTabs<String>(
            items: _items,
            value: _primary,
            fullWidth: true,
            onValueChange: (value) => setState(() => _primary = value),
          ),
        ),
      ],
    );
  }
}

/// Bar + panels sharing one [BCTabsController]: swiping the panels switches
/// tabs and drags the indicator along with the gesture.
class _SwipeableTabs extends StatelessWidget {
  const _SwipeableTabs({required this.controller});

  final BCTabsController<String> controller;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return SizedBox(
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          BCTabs<String>(
            items: const [
              BCTabItem(value: 'music', label: 'Music'),
              BCTabItem(value: 'podcasts', label: 'Podcasts'),
              BCTabItem(value: 'audiobooks', label: 'Books'),
            ],
            controller: controller,
            fullWidth: true,
          ),
          Expanded(
            child: BCTabView<String>(
              controller: controller,
              children: [
                for (final entry in const [
                  ('Music', Icons.music_note),
                  ('Podcasts', Icons.podcasts),
                  ('Books', Icons.menu_book),
                ])
                  BCSurface(
                    variant: BCSurfaceVariant.secondary,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 12,
                        children: [
                          Icon(entry.$2, size: 32, color: bc.accent),
                          BCText(entry.$1, type: BCTextType.h5),
                          const BCText(
                            'Swipe left or right',
                            type: BCTextType.bodySm,
                            color: BCTextColor.muted,
                          ),
                        ],
                      ),
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
