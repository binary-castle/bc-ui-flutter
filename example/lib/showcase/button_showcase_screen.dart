import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_common.dart';
import 'package:flutter/material.dart';

class ButtonShowcaseScreen extends StatelessWidget {
  const ButtonShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buttons')),
      body: ListView(
        padding: const EdgeInsets.all(ShowcaseSpacing.lg),
        children: [
          const ShowcaseSectionTitle('Variants — Medium'),
          ..._variantRows(BCButtonSize.medium),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Size Matrix — Primary'),
          ..._sizeRow(BCButton.primary),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Size Matrix — Secondary'),
          ..._sizeRow(BCButton.secondary),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Size Matrix — Outline'),
          ..._sizeRow(BCButton.outline),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Size Matrix — Text'),
          ..._sizeRow(BCButton.text),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('Size Matrix — Destructive'),
          ..._sizeRow(BCButton.destructive),
          const SizedBox(height: ShowcaseSpacing.xl),
          const ShowcaseSectionTitle('States'),
          BCButton.primary(
            text: 'Full Width',
            onPressed: () {},
            fullWidth: true,
          ),
          const SizedBox(height: ShowcaseSpacing.md),
          BCButton.primary(
            text: 'Loading',
            loading: true,
            fullWidth: true,
          ),
          const SizedBox(height: ShowcaseSpacing.md),
          BCButton.destructive(
            text: 'Delete',
            leading: const Icon(Icons.delete),
            onPressed: () {},
          ),
          const SizedBox(height: ShowcaseSpacing.md),
          BCButton.outline(
            text: 'With Trailing',
            trailing: const Icon(Icons.arrow_forward),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  List<Widget> _variantRows(BCButtonSize size) {
    return [
      BCButton.primary(text: 'Primary', onPressed: () {}, size: size),
      const SizedBox(height: ShowcaseSpacing.sm),
      BCButton.secondary(text: 'Secondary', onPressed: () {}, size: size),
      const SizedBox(height: ShowcaseSpacing.sm),
      BCButton.outline(text: 'Outline', onPressed: () {}, size: size),
      const SizedBox(height: ShowcaseSpacing.sm),
      BCButton.text(text: 'Text', onPressed: () {}, size: size),
      const SizedBox(height: ShowcaseSpacing.sm),
      BCButton.destructive(text: 'Destructive', onPressed: () {}, size: size),
    ];
  }

  List<Widget> _sizeRow(
    BCButton Function({
      required String text,
      VoidCallback? onPressed,
      BCButtonSize size,
    })
    factory,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: factory(
              text: 'Small',
              onPressed: () {},
              size: BCButtonSize.small,
            ),
          ),
          const SizedBox(width: ShowcaseSpacing.sm),
          Expanded(
            child: factory(
              text: 'Medium',
              onPressed: () {},
              size: BCButtonSize.medium,
            ),
          ),
          const SizedBox(width: ShowcaseSpacing.sm),
          Expanded(
            child: factory(
              text: 'Large',
              onPressed: () {},
              size: BCButtonSize.large,
            ),
          ),
        ],
      ),
    ];
  }
}
