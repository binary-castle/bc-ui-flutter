import 'package:flutter/material.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_close_button.dart';

/// HeroUI Native Dialog.
///
/// `BCDialog.show` presents a centered modal over the black-20% backdrop
/// with heroui's content animation (scale 0.96 → 1 + fade, 200ms in /
/// 150ms out). Compose the content with [BCDialogContent], [BCDialogTitle],
/// and [BCDialogDescription].
abstract final class BCDialog {
  static Future<R?> show<R>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    final backdrop = context.bcTheme.backdrop;

    return showGeneralDialog<R>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: backdrop,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: curved.drive(Tween(begin: 0.96, end: 1)),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: builder(dialogContext),
            ),
          ),
        );
      },
    );
  }
}

/// Dialog surface (dialog.css): overlay background, 20px padding, 24px
/// continuous corners, overlay shadow (1px white hairline in dark mode).
class BCDialogContent extends StatelessWidget {
  const BCDialogContent({
    super.key,
    required this.child,
    this.showCloseButton = false,
    this.width,
  });

  final Widget child;
  final bool showCloseButton;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: bc.overlay,
        shape: BCShapes.continuous(
          BCRadius.xxxl,
          side: bc.overlayShadow.innerBorder ?? BorderSide.none,
        ),
        shadows: bc.overlayShadow.shadows,
      ),
      padding: const EdgeInsets.all(20),
      child: Material(
        type: MaterialType.transparency,
        child: showCloseButton
            ? Stack(
                children: [
                  child,
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: BCCloseButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              )
            : child,
      ),
    );
  }
}

/// Dialog title: text-lg, medium, foreground.
class BCDialogTitle extends StatelessWidget {
  const BCDialogTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCTypography.textLg.copyWith(
        color: context.bcTheme.foreground,
        fontWeight: BCTypography.medium,
      ),
    );
  }
}

/// Dialog description: text-base, muted.
class BCDialogDescription extends StatelessWidget {
  const BCDialogDescription(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCTypography.textBase.copyWith(color: context.bcTheme.muted),
    );
  }
}
