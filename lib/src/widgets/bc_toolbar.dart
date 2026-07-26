import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';

enum BCToolbarVariant {
  /// Attached to the bottom edge, full width, hairline on top.
  docked,

  /// Detached rounded bar with the overlay shadow, floating over content.
  floating,
}

enum BCToolbarAxis { horizontal, vertical }

/// A bar of actions for the current screen — Material 3 "toolbars", the
/// bottom-of-screen counterpart to [BCAppHeader].
///
/// Put actions in [children] (usually [BCHeaderIconButton]s) and an optional
/// emphasized action in [primaryAction]; docked toolbars go in
/// `Scaffold.bottomNavigationBar`, floating ones in `Scaffold.floatingActionButton`
/// with a centered `floatingActionButtonLocation`, or in a `Stack`.
///
/// ```dart
/// Scaffold(
///   bottomNavigationBar: BCToolbar(
///     children: [
///       BCHeaderIconButton(icon: const Icon(Icons.undo), onPressed: () {}),
///       BCHeaderIconButton(icon: const Icon(Icons.redo), onPressed: () {}),
///       BCHeaderIconButton(icon: const Icon(Icons.palette_outlined), onPressed: () {}),
///     ],
///     primaryAction: BCFab(icon: const Icon(Icons.check), onPressed: () {}),
///   ),
/// );
/// ```
class BCToolbar extends StatelessWidget {
  const BCToolbar({
    super.key,
    required this.children,
    this.variant = BCToolbarVariant.docked,
    this.axis = BCToolbarAxis.horizontal,
    this.primaryAction,
    this.alignment = MainAxisAlignment.spaceEvenly,
    this.blurred = false,
    this.blurSigma = 24,
    this.backgroundOpacity = 0.72,
    this.backgroundColor,
    this.showSeparator = true,
    this.spacing = BCSpacing.xs,
    this.padding,
  });

  /// The action buttons, in reading order.
  final List<Widget> children;

  final BCToolbarVariant variant;

  /// Vertical toolbars sit along the side of the content, e.g. a canvas
  /// editor's tool strip.
  final BCToolbarAxis axis;

  /// Emphasized action, placed after [children] and separated from them.
  final Widget? primaryAction;

  /// How [children] are distributed along the bar.
  final MainAxisAlignment alignment;

  /// Frosts the bar so content scrolls visibly underneath it.
  final bool blurred;

  final double blurSigma;

  /// Alpha applied to the background when [blurred].
  final double backgroundOpacity;

  /// Defaults to `background` (docked) or `surface` (floating).
  final Color? backgroundColor;

  /// Hairline along the leading edge of a docked toolbar.
  final bool showSeparator;

  final double spacing;
  final EdgeInsetsGeometry? padding;

  bool get _isFloating => variant == BCToolbarVariant.floating;
  bool get _isVertical => axis == BCToolbarAxis.vertical;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final items = <Widget>[
      ...children,
      if (primaryAction != null) ...[
        SizedBox(
          width: _isVertical ? 0 : BCSpacing.sm,
          height: _isVertical ? BCSpacing.sm : 0,
        ),
        primaryAction!,
      ],
    ];

    final content = _isVertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: alignment,
            spacing: spacing,
            children: items,
          )
        : Row(
            mainAxisSize: _isFloating ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: alignment,
            spacing: spacing,
            children: items,
          );

    if (_isFloating) return _floating(bc, content);
    return _docked(bc, content, context);
  }

  Widget _docked(BCThemeExtension bc, Widget content, BuildContext context) {
    final base = backgroundColor ?? bc.background;
    final insets = MediaQuery.viewPaddingOf(context);

    Widget bar = Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(
            BCSpacing.sm,
            BCSpacing.sm,
            BCSpacing.sm,
            BCSpacing.sm + (_isVertical ? 0 : insets.bottom),
          ),
      child: content,
    );

    if (blurred) {
      bar = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: ColoredBox(
            color: base.withValues(alpha: backgroundOpacity),
            child: bar,
          ),
        ),
      );
    } else {
      bar = ColoredBox(color: base, child: bar);
    }

    if (!showSeparator) return bar;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: _isVertical
            ? Border(right: BorderSide(color: bc.border, width: bc.borderWidth))
            : Border(top: BorderSide(color: bc.border, width: bc.borderWidth)),
      ),
      child: bar,
    );
  }

  Widget _floating(BCThemeExtension bc, Widget content) {
    final base = backgroundColor ?? bc.surface;
    final hairline = bc.overlayShadow.innerBorder;
    final shape = BCShapes.continuous(BCRadius.full);

    Widget inner = Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: BCSpacing.sm,
            vertical: BCSpacing.sm,
          ),
      child: content,
    );

    if (blurred) {
      inner = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: inner,
      );
    }

    final bar = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: blurred ? base.withValues(alpha: backgroundOpacity) : base,
        shape: shape,
        shadows: bc.overlayShadow.shadows,
      ),
      child: inner,
    );

    if (hairline == null) return bar;

    // Stroked as an overlay: a stroked ShapeDecoration would inset the row.
    return Stack(
      children: [
        bar,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: BCShapes.continuous(BCRadius.full, side: hairline),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
