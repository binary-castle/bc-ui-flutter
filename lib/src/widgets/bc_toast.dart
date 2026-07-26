import 'dart:async';

import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_button.dart';
import 'bc_close_button.dart';

enum BCToastVariant { defaultVariant, accent, success, warning, danger }

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
}

/// HeroUI Native Toast.
///
/// Mount [BCToastProvider] above your app (e.g. `MaterialApp.builder`) and
/// call `BCToast.show(context, BCToastData(...))`. Toasts stack bottom-up:
/// the newest card is frontmost while older ones peek behind it, scaled and
/// shifted (toast.tsx stacked-collapse behavior). Swipe down to dismiss.
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
    this.bottomInset = 16,
  });

  final Widget child;

  /// Older toasts beyond this count are dismissed immediately.
  final int maxVisible;

  /// Distance from the bottom safe area to the front toast.
  final double bottomInset;

  @override
  State<BCToastProvider> createState() => _BCToastProviderState();
}

class _ToastEntry {
  _ToastEntry(this.id, this.data, this.controller);

  final int id;
  final BCToastData data;
  final AnimationController controller;
  Timer? timer;
  bool removing = false;
}

class _BCToastProviderState extends State<BCToastProvider>
    with TickerProviderStateMixin {
  final List<_ToastEntry> _entries = [];
  int _nextId = 0;

  void showToast(BCToastData data) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 200),
    );
    final entry = _ToastEntry(_nextId++, data, controller);

    setState(() => _entries.add(entry));
    controller.forward();

    if (data.duration > Duration.zero) {
      entry.timer = Timer(data.duration, () => _dismiss(entry));
    }

    // Collapse overflow: drop the oldest beyond maxVisible.
    final visible = _entries.where((e) => !e.removing).toList();
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
    entry.controller.reverse().whenComplete(() {
      if (!mounted) return;
      setState(() => _entries.remove(entry));
      entry.controller.dispose();
    });
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.timer?.cancel();
      entry.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _entries.where((e) => !e.removing).toList();

    return Directionality(
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + widget.bottomInset,
            // Toasts render above the app, outside any Scaffold. A
            // transparent Material provides the proper DefaultTextStyle so
            // text isn't drawn with Flutter's yellow "missing Material"
            // underline.
            child: Material(
              type: MaterialType.transparency,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                fit: StackFit.passthrough,
                children: [
                  for (final entry in _entries)
                    _buildToast(
                      entry,
                      // Depth 0 = frontmost (newest visible).
                      depth: entry.removing
                          ? 0
                          : visible.length - 1 - visible.indexOf(entry),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToast(_ToastEntry entry, {required int depth}) {
    final clampedDepth = depth.clamp(0, widget.maxVisible - 1);

    // Non-positioned Stack children aligned bottom-center: the tallest
    // toast sizes the stack, cards behind the front one shift up and
    // scale down.
    return KeyedSubtree(
      key: ValueKey(entry.id),
      child: AnimatedBuilder(
        animation: entry.controller,
        builder: (context, child) {
          final t = Curves.easeOut.transform(entry.controller.value);

          final depthScale = 1 - 0.05 * clampedDepth;
          final depthOffset = -12.0 * clampedDepth;
          // Enter from below with fade.
          final enterOffset = (1 - t) * 40;

          return Transform.translate(
            offset: Offset(0, depthOffset + enterOffset),
            child: Transform.scale(
              scale: depthScale,
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: t * (clampedDepth == 2 ? 0.9 : 1),
                child: child,
              ),
            ),
          );
        },
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 200) _dismiss(entry);
          },
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
