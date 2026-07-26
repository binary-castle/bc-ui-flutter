import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

enum BCTagGroupSelectionMode { none, single, multiple }

enum BCTagVariant { defaultVariant, surface }

enum BCTagSize { sm, md, lg }

class BCTagItem<T> {
  const BCTagItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// HeroUI Native TagGroup (tag-group.css): a wrapping list (gap 8) of
/// selectable pills; selected tags use the accent-soft background and
/// foreground.
class BCTagGroup<T> extends StatelessWidget {
  const BCTagGroup({
    super.key,
    required this.items,
    this.selectionMode = BCTagGroupSelectionMode.single,
    this.selectedValues = const {},
    this.onSelectionChange,
    this.onRemove,
    this.variant = BCTagVariant.defaultVariant,
    this.size = BCTagSize.md,
    this.isDisabled = false,
  });

  final List<BCTagItem<T>> items;
  final BCTagGroupSelectionMode selectionMode;
  final Set<T> selectedValues;
  final ValueChanged<Set<T>>? onSelectionChange;

  /// When provided, tags render a remove button.
  final ValueChanged<T>? onRemove;

  final BCTagVariant variant;
  final BCTagSize size;
  final bool isDisabled;

  void _toggle(T value) {
    if (onSelectionChange == null) return;
    final next = Set<T>.of(selectedValues);
    switch (selectionMode) {
      case BCTagGroupSelectionMode.none:
        return;
      case BCTagGroupSelectionMode.single:
        next
          ..clear()
          ..add(value);
      case BCTagGroupSelectionMode.multiple:
        next.contains(value) ? next.remove(value) : next.add(value);
    }
    onSelectionChange!(next);
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    Widget group = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          _BCTag(
            label: item.label,
            isSelected: selectedValues.contains(item.value),
            variant: variant,
            size: size,
            onPressed: selectionMode == BCTagGroupSelectionMode.none
                ? null
                : () => _toggle(item.value),
            onRemove: onRemove == null ? null : () => onRemove!(item.value),
          ),
      ],
    );

    if (isDisabled) {
      group = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: group),
      );
    }

    return group;
  }
}

class _BCTag extends StatelessWidget {
  const _BCTag({
    required this.label,
    required this.isSelected,
    required this.variant,
    required this.size,
    this.onPressed,
    this.onRemove,
  });

  final String label;
  final bool isSelected;
  final BCTagVariant variant;
  final BCTagSize size;
  final VoidCallback? onPressed;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final radius = switch (size) {
      BCTagSize.sm => BCRadius.xl,
      BCTagSize.md => BCRadius.xxl,
      BCTagSize.lg => BCRadius.xxxl,
    };
    final padding = switch (size) {
      BCTagSize.sm =>
        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      BCTagSize.md =>
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      BCTagSize.lg =>
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    };
    final labelStyle = switch (size) {
      BCTagSize.sm => BCTypography.textXs,
      BCTagSize.md => BCTypography.textSm,
      BCTagSize.lg => BCTypography.textBase,
    };

    final backgroundColor = isSelected
        ? bc.accentSoft
        : switch (variant) {
            BCTagVariant.defaultVariant => bc.defaultColor,
            BCTagVariant.surface => bc.surface,
          };
    final labelColor =
        isSelected ? bc.accentSoftForeground : bc.fieldForeground;

    final shape = BCShapes.continuous(radius);

    return BCPressable(
      onPressed: onPressed,
      shape: shape,
      enabled: onPressed != null,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(color: backgroundColor, shape: shape),
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: switch (size) {
            BCTagSize.sm || BCTagSize.md => 4.0,
            BCTagSize.lg => 6.0,
          },
          children: [
            Text(
              label,
              style: labelStyle.copyWith(
                color: labelColor,
                fontWeight: BCTypography.medium,
              ),
            ),
            if (onRemove != null)
              BCPressable(
                feedback: BCPressFeedback.none,
                onPressed: onRemove,
                child: Icon(
                  Icons.close,
                  size: labelStyle.fontSize,
                  color: labelColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
