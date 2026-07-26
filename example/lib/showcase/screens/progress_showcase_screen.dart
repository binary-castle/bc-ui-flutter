import 'dart:async';

import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class ProgressShowcaseScreen extends StatelessWidget {
  const ProgressShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Progress & Loading',
      variants: [
        UsageVariant(
          title: 'Linear determinate',
          builder: (context) => const _Ticker(
            builder: _linearDeterminate,
          ),
        ),
        UsageVariant(
          title: 'Linear indeterminate',
          builder: (context) => const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 24,
            children: [
              BCProgress(size: BCProgressSize.sm),
              BCProgress(label: 'Syncing mailboxes'),
              BCProgress(size: BCProgressSize.lg, color: BCProgressColor.success),
            ],
          ),
        ),
        UsageVariant(
          title: 'Colors',
          builder: (context) => const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              BCProgress(value: 0.85, label: 'Storage', showValueLabel: true),
              BCProgress(
                value: 0.62,
                color: BCProgressColor.success,
                label: 'Uploads',
                showValueLabel: true,
              ),
              BCProgress(
                value: 0.4,
                color: BCProgressColor.warning,
                label: 'Quota',
                showValueLabel: true,
              ),
              BCProgress(
                value: 0.18,
                color: BCProgressColor.danger,
                label: 'Battery',
                showValueLabel: true,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Circular',
          builder: (context) => const _Ticker(builder: _circular),
        ),
        UsageVariant(
          title: 'Loading overlay',
          builder: (context) => const _OverlayDemo(),
        ),
      ],
    );
  }
}

Widget _linearDeterminate(BuildContext context, double value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 24,
    children: [
      BCProgress(value: value, size: BCProgressSize.sm),
      BCProgress(value: value, label: 'Downloading', showValueLabel: true),
      BCProgress(
        value: value,
        size: BCProgressSize.lg,
        label: 'Restoring backup',
        showValueLabel: true,
        formatValue: (v) => '${(v * 240).round()} MB',
      ),
    ],
  );
}

Widget _circular(BuildContext context, double value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const BCProgress(
        variant: BCProgressVariant.circular,
        size: BCProgressSize.sm,
      ),
      BCProgress(
        variant: BCProgressVariant.circular,
        value: value,
        showValueLabel: true,
      ),
      BCProgress(
        variant: BCProgressVariant.circular,
        size: BCProgressSize.lg,
        value: value,
        color: BCProgressColor.success,
        label: 'Sync',
      ),
    ],
  );
}

/// Drives a 0→1 value so the determinate demos actually move.
class _Ticker extends StatefulWidget {
  const _Ticker({required this.builder});

  final Widget Function(BuildContext context, double value) builder;

  @override
  State<_Ticker> createState() => _TickerState();
}

class _TickerState extends State<_Ticker> {
  double _value = 0.15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted) return;
      setState(() => _value = _value >= 1 ? 0.1 : (_value + 0.22).clamp(0, 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value);
}

class _OverlayDemo extends StatefulWidget {
  const _OverlayDemo();

  @override
  State<_OverlayDemo> createState() => _OverlayDemoState();
}

class _OverlayDemoState extends State<_OverlayDemo> {
  bool _loading = false;
  BCLoadingBackdrop _backdrop = BCLoadingBackdrop.dim;
  bool _withLabel = true;

  Timer? _autoDismiss;

  /// Save runs a short fake request; the switch below holds the overlay open
  /// so you can inspect each backdrop.
  void _run() {
    setState(() => _loading = true);
    _autoDismiss?.cancel();
    _autoDismiss = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(BCRadius.xxxl),
          child: SizedBox(
            height: 280,
            child: BCLoadingOverlay(
              isLoading: _loading,
              backdrop: _backdrop,
              label: _withLabel ? 'Saving changes' : null,
              child: ColoredBox(
                color: bc.background,
                child: Padding(
                  padding: const EdgeInsets.all(BCSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: BCSpacing.sm,
                    children: [
                      const BCText('Profile', type: BCTextType.h5),
                      const BCTextField(
                        children: [
                          BCTextFieldLabel('Display name'),
                          BCTextFieldInput(hintText: 'Rifat'),
                        ],
                      ),
                      BCButton(
                        onPressed: _run,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        BCTabs<BCLoadingBackdrop>(
          fullWidth: true,
          value: _backdrop,
          onValueChange: (value) => setState(() => _backdrop = value),
          items: const [
            BCTabItem(value: BCLoadingBackdrop.dim, label: 'Dim'),
            BCTabItem(value: BCLoadingBackdrop.blur, label: 'Blur'),
            BCTabItem(value: BCLoadingBackdrop.none, label: 'None'),
          ],
        ),
        BCControlField(
          label: 'Hold overlay open',
          control: BCSwitch(
            isSelected: _loading,
            onSelectedChange: (v) {
              _autoDismiss?.cancel();
              setState(() => _loading = v);
            },
          ),
          onPressed: () {
            _autoDismiss?.cancel();
            setState(() => _loading = !_loading);
          },
        ),
        BCControlField(
          label: 'Show label card',
          control: BCSwitch(
            isSelected: _withLabel,
            onSelectedChange: (v) => setState(() => _withLabel = v),
          ),
          onPressed: () => setState(() => _withLabel = !_withLabel),
        ),
      ],
    );
  }
}
