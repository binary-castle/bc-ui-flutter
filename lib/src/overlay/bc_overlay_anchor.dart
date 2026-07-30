import 'dart:math' as math;

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

/// Room the preferred side must have before it is kept in preference to the
/// side with more space.
const double _kRoomySide = 240;

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
///
/// The on-screen keyboard counts as an edge. Overlays render outside any
/// Scaffold, so nothing resizes them out of the keyboard's way; the delegate
/// takes the bottom view inset off the usable height itself, and the overlay
/// re-lays-out — shrinking, or flipping above the anchor — as the keyboard
/// comes and goes. That is what keeps a Select's search field and its rows on
/// screen while you type.
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final OverlayPortalController _portal = OverlayPortalController();

  late final AnimationController _transition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 150),
  );

  Rect _anchorRect = Rect.zero;

  /// Height of the Overlay the portal draws into — the whole screen, keyboard
  /// included.
  double _viewportHeight = 0;

  /// Bottom view inset: the on-screen keyboard.
  double _bottomInset = 0;

  /// Top padding: the status bar and the notch. The Overlay spans the whole
  /// screen, so an overlay flipped above its trigger would otherwise slide
  /// under them.
  double _topInset = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
    _transition.addStatusListener(_handleStatusChange);
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_handleControllerChange);
    _transition.dispose();
    super.dispose();
  }

  /// The keyboard opening or closing, or the screen rotating — each moves the
  /// ground under an open overlay, so it is measured again.
  @override
  void didChangeMetrics() {
    if (!_portal.isShowing) return;
    // After the frame those metrics produce: the keyboard resizes the page the
    // trigger sits in, so the anchor is only correct once it has been laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_portal.isShowing) return;
      final anchorBefore = _anchorRect;
      final insetsBefore = (_bottomInset, _topInset);
      _captureAnchor();
      if (_anchorRect != anchorBefore ||
          (_bottomInset, _topInset) != insetsBefore) {
        setState(() {});
      }
    });
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
    _viewportHeight =
        overlay?.size.height ?? MediaQuery.sizeOf(context).height;

    // The keyboard, read off the view rather than an ambient MediaQuery.
    // Neither MediaQuery in reach reports it: a Scaffold with
    // resizeToAvoidBottomInset on zeroes the bottom inset throughout its body,
    // and an OverlayPortal's overlay child inherits from the anchor's position
    // in the tree, so it sees that same zero — while being drawn in the
    // Overlay, where the keyboard very much does cover it.
    final view = View.of(context);
    _bottomInset = view.viewInsets.bottom / view.devicePixelRatio;
    // `viewPadding` for the top: the notch is there whether or not the keyboard
    // is, and unlike `padding` it does not shift when the keyboard opens.
    _topInset = view.viewPadding.top / view.devicePixelRatio;
  }

  /// Which side of the anchor the overlay ends up on: the requested side while
  /// it has room, otherwise whichever side has more. The keyboard is taken off
  /// the space below, so a trigger sitting mid-screen opens upward instead of
  /// behind it.
  bool _resolvePlaceBelow() {
    final below = _viewportHeight -
        _bottomInset -
        _anchorRect.bottom -
        widget.gap -
        widget.screenMargin;
    final above =
        _anchorRect.top - _topInset - widget.gap - widget.screenMargin;

    if (widget.placement == BCOverlayPlacement.top) {
      return !(above >= _kRoomySide || above >= below);
    }
    return below >= _kRoomySide || below >= above;
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (overlayContext) {
        final placeBelow = _resolvePlaceBelow();
        final scaleOrigin = Alignment(0, placeBelow ? -1 : 1);

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
                  placeBelow: placeBelow,
                  alignment: widget.alignment,
                  gap: widget.gap,
                  margin: widget.screenMargin,
                  matchAnchorWidth: widget.matchAnchorWidth,
                  bottomInset: _bottomInset,
                  topInset: _topInset,
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
    required this.placeBelow,
    required this.alignment,
    required this.gap,
    required this.margin,
    required this.matchAnchorWidth,
    this.bottomInset = 0,
    this.topInset = 0,
  });

  final Rect anchorRect;

  /// The side already resolved by [BCAnchoredOverlay], so the height the child
  /// is given and the offset it is placed at agree.
  final bool placeBelow;

  final BCOverlayAlignment alignment;
  final double gap;
  final double margin;
  final bool matchAnchorWidth;

  /// Height at the bottom of the Overlay that the keyboard covers.
  final double bottomInset;

  /// Height at the top of the Overlay taken by the status bar and the notch.
  final double topInset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth - 2 * margin;
    // The keyboard and the status bar are edges like any other: the overlay may
    // not grow into either.
    final viewportHeight = constraints.maxHeight - bottomInset - topInset;
    final spaceBelow =
        constraints.maxHeight - bottomInset - anchorRect.bottom - gap - margin;
    final spaceAbove = anchorRect.top - topInset - gap - margin;
    final double heightCap = math.max(48.0, viewportHeight - 2 * margin);
    final double maxHeight =
        (placeBelow ? spaceBelow : spaceAbove).clamp(48.0, heightCap);

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
    x = x.clamp(margin, math.max(margin, size.width - childSize.width - margin));

    // Vertical: resolved side, flipped if the overlay still wouldn't fit, then
    // clamped between the status bar and the keyboard.
    final topLimit = topInset + margin;
    final bottomLimit = size.height - bottomInset - margin;
    double y;
    if (placeBelow) {
      y = anchorRect.bottom + gap;
      if (y + childSize.height > bottomLimit) {
        final above = anchorRect.top - gap - childSize.height;
        if (above >= topLimit) y = above;
      }
    } else {
      y = anchorRect.top - gap - childSize.height;
      if (y < topLimit) {
        final below = anchorRect.bottom + gap;
        if (below + childSize.height <= bottomLimit) y = below;
      }
    }
    y = y.clamp(topLimit, math.max(topLimit, bottomLimit - childSize.height));

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_AnchoredOverlayLayoutDelegate oldDelegate) {
    return anchorRect != oldDelegate.anchorRect ||
        placeBelow != oldDelegate.placeBelow ||
        alignment != oldDelegate.alignment ||
        gap != oldDelegate.gap ||
        margin != oldDelegate.margin ||
        matchAnchorWidth != oldDelegate.matchAnchorWidth ||
        bottomInset != oldDelegate.bottomInset ||
        topInset != oldDelegate.topInset;
  }
}
