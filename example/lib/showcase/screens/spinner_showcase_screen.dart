import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SpinnerShowcaseScreen extends StatefulWidget {
  const SpinnerShowcaseScreen({super.key});

  @override
  State<SpinnerShowcaseScreen> createState() => _SpinnerShowcaseScreenState();
}

class _SpinnerShowcaseScreenState extends State<SpinnerShowcaseScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Spinner',
      variants: [
        UsageVariant(
          title: 'Sizes',
          builder: (context) => const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              BCSpinner(size: BCSpinnerSize.sm),
              BCSpinner(size: BCSpinnerSize.md),
              BCSpinner(size: BCSpinnerSize.lg),
            ],
          ),
        ),
        UsageVariant(
          title: 'Colors',
          builder: (context) => const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              BCSpinner(color: BCSpinnerColor.defaultColor),
              BCSpinner(color: BCSpinnerColor.success),
              BCSpinner(color: BCSpinnerColor.warning),
              BCSpinner(color: BCSpinnerColor.danger),
            ],
          ),
        ),
        UsageVariant(
          title: 'Loading state',
          builder: (context) => Column(
            spacing: 24,
            children: [
              BCSpinner(size: BCSpinnerSize.lg, isLoading: _isLoading),
              BCButton(
                variant: BCButtonVariant.secondary,
                onPressed: () => setState(() => _isLoading = !_isLoading),
                child: Text(_isLoading ? 'Stop' : 'Start'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
