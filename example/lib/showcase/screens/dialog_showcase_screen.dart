import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class DialogShowcaseScreen extends StatelessWidget {
  const DialogShowcaseScreen({super.key});

  void _showBasic(BuildContext context) {
    BCDialog.show<void>(
      context,
      builder: (dialogContext) => BCDialogContent(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            const BCDialogTitle('Delete file?'),
            const BCDialogDescription(
              'This action cannot be undone. The file will be permanently '
              'removed from your workspace.',
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                BCButton(
                  variant: BCButtonVariant.ghost,
                  size: BCButtonSize.sm,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                BCButton(
                  variant: BCButtonVariant.danger,
                  size: BCButtonSize.sm,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWithClose(BuildContext context) {
    BCDialog.show<void>(
      context,
      builder: (dialogContext) => const BCDialogContent(
        width: double.infinity,
        showCloseButton: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            BCDialogTitle('About this app'),
            BCDialogDescription(
              'Built with bc_ui — a Flutter port of the heroui-native '
              'design system.',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Dialog',
      variants: [
        UsageVariant(
          title: 'Confirm dialog',
          builder: (context) => BCButton(
            onPressed: () => _showBasic(context),
            child: const Text('Open dialog'),
          ),
        ),
        UsageVariant(
          title: 'With close button',
          builder: (context) => BCButton(
            variant: BCButtonVariant.secondary,
            onPressed: () => _showWithClose(context),
            child: const Text('Open dialog'),
          ),
        ),
      ],
    );
  }
}
