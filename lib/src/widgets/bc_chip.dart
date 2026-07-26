import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

enum BCChipVariant { primary, secondary, tertiary, soft }

enum BCChipSize { sm, md, lg }

enum BCChipColor { accent, defaultColor, success, warning, danger }

/// HeroUI Native Chip (chip.css): variant × color background matrix,
/// medium-weight label, gap 4, self-start.
class BCChip extends StatelessWidget {
  const BCChip({
    super.key,
    required this.child,
    this.variant = BCChipVariant.primary,
    this.size = BCChipSize.md,
    this.color = BCChipColor.accent,
    this.startContent,
    this.endContent,
    this.onPressed,
  });

  /// Convenience constructor for a plain text chip.
  BCChip.label(
    String label, {
    Key? key,
    BCChipVariant variant = BCChipVariant.primary,
    BCChipSize size = BCChipSize.md,
    BCChipColor color = BCChipColor.accent,
    Widget? startContent,
    Widget? endContent,
    VoidCallback? onPressed,
  }) : this(
          key: key,
          variant: variant,
          size: size,
          color: color,
          startContent: startContent,
          endContent: endContent,
          onPressed: onPressed,
          child: Text(label),
        );

  final Widget child;
  final BCChipVariant variant;
  final BCChipSize size;
  final BCChipColor color;
  final Widget? startContent;
  final Widget? endContent;
  final VoidCallback? onPressed;

  EdgeInsets get _padding => switch (size) {
        BCChipSize.sm => const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        BCChipSize.md =>
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        BCChipSize.lg =>
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      };

  double get _radius => switch (size) {
        BCChipSize.sm => BCRadius.xl,
        BCChipSize.md => BCRadius.xxl,
        BCChipSize.lg => BCRadius.xxxl,
      };

  TextStyle get _labelStyle => switch (size) {
        BCChipSize.sm => BCTypography.textXs,
        BCChipSize.md => BCTypography.textSm,
        BCChipSize.lg => BCTypography.textBase,
      };

  Color _backgroundColor(BCThemeExtension bc) {
    return switch (variant) {
      BCChipVariant.primary => switch (color) {
          BCChipColor.accent => bc.accent,
          BCChipColor.defaultColor => bc.defaultColor,
          BCChipColor.success => bc.success,
          BCChipColor.warning => bc.warning,
          BCChipColor.danger => bc.danger,
        },
      BCChipVariant.secondary => bc.defaultColor,
      BCChipVariant.tertiary => const Color(0x00000000),
      BCChipVariant.soft => switch (color) {
          BCChipColor.accent => bc.accentSoft,
          BCChipColor.defaultColor => bc.defaultColor,
          BCChipColor.success => bc.successSoft,
          BCChipColor.warning => bc.warningSoft,
          BCChipColor.danger => bc.dangerSoft,
        },
    };
  }

  Color _labelColor(BCThemeExtension bc) {
    if (variant == BCChipVariant.primary) {
      return switch (color) {
        BCChipColor.accent => bc.accentForeground,
        BCChipColor.defaultColor => bc.defaultForeground,
        BCChipColor.success => bc.successForeground,
        BCChipColor.warning => bc.warningForeground,
        BCChipColor.danger => bc.dangerForeground,
      };
    }
    // secondary / tertiary / soft all use the soft foregrounds.
    return switch (color) {
      BCChipColor.accent => bc.accentSoftForeground,
      BCChipColor.defaultColor => bc.defaultSoftForeground,
      BCChipColor.success => bc.successSoftForeground,
      BCChipColor.warning => bc.warningSoftForeground,
      BCChipColor.danger => bc.dangerSoftForeground,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final labelColor = _labelColor(bc);
    final shape = BCShapes.continuous(_radius);

    final label = Padding(
      padding: _padding,
      child: DefaultTextStyle.merge(
        style: _labelStyle.copyWith(
          color: labelColor,
          fontWeight: BCTypography.medium,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: labelColor, size: _labelStyle.fontSize),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              ?startContent,
              child,
              ?endContent,
            ],
          ),
        ),
      ),
    );

    final decoration = ShapeDecoration(
      color: _backgroundColor(bc),
      shape: shape,
    );

    if (onPressed != null) {
      return BCPressable(
        onPressed: onPressed,
        shape: shape,
        background: DecoratedBox(decoration: decoration),
        child: label,
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: decoration,
      padding: EdgeInsets.zero,
      child: label,
    );
  }
}
