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

  void _showForm(BuildContext context) {
    BCDialog.show<void>(
      context,
      builder: (dialogContext) => const _ProfileFormDialog(),
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
        UsageVariant(
          title: 'Form dialog',
          builder: (context) => BCButton(
            variant: BCButtonVariant.secondary,
            onPressed: () => _showForm(context),
            child: const Text('Edit profile'),
          ),
        ),
      ],
    );
  }
}

/// Six fields in a modal — enough that the keyboard would cover the lower
/// half of them. Focusing one scrolls it into the band above the keyboard,
/// and the whole dialog can be swiped down to dismiss once it fits again.
class _ProfileFormDialog extends StatefulWidget {
  const _ProfileFormDialog();

  @override
  State<_ProfileFormDialog> createState() => _ProfileFormDialogState();
}

class _ProfileFormDialogState extends State<_ProfileFormDialog> {
  final _controllers = List.generate(5, (_) => TextEditingController());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _field(String label, String hint, TextEditingController c) {
    return BCTextField(
      children: [
        BCTextFieldLabel(label),
        BCTextFieldInput(controller: c, hintText: hint),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BCDialogContent(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const BCDialogTitle('Edit profile'),
          _field('Full name', 'Ada Lovelace', _controllers[0]),
          _field('Email', 'ada@example.com', _controllers[1]),
          _field('Company', 'Analytical Engines Ltd', _controllers[2]),
          _field('Job title', 'Mathematician', _controllers[3]),
          _field('Website', 'https://example.com', _controllers[4]),
          const BCTextField(
            children: [
              BCTextFieldLabel('Password'),
              BCPasswordInput(placeholder: 'Enter password'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              BCButton(
                variant: BCButtonVariant.ghost,
                size: BCButtonSize.sm,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              BCButton(
                size: BCButtonSize.sm,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
