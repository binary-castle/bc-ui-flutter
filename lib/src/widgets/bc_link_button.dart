import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

/// HeroUI Native LinkButton: a ghost-variant button with no highlight
/// feedback, auto height and no padding (link-button.tsx enforces these).
class BCLinkButton extends StatelessWidget {
  const BCLinkButton({
    super.key,
    required this.child,
    this.onPressed,
    this.size = BCLinkButtonSize.md,
    this.isDisabled = false,
    this.feedback = BCPressFeedback.scale,
    this.startContent,
    this.endContent,
  });

  BCLinkButton.label(
    String label, {
    Key? key,
    VoidCallback? onPressed,
    BCLinkButtonSize size = BCLinkButtonSize.md,
    bool isDisabled = false,
    BCPressFeedback feedback = BCPressFeedback.scale,
    Widget? startContent,
    Widget? endContent,
  }) : this(
          key: key,
          onPressed: onPressed,
          size: size,
          isDisabled: isDisabled,
          feedback: feedback,
          startContent: startContent,
          endContent: endContent,
          child: Text(label),
        );

  final Widget child;
  final VoidCallback? onPressed;
  final BCLinkButtonSize size;
  final bool isDisabled;
  final BCPressFeedback feedback;
  final Widget? startContent;
  final Widget? endContent;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final labelStyle = switch (size) {
      BCLinkButtonSize.sm => BCTypography.textSm,
      BCLinkButtonSize.md => BCTypography.textBase,
      BCLinkButtonSize.lg => BCTypography.textLg,
    };

    final gap = switch (size) {
      BCLinkButtonSize.sm => 6.0,
      BCLinkButtonSize.md => 8.0,
      BCLinkButtonSize.lg => 10.0,
    };

    Widget content = DefaultTextStyle.merge(
      style: labelStyle.copyWith(
        color: bc.defaultForeground,
        fontWeight: BCTypography.medium,
      ),
      child: IconTheme.merge(
        data: IconThemeData(
          color: bc.defaultForeground,
          size: labelStyle.fontSize,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: gap,
          children: [
            ?startContent,
            child,
            ?endContent,
          ],
        ),
      ),
    );

    if (isDisabled) {
      content = Opacity(opacity: bc.opacityDisabled, child: content);
    }

    return BCPressable(
      onPressed: isDisabled ? null : onPressed,
      feedback: feedback,
      enabled: !isDisabled,
      child: content,
    );
  }
}

enum BCLinkButtonSize { sm, md, lg }
