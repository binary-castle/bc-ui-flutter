import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../overlay/bc_overlay_anchor.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';
import 'bc_separator.dart';

enum BCMenuItemVariant { defaultVariant, danger }

/// HeroUI Native Menu (menu.css): an anchored overlay list — overlay
/// background, 24px continuous corners, px6/py12, items with 16px-radius
/// press highlight.
class BCMenu extends StatefulWidget {
  const BCMenu({
    super.key,
    required this.trigger,
    required this.children,
    this.controller,
    this.placement = BCOverlayPlacement.auto,
    this.alignment = BCOverlayAlignment.start,
    this.minWidth = 200,
    this.maxWidth = 320,
    this.onOpenChange,
  });

  final Widget Function(
    BuildContext context,
    BCAnchoredOverlayController controller,
  ) trigger;

  /// Menu content: [BCMenuItem], [BCMenuLabel], [BCMenuSeparator]…
  final List<Widget> children;

  final BCAnchoredOverlayController? controller;
  final BCOverlayPlacement placement;
  final BCOverlayAlignment alignment;
  final double minWidth;

  /// The menu never grows wider than this; it sizes to its content between
  /// [minWidth] and [maxWidth] rather than stretching to the screen.
  final double maxWidth;

  final ValueChanged<bool>? onOpenChange;

  @override
  State<BCMenu> createState() => _BCMenuState();
}

class _BCMenuState extends State<BCMenu> {
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
        return _BCMenuScope(
          controller: _controller,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minWidth,
              maxWidth: widget.maxWidth,
            ),
            // Size to the widest item instead of filling the screen; items
            // still stretch to this intrinsic width for full-row tap targets.
            child: IntrinsicWidth(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.children,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: widget.trigger(context, _controller),
    );
  }
}

/// Menu row (menu.css `menu__item`): gap 10, px10/py8, radius 16,
/// press highlight; danger variant colors the title/icon.
class BCMenuItem extends StatelessWidget {
  const BCMenuItem({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.trailing,
    this.variant = BCMenuItemVariant.defaultVariant,
    this.isDisabled = false,
    this.closeOnSelect = true,
    this.onSelected,
  });

  final String title;
  final String? description;
  final Widget? icon;
  final Widget? trailing;
  final BCMenuItemVariant variant;
  final bool isDisabled;
  final bool closeOnSelect;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final scope = _BCMenuScope.of(context);

    final titleColor = switch (variant) {
      BCMenuItemVariant.defaultVariant => bc.foreground,
      BCMenuItemVariant.danger => bc.danger,
    };

    Widget row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        spacing: 10,
        children: [
          if (icon != null)
            IconTheme.merge(
              data: IconThemeData(color: titleColor, size: 18),
              child: icon!,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BCTypography.textBase.copyWith(
                    color: titleColor,
                    fontWeight: BCTypography.medium,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: BCTypography.textSm.copyWith(color: bc.muted),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (isDisabled) {
      row = Opacity(
        opacity: bc.opacityDisabled,
        child: IgnorePointer(child: row),
      );
    }

    return BCPressable(
      feedback: BCPressFeedback.highlight,
      shape: BCShapes.continuous(BCRadius.xxl),
      highlightColor: bc.surfaceHover,
      highlightOpacityRange: (0, 1),
      enabled: !isDisabled,
      onPressed: isDisabled
          ? null
          : () {
              if (closeOnSelect) scope?.controller.close();
              onSelected?.call();
            },
      child: row,
    );
  }
}

/// Section label (menu.css `menu__label`): text-sm, medium, muted.
class BCMenuLabel extends StatelessWidget {
  const BCMenuLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 12,
        top: 6,
        bottom: 6,
      ),
      child: Text(
        text,
        style: BCTypography.textSm.copyWith(
          color: context.bcTheme.muted,
          fontWeight: BCTypography.medium,
        ),
      ),
    );
  }
}

class BCMenuSeparator extends StatelessWidget {
  const BCMenuSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: BCSeparator(),
    );
  }
}

class _BCMenuScope extends InheritedWidget {
  const _BCMenuScope({required this.controller, required super.child});

  final BCAnchoredOverlayController controller;

  static _BCMenuScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BCMenuScope>();

  @override
  bool updateShouldNotify(_BCMenuScope oldWidget) =>
      controller != oldWidget.controller;
}
