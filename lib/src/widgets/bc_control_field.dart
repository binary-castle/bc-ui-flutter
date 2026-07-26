import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import 'bc_pressable.dart';
import 'field_parts/bc_description.dart';
import 'field_parts/bc_label.dart';

/// HeroUI Native ControlField (control-field.css): a row (gap 12) pairing a
/// control (Switch, Checkbox, Radio…) with a label and optional description;
/// tapping anywhere activates the control.
class BCControlField extends StatelessWidget {
  const BCControlField({
    super.key,
    required this.control,
    required this.label,
    this.description,
    this.isDisabled = false,
    this.controlAtEnd = false,
    this.onPressed,
  });

  final Widget control;
  final String label;
  final String? description;
  final bool isDisabled;

  /// Places the control after the text content (e.g. trailing switch rows).
  final bool controlAtEnd;

  /// Called on tap anywhere in the field — toggle the control here.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final content = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BCLabel(label, isDisabled: isDisabled),
          if (description != null)
            BCDescription(description!, isDisabled: isDisabled),
        ],
      ),
    );

    Widget row = Row(
      spacing: 12,
      children: controlAtEnd ? [content, control] : [control, content],
    );

    if (isDisabled) {
      row = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: row),
      );
    }

    return BCPressable(
      feedback: BCPressFeedback.none,
      onPressed: isDisabled ? null : onPressed,
      enabled: !isDisabled,
      child: row,
    );
  }
}
