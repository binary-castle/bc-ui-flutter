import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class EmptyStateShowcaseScreen extends StatelessWidget {
  const EmptyStateShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'EmptyState',
      variants: [
        UsageVariant(
          title: 'Default',
          builder: (context) => BCEmptyState(
            icon: const Icon(Icons.notifications_none),
            title: 'No notifications yet',
            description:
                'Stay in the loop by enabling push alerts for account '
                'activity and reminders.',
            actions: [
              BCButton(
                fullWidth: true,
                onPressed: () {},
                child: const Text('Enable notifications'),
              ),
              BCButton(
                variant: BCButtonVariant.outline,
                fullWidth: true,
                onPressed: () {},
                child: const Text('Settings'),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Minimal',
          builder: (context) => const BCEmptyState(
            title: 'Inbox zero',
            description:
                "You're all caught up. New messages will appear here.",
          ),
        ),
        UsageVariant(
          title: 'Outline',
          builder: (context) => BCEmptyState(
            variant: BCEmptyStateVariant.outline,
            icon: const Icon(Icons.rocket_launch_outlined),
            title: 'Start your first automation',
            description:
                'Connect one app and create a workflow in under a minute.',
            actions: [
              BCButton(
                variant: BCButtonVariant.outline,
                onPressed: () {},
                child: const Text('Get started'),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'No search results',
          builder: (context) => BCEmptyState(
            icon: const Icon(Icons.search),
            title: 'No matches found',
            description:
                'Try another keyword, remove a filter, or clear your '
                'current search.',
            actions: [
              BCButton(
                variant: BCButtonVariant.outline,
                onPressed: () {},
                child: const Text('Clear search'),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'With avatar group',
          builder: (context) => BCEmptyState(
            illustration: const BCEmptyStateAvatarCluster(),
            title: 'No teammates yet',
            description:
                'Invite your team to collaborate on tasks, comments, and '
                'release checklists.',
            actions: [
              BCButton(
                fullWidth: true,
                startContent: const Icon(Icons.add),
                onPressed: () {},
                child: const Text('Invite members'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
