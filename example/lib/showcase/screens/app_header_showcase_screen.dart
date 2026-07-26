import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class AppHeaderShowcaseScreen extends StatelessWidget {
  const AppHeaderShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'AppHeader',
      variants: [
        UsageVariant(
          title: 'Blurred',
          builder: (context) => const _HeaderCanvas(
            header: BCAppHeader(
              title: Text('Inbox'),
              subtitle: Text('12 unread'),
              actions: [
                BCHeaderIconButton(
                  icon: Icon(Icons.search),
                  onPressed: _noop,
                ),
                BCHeaderIconButton(
                  icon: Icon(Icons.notifications_none),
                  badgeCount: 3,
                  onPressed: _noop,
                ),
              ],
            ),
          ),
        ),
        UsageVariant(
          title: 'Solid',
          builder: (context) => const _HeaderCanvas(
            header: BCAppHeader(
              variant: BCAppHeaderVariant.solid,
              title: Text('Settings'),
              centerTitle: true,
              leading: BCHeaderIconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                iconSize: 20,
                onPressed: _noop,
              ),
              actions: [
                BCHeaderIconButton(icon: Icon(Icons.more_horiz), onPressed: _noop),
              ],
            ),
          ),
        ),
        UsageVariant(
          title: 'Transparent over hero',
          builder: (context) => const _HeaderCanvas(
            hero: true,
            header: BCAppHeader(
              variant: BCAppHeaderVariant.transparent,
              showSeparator: false,
              foregroundColor: _onHero,
              title: Text('Trip to Kyoto'),
              subtitle: Text('3 nights · April'),
              leading: BCHeaderIconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                iconSize: 20,
                filled: true,
                backgroundColor: _heroScrim,
                onPressed: _noop,
              ),
              actions: [
                BCHeaderIconButton(
                  icon: Icon(Icons.favorite_border),
                  filled: true,
                  backgroundColor: _heroScrim,
                  onPressed: _noop,
                ),
                BCHeaderIconButton(
                  icon: Icon(Icons.ios_share),
                  filled: true,
                  backgroundColor: _heroScrim,
                  onPressed: _noop,
                ),
              ],
            ),
          ),
        ),
        UsageVariant(
          title: 'Transparent, no hero',
          builder: (context) => const _HeaderCanvas(
            header: BCAppHeader(
              variant: BCAppHeaderVariant.transparent,
              showSeparator: false,
              title: Text('Get started'),
              leading: BCHeaderIconButton(
                icon: Icon(Icons.close),
                onPressed: _noop,
              ),
            ),
          ),
        ),
        UsageVariant(
          title: 'Floating',
          builder: (context) => const _HeaderCanvas(
            header: BCAppHeader(
              variant: BCAppHeaderVariant.floating,
              title: Text('Discover'),
              leading: BCHeaderIconButton(
                icon: Icon(Icons.menu),
                onPressed: _noop,
              ),
              actions: [
                BCHeaderIconButton(icon: Icon(Icons.tune), onPressed: _noop),
              ],
            ),
          ),
        ),
        UsageVariant(
          title: 'Materialize on scroll',
          builder: (context) => const _HeaderCanvas(
            hero: true,
            header: BCAppHeader(
              materializeOnScroll: true,
              title: Text('Trip to Kyoto'),
              leading: BCHeaderIconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                iconSize: 20,
                filled: true,
                backgroundColor: _heroScrim,
                onPressed: _noop,
              ),
            ),
          ),
        ),
        UsageVariant(
          title: 'With tabs',
          builder: (context) => const _TabbedHeaderCanvas(),
        ),
        UsageVariant(
          title: 'Large title (sliver)',
          builder: (context) => const _LargeTitleCanvas(),
        ),
      ],
    );
  }
}

void _noop() {}

/// Fixed colors for the hero variants — a real screen would layer these over
/// a photo, where the theme foreground is not guaranteed to be legible.
const Color _onHero = Color(0xFFFFFFFF);
const Color _heroScrim = Color(0x40000000);

/// A mini phone-screen canvas: scrollable content with the header layered
/// over it, so the blur and the scroll-under separator are both visible.
class _HeaderCanvas extends StatelessWidget {
  const _HeaderCanvas({required this.header, this.hero = false, this.body});

  final PreferredSizeWidget header;

  /// Puts a gradient hero image behind the header instead of a plain list.
  final bool hero;

  /// Replaces the default scrolling list under the header.
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(BCRadius.xxxl),
      child: SizedBox(
        height: 520,
        // The canvas is not the real screen top — drop the device inset so
        // the header does not reserve room for a status bar here.
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Scaffold(
            backgroundColor: bc.background,
            extendBodyBehindAppBar: true,
            appBar: header,
            body: body ??
                _CanvasContent(
                  hero: hero,
                  // Content starts under the translucent header; the hero
                  // fills that space itself, a plain list has to reserve it.
                  topInset: hero ? 0 : header.preferredSize.height,
                ),
          ),
        ),
      ),
    );
  }
}

class _CanvasContent extends StatelessWidget {
  const _CanvasContent({this.hero = false, this.topInset = 0});

  final bool hero;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (hero)
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bc.accent, const Color(0xFF1E1B4B)],
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            BCSpacing.md,
            topInset + BCSpacing.md,
            BCSpacing.md,
            BCSpacing.md,
          ),
          child: Column(
            spacing: BCSpacing.sm,
            children: [
              for (var i = 0; i < 10; i++)
                BCSurface(
                  variant: BCSurfaceVariant.secondary,
                  padding: const EdgeInsets.all(BCSpacing.md),
                  child: Row(
                    spacing: BCSpacing.md,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: i.isEven ? bc.accentSoft : bc.successSoft,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BCText('Item ${i + 1}', type: BCTextType.h6),
                            const BCText(
                              'Scroll to see the header react',
                              type: BCTextType.bodyXs,
                              color: BCTextColor.muted,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Header with a tab strip docked underneath it.
class _TabbedHeaderCanvas extends StatefulWidget {
  const _TabbedHeaderCanvas();

  @override
  State<_TabbedHeaderCanvas> createState() => _TabbedHeaderCanvasState();
}

class _TabbedHeaderCanvasState extends State<_TabbedHeaderCanvas> {
  final _tabs = BCTabsController<String>(
    values: const ['all', 'open', 'done'],
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = BCAppHeader(
      title: const Text('Orders'),
      actions: [
        BCHeaderIconButton(icon: const Icon(Icons.search), onPressed: _noop),
      ],
      bottomHeight: 56,
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(
          BCSpacing.md,
          0,
          BCSpacing.md,
          BCSpacing.sm,
        ),
        child: BCTabs<String>(
          fullWidth: true,
          controller: _tabs,
          items: const [
            BCTabItem(value: 'all', label: 'All'),
            BCTabItem(value: 'open', label: 'Open'),
            BCTabItem(value: 'done', label: 'Done'),
          ],
        ),
      ),
    );

    // Panels swipe horizontally under the header; the tab indicator follows.
    return _HeaderCanvas(
      header: header,
      body: BCTabView<String>(
        controller: _tabs,
        children: [
          for (var i = 0; i < 3; i++)
            _CanvasContent(topInset: header.preferredSize.height),
        ],
      ),
    );
  }
}

/// iOS-style large title collapsing into the compact toolbar.
class _LargeTitleCanvas extends StatelessWidget {
  const _LargeTitleCanvas();

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(BCRadius.xxxl),
      child: SizedBox(
        height: 520,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Scaffold(
            backgroundColor: bc.background,
            body: CustomScrollView(
              slivers: [
                BCSliverAppHeader(
                  largeTitle: const Text('Library'),
                  automaticallyImplyLeading: false,
                  actions: [
                    BCHeaderIconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _noop,
                    ),
                  ],
                ),
                SliverList.builder(
                  itemCount: 12,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(
                      BCSpacing.md,
                      0,
                      BCSpacing.md,
                      BCSpacing.sm,
                    ),
                    child: BCSurface(
                      variant: BCSurfaceVariant.secondary,
                      child: BCText('Album ${index + 1}'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
