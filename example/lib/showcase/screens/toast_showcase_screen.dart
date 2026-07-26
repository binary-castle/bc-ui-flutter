import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class ToastShowcaseScreen extends StatelessWidget {
  const ToastShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Toast',
      variants: [
        UsageVariant(
          title: 'Variants',
          builder: (context) => Column(
            spacing: 12,
            children: [
              BCButton(
                variant: BCButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => BCToast.show(
                  context,
                  const BCToastData(
                    title: 'Default toast',
                    description: 'Something happened.',
                  ),
                ),
                child: const Text('Default'),
              ),
              BCButton(
                variant: BCButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => BCToast.show(
                  context,
                  const BCToastData(
                    title: 'Changes saved',
                    description: 'Your profile was updated.',
                    variant: BCToastVariant.success,
                  ),
                ),
                child: const Text('Success'),
              ),
              BCButton(
                variant: BCButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => BCToast.show(
                  context,
                  const BCToastData(
                    title: 'Storage almost full',
                    description: 'You have used 90% of your quota.',
                    variant: BCToastVariant.warning,
                  ),
                ),
                child: const Text('Warning'),
              ),
              BCButton(
                variant: BCButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => BCToast.show(
                  context,
                  const BCToastData(
                    title: 'Upload failed',
                    description: 'Check your connection and try again.',
                    variant: BCToastVariant.danger,
                  ),
                ),
                child: const Text('Danger'),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'With icon',
          builder: (context) => Column(
            spacing: 12,
            children: [
              BCButton(
                variant: BCButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => BCToast.show(
                  context,
                  const BCToastData(
                    title: 'Changes saved',
                    description: 'Your profile was updated.',
                    variant: BCToastVariant.success,
                    icon: Icon(Icons.check_circle),
                  ),
                ),
                child: const Text('Success with icon'),
              ),
              BCButton(
                variant: BCButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => BCToast.show(
                  context,
                  const BCToastData(
                    title: 'Upload failed',
                    description: 'Check your connection and try again.',
                    variant: BCToastVariant.danger,
                    icon: Icon(Icons.error_outline),
                  ),
                ),
                child: const Text('Danger with icon'),
              ),
              BCButton(
                fullWidth: true,
                onPressed: () => BCToast.show(
                  context,
                  const BCToastData(
                    title: 'New message',
                    description: 'Tap to open your inbox.',
                    icon: Icon(Icons.notifications_outlined),
                    showCloseButton: true,
                  ),
                ),
                child: const Text('Icon + close'),
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'With action',
          builder: (context) => BCButton(
            onPressed: () => BCToast.show(
              context,
              BCToastData(
                title: 'Message archived',
                variant: BCToastVariant.accent,
                actionLabel: 'Undo',
                onAction: () {},
              ),
            ),
            child: const Text('Show action toast'),
          ),
        ),
        UsageVariant(
          title: 'Persistent',
          builder: (context) => BCButton(
            variant: BCButtonVariant.outline,
            onPressed: () => BCToast.show(
              context,
              const BCToastData(
                title: 'Sticky toast',
                description: 'Stays until dismissed. Swipe down or close.',
                showCloseButton: true,
                duration: Duration.zero,
              ),
            ),
            child: const Text('Show persistent toast'),
          ),
        ),
      ],
    );
  }
}
