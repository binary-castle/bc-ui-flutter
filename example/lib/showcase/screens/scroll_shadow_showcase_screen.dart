import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/presentation/usage_variant_page_view.dart';
import 'package:flutter/material.dart';

class ScrollShadowShowcaseScreen extends StatelessWidget {
  const ScrollShadowShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentShowcaseScaffold(
      title: 'ScrollShadow',
      variants: [
        UsageVariant(
          title: 'Vertical',
          builder: (context) => SizedBox(
            height: 320,
            child: BCScrollShadow(
              child: ListView.separated(
                itemCount: 20,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 8,
                ),
                itemBuilder: (context, index) => BCSurface(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BCRadius.xxl,
                  child: BCText('Row ${index + 1}'),
                ),
              ),
            ),
          ),
        ),
        UsageVariant(
          title: 'Horizontal',
          builder: (context) => SizedBox(
            height: 96,
            child: BCScrollShadow(
              direction: Axis.horizontal,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 12,
                separatorBuilder: (context, index) => const SizedBox(
                  width: 8,
                ),
                itemBuilder: (context, index) => BCSurface(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BCRadius.xxl,
                  child: Center(child: BCText('Card ${index + 1}')),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
