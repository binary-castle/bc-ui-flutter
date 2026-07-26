import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';

enum BCSeparatorVariant { thin, thick }

enum BCSeparatorOrientation { horizontal, vertical }

/// HeroUI Native Separator (separator.css): hairline (thin) or 6px (thick)
/// line in the `separator` token color.
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
    final lineThickness = thickness ??
        switch (variant) {
          BCSeparatorVariant.thin =>
            1.0 / MediaQuery.devicePixelRatioOf(context),
          BCSeparatorVariant.thick => 6.0,
        };
    final lineColor = color ?? context.bcTheme.separator;

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
