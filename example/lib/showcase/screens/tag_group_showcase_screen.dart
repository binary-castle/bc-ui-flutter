import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class TagGroupShowcaseScreen extends StatefulWidget {
  const TagGroupShowcaseScreen({super.key});

  @override
  State<TagGroupShowcaseScreen> createState() =>
      _TagGroupShowcaseScreenState();
}

class _TagGroupShowcaseScreenState extends State<TagGroupShowcaseScreen> {
  Set<String> _single = {'react'};
  Set<String> _multiple = {'travel', 'food'};
  List<String> _removable = ['Design', 'Engineering', 'Marketing'];

  static const _frameworks = [
    BCTagItem(value: 'react', label: 'React Native'),
    BCTagItem(value: 'flutter', label: 'Flutter'),
    BCTagItem(value: 'swift', label: 'SwiftUI'),
    BCTagItem(value: 'compose', label: 'Compose'),
  ];

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'TagGroup',
      variants: [
        UsageVariant(
          title: 'Single select',
          builder: (context) => BCTagGroup<String>(
            items: _frameworks,
            selectedValues: _single,
            onSelectionChange: (values) => setState(() => _single = values),
          ),
        ),
        UsageVariant(
          title: 'Multiple select',
          builder: (context) => BCTagGroup<String>(
            items: const [
              BCTagItem(value: 'travel', label: 'Travel'),
              BCTagItem(value: 'food', label: 'Food'),
              BCTagItem(value: 'music', label: 'Music'),
              BCTagItem(value: 'sports', label: 'Sports'),
              BCTagItem(value: 'art', label: 'Art'),
            ],
            selectionMode: BCTagGroupSelectionMode.multiple,
            selectedValues: _multiple,
            onSelectionChange: (values) =>
                setState(() => _multiple = values),
          ),
        ),
        UsageVariant(
          title: 'Removable',
          builder: (context) => BCTagGroup<String>(
            items: [
              for (final tag in _removable)
                BCTagItem(value: tag, label: tag),
            ],
            selectionMode: BCTagGroupSelectionMode.none,
            variant: BCTagVariant.surface,
            onRemove: (value) =>
                setState(() => _removable = [..._removable]..remove(value)),
          ),
        ),
        UsageVariant(
          title: 'Sizes',
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              for (final size in BCTagSize.values)
                BCTagGroup<String>(
                  items: _frameworks.take(3).toList(),
                  size: size,
                  selectedValues: const {'react'},
                ),
            ],
          ),
        ),
      ],
    );
  }
}
