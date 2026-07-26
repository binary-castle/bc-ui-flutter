import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../overlay/bc_overlay_anchor.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

class BCSelectItem<T> {
  const BCSelectItem({
    required this.value,
    required this.label,
    this.description,
  });

  final T value;
  final String label;
  final String? description;
}

/// HeroUI Native Select (select.css): a surface-styled trigger
/// (py12/px16, radius 16, surface shadow) with a rotating chevron, opening
/// an anchored option list (overlay bg, p12, radius 24) with accent check
/// indicators.
class BCSelect<T> extends StatefulWidget {
  const BCSelect({
    super.key,
    required this.items,
    this.value,
    this.onValueChange,
    this.placeholder = 'Select an option',
    this.listLabel,
    this.isDisabled = false,
    this.placement = BCOverlayPlacement.auto,
  });

  final List<BCSelectItem<T>> items;
  final T? value;
  final ValueChanged<T>? onValueChange;
  final String placeholder;

  /// Optional label above the option list (select__list-label).
  final String? listLabel;

  final bool isDisabled;
  final BCOverlayPlacement placement;

  @override
  State<BCSelect<T>> createState() => _BCSelectState<T>();
}

class _BCSelectState<T> extends State<BCSelect<T>> {
  final BCAnchoredOverlayController _controller =
      BCAnchoredOverlayController();
  bool _isOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BCSelectItem<T>? get _selected {
    for (final item in widget.items) {
      if (item.value == widget.value) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final selected = _selected;

    final triggerShape = BCShapes.continuous(BCRadius.xxl);

    Widget trigger = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: bc.surface,
        shape: triggerShape,
        shadows: bc.surfaceShadow.shadows,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Text(
              selected?.label ?? widget.placeholder,
              style: BCTypography.textBase.copyWith(
                color:
                    selected != null ? bc.foreground : bc.fieldPlaceholder,
              ),
            ),
          ),
          AnimatedRotation(
            turns: _isOpen ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: bc.muted,
            ),
          ),
        ],
      ),
    );

    if (widget.isDisabled) {
      trigger = Opacity(opacity: bc.opacityDisabled, child: trigger);
    }

    return BCAnchoredOverlay(
      controller: _controller,
      placement: widget.placement,
      matchAnchorWidth: true,
      onOpenChange: (open) => setState(() => _isOpen = open),
      overlayBuilder: (overlayContext) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: bc.overlay,
            shape: BCShapes.continuous(
              BCRadius.xxxl,
              side: bc.overlayShadow.innerBorder ?? BorderSide.none,
            ),
            shadows: bc.overlayShadow.shadows,
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.listLabel != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(
                      widget.listLabel!,
                      style: BCTypography.textSm.copyWith(
                        color: bc.muted,
                        fontWeight: BCTypography.medium,
                      ),
                    ),
                  ),
                for (final item in widget.items)
                  _buildItem(context, item, bc: bc),
              ],
            ),
          ),
        );
      },
      child: BCPressable(
        feedback: BCPressFeedback.scale,
        enabled: !widget.isDisabled,
        onPressed: widget.isDisabled ? null : _controller.toggle,
        child: trigger,
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    BCSelectItem<T> item, {
    required BCThemeExtension bc,
  }) {
    final isSelected = item.value == widget.value;

    return BCPressable(
      feedback: BCPressFeedback.highlight,
      shape: BCShapes.continuous(BCRadius.xxl),
      highlightColor: bc.surfaceHover,
      highlightOpacityRange: (0.0, 1.0),
      onPressed: () {
        _controller.close();
        widget.onValueChange?.call(item.value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: BCTypography.textBase.copyWith(
                      color: bc.foreground,
                      fontWeight: BCTypography.medium,
                    ),
                  ),
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: BCTypography.textSm.copyWith(
                        color: bc.muted,
                        height: 1.375,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
              height: 20,
              child: isSelected
                  ? Icon(Icons.check, size: 18, color: bc.accent)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
