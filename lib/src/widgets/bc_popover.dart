import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../overlay/bc_overlay_anchor.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';

export '../overlay/bc_overlay_anchor.dart'
    show
        BCAnchoredOverlayController,
        BCOverlayAlignment,
        BCOverlayPlacement;

/// HeroUI Native Popover (popover.css): an anchored overlay card
/// (overlay background, px16/py12, 24px continuous corners, overlay shadow)
/// that scales in from the anchor.
class BCPopover extends StatefulWidget {
  const BCPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.controller,
    this.placement = BCOverlayPlacement.auto,
    this.alignment = BCOverlayAlignment.center,
    this.maxWidth = 300,
    this.onOpenChange,
  });

  /// Builds the trigger; call `controller.toggle()` from it.
  final Widget Function(
    BuildContext context,
    BCAnchoredOverlayController controller,
  ) trigger;

  final WidgetBuilder content;
  final BCAnchoredOverlayController? controller;
  final BCOverlayPlacement placement;
  final BCOverlayAlignment alignment;
  final double maxWidth;
  final ValueChanged<bool>? onOpenChange;

  @override
  State<BCPopover> createState() => _BCPopoverState();
}

class _BCPopoverState extends State<BCPopover> {
  BCAnchoredOverlayController? _internal;

  BCAnchoredOverlayController get _controller =>
      widget.controller ?? (_internal ??= BCAnchoredOverlayController());

  @override
  void dispose() {
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BCAnchoredOverlay(
      controller: _controller,
      placement: widget.placement,
      alignment: widget.alignment,
      onOpenChange: widget.onOpenChange,
      overlayBuilder: (overlayContext) {
        final bc = context.bcTheme;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: bc.overlay,
              shape: BCShapes.continuous(
                BCRadius.xxxl,
                side: bc.overlayShadow.innerBorder ?? BorderSide.none,
              ),
              shadows: bc.overlayShadow.shadows,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: widget.content(overlayContext),
          ),
        );
      },
      child: widget.trigger(context, _controller),
    );
  }
}

/// Popover title: text-lg, medium, foreground.
class BCPopoverTitle extends StatelessWidget {
  const BCPopoverTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCTypography.textLg.copyWith(
        color: context.bcTheme.foreground,
        fontWeight: BCTypography.medium,
      ),
    );
  }
}

/// Popover description: text-base, muted, 1.375 line-height.
class BCPopoverDescription extends StatelessWidget {
  const BCPopoverDescription(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCTypography.textBase.copyWith(
        color: context.bcTheme.muted,
        height: 1.375,
      ),
    );
  }
}
