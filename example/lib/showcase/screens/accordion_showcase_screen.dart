import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

/// One FAQ entry, mirroring heroui's `accordionData`.
class _Faq {
  const _Faq(this.value, this.icon, this.title, this.answer);

  final String value;
  final IconData icon;
  final String title;
  final String answer;
}

const _faqs = [
  _Faq(
    '1',
    Icons.shopping_bag_outlined,
    'How do I place an order?',
    'Add what you want to the bag, then check out. You will get a '
        'confirmation email within a couple of minutes.',
  ),
  _Faq(
    '2',
    Icons.receipt_long_outlined,
    'Can I modify or cancel my order?',
    'Until it ships, yes — open the order and pick Modify. Once it is with '
        'the courier you will need to return it instead.',
  ),
  _Faq(
    '3',
    Icons.inventory_2_outlined,
    'How much does shipping cost?',
    'Standard shipping is free over \$50, and \$4.95 below that.',
  ),
  _Faq(
    '4',
    Icons.public,
    'Do you ship internationally?',
    'We ship to 40 countries. Duties are calculated at checkout, so the '
        'price you see is the price you pay.',
  ),
];

class AccordionShowcaseScreen extends StatefulWidget {
  const AccordionShowcaseScreen({super.key});

  @override
  State<AccordionShowcaseScreen> createState() =>
      _AccordionShowcaseScreenState();
}

class _AccordionShowcaseScreenState extends State<AccordionShowcaseScreen> {
  // heroui's `defaultValue="2"`.
  final _plain = BCAccordionController(initialValue: const {'2'});
  final _surface = BCAccordionController();
  final _multiple = BCAccordionController(initialValue: const {'1', '3'});
  final _seamless = BCAccordionController();
  final _custom = BCAccordionController();
  final _pinned = BCAccordionController(initialValue: const {'1'});

  /// The last variant holds its set here rather than in a controller, to show
  /// the accordion keeps none of its own state.
  Set<String> _controlled = const {'1'};

  @override
  void dispose() {
    _plain.dispose();
    _surface.dispose();
    _multiple.dispose();
    _seamless.dispose();
    _custom.dispose();
    _pinned.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'Accordion',
      variants: [
        UsageVariant(
          title: 'Default',
          builder: (context) => BCAccordion(
            controller: _plain,
            children: [for (final faq in _faqs) _item(faq)],
          ),
        ),
        UsageVariant(
          title: 'Surface',
          builder: (context) => BCAccordion(
            controller: _surface,
            variant: BCAccordionVariant.surface,
            children: [for (final faq in _faqs.take(3)) _item(faq)],
          ),
        ),
        UsageVariant(
          title: 'Multiple',
          builder: (context) => BCAccordion(
            controller: _multiple,
            variant: BCAccordionVariant.surface,
            selectionMode: BCAccordionSelectionMode.multiple,
            children: [for (final faq in _faqs.take(3)) _item(faq)],
          ),
        ),
        UsageVariant(
          title: 'No separators',
          builder: (context) => BCAccordion(
            controller: _seamless,
            hideSeparator: true,
            children: [for (final faq in _faqs.take(3)) _item(faq)],
          ),
        ),
        UsageVariant(
          title: 'Custom indicator',
          builder: (context) => BCAccordion(
            controller: _custom,
            variant: BCAccordionVariant.surface,
            children: [
              for (final faq in _faqs.take(3))
                _item(faq, indicator: const _PlusMinusIndicator()),
            ],
          ),
        ),
        UsageVariant(
          title: 'Disabled & pinned',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              BCAccordion(
                controller: _pinned,
                // Something always stays open.
                isCollapsible: false,
                variant: BCAccordionVariant.surface,
                children: [
                  _item(_faqs[0]),
                  _item(_faqs[1]),
                  _item(_faqs[2], isDisabled: true),
                ],
              ),
              const BCText(
                'isCollapsible: false — tapping the open row leaves it open. '
                'The last row is isDisabled.',
                type: BCTextType.bodySm,
                color: BCTextColor.muted,
              ),
            ],
          ),
        ),
        UsageVariant(
          title: 'Controlled',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                spacing: 8,
                children: [
                  BCButton(
                    size: BCButtonSize.sm,
                    variant: BCButtonVariant.secondary,
                    onPressed: () => setState(
                      () => _controlled = {
                        for (final faq in _faqs.take(3)) faq.value,
                      },
                    ),
                    child: const Text('Expand all'),
                  ),
                  BCButton(
                    size: BCButtonSize.sm,
                    variant: BCButtonVariant.outline,
                    onPressed: () => setState(() => _controlled = const {}),
                    child: const Text('Collapse all'),
                  ),
                ],
              ),
              BCText(
                'Expanded: ${_controlled.isEmpty ? 'none' : (_controlled.toList()..sort()).join(', ')}',
                type: BCTextType.bodySm,
                color: BCTextColor.muted,
              ),
              BCAccordion(
                value: _controlled,
                onValueChange: (value) => setState(() => _controlled = value),
                selectionMode: BCAccordionSelectionMode.multiple,
                variant: BCAccordionVariant.surface,
                children: [for (final faq in _faqs.take(3)) _item(faq)],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item(_Faq faq, {Widget? indicator, bool isDisabled = false}) {
    return BCAccordionItem(
      value: faq.value,
      isDisabled: isDisabled,
      children: [
        BCAccordionTrigger(
          indicator: indicator,
          child: Builder(
            builder: (context) => Row(
              spacing: 12,
              children: [
                Icon(faq.icon, size: 16, color: context.bcTheme.muted),
                Expanded(child: BCText(faq.title)),
              ],
            ),
          ),
        ),
        BCAccordionContent(
          child: BCText(faq.answer, color: BCTextColor.muted),
        ),
      ],
    );
  }
}

/// heroui's custom-indicator example: plus and minus swapped with a zoom,
/// which [BCAccordionIndicator] deliberately does not animate for you.
class _PlusMinusIndicator extends StatelessWidget {
  const _PlusMinusIndicator();

  @override
  Widget build(BuildContext context) {
    final isExpanded = BCAccordionItem.isExpandedOf(context);

    return BCAccordionIndicator(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isExpanded ? Icons.remove : Icons.add,
          key: ValueKey(isExpanded),
          size: 16,
          color: context.bcTheme.foreground,
        ),
      ),
    );
  }
}
