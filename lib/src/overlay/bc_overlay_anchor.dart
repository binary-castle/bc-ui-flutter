import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';

/// Vertical placement preference for an anchored overlay.
enum BCOverlayPlacement { bottom, top, auto }

/// Horizontal alignment of the overlay relative to its anchor.
enum BCOverlayAlignment { start, center, end }

/// Controller for a [BCAnchoredOverlay].
class BCAnchoredOverlayController extends ChangeNotifier {
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  void toggle() => _isOpen ? close() : open();
}

/// Anchored overlay engine shared by Popover, Menu, and Select.
///
/// Positions the overlay relative to the anchor with a layout delegate that
/// always keeps it fully inside the screen: it prefers the requested
/// vertical placement but flips when there is not enough room, and clamps
/// horizontally — a trigger at the right edge opens leftward, one at the
/// bottom opens upward, and so on. The content enters with
/// scale 0.96 → 1 + fade over 200ms and exits in 150ms, matching heroui's
/// popup content animations; a full-screen barrier dismisses on outside
/// taps.
class BCAnchoredOverlay extends StatefulWidget {
  const BCAnchoredOverlay({
    super.key,
    required this.controller,
    required this.overlayBuilder,
    required this.child,
    this.placement = BCOverlayPlacement.auto,
    this.alignment = BCOverlayAlignment.start,
    this.gap = 8,
    this.screenMargin = 12,
    this.matchAnchorWidth = false,
    this.barrierColor,
    this.onOpenChange,
  });

  final BCAnchoredOverlayController controller;
  final WidgetBuilder overlayBuilder;

  /// The anchor (trigger) widget.
  final Widget child;

  final BCOverlayPlacement placement;
  final BCOverlayAlignment alignment;

  /// Space between anchor and overlay.
  final double gap;

  /// Minimum distance kept between the overlay and the screen edges.
  final double screenMargin;

  /// Sizes the overlay to the anchor's width (used by Select).
  final bool matchAnchorWidth;

  /// Color of the dismiss barrier. Defaults to fully transparent.
  final Color? barrierColor;

  final ValueChanged<bool>? onOpenChange;

  @override
  State<BCAnchoredOverlay> createState() => _BCAnchoredOverlayState();
}

class _BCAnchoredOverlayState extends State<BCAnchoredOverlay>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();

  late final AnimationController _transition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 150),
  );

  Rect _anchorRect = Rect.zero;
  bool _preferBelow = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
    _transition.addStatusListener(_handleStatusChange);
  }

  @override
  void didUpdateWidget(BCAnchoredOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _transition.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (widget.controller.isOpen) {
      _captureAnchor();
      _portal.show();
      _transition.forward();
      widget.onOpenChange?.call(true);
    } else {
      _transition.reverse();
      widget.onOpenChange?.call(false);
    }
  }

  void _handleStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _portal.isShowing) {
      _portal.hide();
    }
  }

  void _captureAnchor() {
    final box = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    _anchorRect = topLeft & box.size;

    final screenHeight =
        overlay?.size.height ?? MediaQuery.sizeOf(context).height;
    final spaceBelow = screenHeight - _anchorRect.bottom;
    final spaceAbove = _anchorRect.top;

    _preferBelow = switch (widget.placement) {
      BCOverlayPlacement.bottom => true,
      BCOverlayPlacement.top => false,
      // Flip up when below-space is tight and above has more room.
      BCOverlayPlacement.auto =>
        spaceBelow >= 240 || spaceBelow >= spaceAbove,
    };
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (overlayContext) {
        final scaleOrigin = Alignment(0, _preferBelow ? -1 : 1);

        return Stack(
          children: [
            // Dismiss barrier
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.controller.close,
                child: widget.barrierColor == null
                    ? const SizedBox.expand()
                    : FadeTransition(
                        opacity: _transition,
                        child: ColoredBox(color: widget.barrierColor!),
                      ),
              ),
            ),
            Positioned.fill(
              child: CustomSingleChildLayout(
                delegate: _AnchoredOverlayLayoutDelegate(
                  anchorRect: _anchorRect,
                  preferBelow: _preferBelow,
                  alignment: widget.alignment,
                  gap: widget.gap,
                  margin: widget.screenMargin,
                  matchAnchorWidth: widget.matchAnchorWidth,
                ),
                // Overlays render outside any Scaffold; a transparent
                // Material supplies the correct DefaultTextStyle (no yellow
                // "missing Material" underline) for the content's text.
                child: Material(
                  type: MaterialType.transparency,
                  child: FadeTransition(
                    opacity: _transition,
                    child: ScaleTransition(
                      scale: _transition.drive(
                        Tween<double>(begin: 0.96, end: 1)
                            .chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      alignment: scaleOrigin,
                      child: widget.overlayBuilder(overlayContext),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Positions the overlay near the anchor while always keeping it fully on
/// screen (mirrors the flip/shift behavior of Material's popup menus).
class _AnchoredOverlayLayoutDelegate extends SingleChildLayoutDelegate {
  _AnchoredOverlayLayoutDelegate({
    required this.anchorRect,
    required this.preferBelow,
    required this.alignment,
    required this.gap,
    required this.margin,
    required this.matchAnchorWidth,
  });

  final Rect anchorRect;
  final bool preferBelow;
  final BCOverlayAlignment alignment;
  final double gap;
  final double margin;
  final bool matchAnchorWidth;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth - 2 * margin;
    final spaceBelow = constraints.maxHeight - anchorRect.bottom - gap;
    final spaceAbove = anchorRect.top - gap;
    final maxHeight = ((preferBelow ? spaceBelow : spaceAbove) - margin)
        .clamp(48.0, constraints.maxHeight - 2 * margin);

    return BoxConstraints(
      minWidth: matchAnchorWidth
          ? anchorRect.width.clamp(0.0, maxWidth)
          : 0.0,
      maxWidth: matchAnchorWidth
          ? anchorRect.width.clamp(0.0, maxWidth)
          : maxWidth,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Horizontal: align to the anchor, then clamp inside the screen —
    // a trigger at the right edge naturally opens leftward.
    double x = switch (alignment) {
      BCOverlayAlignment.start => anchorRect.left,
      BCOverlayAlignment.center =>
        anchorRect.center.dx - childSize.width / 2,
      BCOverlayAlignment.end => anchorRect.right - childSize.width,
    };
    x = x.clamp(margin, size.width - childSize.width - margin);

    // Vertical: preferred side, flipped if the overlay wouldn't fit,
    // then clamped.
    double y;
    if (preferBelow) {
      y = anchorRect.bottom + gap;
      if (y + childSize.height > size.height - margin) {
        final above = anchorRect.top - gap - childSize.height;
        if (above >= margin) y = above;
      }
    } else {
      y = anchorRect.top - gap - childSize.height;
      if (y < margin) {
        final below = anchorRect.bottom + gap;
        if (below + childSize.height <= size.height - margin) y = below;
      }
    }
    y = y.clamp(margin, size.height - childSize.height - margin);

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_AnchoredOverlayLayoutDelegate oldDelegate) {
    return anchorRect != oldDelegate.anchorRect ||
        preferBelow != oldDelegate.preferBelow ||
        alignment != oldDelegate.alignment ||
        gap != oldDelegate.gap ||
        margin != oldDelegate.margin ||
        matchAnchorWidth != oldDelegate.matchAnchorWidth;
  }
}
