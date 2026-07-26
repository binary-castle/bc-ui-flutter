import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../tokens/bc_motion.dart';
import '../../tokens/bc_spacing.dart';
import '../../tokens/bc_typography.dart';

/// HeroUI Native Description: muted helper text that fades in on mount
/// (description.css, 150ms ease-out).
class BCDescription extends StatelessWidget {
  const BCDescription(
    this.text, {
    super.key,
    this.isInvalid = false,
    this.isDisabled = false,
    this.isInsideField = false,
    this.animate = true,
  });

  final String text;
  final bool isInvalid;
  final bool isDisabled;
  final bool isInsideField;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    Widget description = Text(
      text,
      style: BCTypography.textSm.copyWith(
        color: isInvalid ? bc.danger : bc.muted,
      ),
    );

    if (isDisabled) {
      description = Opacity(opacity: bc.opacityDisabled, child: description);
    }
    if (isInsideField) {
      description = Padding(
        padding: EdgeInsets.symmetric(horizontal: BCSpacing.unit(1.5)),
        child: description,
      );
    }
    if (animate && !MediaQuery.disableAnimationsOf(context)) {
      description = _FadeInOnMount(child: description);
    }
    return description;
  }
}

class _FadeInOnMount extends StatelessWidget {
  const _FadeInOnMount({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: BCMotion.helperFadeDuration,
      curve: Curves.easeOut,
      child: child,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
    );
  }
}
