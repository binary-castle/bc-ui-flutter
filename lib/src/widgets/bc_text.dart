import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';
import '../tokens/bc_typography.dart';

/// Type scale from heroui-native's Text component (text.css).
enum BCTextType { h1, h2, h3, h4, h5, h6, body, bodySm, bodyXs, code }

enum BCTextColor { foreground, muted }

enum BCTextWeight { normal, medium, semibold, bold }

/// HeroUI Native Text: typography with the library's type scale.
class BCText extends StatelessWidget {
  const BCText(
    this.data, {
    super.key,
    this.type = BCTextType.body,
    this.color = BCTextColor.foreground,
    this.weight,
    this.align,
    this.maxLines,
    this.overflow,
    this.style,
  });

  final String data;
  final BCTextType type;
  final BCTextColor color;

  /// Explicit weight wins over the type's default weight.
  final BCTextWeight? weight;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Merged last, over the resolved style.
  final TextStyle? style;

  static TextStyle resolveStyle(
    BuildContext context, {
    BCTextType type = BCTextType.body,
    BCTextColor color = BCTextColor.foreground,
    BCTextWeight? weight,
  }) {
    final bc = context.bcTheme;

    TextStyle base = switch (type) {
      BCTextType.h1 => BCTypography.text4xl,
      BCTextType.h2 => BCTypography.text3xl,
      BCTextType.h3 => BCTypography.text2xl,
      BCTextType.h4 => BCTypography.textXl,
      BCTextType.h5 => BCTypography.textLg,
      BCTextType.h6 => BCTypography.textBase,
      // body types use spacing-based line heights (28 / 24 / 20)
      BCTextType.body => BCTypography.textBase.copyWith(height: 28 / 16),
      BCTextType.bodySm => BCTypography.textSm.copyWith(height: 24 / 14),
      BCTextType.bodyXs => BCTypography.textXs.copyWith(height: 20 / 12),
      BCTextType.code => BCTypography.textSm,
    };

    final isHeading = switch (type) {
      BCTextType.h1 ||
      BCTextType.h2 ||
      BCTextType.h3 ||
      BCTextType.h4 ||
      BCTextType.h5 ||
      BCTextType.h6 =>
        true,
      _ => false,
    };

    if (isHeading) {
      base = base.copyWith(
        fontWeight: BCTypography.semiBold,
        letterSpacing: BCTypography.trackingTight(base.fontSize!),
      );
    }

    if (weight != null) {
      base = base.copyWith(
        fontWeight: switch (weight) {
          BCTextWeight.normal => BCTypography.regular,
          BCTextWeight.medium => BCTypography.medium,
          BCTextWeight.semibold => BCTypography.semiBold,
          BCTextWeight.bold => BCTypography.bold,
        },
      );
    }

    return base.copyWith(
      color: switch (color) {
        BCTextColor.foreground => bc.foreground,
        BCTextColor.muted => bc.muted,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveStyle(
      context,
      type: type,
      color: color,
      weight: weight,
    ).merge(style);

    final text = Text(
      data,
      style: resolved,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
    );

    if (type != BCTextType.code) return text;

    // Code: default background chip, radius-md, px 6 / py 2, self-start.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      heightFactor: 1,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: context.bcTheme.defaultColor,
          shape: BCShapes.continuous(BCRadius.md),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BCSpacing.unit(1.5),
            vertical: BCSpacing.unit(0.5),
          ),
          child: text,
        ),
      ),
    );
  }
}
