import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

/// Which corner a FAB / speed dial anchors to (controls how the speed-dial
/// items and their labels align).
enum BCFabAlignment { right, left }

/// Backdrop shown behind an open [BCSpeedDial].
enum BCFabBackdrop { dim, blur, none }

/// A circular floating action button (accent background, soft shadow,
/// press-scale feedback). For an expandable menu use [BCSpeedDial].
class BCFab extends StatelessWidget {
  const BCFab({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56,
    this.isDisabled = false,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;

  /// Defaults to the accent token.
  final Color? backgroundColor;

  /// Defaults to the accent-foreground token.
  final Color? foregroundColor;

  final double size;
  final bool isDisabled;
  final String? tooltip;

  static List<BoxShadow> shadowsFor(BCThemeExtension bc) {
    if (bc.overlayShadow.shadows.isNotEmpty) return bc.overlayShadow.shadows;
    // Dark mode has no drop shadow token; give the FAB a subtle lift anyway.
    return const [
      BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final bg = backgroundColor ?? bc.accent;
    final fg = foregroundColor ?? bc.accentForeground;

    Widget fab = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: shadowsFor(bc),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: fg, size: size * 24 / 56),
        child: Center(child: icon),
      ),
    );

    if (isDisabled) {
      fab = Opacity(opacity: bc.opacityDisabled, child: fab);
    }

    return BCPressable(
      feedback: BCPressFeedback.scale,
      shape: const CircleBorder(),
      enabled: !isDisabled,
      onPressed: isDisabled ? null : onPressed,
      child: Semantics(button: true, label: tooltip, child: fab),
    );
  }
}

/// A single action inside a [BCSpeedDial].
class BCSpeedDialItem {
  const BCSpeedDialItem({
    required this.label,
    this.icon,
    this.onPressed,
    this.isDanger = false,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;

  /// Renders the label/icon in the danger color (e.g. "Delete").
  final bool isDanger;
}

/// An expandable FAB (speed dial): tapping the button reveals a stack of
/// labelled action pills over a dim or blurred backdrop, and the button's
/// icon morphs to [openIcon]. Items and labels anchor to [alignment].
class BCSpeedDial extends StatefulWidget {
  const BCSpeedDial({
    super.key,
    required this.items,
    this.icon = const Icon(Icons.add),
    this.openIcon = const Icon(Icons.close),
    this.alignment = BCFabAlignment.right,
    this.backdrop = BCFabBackdrop.dim,
    this.size = 56,
    this.isDisabled = false,
    this.onOpenChange,
  });

  final List<BCSpeedDialItem> items;

  /// Icon shown when closed.
  final Widget icon;

  /// Icon shown when open (defaults to a close X).
  final Widget openIcon;

  final BCFabAlignment alignment;
  final BCFabBackdrop backdrop;
  final double size;
  final bool isDisabled;
  final ValueChanged<bool>? onOpenChange;

  @override
  State<BCSpeedDial> createState() => _BCSpeedDialState();
}

class _BCSpeedDialState extends State<BCSpeedDial>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 200),
  );

  bool get _isOpen => _controller.status == AnimationStatus.forward ||
      _controller.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && _portal.isShowing) {
        _portal.hide();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    if (_isOpen) return;
    _portal.show();
    _controller.forward();
    widget.onOpenChange?.call(true);
  }

  void _close() {
    _controller.reverse();
    widget.onOpenChange?.call(false);
  }

  void _toggle() => _isOpen ? _close() : _open();

  bool get _isRight => widget.alignment == BCFabAlignment.right;

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: CompositedTransformTarget(
        link: _link,
        child: BCFab(
          icon: widget.icon,
          size: widget.size,
          isDisabled: widget.isDisabled,
          onPressed: widget.isDisabled ? null : _toggle,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final bc = context.bcTheme;

    return Stack(
      children: [
        // Backdrop (tap to dismiss).
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => _backdrop(bc, _controller.value),
            ),
          ),
        ),
        // Action pills, anchored above the FAB.
        CompositedTransformFollower(
          link: _link,
          targetAnchor:
              _isRight ? Alignment.topRight : Alignment.topLeft,
          followerAnchor:
              _isRight ? Alignment.bottomRight : Alignment.bottomLeft,
          offset: const Offset(0, -16),
          child: Column(
            crossAxisAlignment:
                _isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.items.length; i++)
                _buildItem(bc, widget.items[i], i),
            ],
          ),
        ),
        // FAB (close icon) on top of the backdrop, over the trigger.
        CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.topLeft,
          child: BCFab(
            size: widget.size,
            onPressed: _close,
            icon: RotationTransition(
              turns: _controller.drive(Tween(begin: -0.25, end: 0)),
              child: FadeTransition(
                opacity: _controller,
                child: widget.openIcon,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _backdrop(BCThemeExtension bc, double t) {
    switch (widget.backdrop) {
      case BCFabBackdrop.none:
        return const SizedBox.expand();
      case BCFabBackdrop.dim:
        return ColoredBox(color: bc.backdrop.withValues(alpha: 0.2 * t));
      case BCFabBackdrop.blur:
        if (t == 0) return const SizedBox.expand();
        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12 * t, sigmaY: 12 * t),
          child: ColoredBox(
            color: bc.background.withValues(alpha: 0.15 * t),
          ),
        );
    }
  }

  Widget _buildItem(BCThemeExtension bc, BCSpeedDialItem item, int index) {
    // Stagger: items nearest the FAB (bottom of the column) appear first.
    final total = widget.items.length;
    final reverseIndex = total - 1 - index;
    final start = (reverseIndex / (total + 1)).clamp(0.0, 0.6);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: Curves.easeOut),
    );

    final color = item.isDanger ? bc.danger : bc.foreground;

    final pill = Container(
      decoration: ShapeDecoration(
        color: bc.surface,
        shape: const StadiumBorder(),
        shadows: BCFab.shadowsFor(bc),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          if (item.icon != null)
            IconTheme.merge(
              data: IconThemeData(color: color, size: 20),
              child: item.icon!,
            ),
          Text(
            item.label,
            style: BCTypography.textBase.copyWith(
              color: color,
              fontWeight: BCTypography.medium,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, (1 - curved.value) * 12),
            child: child,
          ),
        ),
        child: BCPressable(
          feedback: BCPressFeedback.scale,
          shape: const StadiumBorder(),
          onPressed: () {
            _close();
            item.onPressed?.call();
          },
          child: pill,
        ),
      ),
    );
  }
}
