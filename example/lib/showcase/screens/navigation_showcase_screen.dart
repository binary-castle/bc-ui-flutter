import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class NavigationShowcaseScreen extends StatelessWidget {
  const NavigationShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'NavRail & NavDrawer',
      variants: [
        UsageVariant(
          title: 'Rail, collapsed',
          builder: (context) => const _RailCanvas(),
        ),
        UsageVariant(
          title: 'Rail, extended',
          builder: (context) => const _RailCanvas(extended: true),
        ),
        UsageVariant(
          title: 'Rail, icons only + centered',
          builder: (context) => const _RailCanvas(
            labels: BCNavRailLabels.none,
            groupAlignment: 0,
          ),
        ),
        UsageVariant(
          title: 'Rail, responsive',
          builder: (context) => const _RailCanvas(responsive: true),
        ),
        UsageVariant(
          title: 'Drawer, standard',
          builder: (context) => const _DrawerCanvas(),
        ),
        UsageVariant(
          title: 'Drawer, modal',
          builder: (context) => const _DrawerCanvas(
            variant: BCNavDrawerVariant.modal,
          ),
        ),
      ],
    );
  }
}

const _railDestinations = [
  BCNavRailDestination(
    icon: Icon(Icons.inbox_outlined),
    selectedIcon: Icon(Icons.inbox),
    label: 'Inbox',
    badgeCount: 12,
  ),
  BCNavRailDestination(
    icon: Icon(Icons.send_outlined),
    selectedIcon: Icon(Icons.send),
    label: 'Sent',
  ),
  BCNavRailDestination(
    icon: Icon(Icons.drafts_outlined),
    selectedIcon: Icon(Icons.drafts),
    label: 'Drafts',
    showDot: true,
  ),
  BCNavRailDestination(
    icon: Icon(Icons.archive_outlined),
    selectedIcon: Icon(Icons.archive),
    label: 'Archive',
  ),
];

class _RailCanvas extends StatefulWidget {
  const _RailCanvas({
    this.extended = false,
    this.labels = BCNavRailLabels.all,
    this.groupAlignment = -1,
    this.responsive = false,
  });

  final bool extended;
  final BCNavRailLabels labels;
  final double groupAlignment;

  /// Toggles [extended] from the canvas width, the way a real layout would.
  final bool responsive;

  @override
  State<_RailCanvas> createState() => _RailCanvasState();
}

class _RailCanvasState extends State<_RailCanvas> {
  int _index = 0;
  bool _manuallyExtended = false;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(BCRadius.xxxl),
      child: SizedBox(
        height: 460,
        child: ColoredBox(
          color: bc.background,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final extended = widget.responsive
                  ? _manuallyExtended
                  : widget.extended;

              return Row(
                children: [
                  BCNavRail(
                    destinations: _railDestinations,
                    selectedIndex: _index,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    extended: extended,
                    labels: widget.labels,
                    groupAlignment: widget.groupAlignment,
                    leading: widget.responsive
                        ? BCHeaderIconButton(
                            icon: Icon(
                              extended ? Icons.menu_open : Icons.menu,
                            ),
                            onPressed: () => setState(
                              () => _manuallyExtended = !_manuallyExtended,
                            ),
                          )
                        : BCFab(
                            icon: const Icon(Icons.edit),
                            size: 48,
                            onPressed: () {},
                          ),
                    trailing: BCHeaderIconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {},
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: BCText(
                        _railDestinations[_index].label,
                        type: BCTextType.h3,
                        color: BCTextColor.muted,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

const _drawerItems = [
  BCNavDrawerSection('Mail'),
  BCNavDrawerDestination(
    icon: Icon(Icons.inbox_outlined),
    selectedIcon: Icon(Icons.inbox),
    label: 'Inbox',
    badgeCount: 24,
  ),
  BCNavDrawerDestination(
    icon: Icon(Icons.star_outline),
    selectedIcon: Icon(Icons.star),
    label: 'Starred',
  ),
  BCNavDrawerDestination(
    icon: Icon(Icons.send_outlined),
    selectedIcon: Icon(Icons.send),
    label: 'Sent',
    showDot: true,
  ),
  BCNavDrawerDivider(),
  BCNavDrawerSection('Labels'),
  BCNavDrawerDestination(icon: Icon(Icons.work_outline), label: 'Work'),
  BCNavDrawerDestination(icon: Icon(Icons.home_outlined), label: 'Personal'),
  BCNavDrawerDestination(
    icon: Icon(Icons.delete_outline),
    label: 'Trash',
    isDisabled: true,
  ),
];

class _DrawerCanvas extends StatefulWidget {
  const _DrawerCanvas({this.variant = BCNavDrawerVariant.standard});

  final BCNavDrawerVariant variant;

  @override
  State<_DrawerCanvas> createState() => _DrawerCanvasState();
}

class _DrawerCanvasState extends State<_DrawerCanvas> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final isModal = widget.variant == BCNavDrawerVariant.modal;

    final drawer = BCNavDrawer(
      items: _drawerItems,
      selectedIndex: _index,
      variant: widget.variant,
      width: 280,
      // Nothing to pop inside the canvas.
      closeOnSelect: false,
      onDestinationSelected: (i) => setState(() => _index = i),
      header: const Text('Binary Castle'),
      footer: BCListGroupItem(
        title: 'Rifat Khan',
        description: 'khanmrifat7@gmail.com',
        prefix: const BCAvatar(
          size: BCAvatarSize.small,
          children: [BCAvatarFallback(initials: 'RK')],
        ),
        onPressed: () {},
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(BCRadius.xxxl),
      child: SizedBox(
        height: 520,
        child: ColoredBox(
          color: isModal ? bc.backgroundSecondary : bc.background,
          child: Row(
            children: [
              drawer,
              Expanded(
                child: Center(
                  child: BCText(
                    'Pane',
                    type: BCTextType.h4,
                    color: BCTextColor.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
