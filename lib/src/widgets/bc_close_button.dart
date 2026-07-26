import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import 'bc_pressable.dart';

/// HeroUI Native CloseButton: a 32px tertiary icon-only button with a muted
/// close icon (close-button.tsx: Button tertiary/sm/iconOnly with the root
/// height overridden to 32 by close-button.css).
class BCCloseButton extends StatelessWidget {
  const BCCloseButton({
    super.key,
    this.onPressed,
    this.iconSize = 18,
    this.iconColor,
    this.isDisabled = false,
    this.feedback = BCPressFeedback.scaleHighlight,
  });

  final VoidCallback? onPressed;
  final double iconSize;

  /// Defaults to the muted token.
  final Color? iconColor;
  final bool isDisabled;
  final BCPressFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final shape = BCShapes.continuous(BCRadius.xxxl);

    Widget button = BCPressable(
      onPressed: isDisabled ? null : onPressed,
      feedback: feedback,
      shape: shape,
      background: DecoratedBox(
        decoration: ShapeDecoration(color: bc.defaultColor, shape: shape),
      ),
      highlightColor: bc.defaultHover,
      highlightOpacityRange: (0, 1),
      enabled: !isDisabled,
      child: SizedBox(
        height: 32,
        width: 32,
        child: Center(
          child: Icon(
            Icons.close,
            size: iconSize,
            color: iconColor ?? bc.muted,
          ),
        ),
      ),
    );

    if (isDisabled) {
      button = Opacity(opacity: bc.opacityDisabled, child: button);
    }

    return button;
  }
}
