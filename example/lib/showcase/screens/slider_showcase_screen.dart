import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SliderShowcaseScreen extends StatefulWidget {
  const SliderShowcaseScreen({super.key});

  @override
  State<SliderShowcaseScreen> createState() => _SliderShowcaseScreenState();
}

class _SliderShowcaseScreenState extends State<SliderShowcaseScreen> {
  double _basic = 0.4;
  double _volume = 40;

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Slider',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => BCSlider(
            value: _basic,
            onChanged: (value) => setState(() => _basic = value),
          ),
        ),
        UsageVariant(
          title: 'With output',
          builder: (context) => BCSlider(
            value: _volume,
            minValue: 0,
            maxValue: 100,
            step: 5,
            label: 'Volume',
            showOutput: true,
            onChanged: (value) => setState(() => _volume = value),
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const BCSlider(
            value: 0.6,
            isDisabled: true,
          ),
        ),
      ],
    );
  }
}
