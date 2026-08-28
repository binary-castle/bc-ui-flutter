import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_button.dart';
import 'bc_close_button.dart';

enum BCToastVariant { defaultVariant, accent, success, warning, danger }

/// Which screen edge toasts stack against (toast.animation.ts `placement`).
///
/// The placement drives everything directional: a top toast springs in from
/// above, stacks downwards and is dismissed by swiping **up**; a bottom toast
/// does the mirror image.
enum BCToastPlacement { top, bottom }

/// Motion constants ported from heroui-native's `toast.animation.ts`.
abstract final class _ToastMotion {
  /// Distance the card covers entering and leaving.
  static const double travel = 100;

  /// Exit keyframe: 150ms to opacity 0.5 / scale 0.97 / translate [travel].
  static const Duration exitDuration = Duration(milliseconds: 150);
  static const Curve exitCurve = Cubic(0.4, 0, 1, 1);
  static const double exitOpacity = 0.5;
  static const double exitScale = 0.97;

  /// Past 50px of travel or 500px/s in the dismiss direction, the toast goes.
  static const double dismissDistance = 50;
  static const double dismissVelocity = 500;

  /// Dragging *against* the dismiss direction is rubber-banded: the card
  /// gives at most 40px however far the finger travels.
  static const double rubberBandDistance = 40;

  /// The card shrinks a hair while it is held.
  static const double dragScale = 0.995;

  /// Entrance spring.
  ///
  /// heroui-native uses `FadeInDown/FadeInUp.springify().mass(3)` — the
  /// Reanimated defaults at mass 3, which is a 0.29 damping ratio and rings
  /// three visible times before it rests. This keeps the same spring feel at
  /// a 0.75 ratio: one ~3px settle instead of a bounce sequence, and it comes
  /// to rest in about half a second.
  static final SpringDescription enterSpring =
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 150,
        ratio: 0.75,
      );

  /// `withSpring()` defaults — used to snap back an abandoned swipe.
  static const SpringDescription snapSpring = SpringDescription(
    mass: 1,
    stiffness: 100,
    damping: 10,
  );

  /// `withDecay()`'s deceleration, in Flutter's per-second form, and the
  /// velocity boost heroui gives the fling.
  static const double decayDrag = 0.135;
  static const double decayVelocityScale = 1.5;

  /// A flung toast is removed this long after the fling starts, so the decay
  /// has time to carry it off screen first.
  static const Duration maxFlingDelay = Duration(milliseconds: 200);
}

class BCToastData {
  const BCToastData({
    required this.title,
    this.description,
    this.variant = BCToastVariant.defaultVariant,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.showCloseButton = false,
    this.duration = const Duration(seconds: 4),
    this.placement,
    this.isSwipeable,
  });

  final String title;
  final String? description;
  final BCToastVariant variant;

  /// Optional leading icon, tinted to match [variant] unless it carries its
  /// own color.
  final Widget? icon;

  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showCloseButton;

  /// Auto-dismiss delay; `Duration.zero` keeps the toast until dismissed.
  final Duration duration;

  /// Overrides [BCToastProvider.placement] for this toast.
  final BCToastPlacement? placement;

  /// Overrides [BCToastProvider.isSwipeable] for this toast.
  final bool? isSwipeable;
}

/// HeroUI Native Toast.
///
/// Mount [BCToastProvider] above your app (e.g. `MaterialApp.builder`) and
/// call `BCToast.show(context, BCToastData(...))`. The newest card is
/// frontmost while older ones peek behind it, scaled and shifted (toast.tsx
/// stacked-collapse behavior).
///
/// Toasts stack against whichever edge [BCToastProvider.placement] names, and
/// a single toast can opt out with [BCToastData.placement]. Swiping toward
/// that edge drags the card with the finger and lets go of it — swipe up to
/// dismiss a top toast, down to dismiss a bottom one.
abstract final class BCToast {
  static void show(BuildContext context, BCToastData data) {
    final state = context.findAncestorStateOfType<_BCToastProviderState>();
    assert(
      state != null,
      'BCToast.show requires a BCToastProvider above this context '
      '(wrap your app via MaterialApp.builder).',
    );
    state?.showToast(data);
  }

  static void hideAll(BuildContext context) {
    context
        .findAncestorStateOfType<_BCToastProviderState>()
        ?.hideAll();
  }
}

class BCToastProvider extends StatefulWidget {
  const BCToastProvider({
    super.key,
    required this.child,
    this.maxVisible = 3,
    this.placement = BCToastPlacement.bottom,
    this.topInset = 16,
    this.bottomInset = 16,
    this.horizontalInset = 16,
    this.isSwipeable = true,
  });

  final Widget child;

  /// Older toasts beyond this count are dismissed immediately.
  final int maxVisible;

  /// Edge toasts stack against unless [BCToastData.placement] says otherwise.
  ///
  /// Defaults to [BCToastPlacement.bottom]; heroui-native's own default is
  /// `top`, so pass [BCToastPlacement.top] to match it exactly.
  final BCToastPlacement placement;

  /// Distance from the top safe area to a [BCToastPlacement.top] toast.
  final double topInset;

  /// Distance from the bottom safe area — or from the keyboard, whenever it
  /// covers more — to a [BCToastPlacement.bottom] toast.
  final double bottomInset;

  /// Distance from the left and right edges.
  final double horizontalInset;

  /// Whether toasts can be swiped away, unless [BCToastData.isSwipeable]
  /// says otherwise.
  final bool isSwipeable;

  @override
  State<BCToastProvider> createState() => _BCToastProviderState();
}

class _ToastEntry {
  _ToastEntry({
    required this.id,
    required this.data,
    required this.placement,
    required this.slide,
    required this.exit,
    required this.drag,
    required this.press,
  });

  final int id;
  final BCToastData data;
  final BCToastPlacement placement;

  /// Enter offset in logical pixels — springs from ±travel to rest.
  final AnimationController slide;

  /// 0 → 1 over the exit keyframe.
  final AnimationController exit;

  /// Live swipe offset in logical pixels: driven by the finger while
  /// dragging, then by a spring (snap back) or a friction decay (fling).
  final AnimationController drag;

  /// 0 → 1 while the card is held.
  final AnimationController press;

  /// Raw finger travel since the drag began, before rubber-banding.
  double translation = 0;

  Timer? timer;
  bool removing = false;

  /// +1 when the card leaves downwards, -1 when it leaves upwards.
  double get dismissSign => placement == BCToastPlacement.top ? -1 : 1;

  void dispose() {
    timer?.cancel();
    slide.dispose();
    exit.dispose();
    drag.dispose();
    press.dispose();
  }
}

class _BCToastProviderState extends State<BCToastProvider>
    with TickerProviderStateMixin {
  final List<_ToastEntry> _entries = [];
  int _nextId = 0;

  void showToast(BCToastData data) {
    final placement = data.placement ?? widget.placement;
    final entry = _ToastEntry(
      id: _nextId++,
      data: data,
      placement: placement,
      slide: AnimationController.unbounded(vsync: this),
      exit: AnimationController(
        vsync: this,
        duration: _ToastMotion.exitDuration,
      ),
      drag: AnimationController.unbounded(vsync: this),
      press: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
      ),
    );

    // Springs in from beyond the edge the toast is anchored to.
    final from = entry.dismissSign * _ToastMotion.travel;
    entry.slide.value = from;
    entry.slide.animateWith(
      SpringSimulation(_ToastMotion.enterSpring, from, 0, 0),
    );

    setState(() => _entries.add(entry));

    if (data.duration > Duration.zero) {
      entry.timer = Timer(data.duration, () => _dismiss(entry));
    }

    // Collapse overflow: drop the oldest beyond maxVisible. Each edge keeps
    // its own stack, so they overflow independently.
    final visible = _entries
        .where((e) => !e.removing && e.placement == placement)
        .toList();
    if (visible.length > widget.maxVisible) {
      _dismiss(visible.first);
    }
  }

  void hideAll() {
    for (final entry in List.of(_entries)) {
      _dismiss(entry);
    }
  }

  void _dismiss(_ToastEntry entry) {
    if (!mounted || entry.removing) return;
    entry.removing = true;
    entry.timer?.cancel();
    setState(() {});
    entry.exit.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _entries.remove(entry));
      entry.dispose();
    });
  }

  void _handleDragStart(_ToastEntry entry) {
    // Grabbing a card mid-flight takes over wherever it currently sits.
    entry.drag.stop();
    entry.translation = entry.drag.value;
    entry.press.forward();
  }

  void _handleDragUpdate(
    _ToastEntry entry,
    DragUpdateDetails details,
    double viewportHeight,
  ) {
    entry.translation += details.delta.dy;
    final travel = entry.translation;

    if (travel * entry.dismissSign > 0) {
      // Toward the anchored edge: the card tracks the finger 1:1.
      entry.drag.value = travel;
    } else {
      // Away from it: rubber band, so a full-screen drag still only gives
      // rubberBandDistance.
      final progress = (travel.abs() / math.max(viewportHeight, 1)).clamp(
        0.0,
        1.0,
      );
      entry.drag.value =
          -entry.dismissSign * progress * _ToastMotion.rubberBandDistance;
    }
  }

  void _handleDragEnd(_ToastEntry entry, double velocity) {
    entry.press.reverse();

    final travel = entry.translation;
    final towardEdge = travel * entry.dismissSign > 0;
    final shouldDismiss =
        towardEdge &&
        (travel.abs() > _ToastMotion.dismissDistance ||
            velocity.abs() > _ToastMotion.dismissVelocity);

    if (!shouldDismiss) {
      entry.drag.animateWith(
        SpringSimulation(
          _ToastMotion.snapSpring,
          entry.drag.value,
          0,
          velocity,
        ),
      );
      return;
    }

    // Let the throw carry the card away first, then run the exit keyframe.
    entry.drag.animateWith(
      FrictionSimulation(
        _ToastMotion.decayDrag,
        entry.drag.value,
        velocity * _ToastMotion.decayVelocityScale,
      ),
    );
    entry.timer?.cancel();
    entry.timer = Timer(
      Duration(
        milliseconds: math.min(
          _ToastMotion.maxFlingDelay.inMilliseconds,
          velocity.abs().round(),
        ),
      ),
      () => _dismiss(entry),
    );
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.paddingOf(context);
    final viewportHeight = MediaQuery.sizeOf(context).height;

    // The keyboard. A bottom toast that ignores it comes up behind the keys,
    // where there is nothing to see. Unlike BCOverlayAnchor, the ambient
    // MediaQuery is the right source here, because this Stack is laid out
    // exactly where the toasts are drawn: a provider mounted above the app —
    // the documented spot — sees the real keyboard and lifts clear of it,
    // while one sitting inside a Scaffold that already resized itself around
    // the keyboard reads the zero that Scaffold reports and stays put.
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Directionality(
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          for (final placement in BCToastPlacement.values)
            _buildStack(placement, viewPadding, keyboardInset, viewportHeight),
        ],
      ),
    );
  }

  /// One anchored stack per edge — a toast only ever belongs to one of them.
  Widget _buildStack(
    BCToastPlacement placement,
    EdgeInsets viewPadding,
    double keyboardInset,
    double viewportHeight,
  ) {
    final entries = [
      for (final entry in _entries)
        if (entry.placement == placement) entry,
    ];
    if (entries.isEmpty) return const SizedBox.shrink();

    final visible = [
      for (final entry in entries)
        if (!entry.removing) entry,
    ];
    final isTop = placement == BCToastPlacement.top;

    return Positioned(
      left: widget.horizontalInset,
      right: widget.horizontalInset,
      top: isTop ? viewPadding.top + widget.topInset : null,
      // `padding.bottom` drops to zero the moment the keyboard covers the
      // home indicator, so the taller of the two is the obstruction to clear.
      bottom: isTop
          ? null
          : math.max(viewPadding.bottom, keyboardInset) + widget.bottomInset,
      // Toasts render above the app, outside any Scaffold. A transparent
      // Material provides the proper DefaultTextStyle so text isn't drawn
      // with Flutter's yellow "missing Material" underline.
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          fit: StackFit.passthrough,
          children: [
            for (final entry in entries)
              _buildToast(
                entry,
                // Depth 0 = frontmost (newest visible).
                depth: entry.removing
                    ? 0
                    : visible.length - 1 - visible.indexOf(entry),
                viewportHeight: viewportHeight,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToast(
    _ToastEntry entry, {
    required int depth,
    required double viewportHeight,
  }) {
    final clampedDepth = depth.clamp(0, widget.maxVisible - 1);
    final sign = entry.dismissSign;
    final isTop = entry.placement == BCToastPlacement.top;
    final isSwipeable = entry.data.isSwipeable ?? widget.isSwipeable;

    // Non-positioned Stack children aligned to the anchored edge: the tallest
    // toast sizes the stack, cards behind the front one shift toward the
    // opposite edge and scale down.
    return KeyedSubtree(
      key: ValueKey(entry.id),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          entry.slide,
          entry.drag,
          entry.exit,
          entry.press,
        ]),
        builder: (context, child) {
          final exitT = _ToastMotion.exitCurve.transform(entry.exit.value);

          final offset =
              entry.slide.value +
              entry.drag.value +
              -sign * 12.0 * clampedDepth +
              sign * _ToastMotion.travel * exitT;

          final scale =
              (1 - 0.05 * clampedDepth) *
              (1 - (1 - _ToastMotion.exitScale) * exitT) *
              (1 - (1 - _ToastMotion.dragScale) * entry.press.value);

          final depthOpacity =
              clampedDepth > 0 && clampedDepth >= widget.maxVisible - 1
              ? 0.9
              : 1.0;
          final opacity =
              depthOpacity * (1 - (1 - _ToastMotion.exitOpacity) * exitT);

          return Transform.translate(
            offset: Offset(0, offset),
            child: Transform.scale(
              scale: scale,
              alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
              child: Opacity(opacity: opacity, child: child),
            ),
          );
        },
        child: GestureDetector(
          onVerticalDragStart: isSwipeable
              ? (_) => _handleDragStart(entry)
              : null,
          onVerticalDragUpdate: isSwipeable
              ? (details) => _handleDragUpdate(entry, details, viewportHeight)
              : null,
          onVerticalDragEnd: isSwipeable
              ? (details) => _handleDragEnd(entry, details.primaryVelocity ?? 0)
              : null,
          onVerticalDragCancel: isSwipeable
              ? () => _handleDragEnd(entry, 0)
              : null,
          child: _BCToastCard(
            data: entry.data,
            onClose: () => _dismiss(entry),
          ),
        ),
      ),
    );
  }
}

class _BCToastCard extends StatelessWidget {
  const _BCToastCard({required this.data, required this.onClose});

  final BCToastData data;
  final VoidCallback onClose;

  Color _titleColor(BCThemeExtension bc) => switch (data.variant) {
        BCToastVariant.defaultVariant => bc.foreground,
        BCToastVariant.accent => bc.accentSoftForeground,
        BCToastVariant.success => bc.successSoftForeground,
        BCToastVariant.warning => bc.warningSoftForeground,
        BCToastVariant.danger => bc.dangerSoftForeground,
      };

  Color _iconColor(BCThemeExtension bc) => switch (data.variant) {
        BCToastVariant.defaultVariant => bc.foreground,
        BCToastVariant.accent => bc.accent,
        BCToastVariant.success => bc.success,
        BCToastVariant.warning => bc.warning,
        BCToastVariant.danger => bc.danger,
      };

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: bc.surface,
        shape: BCShapes.continuous(
          BCRadius.xxxl,
          side: bc.overlayShadow.innerBorder ?? BorderSide.none,
        ),
        shadows: bc.overlayShadow.shadows,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 12,
        children: [
          if (data.icon != null)
            IconTheme.merge(
              data: IconThemeData(color: _iconColor(bc), size: 22),
              child: data.icon!,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: BCTypography.textBase.copyWith(
                    color: _titleColor(bc),
                    fontWeight: BCTypography.medium,
                  ),
                ),
                if (data.description != null)
                  Text(
                    data.description!,
                    style: BCTypography.textSm.copyWith(color: bc.muted),
                  ),
              ],
            ),
          ),
          if (data.actionLabel != null)
            BCButton(
              size: BCButtonSize.sm,
              variant: switch (data.variant) {
                BCToastVariant.danger => BCButtonVariant.danger,
                _ => BCButtonVariant.secondary,
              },
              onPressed: () {
                data.onAction?.call();
                onClose();
              },
              child: Text(data.actionLabel!),
            ),
          if (data.showCloseButton) BCCloseButton(onPressed: onClose),
        ],
      ),
    );
  }
}
