import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class ListGroupShowcaseScreen extends StatelessWidget {
  const ListGroupShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'ListGroup',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => BCListGroup(
            children: [
              BCListGroupItem(
                prefix: const Icon(Icons.person_outline),
                title: 'Account',
                description: 'Profile, security, and sign-in',
                suffix: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {},
              ),
              BCListGroupItem(
                prefix: const Icon(Icons.notifications_outlined),
                title: 'Notifications',
                description: 'Alerts and sounds',
                suffix: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {},
              ),
              BCListGroupItem(
                prefix: const Icon(Icons.lock_outline),
                title: 'Privacy',
                suffix: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'With controls',
          builder: (context) => const _ControlListGroup(),
        ),
      ],
    );
  }
}

class _ControlListGroup extends StatefulWidget {
  const _ControlListGroup();

  @override
  State<_ControlListGroup> createState() => _ControlListGroupState();
}

class _ControlListGroupState extends State<_ControlListGroup> {
  bool _wifi = true;
  bool _bluetooth = false;

  @override
  Widget build(BuildContext context) {
    return BCListGroup(
      children: [
        BCListGroupItem(
          prefix: const Icon(Icons.wifi),
          title: 'Wi-Fi',
          suffix: BCSwitch(
            isSelected: _wifi,
            onSelectedChange: (value) => setState(() => _wifi = value),
          ),
        ),
        BCListGroupItem(
          prefix: const Icon(Icons.bluetooth),
          title: 'Bluetooth',
          suffix: BCSwitch(
            isSelected: _bluetooth,
            onSelectedChange: (value) => setState(() => _bluetooth = value),
          ),
        ),
        const BCListGroupItem(
          prefix: Icon(Icons.battery_full_outlined),
          title: 'Battery',
          description: 'Disabled row',
          isDisabled: true,
        ),
      ],
    );
  }
}
