import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

enum BCToggleButtonSize { sm, md, lg }

/// Selected-state styling for [BCToggleButton].
enum BCToggleButtonVariant {
  /// Neutral `default`-colored background, foreground text (the standard look).
  standard,

  /// Accent-soft background with accent foreground.
  accent,

  /// No background — only the icon/label color changes to accent.
  ghost,
}

/// A button that stays visually "on" while selected — Like, Save, Bookmark,
/// mute, and similar sticky actions.
///
/// Unselected it is transparent with muted-to-foreground content; selected it
/// fills with the variant's background. Supports an optional [selectedIcon]
/// (e.g. outline heart → filled heart) and an [isIconOnly] circular form.
class BCToggleButton extends StatelessWidget {
  const BCToggleButton({
    super.key,
    required this.isSelected,
    this.onSelectedChange,
    this.icon,
    this.selectedIcon,
    this.label,
    this.size = BCToggleButtonSize.md,
    this.variant = BCToggleButtonVariant.standard,
    this.isIconOnly = false,
    this.isDisabled = false,
    this.feedback = BCPressFeedback.scale,
  })  : assert(
          icon != null || label != null,
          'BCToggleButton needs an icon, a label, or both',
        ),
        assert(
          !isIconOnly || icon != null,
          'isIconOnly requires an icon',
        );

  final bool isSelected;
  final ValueChanged<bool>? onSelectedChange;

  final Widget? icon;

  /// Shown instead of [icon] while selected (e.g. a filled variant).
  final Widget? selectedIcon;

  final String? label;

  final BCToggleButtonSize size;
  final BCToggleButtonVariant variant;

  /// Circular, label-free form.
  final bool isIconOnly;

  final bool isDisabled;
  final BCPressFeedback feedback;

  double get _height => switch (size) {
        BCToggleButtonSize.sm => 36,
        BCToggleButtonSize.md => 44,
        BCToggleButtonSize.lg => 52,
      };

  double get _paddingX => switch (size) {
        BCToggleButtonSize.sm => 12,
        BCToggleButtonSize.md => 16,
        BCToggleButtonSize.lg => 20,
      };

  double get _gap => switch (size) {
        BCToggleButtonSize.sm => 6,
        BCToggleButtonSize.md => 8,
        BCToggleButtonSize.lg => 10,
      };

  TextStyle get _labelStyle => switch (size) {
        BCToggleButtonSize.sm => BCTypography.textSm,
        BCToggleButtonSize.md => BCTypography.textBase,
        BCToggleButtonSize.lg => BCTypography.textLg,
      };

  double get _iconSize => switch (size) {
        BCToggleButtonSize.sm => 18,
        BCToggleButtonSize.md => 20,
        BCToggleButtonSize.lg => 24,
      };

  Color _backgroundColor(BCThemeExtension bc) {
    if (!isSelected) return const Color(0x00000000);
    return switch (variant) {
      BCToggleButtonVariant.standard => bc.defaultColor,
      BCToggleButtonVariant.accent => bc.accentSoft,
      BCToggleButtonVariant.ghost => const Color(0x00000000),
    };
  }

  Color _contentColor(BCThemeExtension bc) {
    if (!isSelected) return bc.foreground;
    return switch (variant) {
      BCToggleButtonVariant.standard => bc.foreground,
      BCToggleButtonVariant.accent ||
      BCToggleButtonVariant.ghost =>
        bc.accentSoftForeground,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final contentColor = _contentColor(bc);
    final shape = const StadiumBorder();

    final resolvedIcon = (isSelected ? selectedIcon : null) ?? icon;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: _gap,
      children: [
        if (resolvedIcon != null)
          IconTheme.merge(
            data: IconThemeData(color: contentColor, size: _iconSize),
            child: resolvedIcon,
          ),
        if (!isIconOnly && label != null)
          Text(
            label!,
            style: _labelStyle.copyWith(
              color: contentColor,
              fontWeight: BCTypography.medium,
            ),
          ),
      ],
    );

    Widget button = BCPressable(
      feedback: feedback,
      shape: shape,
      enabled: !isDisabled,
      onPressed: isDisabled
          ? null
          : () => onSelectedChange?.call(!isSelected),
      background: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: ShapeDecoration(
          color: _backgroundColor(bc),
          shape: shape,
        ),
      ),
      child: SizedBox(
        height: _height,
        width: isIconOnly ? _height : null,
        child: Padding(
          padding: isIconOnly
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: _paddingX),
          child: Center(child: content),
        ),
      ),
    );

    if (isDisabled) {
      button = Opacity(opacity: bc.opacityDisabled, child: button);
    }

    return button;
  }
}

/// One option inside a [BCToggleButtonGroup].
class BCToggleButtonOption<T> {
  const BCToggleButtonOption({
    required this.value,
    this.icon,
    this.selectedIcon,
    this.label,
  });

  final T value;
  final Widget? icon;
  final Widget? selectedIcon;
  final String? label;
}

/// A row of [BCToggleButton]s behaving as a set — single-select (like a
/// segmented choice) or multi-select (like formatting toggles).
class BCToggleButtonGroup<T> extends StatelessWidget {
  const BCToggleButtonGroup({
    super.key,
    required this.options,
    required this.selectedValues,
    this.onSelectionChange,
    this.allowMultiple = false,
    this.allowEmpty = true,
    this.size = BCToggleButtonSize.md,
    this.variant = BCToggleButtonVariant.standard,
    this.isIconOnly = false,
    this.isDisabled = false,
    this.spacing = 8,
  });

  final List<BCToggleButtonOption<T>> options;
  final Set<T> selectedValues;
  final ValueChanged<Set<T>>? onSelectionChange;

  /// Allows more than one option to be selected at a time.
  final bool allowMultiple;

  /// When false, the last selected option can't be deselected.
  final bool allowEmpty;

  final BCToggleButtonSize size;
  final BCToggleButtonVariant variant;
  final bool isIconOnly;
  final bool isDisabled;
  final double spacing;

  void _toggle(T value) {
    if (onSelectionChange == null) return;
    final next = Set<T>.of(selectedValues);
    final isSelected = next.contains(value);

    if (isSelected) {
      if (!allowEmpty && next.length == 1) return;
      next.remove(value);
    } else {
      if (!allowMultiple) next.clear();
      next.add(value);
    }
    onSelectionChange!(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final option in options)
          BCToggleButton(
            isSelected: selectedValues.contains(option.value),
            onSelectedChange: (_) => _toggle(option.value),
            icon: option.icon,
            selectedIcon: option.selectedIcon,
            label: option.label,
            size: size,
            variant: variant,
            isIconOnly: isIconOnly,
            isDisabled: isDisabled,
          ),
      ],
    );
  }
}
