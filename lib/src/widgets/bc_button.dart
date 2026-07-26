import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

/// Button variants from heroui-native (button.css).
enum BCButtonVariant {
  primary,
  secondary,
  tertiary,
  outline,
  ghost,
  danger,
  dangerSoft,
}

enum BCButtonSize { sm, md, lg }

/// HeroUI Native Button.
///
/// Visual spec (button.css): sm h40/px14/gap6/r24, md h48/px16/gap8/r24,
/// lg h56/px20/gap10/r32; medium-weight label. Press feedback is
/// scale + highlight, where the highlight fades in the variant's hover color
/// at full opacity (button.tsx highlightColorMap).
class BCButton extends StatelessWidget {
  const BCButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = BCButtonVariant.primary,
    this.size = BCButtonSize.md,
    this.isIconOnly = false,
    this.isDisabled = false,
    this.fullWidth = false,
    this.feedback = BCPressFeedback.scaleHighlight,
    this.startContent,
    this.endContent,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final BCButtonVariant variant;
  final BCButtonSize size;

  /// Square button with no horizontal padding (aspect-ratio 1).
  final bool isIconOnly;

  final bool isDisabled;

  /// Stretches the button to the available width.
  final bool fullWidth;

  final BCPressFeedback feedback;
  final Widget? startContent;
  final Widget? endContent;

  double get _height => switch (size) {
        BCButtonSize.sm => 40,
        BCButtonSize.md => 48,
        BCButtonSize.lg => 56,
      };

  double get _paddingX => switch (size) {
        BCButtonSize.sm => 14,
        BCButtonSize.md => 16,
        BCButtonSize.lg => 20,
      };

  double get _gap => switch (size) {
        BCButtonSize.sm => 6,
        BCButtonSize.md => 8,
        BCButtonSize.lg => 10,
      };

  double get _radius => switch (size) {
        BCButtonSize.sm || BCButtonSize.md => BCRadius.xxxl,
        BCButtonSize.lg => BCRadius.xxxxl,
      };

  TextStyle get _labelStyle => switch (size) {
        BCButtonSize.sm => BCTypography.textSm,
        BCButtonSize.md => BCTypography.textBase,
        BCButtonSize.lg => BCTypography.textLg,
      };

  Color _backgroundColor(BCThemeExtension bc) => switch (variant) {
        BCButtonVariant.primary => bc.accent,
        BCButtonVariant.secondary || BCButtonVariant.tertiary => bc.defaultColor,
        BCButtonVariant.outline ||
        BCButtonVariant.ghost =>
          const Color(0x00000000),
        BCButtonVariant.danger => bc.danger,
        BCButtonVariant.dangerSoft => bc.dangerSoft,
      };

  Color _labelColor(BCThemeExtension bc) => switch (variant) {
        BCButtonVariant.primary => bc.accentForeground,
        BCButtonVariant.secondary => bc.accentSoftForeground,
        BCButtonVariant.tertiary ||
        BCButtonVariant.outline ||
        BCButtonVariant.ghost =>
          bc.defaultForeground,
        BCButtonVariant.danger => bc.dangerForeground,
        BCButtonVariant.dangerSoft => bc.dangerSoftForeground,
      };

  Color _highlightColor(BCThemeExtension bc) => switch (variant) {
        BCButtonVariant.primary => bc.accentHover,
        BCButtonVariant.secondary || BCButtonVariant.tertiary => bc.defaultHover,
        BCButtonVariant.outline ||
        BCButtonVariant.ghost =>
          bc.defaultHover.withValues(alpha: 0.3),
        BCButtonVariant.danger => bc.dangerHover,
        BCButtonVariant.dangerSoft => bc.dangerSoftHover,
      };

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final labelColor = _labelColor(bc);

    final shape = BCShapes.continuous(
      _radius,
      side: variant == BCButtonVariant.outline
          ? BorderSide(color: bc.border, width: bc.borderWidth)
          : BorderSide.none,
    );

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: _gap,
      children: [
        ?startContent,
        Flexible(child: child),
        ?endContent,
      ],
    );

    final label = Container(
      height: _height,
      width: isIconOnly ? _height : null,
      padding: isIconOnly
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(horizontal: _paddingX),
      child: DefaultTextStyle.merge(
        style: _labelStyle.copyWith(
          color: labelColor,
          fontWeight: BCTypography.medium,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: labelColor, size: _labelStyle.fontSize),
          child: content,
        ),
      ),
    );

    Widget button = BCPressable(
      onPressed: isDisabled ? null : onPressed,
      feedback: feedback,
      shape: shape,
      // Background paints below the press highlight, which paints below
      // the label — the highlight never covers the text.
      background: DecoratedBox(
        decoration: ShapeDecoration(
          color: _backgroundColor(bc),
          shape: shape,
        ),
      ),
      highlightColor: _highlightColor(bc),
      highlightOpacityRange: (0, 1),
      enabled: !isDisabled,
      child: label,
    );

    if (isDisabled) {
      button = Opacity(opacity: bc.opacityDisabled, child: button);
    }

    return button;
  }
}
