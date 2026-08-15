import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_close_button.dart';

/// Motion for the dialog's swipe-to-dismiss, shared with `bc_toast.dart`'s
/// numbers so a dragged dialog and a dragged toast feel like the same surface.
abstract final class _DialogMotion {
  /// Past this much travel, or this much velocity, the dialog goes.
  static const double dismissDistance = 80;
  static const double dismissVelocity = 500;

  /// Dragging *up* is rubber-banded: the dialog gives at most this much
  /// however far the finger travels.
  static const double rubberBandDistance = 40;

  /// The dialog shrinks a hair while it is held.
  static const double dragScale = 0.995;

  /// `withSpring()` defaults — used to snap back an abandoned swipe.
  static const SpringDescription snapSpring = SpringDescription(
    mass: 1,
    stiffness: 100,
    damping: 10,
  );

  /// `withDecay()`'s deceleration in Flutter's per-second form, and the
  /// velocity boost given to the fling.
  static const double decayDrag = 0.135;
  static const double decayVelocityScale = 1.5;

  /// A flung dialog is popped this long after the fling starts, so the decay
  /// has time to carry it downwards before the route's exit runs.
  static const Duration maxFlingDelay = Duration(milliseconds: 200);
}

/// HeroUI Native Dialog.
///
/// `BCDialog.show` presents a centered modal over the black-20% backdrop
/// with heroui's content animation (scale 0.96 → 1 + fade, 200ms in /
/// 150ms out). Compose the content with [BCDialogContent], [BCDialogTitle],
/// and [BCDialogDescription].
///
/// The modal is built for forms as much as for confirmations: it lifts clear
/// of the on-screen keyboard, scrolls whatever no longer fits between the
/// status bar and the keyboard, and follows a downward swipe the way a bottom
/// sheet does. See [show] for the details of each.
abstract final class BCDialog {
  /// Presents [builder] over the themed backdrop.
  ///
  /// **Keyboard.** The dialog sits in the band above the keyboard rather than
  /// behind it, and any content that no longer fits in that band scrolls — so
  /// a modal with six fields in it stays reachable, and focusing a field
  /// scrolls it into view instead of leaving the caret under the keyboard.
  ///
  /// **Swipe.** With [isSwipeable] the dialog tracks a downward drag one to
  /// one, rubber-bands an upward one, and either springs back or is carried
  /// off by the throw — the same drag physics as [BCToast], not a gesture that
  /// merely triggers the close animation. While the content is tall enough to
  /// scroll, the scroll takes the drag; the swipe returns once it fits again.
  static Future<R?> show<R>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    bool isSwipeable = true,
  }) {
    final backdrop = context.bcTheme.backdrop;

    return showGeneralDialog<R>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: backdrop,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: curved.drive(Tween(begin: 0.96, end: 1)),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _BCDialogSurface(builder: builder, isSwipeable: isSwipeable);
      },
    );
  }
}

/// The keyboard-aware, swipeable frame [BCDialog.show] wraps its content in.
class _BCDialogSurface extends StatefulWidget {
  const _BCDialogSurface({required this.builder, required this.isSwipeable});

  final WidgetBuilder builder;
  final bool isSwipeable;

  @override
  State<_BCDialogSurface> createState() => _BCDialogSurfaceState();
}

class _BCDialogSurfaceState extends State<_BCDialogSurface>
    with TickerProviderStateMixin {
  /// Live swipe offset in logical pixels: driven by the finger while
  /// dragging, then by a spring (snap back) or a friction decay (fling).
  late final AnimationController _drag = AnimationController.unbounded(
    vsync: this,
  );

  /// 0 → 1 while the dialog is held.
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );

  /// Raw finger travel since the drag began, before rubber-banding.
  double _translation = 0;

  /// True once the content is taller than the room it has — see [_physics].
  bool _isScrollable = false;

  bool _dismissing = false;
  Timer? _flingTimer;

  @override
  void dispose() {
    _flingTimer?.cancel();
    _drag.dispose();
    _press.dispose();
    super.dispose();
  }

  /// The inner scroller only competes for vertical drags while it has
  /// somewhere to scroll to. Left unscrollable the rest of the time, it lets
  /// the drags through to the swipe-to-dismiss gesture underneath it, so the
  /// whole dialog — not just its margins — is a drag handle.
  ScrollPhysics get _physics => _isScrollable
      ? const ClampingScrollPhysics()
      : const NeverScrollableScrollPhysics();

  bool _handleScrollMetrics(ScrollMetricsNotification notification) {
    final isScrollable = notification.metrics.maxScrollExtent > 0;
    if (isScrollable != _isScrollable) {
      // Metrics arrive mid-layout; the physics swap has to wait for the frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isScrollable = isScrollable);
      });
    }
    return false;
  }

  void _handleDragStart(DragStartDetails details) {
    // Grabbing a dialog mid-flight takes over wherever it currently sits.
    _flingTimer?.cancel();
    _drag.stop();
    _translation = _drag.value;
    _press.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details, double viewportHeight) {
    _translation += details.delta.dy;

    if (_translation > 0) {
      // Downwards: the dialog tracks the finger 1:1.
      _drag.value = _translation;
    } else {
      // Upwards: rubber band, so a full-screen drag still only gives
      // rubberBandDistance.
      final progress = (_translation.abs() / math.max(viewportHeight, 1)).clamp(
        0.0,
        1.0,
      );
      _drag.value = -progress * _DialogMotion.rubberBandDistance;
    }
  }

  void _handleDragEnd(double velocity) {
    _press.reverse();

    final shouldDismiss =
        _translation > 0 &&
        (_translation > _DialogMotion.dismissDistance ||
            velocity > _DialogMotion.dismissVelocity);

    if (!shouldDismiss) {
      _drag.animateWith(
        SpringSimulation(_DialogMotion.snapSpring, _drag.value, 0, velocity),
      );
      return;
    }

    // Let the throw carry the dialog away first, then pop — the route's fade
    // and scale play out on a dialog that is already on its way down.
    _dismissing = true;
    _drag.animateWith(
      FrictionSimulation(
        _DialogMotion.decayDrag,
        _drag.value,
        velocity * _DialogMotion.decayVelocityScale,
      ),
    );
    _flingTimer = Timer(
      Duration(
        milliseconds: math.min(
          _DialogMotion.maxFlingDelay.inMilliseconds,
          velocity.round(),
        ),
      ),
      () {
        if (mounted) Navigator.of(context).maybePop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isSwipeable = widget.isSwipeable && !_dismissing;

    return Padding(
      // Lifts the dialog clear of the keyboard. Reading `viewInsets` is also
      // what rebuilds this frame as the keyboard slides, which re-measures the
      // content against the room that is left.
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return NotificationListener<ScrollMetricsNotification>(
              onNotification: _handleScrollMetrics,
              // Outside the scroller on purpose. Flutter's gesture arena hands
              // a vertical drag to the deepest competitor, so a detector
              // *inside* the scroll view would take every drag and the content
              // could never be scrolled; out here the scroller wins whenever
              // it has room to move, and the swipe gets the drags the rest of
              // the time. `deferToChild` keeps it off the space beside the
              // dialog, which belongs to the barrier.
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onVerticalDragStart: isSwipeable ? _handleDragStart : null,
                onVerticalDragUpdate: isSwipeable
                    ? (details) =>
                          _handleDragUpdate(details, constraints.maxHeight)
                    : null,
                onVerticalDragEnd: isSwipeable
                    ? (details) => _handleDragEnd(details.primaryVelocity ?? 0)
                    : null,
                onVerticalDragCancel: isSwipeable ? () => _handleDragEnd(0) : null,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_drag, _press]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _drag.value),
                      child: Transform.scale(
                        scale:
                            1 - (1 - _DialogMotion.dragScale) * _press.value,
                        child: child,
                      ),
                    );
                  },
                  child: SingleChildScrollView(
                    physics: _physics,
                    // The scroller spans the whole screen so the dialog can be
                    // centered in it, and an opaque one would swallow the taps
                    // meant for the barrier behind it. Deferring to the child
                    // keeps `barrierDismissible` working: only the dialog
                    // itself takes hits, the space around it falls through.
                    hitTestBehavior: HitTestBehavior.deferToChild,
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      // Centers the dialog while it fits, and gives the
                      // scroller something taller than itself to scroll once
                      // it doesn't.
                      constraints: BoxConstraints(
                        minHeight: math.max(constraints.maxHeight - 40, 0),
                      ),
                      child: Center(child: widget.builder(context)),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Dialog surface (dialog.css): overlay background, 20px padding, 24px
/// continuous corners, overlay shadow (1px white hairline in dark mode).
class BCDialogContent extends StatelessWidget {
  const BCDialogContent({
    super.key,
    required this.child,
    this.showCloseButton = false,
    this.width,
  });

  final Widget child;
  final bool showCloseButton;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: bc.overlay,
        shape: BCShapes.continuous(
          BCRadius.xxxl,
          side: bc.overlayShadow.innerBorder ?? BorderSide.none,
        ),
        shadows: bc.overlayShadow.shadows,
      ),
      padding: const EdgeInsets.all(20),
      child: Material(
        type: MaterialType.transparency,
        child: showCloseButton
            ? Stack(
                children: [
                  child,
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: BCCloseButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              )
            : child,
      ),
    );
  }
}

/// Dialog title: text-lg, medium, foreground.
class BCDialogTitle extends StatelessWidget {
  const BCDialogTitle(this.text, {super.key});

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

/// Dialog description: text-base, muted.
class BCDialogDescription extends StatelessWidget {
  const BCDialogDescription(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BCTypography.textBase.copyWith(color: context.bcTheme.muted),
    );
  }
}
