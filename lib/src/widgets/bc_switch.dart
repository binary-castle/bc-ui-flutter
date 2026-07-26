import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_motion.dart';

/// HeroUI Native Switch (switch.css / switch.animation.ts):
/// 48×24 pill track (`default` → accent, 150ms), 28×20 pill thumb sliding
/// from left 2 to 18 with a stiff spring (mass 2, stiffness 1600,
/// damping 120), thumb color white → accent-foreground, root press scale.
class BCSwitch extends StatefulWidget {
  const BCSwitch({
    super.key,
    required this.isSelected,
    this.onSelectedChange,
    this.isDisabled = false,
    this.startContent,
    this.endContent,
  });

  final bool isSelected;
  final ValueChanged<bool>? onSelectedChange;
  final bool isDisabled;

  /// Shown inside the track near the left edge (visible when selected).
  final Widget? startContent;

  /// Shown inside the track near the right edge (visible when unselected).
  final Widget? endContent;

  static const double _trackWidth = 48;
  static const double _trackHeight = 24;
  static const double _thumbWidth = 28;
  static const double _thumbHeight = 20;
  static const double _thumbInset = 2;

  @override
  State<BCSwitch> createState() => _BCSwitchState();
}

class _BCSwitchState extends State<BCSwitch>
    with TickerProviderStateMixin {
  /// 0 = unselected position, 1 = selected position.
  late final AnimationController _position = AnimationController(
    vsync: this,
    value: widget.isSelected ? 1 : 0,
  );
  late final AnimationController _pressScale = AnimationController(
    vsync: this,
    duration: BCMotion.pressScaleDuration,
  );

  @override
  void didUpdateWidget(BCSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _position.value = widget.isSelected ? 1 : 0;
      } else {
        _position.animateWith(
          SpringSimulation(
            BCMotion.switchThumbSpring,
            _position.value,
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
    _position.dispose();
    _pressScale.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onSelectedChange?.call(!widget.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final track = AnimatedBuilder(
      animation: _position,
      builder: (context, _) {
        final t = _position.value.clamp(0.0, 1.0);
        final trackColor = Color.lerp(bc.defaultColor, bc.accent, t)!;
        final thumbColor = Color.lerp(
          const Color(0xFFFFFFFF),
          bc.accentForeground,
          t,
        )!;
        final left = BCSwitch._thumbInset +
            _position.value *
                (BCSwitch._trackWidth -
                    BCSwitch._thumbWidth -
                    2 * BCSwitch._thumbInset);

        return Container(
          width: BCSwitch._trackWidth,
          height: BCSwitch._trackHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              if (widget.startContent != null)
                Positioned(
                  left: BCSwitch._thumbInset,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: t,
                    child: Center(child: widget.startContent),
                  ),
                ),
              if (widget.endContent != null)
                Positioned(
                  right: BCSwitch._thumbInset,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: 1 - t,
                    child: Center(child: widget.endContent),
                  ),
                ),
              Positioned(
                left: left,
                top: BCSwitch._thumbInset,
                child: Container(
                  width: BCSwitch._thumbWidth,
                  height: BCSwitch._thumbHeight,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: bc.fieldShadow.shadows,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Widget result = ScaleTransition(
      scale: _pressScale.drive(Tween(begin: 1, end: 0.96)),
      child: track,
    );

    if (widget.isDisabled) {
      result = Opacity(opacity: bc.opacityDisabled, child: result);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.isDisabled
          ? null
          : (_) => _pressScale.animateTo(1, curve: Curves.easeOut),
      onTapUp: widget.isDisabled
          ? null
          : (_) {
              _pressScale.animateBack(0, curve: Curves.easeOut);
              _toggle();
            },
      onTapCancel: () => _pressScale.animateBack(0, curve: Curves.easeOut),
      child: result,
    );
  }
}
