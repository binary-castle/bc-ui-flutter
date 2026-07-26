import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_motion.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';
import '../tokens/bc_typography.dart';
import 'bc_spinner.dart';

/// How the content behind a [BCLoadingOverlay] is treated while loading.
enum BCLoadingBackdrop {
  /// Tinted with the `backdrop` token.
  dim,

  /// Blurred and lightly tinted — heavier, best for full screens.
  blur,

  /// Left untouched; only the indicator is layered on top.
  none,
}

/// Covers a page or a section while work is in flight: fades a backdrop in,
/// blocks input underneath, and centers an indicator with an optional label.
///
/// [BCSpinner] is the indicator itself; this is the state around it — use it
/// when a tap must not land on the content behind.
///
/// ```dart
/// BCLoadingOverlay(
///   isLoading: _saving,
///   label: 'Saving changes',
///   child: ProfileForm(),
/// );
/// ```
class BCLoadingOverlay extends StatelessWidget {
  const BCLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.label,
    this.backdrop = BCLoadingBackdrop.dim,
    this.indicator,
    this.blurSigma = 6,
    this.blockInput = true,
    this.semanticLabel = 'Loading',
  });

  final bool isLoading;
  final Widget child;

  /// Caption under the indicator. With a label the indicator sits on a
  /// surface card; without one it floats bare.
  final String? label;

  final BCLoadingBackdrop backdrop;

  /// Defaults to a large [BCSpinner].
  final Widget? indicator;

  /// Blur strength for [BCLoadingBackdrop.blur].
  final double blurSigma;

  /// Swallows pointer events aimed at [child] while loading.
  final bool blockInput;

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    Widget content = indicator ?? const BCSpinner(size: BCSpinnerSize.lg);

    if (label != null) {
      content = Container(
        constraints: const BoxConstraints(minWidth: 140, maxWidth: 260),
        padding: const EdgeInsets.symmetric(
          horizontal: BCSpacing.lg,
          vertical: BCSpacing.md,
        ),
        decoration: ShapeDecoration(
          color: bc.overlay,
          shape: BCShapes.continuous(
            BCRadius.xxxl,
            side: bc.overlayShadow.innerBorder ?? BorderSide.none,
          ),
          shadows: bc.overlayShadow.shadows,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            content,
            const SizedBox(height: BCSpacing.md),
            Text(
              label!,
              textAlign: TextAlign.center,
              style: BCTypography.textSm.copyWith(
                color: bc.overlayForeground,
                fontWeight: BCTypography.medium,
              ),
            ),
          ],
        ),
      );
    }

    Widget layer = Stack(
      fit: StackFit.expand,
      children: [
        if (backdrop == BCLoadingBackdrop.dim)
          ColoredBox(color: bc.backdrop)
        else if (backdrop == BCLoadingBackdrop.blur)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: ColoredBox(color: bc.backdrop.withValues(alpha: 0.35)),
          ),
        Center(child: content),
      ],
    );

    if (blockInput) {
      layer = AbsorbPointer(child: layer);
    }

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isLoading,
            child: AnimatedOpacity(
              opacity: isLoading ? 1 : 0,
              duration: BCMotion.timingDuration,
              curve: BCMotion.timingCurve,
              // Keeping the subtree alive would keep the spinner ticking, so
              // it is dropped once faded out.
              child: isLoading
                  ? Semantics(
                      label: semanticLabel,
                      liveRegion: true,
                      child: layer,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
