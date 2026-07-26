import 'package:flutter/widgets.dart';

import '../../extensions/context_extension.dart';
import '../../tokens/bc_spacing.dart';
import '../../tokens/bc_typography.dart';

/// HeroUI Native Label: medium-weight field label with an optional required
/// asterisk (label.css).
class BCLabel extends StatelessWidget {
  const BCLabel(
    this.text, {
    super.key,
    this.isRequired = false,
    this.isInvalid = false,
    this.isDisabled = false,
    this.isInsideField = false,
  });

  final String text;
  final bool isRequired;
  final bool isInvalid;
  final bool isDisabled;

  /// Adds the horizontal padding used when the label sits inside a
  /// TextField layout.
  final bool isInsideField;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    Widget label = Text.rich(
      TextSpan(
        text: text,
        style: BCTypography.textBase.copyWith(
          color: isInvalid ? bc.danger : bc.foreground,
          fontWeight: BCTypography.medium,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: BCTypography.textLg.copyWith(
                height: 24 / 18,
                color: isDisabled ? bc.muted : bc.danger,
              ),
            ),
        ],
      ),
    );

    if (isDisabled) {
      label = Opacity(opacity: bc.opacityDisabled, child: label);
    }
    if (isInsideField) {
      label = Padding(
        padding: EdgeInsets.symmetric(horizontal: BCSpacing.unit(1.5)),
        child: label,
      );
    }
    return label;
  }
}
