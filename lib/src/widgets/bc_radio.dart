import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import 'bc_pressable.dart';
import 'field_parts/bc_description.dart';
import 'field_parts/bc_label.dart';

enum BCRadioVariant { primary, secondary }

/// HeroUI Native RadioGroup: provides the selected value to descendant
/// [BCRadio]s via an inherited scope.
class BCRadioGroup<T> extends StatelessWidget {
  const BCRadioGroup({
    super.key,
    required this.value,
    required this.onValueChange,
    required this.children,
    this.isDisabled = false,
    this.gap = 16,
  });

  final T? value;
  final ValueChanged<T>? onValueChange;
  final List<Widget> children;
  final bool isDisabled;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return _BCRadioGroupScope<T>(
      value: value,
      onValueChange: onValueChange,
      isDisabled: isDisabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: children,
      ),
    );
  }
}

/// HeroUI Native Radio (radio.css): a row with label/description content and
/// a trailing 24px round indicator — field background when idle, accent when
/// selected (danger when invalid), with a 10px fading thumb.
class BCRadio<T> extends StatelessWidget {
  const BCRadio({
    super.key,
    required this.value,
    this.label,
    this.description,
    this.child,
    this.variant = BCRadioVariant.primary,
    this.isInvalid = false,
    this.isDisabled = false,
  });

  final T value;
  final String? label;
  final String? description;

  /// Custom content shown instead of [label]/[description].
  final Widget? child;

  final BCRadioVariant variant;
  final bool isInvalid;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final scope = _BCRadioGroupScope.of<T>(context);

    final isSelected = scope?.value == value;
    final disabled = isDisabled || (scope?.isDisabled ?? false);

    final Color indicatorColor;
    if (isInvalid) {
      indicatorColor = isSelected ? bc.danger : const Color(0x00000000);
    } else if (isSelected) {
      indicatorColor = bc.accent;
    } else {
      indicatorColor = switch (variant) {
        BCRadioVariant.primary => bc.field,
        BCRadioVariant.secondary => bc.defaultColor,
      };
    }

    final indicator = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: isInvalid && !isSelected
            ? Border.all(color: bc.danger)
            : null,
        boxShadow: variant == BCRadioVariant.primary && !isInvalid
            ? bc.fieldShadow.shadows
            : null,
      ),
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1 : 0.4,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: isSelected ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: bc.accentForeground,
                shape: BoxShape.circle,
                boxShadow: bc.fieldShadow.shadows,
              ),
            ),
          ),
        ),
      ),
    );

    Widget content = Row(
      spacing: 12,
      children: [
        Expanded(
          child: child ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    BCLabel(label!, isDisabled: disabled),
                  if (description != null)
                    BCDescription(description!, isDisabled: disabled),
                ],
              ),
        ),
        indicator,
      ],
    );

    if (disabled) {
      content = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: content),
      );
    }

    return BCPressable(
      feedback: BCPressFeedback.none,
      enabled: !disabled,
      onPressed: disabled ? null : () => scope?.onValueChange?.call(value),
      child: content,
    );
  }
}

class _BCRadioGroupScope<T> extends InheritedWidget {
  const _BCRadioGroupScope({
    required this.value,
    required this.onValueChange,
    required this.isDisabled,
    required super.child,
  });

  final T? value;
  final ValueChanged<T>? onValueChange;
  final bool isDisabled;

  static _BCRadioGroupScope<T>? of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BCRadioGroupScope<T>>();

  @override
  bool updateShouldNotify(_BCRadioGroupScope<T> oldWidget) =>
      value != oldWidget.value || isDisabled != oldWidget.isDisabled;
}
