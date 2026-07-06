import 'package:flutter/material.dart';

abstract final class ShowcaseSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

abstract final class ShowcaseRadius {
  static const lg = 16.0;
  static const full = 999.0;
}

class ShowcaseSectionTitle extends StatelessWidget {
  const ShowcaseSectionTitle(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ShowcaseSpacing.md),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
