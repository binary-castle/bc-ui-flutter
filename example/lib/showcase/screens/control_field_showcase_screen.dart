import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class ControlFieldShowcaseScreen extends StatefulWidget {
  const ControlFieldShowcaseScreen({super.key});

  @override
  State<ControlFieldShowcaseScreen> createState() =>
      _ControlFieldShowcaseScreenState();
}

class _ControlFieldShowcaseScreenState
    extends State<ControlFieldShowcaseScreen> {
  bool _notifications = true;
  bool _terms = false;

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'ControlField',
      variants: [
        UsageVariant(
          title: 'With switch',
          builder: (context) => BCControlField(
            control: BCSwitch(
              isSelected: _notifications,
              onSelectedChange: (value) =>
                  setState(() => _notifications = value),
            ),
            label: 'Push notifications',
            description: 'Get notified when something happens.',
            controlAtEnd: true,
            onPressed: () =>
                setState(() => _notifications = !_notifications),
          ),
        ),
        UsageVariant(
          title: 'With checkbox',
          builder: (context) => BCControlField(
            control: BCCheckbox(
              isSelected: _terms,
              onSelectedChange: (value) => setState(() => _terms = value),
            ),
            label: 'Accept terms',
            description: 'You agree to our terms and privacy policy.',
            onPressed: () => setState(() => _terms = !_terms),
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => BCControlField(
            control: const BCSwitch(isSelected: true),
            label: 'Disabled field',
            description: 'This row cannot be toggled.',
            controlAtEnd: true,
            isDisabled: true,
          ),
        ),
      ],
    );
  }
}
