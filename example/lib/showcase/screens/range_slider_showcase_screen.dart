import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class RangeSliderShowcaseScreen extends StatefulWidget {
  const RangeSliderShowcaseScreen({super.key});

  @override
  State<RangeSliderShowcaseScreen> createState() =>
      _RangeSliderShowcaseScreenState();
}

class _RangeSliderShowcaseScreenState extends State<RangeSliderShowcaseScreen> {
  BCRange _basic = const BCRange(0.25, 0.75);
  BCRange _price = const BCRange(120, 380);
  BCRange _hours = const BCRange(9, 17);

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'RangeSlider',
      variants: [
        UsageVariant(
          title: 'Basic',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              BCRangeSlider(
                values: _basic,
                onChanged: (value) => setState(() => _basic = value),
              ),
              BCText(
                '${_basic.start.toStringAsFixed(2)} – '
                '${_basic.end.toStringAsFixed(2)}',
                type: BCTextType.bodySm,
                color: BCTextColor.muted,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Label and output',
          builder: (context) => BCRangeSlider(
            values: _price,
            minValue: 0,
            maxValue: 500,
            step: 10,
            label: 'Price',
            showOutput: true,
            formatOutput: (value) => '\$${value.round()}',
            onChanged: (value) => setState(() => _price = value),
          ),
        ),
        UsageVariant(
          title: 'Stepped with minimum gap',
          builder: (context) => BCRangeSlider(
            values: _hours,
            minValue: 0,
            maxValue: 24,
            step: 1,
            minSeparation: 4,
            label: 'Working hours',
            showOutput: true,
            formatOutput: (value) => '${value.round()}:00',
            onChanged: (value) => setState(() => _hours = value),
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const BCRangeSlider(
            values: BCRange(0.3, 0.6),
            label: 'Locked',
            showOutput: true,
            isDisabled: true,
          ),
        ),
      ],
    );
  }
}
