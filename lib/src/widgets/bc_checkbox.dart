import 'package:flutter/material.dart' show Icons;
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_motion.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';

enum BCCheckboxVariant { primary, secondary }

/// HeroUI Native Checkbox (checkbox.css): 24×24 with 8px continuous corners,
/// field background + field shadow (primary), accent overlay with a
/// spring-scaled check when selected (stiffness 1200, damping 120);
/// danger colors when invalid.
class BCCheckbox extends StatefulWidget {
  const BCCheckbox({
    super.key,
    required this.isSelected,
    this.onSelectedChange,
    this.variant = BCCheckboxVariant.primary,
    this.isInvalid = false,
    this.isDisabled = false,
    this.icon,
  });

  final bool isSelected;
  final ValueChanged<bool>? onSelectedChange;
  final BCCheckboxVariant variant;
  final bool isInvalid;
  final bool isDisabled;

  /// Custom indicator icon; defaults to a check.
  final Widget? icon;

  @override
  State<BCCheckbox> createState() => _BCCheckboxState();
}

class _BCCheckboxState extends State<BCCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _indicator = AnimationController(
    vsync: this,
    value: widget.isSelected ? 1 : 0,
  );

  @override
  void didUpdateWidget(BCCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _indicator.value = widget.isSelected ? 1 : 0;
      } else {
        _indicator.animateWith(
          SpringSimulation(
            BCMotion.checkboxIndicatorSpring,
            _indicator.value,
            widget.isSelected ? 1 : 0,
            0,
            snapToEnd: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _indicator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final unselectedInvalid = widget.isInvalid && !widget.isSelected;

    final Color baseColor;
    if (unselectedInvalid) {
      baseColor = const Color(0x00000000);
    } else if (widget.variant == BCCheckboxVariant.primary) {
      baseColor = bc.field;
    } else {
      baseColor = bc.defaultColor;
    }

    final shape = BCShapes.continuous(
      BCRadius.lg,
      side: widget.isInvalid
          ? BorderSide(color: bc.danger, width: 1)
          : BorderSide.none,
    );

    Widget box = Container(
      width: 24,
      height: 24,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: baseColor,
        shape: shape,
        shadows:
            widget.variant == BCCheckboxVariant.primary && !unselectedInvalid
                ? bc.fieldShadow.shadows
                : null,
      ),
      child: FadeTransition(
        opacity: _indicator.drive(Tween(begin: 0, end: 1)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.isInvalid ? bc.danger : bc.accent,
          ),
          child: ScaleTransition(
            scale: _indicator,
            child: Center(
              child: widget.icon ??
                  Icon(
                    Icons.check,
                    size: 16,
                    color: widget.isInvalid
                        ? bc.dangerForeground
                        : bc.accentForeground,
                  ),
            ),
          ),
        ),
      ),
    );

    if (widget.isDisabled) {
      box = Opacity(opacity: bc.opacityDisabled, child: box);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.isDisabled
          ? null
          : () => widget.onSelectedChange?.call(!widget.isSelected),
      child: box,
    );
  }
}
