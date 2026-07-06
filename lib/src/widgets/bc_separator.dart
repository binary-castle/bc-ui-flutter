import 'package:bc_ui/src/extensions/context_extension.dart';
import 'package:bc_ui/src/theme/component_themes/separator_theme.dart';
import 'package:flutter/material.dart';

export 'package:bc_ui/src/theme/component_themes/separator_theme.dart'
    show BCSeparatorOrientation, BCSeparatorVariant;

class BCSeparator extends StatelessWidget {
  const BCSeparator({
    super.key,
    this.variant = BCSeparatorVariant.thin,
    this.orientation = BCSeparatorOrientation.horizontal,
    this.thickness,
    this.color,
    this.margin,
  });

  final BCSeparatorVariant variant;
  final BCSeparatorOrientation orientation;
  final double? thickness;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final lineThickness = BCSeparatorTheme.thickness(
      variant: variant,
      context: context,
      override: thickness,
    );
    final lineColor = color ?? BCSeparatorTheme.color(context.colors);

    final line = switch (orientation) {
      BCSeparatorOrientation.horizontal => SizedBox(
        width: double.infinity,
        height: lineThickness,
        child: ColoredBox(color: lineColor),
      ),
      BCSeparatorOrientation.vertical => SizedBox(
        width: lineThickness,
        height: double.infinity,
        child: ColoredBox(color: lineColor),
      ),
    };

    if (margin == null) return line;

    return Padding(padding: margin!, child: line);
  }
}
