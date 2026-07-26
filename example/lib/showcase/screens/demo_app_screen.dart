import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';

/// A single realistic screen assembled entirely from bc_ui components —
/// header, card, tabs, list group, chips and bottom nav — used as the README
/// banner shot and as a "how do these fit together" reference.
class DemoAppScreen extends StatefulWidget {
  const DemoAppScreen({super.key});

  @override
  State<DemoAppScreen> createState() => _DemoAppScreenState();
}

class _DemoAppScreenState extends State<DemoAppScreen> {
  final _tabs = BCTabsController<String>(
    values: const ['week', 'month', 'year'],
  );
  int _navIndex = 0;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return Scaffold(
      backgroundColor: bc.background,
      extendBodyBehindAppBar: true,
      appBar: BCAppHeader(
        title: const Text('Overview'),
        subtitle: const Text('Tuesday, 26 July'),
        automaticallyImplyLeading: false,
        actions: [
          BCHeaderIconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          BCHeaderIconButton(
            icon: const Icon(Icons.notifications_none),
            badgeCount: 3,
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BCBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BCBottomNavItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Overview',
          ),
          BCBottomNavItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Activity',
          ),
          BCBottomNavItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Budget',
            showDot: true,
          ),
          BCBottomNavItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: ListView(
        // The body sits behind the frosted header, so it reserves the status
        // bar inset plus the toolbar itself.
        padding: EdgeInsets.fromLTRB(
          BCSpacing.md,
          MediaQuery.paddingOf(context).top +
              BCAppHeader.defaultToolbarHeight +
              BCSpacing.md,
          BCSpacing.md,
          BCSpacing.lg,
        ),
        children: [
          const _BalanceCard(),
          const SizedBox(height: BCSpacing.lg),
          BCTabs<String>(
            controller: _tabs,
            fullWidth: true,
            items: const [
              BCTabItem(value: 'week', label: 'Week'),
              BCTabItem(value: 'month', label: 'Month'),
              BCTabItem(value: 'year', label: 'Year'),
            ],
          ),
          const SizedBox(height: BCSpacing.md),
          SizedBox(
            height: 232,
            child: BCTabView<String>(
              controller: _tabs,
              children: const [
                _TransactionList(),
                _TransactionList(),
                _TransactionList(),
              ],
            ),
          ),
          const SizedBox(height: BCSpacing.lg),
          const BCText('Quick actions', type: BCTextType.h6),
          const SizedBox(height: BCSpacing.sm),
          Wrap(
            spacing: BCSpacing.sm,
            runSpacing: BCSpacing.sm,
            children: [
              BCChip(
                startContent: const Icon(Icons.bolt, size: 16),
                onPressed: () {},
                child: const Text('Pay bills'),
              ),
              BCChip(
                variant: BCChipVariant.soft,
                color: BCChipColor.success,
                onPressed: () {},
                child: const Text('Split'),
              ),
              BCChip(
                variant: BCChipVariant.tertiary,
                onPressed: () {},
                child: const Text('Request'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return BCCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BCCardHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BCCardDescription('Total balance'),
                BCChip(
                  size: BCChipSize.sm,
                  variant: BCChipVariant.soft,
                  color: BCChipColor.success,
                  startContent: const Icon(Icons.trending_up, size: 14),
                  child: const Text('+12.4%'),
                ),
              ],
            ),
          ),
          const SizedBox(height: BCSpacing.xs),
          BCCardBody(
            child: Text(
              r'$12,480.55',
              style: BCTypography.text4xl.copyWith(
                color: bc.foreground,
                fontWeight: BCTypography.bold,
                letterSpacing: BCTypography.trackingTight(BCTypography.size4xl),
              ),
            ),
          ),
          const SizedBox(height: BCSpacing.md),
          BCCardFooter(
            child: Row(
              spacing: BCSpacing.sm,
              children: [
                Expanded(
                  child: BCButton(
                    onPressed: () {},
                    startContent: const Icon(Icons.add, size: 18),
                    child: const Text('Add money'),
                  ),
                ),
                Expanded(
                  child: BCButton(
                    variant: BCButtonVariant.secondary,
                    onPressed: () {},
                    startContent: const Icon(Icons.north_east, size: 18),
                    child: const Text('Transfer'),
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

class _TransactionList extends StatelessWidget {
  const _TransactionList();

  static const _rows = [
    ('Figma', 'Design tools', r'-$15.00', 'FI', BCAvatarColor.accent),
    ('Whole Foods', 'Groceries', r'-$84.20', 'WF', BCAvatarColor.success),
    ('Payroll', 'Monthly salary', r'+$4,200.00', 'PR', BCAvatarColor.warning),
  ];

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return BCListGroup(
      children: [
        for (final (title, subtitle, amount, initials, color) in _rows)
          BCListGroupItem(
            title: title,
            description: subtitle,
            onPressed: () {},
            prefix: BCAvatar(
              size: BCAvatarSize.small,
              variant: BCAvatarVariant.soft,
              color: color,
              children: [BCAvatarFallback(initials: initials)],
            ),
            suffix: Text(
              amount,
              style: BCTypography.textSm.copyWith(
                color: amount.startsWith('+') ? bc.success : bc.foreground,
                fontWeight: BCTypography.semiBold,
              ),
            ),
          ),
      ],
    );
  }
}
