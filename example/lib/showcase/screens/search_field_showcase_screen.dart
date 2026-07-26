import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class SearchFieldShowcaseScreen extends StatelessWidget {
  const SearchFieldShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'SearchField',
      variants: [
        UsageVariant(
          title: 'Default',
          builder: (context) => const BCSearchField(
            placeholder: 'Search components…',
          ),
        ),
        UsageVariant(
          title: 'Secondary',
          builder: (context) => const BCSearchField(
            variant: BCInputVariant.secondary,
            placeholder: 'Search…',
          ),
        ),
        UsageVariant(
          title: 'Disabled',
          builder: (context) => const BCSearchField(
            placeholder: 'Disabled',
            isDisabled: true,
          ),
        ),
      ],
    );
  }
}
