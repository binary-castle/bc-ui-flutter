import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../tokens/bc_motion.dart';
import '../../tokens/bc_spacing.dart';
import '../../tokens/bc_typography.dart';

/// HeroUI Native FieldError: danger-colored validation message that fades in
/// on mount (field-error.css, 150ms ease-out).
class BCFieldError extends StatelessWidget {
  const BCFieldError(
    this.text, {
    super.key,
    this.isInsideField = false,
    this.animate = true,
  });

  final String text;
  final bool isInsideField;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    Widget error = Text(
      text,
      style: BCTypography.textSm.copyWith(color: bc.danger),
    );

    if (isInsideField) {
      error = Padding(
        padding: EdgeInsets.symmetric(horizontal: BCSpacing.unit(1.5)),
        child: error,
      );
    }
    if (animate && !MediaQuery.disableAnimationsOf(context)) {
      error = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: BCMotion.helperFadeDuration,
        curve: Curves.easeOut,
        child: error,
        builder: (context, opacity, child) =>
            Opacity(opacity: opacity, child: child),
      );
    }
    return error;
  }
}
