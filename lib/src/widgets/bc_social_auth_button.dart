import 'package:flutter/widgets.dart';

import 'bc_brand_logo.dart';
import 'bc_button.dart';
import 'bc_pressable.dart';
import 'bc_spinner.dart';

/// How a provider's mark is coloured inside a [BCSocialAuthButton].
enum BCBrandLogoStyle {
  /// Brand colours on neutral backgrounds, and the label colour on tinted
  /// variants (primary/danger) or for marks that are monochrome by design.
  auto,

  /// Always the official brand colours.
  brand,

  /// Always the button's label colour.
  monochrome,
}

/// A social sign-in button: a [BCButton] with a provider's brand mark as its
/// start content.
///
/// It is deliberately a thin wrapper — sizing, radius, press feedback,
/// disabled opacity and every variant come from [BCButton], so a row of
/// social buttons lines up with the rest of the buttons on the screen.
///
/// ```dart
/// BCSocialAuthButton(
///   provider: BCSocialProvider.google,
///   label: 'Continue with Google',
///   onPressed: signInWithGoogle,
/// )
/// ```
class BCSocialAuthButton extends StatelessWidget {
  const BCSocialAuthButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.label,
    this.variant = BCButtonVariant.outline,
    this.size = BCButtonSize.md,
    this.logoStyle = BCBrandLogoStyle.auto,
    this.isIconOnly = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
    this.feedback = BCPressFeedback.scaleHighlight,
    this.endContent,
  });

  final BCSocialProvider provider;
  final VoidCallback? onPressed;

  /// Defaults to the provider's name ('Google', 'GitHub', …). Pass a full
  /// phrase for the common 'Continue with X' framing.
  final String? label;

  final BCButtonVariant variant;
  final BCButtonSize size;
  final BCBrandLogoStyle logoStyle;

  /// Drops the label and renders a square, logo-only button.
  final bool isIconOnly;

  /// Swaps the logo for a spinner and blocks presses while a sign-in is in
  /// flight.
  final bool isLoading;

  final bool isDisabled;

  /// Stretches the button to the available width — the usual layout for a
  /// stack of sign-in options. Ignored when [isIconOnly] is set.
  final bool fullWidth;

  final BCPressFeedback feedback;
  final Widget? endContent;

  double get _logoSize => switch (size) {
        BCButtonSize.sm => 18,
        BCButtonSize.md => 20,
        BCButtonSize.lg => 22,
      };

  BCSpinnerSize get _spinnerSize => switch (size) {
        BCButtonSize.sm || BCButtonSize.md => BCSpinnerSize.sm,
        BCButtonSize.lg => BCSpinnerSize.md,
      };

  /// Whether the variant paints a saturated background that multi-colour
  /// marks would clash with.
  bool get _isTinted =>
      variant == BCButtonVariant.primary || variant == BCButtonVariant.danger;

  Color? _logoColor(Color? labelColor) => switch (logoStyle) {
        BCBrandLogoStyle.brand => null,
        BCBrandLogoStyle.monochrome => labelColor,
        BCBrandLogoStyle.auto =>
          provider.hasMonochromeMark || _isTinted ? labelColor : null,
      };

  @override
  Widget build(BuildContext context) {
    // Built below BCButton so it can read the resolved label colour the
    // button publishes through IconTheme, instead of re-deriving it.
    final mark = Builder(
      builder: (context) {
        final labelColor = IconTheme.of(context).color;
        if (isLoading) {
          return BCSpinner(size: _spinnerSize, customColor: labelColor);
        }
        return BCBrandLogo(
          provider: provider,
          size: _logoSize,
          color: _logoColor(labelColor),
        );
      },
    );

    return BCButton(
      variant: variant,
      size: size,
      onPressed: isLoading ? null : onPressed,
      isDisabled: isDisabled,
      isIconOnly: isIconOnly,
      fullWidth: fullWidth && !isIconOnly,
      feedback: feedback,
      startContent: isIconOnly ? null : mark,
      endContent: isIconOnly ? null : endContent,
      child: isIconOnly
          ? mark
          : Text(
              label ?? provider.label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }
}
