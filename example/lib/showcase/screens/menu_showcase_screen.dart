import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class MenuShowcaseScreen extends StatelessWidget {
  const MenuShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Menu',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => BCMenu(
            trigger: (context, controller) => BCButton(
              variant: BCButtonVariant.secondary,
              onPressed: controller.toggle,
              endContent: const Icon(Icons.keyboard_arrow_down),
              child: const Text('Actions'),
            ),
            children: [
              BCMenuItem(
                title: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onSelected: () {},
              ),
              BCMenuItem(
                title: 'Duplicate',
                icon: const Icon(Icons.copy_outlined),
                onSelected: () {},
              ),
              BCMenuItem(
                title: 'Share',
                description: 'Send a link to this file',
                icon: const Icon(Icons.share_outlined),
                onSelected: () {},
              ),
              const BCMenuSeparator(),
              BCMenuItem(
                title: 'Delete',
                icon: const Icon(Icons.delete_outline),
                variant: BCMenuItemVariant.danger,
                onSelected: () {},
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'With sections',
          builder: (context) => BCMenu(
            trigger: (context, controller) => BCButton(
              isIconOnly: true,
              variant: BCButtonVariant.tertiary,
              onPressed: controller.toggle,
              child: const Icon(Icons.more_horiz),
            ),
            children: [
              const BCMenuLabel('Account'),
              BCMenuItem(
                title: 'Profile',
                icon: const Icon(Icons.person_outline),
                onSelected: () {},
              ),
              BCMenuItem(
                title: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onSelected: () {},
              ),
              const BCMenuSeparator(),
              const BCMenuLabel('Workspace'),
              BCMenuItem(
                title: 'Members',
                icon: const Icon(Icons.group_outlined),
                onSelected: () {},
              ),
              BCMenuItem(
                title: 'Disabled item',
                icon: const Icon(Icons.block_outlined),
                isDisabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
