import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SwitchShowcaseScreen extends StatefulWidget {
  const SwitchShowcaseScreen({super.key});

  @override
  State<SwitchShowcaseScreen> createState() => _SwitchShowcaseScreenState();
}

class _SwitchShowcaseScreenState extends State<SwitchShowcaseScreen> {
  bool _basic = true;
  bool _withIcons = false;

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Switch',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => BCSwitch(
            isSelected: _basic,
            onSelectedChange: (value) => setState(() => _basic = value),
          ),
        ),
        UsageVariant(
          title: 'With content',
          builder: (context) => BCSwitch(
            isSelected: _withIcons,
            onSelectedChange: (value) => setState(() => _withIcons = value),
            startContent: const Icon(
              Icons.light_mode,
              size: 12,
              color: Color(0xFFFCFCFC),
            ),
            endContent: Icon(
              Icons.dark_mode,
              size: 12,
              color: context.bcTheme.muted,
            ),
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              BCSwitch(isSelected: true, isDisabled: true),
              BCSwitch(isSelected: false, isDisabled: true),
            ],
          ),
        ),
      ],
    );
  }
}
