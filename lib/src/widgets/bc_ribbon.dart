import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';

/// The shape a ribbon takes on a card.
enum BCRibbonForm {
  /// Rounded pill floating inside the corner — the everyday 'Hot Sale' tag.
  tag,

  /// Rectangle flush with the left or right edge, with a swallowtail notch
  /// cut into its free end.
  flag,

  /// Diagonal band wrapping the corner — the 'Best Seller' sash.
  ///
  /// The band is as thick as its label needs and sits [BCRibbon.cornerOffset]
  /// away from the corner; at an offset of 0 it fills the corner outright.
  /// Needs a [BCRibbon.child] to clip against.
  corner,

  /// Full-width strip along the top or bottom edge.
  banner,

  /// Vertical tab hanging off the top (or bottom) edge, notched like a
  /// bookmark. Good for a discount figure.
  bookmark,
}

/// Fill treatment, matching the rest of the library's `variant` prop.
enum BCRibbonVariant { solid, soft, outline }

enum BCRibbonColor { accent, defaultColor, success, warning, danger }

enum BCRibbonSize { sm, md, lg }

/// Corner or edge the ribbon attaches to. `start`/`end` follow the ambient
/// [Directionality], so a `topStart` ribbon sits top-right in RTL.
enum BCRibbonPosition {
  topStart,
  topEnd,
  bottomStart,
  bottomEnd;

  bool get isTop =>
      this == BCRibbonPosition.topStart || this == BCRibbonPosition.topEnd;

  bool get isStart =>
      this == BCRibbonPosition.topStart || this == BCRibbonPosition.bottomStart;
}

/// A merchandising ribbon for product cards — 'Hot Sale', 'Nearby',
/// '-30%', 'Best deal'.
///
/// Give it a [child] and it overlays that child, anchored to [position] and
/// clipped to the card's corners where the form needs it ([BCRibbonForm.corner]
/// and [BCRibbonForm.banner]). Leave [child] null and it renders on its own,
/// for placement in a [Stack] you already have.
///
/// The overlay never takes pointer events, so a card behind it stays tappable
/// in full.
///
/// ```dart
/// BCRibbon.label(
///   'Hot Sale',
///   form: BCRibbonForm.corner,
///   position: BCRibbonPosition.topEnd,
///   color: BCRibbonColor.danger,
///   child: ProductCard(),
/// )
/// ```
class BCRibbon extends StatelessWidget {
  const BCRibbon({
    super.key,
    required this.label,
    this.form = BCRibbonForm.tag,
    this.variant = BCRibbonVariant.solid,
    this.color = BCRibbonColor.accent,
    this.size = BCRibbonSize.md,
    this.position = BCRibbonPosition.topStart,
    this.startContent,
    this.inset,
    this.cornerOffset,
    this.cornerThickness,
    this.borderRadius,
    this.child,
  });

  /// Convenience constructor for a plain text ribbon.
  BCRibbon.label(
    String text, {
    Key? key,
    BCRibbonForm form = BCRibbonForm.tag,
    BCRibbonVariant variant = BCRibbonVariant.solid,
    BCRibbonColor color = BCRibbonColor.accent,
    BCRibbonSize size = BCRibbonSize.md,
    BCRibbonPosition position = BCRibbonPosition.topStart,
    Widget? startContent,
    double? inset,
    double? cornerOffset,
    double? cornerThickness,
    double? borderRadius,
    Widget? child,
  }) : this(
          key: key,
          form: form,
          variant: variant,
          color: color,
          size: size,
          position: position,
          startContent: startContent,
          inset: inset,
          cornerOffset: cornerOffset,
          cornerThickness: cornerThickness,
          borderRadius: borderRadius,
          child: child,
          label: Text(text),
        );

  final Widget label;
  final BCRibbonForm form;
  final BCRibbonVariant variant;
  final BCRibbonColor color;
  final BCRibbonSize size;
  final BCRibbonPosition position;

  /// Small leading icon, tinted to match the label.
  final Widget? startContent;

  /// Distance from the card edges. Defaults to 8/10/12 by [size], and is
  /// ignored by [BCRibbonForm.corner] and [BCRibbonForm.banner], which sit
  /// flush against the edges.
  final double? inset;

  /// [BCRibbonForm.corner] only: gap between the card's corner and the near
  /// edge of the band.
  ///
  /// Defaults to whatever keeps the band clear of the corner while still long
  /// enough for the label. Pass `0` to fill the corner completely, or a larger
  /// value to float the band further down the card.
  final double? cornerOffset;

  /// [BCRibbonForm.corner] only: thickness of the band.
  ///
  /// Defaults to the label's height plus padding — and, when [cornerOffset]
  /// pulls the band toward the corner where there is less room, to whatever
  /// the label needs to fit.
  final double? cornerThickness;

  /// Corner radius the ribbon is clipped to, i.e. the radius of the card it
  /// covers. Defaults to [BCRadius.xxxl] (24), matching `BCSurface`.
  final double? borderRadius;

  /// The card the ribbon is laid over. Without one the ribbon sizes itself.
  final Widget? child;

  TextStyle get _labelStyle => switch (size) {
        BCRibbonSize.sm => BCTypography.textXs,
        BCRibbonSize.md => BCTypography.textSm,
        BCRibbonSize.lg => BCTypography.textBase,
      };

  EdgeInsets get _padding => switch (size) {
        BCRibbonSize.sm =>
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        BCRibbonSize.md =>
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        BCRibbonSize.lg =>
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      };

  /// Depth of the swallowtail cut on [BCRibbonForm.flag] and
  /// [BCRibbonForm.bookmark].
  double get _notch => switch (size) {
        BCRibbonSize.sm => 8,
        BCRibbonSize.md => 10,
        BCRibbonSize.lg => 12,
      };

  /// Padding around a [BCRibbonForm.corner] label inside its band. Three
  /// quarters of the type size keeps the sash bold at every size.
  double get _bandPadding => _labelStyle.fontSize! * 0.75;

  /// Side of the box a corner ribbon draws into when it has no card of its
  /// own to be cut from.
  double get _standaloneCorner => switch (size) {
        BCRibbonSize.sm => 96,
        BCRibbonSize.md => 120,
        BCRibbonSize.lg => 148,
      };

  double get _inset =>
      inset ??
      switch (size) {
        BCRibbonSize.sm => 8,
        BCRibbonSize.md => 10,
        BCRibbonSize.lg => 12,
      };

  Color _background(BCThemeExtension bc) => switch (variant) {
        BCRibbonVariant.solid => switch (color) {
            BCRibbonColor.accent => bc.accent,
            BCRibbonColor.defaultColor => bc.defaultColor,
            BCRibbonColor.success => bc.success,
            BCRibbonColor.warning => bc.warning,
            BCRibbonColor.danger => bc.danger,
          },
        BCRibbonVariant.soft => switch (color) {
            BCRibbonColor.accent => bc.accentSoft,
            BCRibbonColor.defaultColor => bc.defaultSoft,
            BCRibbonColor.success => bc.successSoft,
            BCRibbonColor.warning => bc.warningSoft,
            BCRibbonColor.danger => bc.dangerSoft,
          },
        // Reads as a card of its own, so it stays legible over photography.
        BCRibbonVariant.outline => bc.surface,
      };

  Color _foreground(BCThemeExtension bc) {
    if (variant == BCRibbonVariant.solid) {
      return switch (color) {
        BCRibbonColor.accent => bc.accentForeground,
        BCRibbonColor.defaultColor => bc.defaultForeground,
        BCRibbonColor.success => bc.successForeground,
        BCRibbonColor.warning => bc.warningForeground,
        BCRibbonColor.danger => bc.dangerForeground,
      };
    }
    return switch (color) {
      BCRibbonColor.accent => bc.accentSoftForeground,
      BCRibbonColor.defaultColor => bc.defaultSoftForeground,
      BCRibbonColor.success => bc.successSoftForeground,
      BCRibbonColor.warning => bc.warningSoftForeground,
      BCRibbonColor.danger => bc.dangerSoftForeground,
    };
  }

  BorderSide _side(BCThemeExtension bc) => variant == BCRibbonVariant.outline
      ? BorderSide(color: _foreground(bc), width: bc.borderWidth)
      : BorderSide.none;

  /// Icon + label, styled but unpainted.
  Widget _labelRow(BCThemeExtension bc) {
    final foreground = _foreground(bc);

    return DefaultTextStyle.merge(
      // Tighter than the body line height: a ribbon is a single line and
      // should hug its label.
      style: _labelStyle.copyWith(
        color: foreground,
        fontWeight: BCTypography.semiBold,
        height: 1.1,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: IconTheme.merge(
        data: IconThemeData(color: foreground, size: _labelStyle.fontSize),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            ?startContent,
            Flexible(child: label),
          ],
        ),
      ),
    );
  }

  /// The label row, painted on [shape].
  Widget _body(
    BCThemeExtension bc, {
    required ShapeBorder shape,
    required EdgeInsets padding,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(color: _background(bc), shape: shape),
      padding: padding,
      alignment: width != null || height != null ? Alignment.center : null,
      child: _labelRow(bc),
    );
  }

  /// The ribbon itself, without any positioning.
  Widget _ribbon(BCThemeExtension bc, {required bool isLeft}) {
    final side = _side(bc);

    switch (form) {
      case BCRibbonForm.tag:
        return _body(
          bc,
          shape: BCShapes.continuous(BCRadius.full, side: side),
          padding: _padding,
        );

      case BCRibbonForm.banner:
        return _body(
          bc,
          shape: RoundedRectangleBorder(side: side),
          padding: _padding,
        );

      case BCRibbonForm.flag:
        // The tail eats into the free end, so pad that side by its depth.
        final padding = _padding + EdgeInsets.only(
          left: isLeft ? 0 : _notch,
          right: isLeft ? _notch : 0,
        );
        return _body(
          bc,
          shape: _RibbonShape(
            cut: isLeft ? _RibbonCut.tailEnd : _RibbonCut.tailStart,
            notch: _notch,
            side: side,
          ),
          padding: padding,
        );

      case BCRibbonForm.bookmark:
        final fromTop = position.isTop;
        return _body(
          bc,
          shape: _RibbonShape(
            cut: fromTop ? _RibbonCut.tailBottom : _RibbonCut.tailTop,
            notch: _notch,
            side: side,
          ),
          padding: _padding + EdgeInsets.only(
            top: fromTop ? 0 : _notch,
            bottom: fromTop ? _notch : 0,
          ),
        );

      case BCRibbonForm.corner:
        final angle = (position.isTop == isLeft) ? -math.pi / 4 : math.pi / 4;
        return CustomMultiChildLayout(
          delegate: _CornerBandLayout(
            isTop: position.isTop,
            isLeft: isLeft,
            gap: _bandPadding,
            offset: cornerOffset,
            thickness: cornerThickness,
          ),
          children: [
            LayoutId(
              id: _CornerBandSlot.band,
              child: Transform.rotate(
                angle: angle,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: _background(bc),
                    shape: RoundedRectangleBorder(side: side),
                  ),
                ),
              ),
            ),
            LayoutId(
              id: _CornerBandSlot.label,
              child: Transform.rotate(angle: angle, child: _labelRow(bc)),
            ),
          ],
        );
    }
  }

  /// Where the ribbon sits inside the card's bounds.
  Widget _positioned(Widget ribbon, {required bool isLeft}) {
    final isTop = position.isTop;

    return switch (form) {
      // Lays itself out against the card's own bounds.
      BCRibbonForm.corner => Positioned.fill(child: ribbon),
      BCRibbonForm.banner => Positioned(
          left: 0,
          right: 0,
          top: isTop ? 0 : null,
          bottom: isTop ? null : 0,
          child: ribbon,
        ),
      // Flush with the side edge, offset down (or up) from the corner.
      BCRibbonForm.flag => Positioned(
          left: isLeft ? 0 : null,
          right: isLeft ? null : 0,
          top: isTop ? _inset : null,
          bottom: isTop ? null : _inset,
          child: ribbon,
        ),
      // Hangs from the top (or bottom) edge, offset in from the side.
      BCRibbonForm.bookmark => Positioned(
          left: isLeft ? _inset : null,
          right: isLeft ? null : _inset,
          top: isTop ? 0 : null,
          bottom: isTop ? null : 0,
          child: ribbon,
        ),
      BCRibbonForm.tag => Positioned(
          left: isLeft ? _inset : null,
          right: isLeft ? null : _inset,
          top: isTop ? _inset : null,
          bottom: isTop ? null : _inset,
          child: ribbon,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    final isLeft = position.isStart == isLtr;

    final ribbon = _ribbon(bc, isLeft: isLeft);
    final card = child;
    if (card == null) {
      // The corner forms are cut from the card's own bounds, so on their own
      // they need a box to be cut from.
      return switch (form) {
        BCRibbonForm.corner => ClipRect(
            child: SizedBox.square(
              dimension: _standaloneCorner,
              child: ribbon,
            ),
          ),
        _ => ribbon,
      };
    }

    // Only the forms that run off the card's edges by construction need
    // clipping; the inset ones stay free to overhang if a design wants it.
    final needsClip =
        form == BCRibbonForm.corner || form == BCRibbonForm.banner;

    Widget overlay = Stack(
      clipBehavior: Clip.none,
      children: [_positioned(ribbon, isLeft: isLeft)],
    );

    if (needsClip) {
      overlay = ClipPath(
        clipper: ShapeBorderClipper(
          shape: BCShapes.continuous(borderRadius ?? BCRadius.xxxl),
        ),
        child: overlay,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        // The card keeps every pointer event; the ribbon is decoration.
        Positioned.fill(child: IgnorePointer(child: overlay)),
      ],
    );
  }
}

enum _CornerBandSlot { band, label }

/// Lays out the corner band.
///
/// Distances are measured perpendicular from the card's corner, where the
/// slice of card `t` away from the corner is exactly `2 * t` long. So a band
/// running from `offset` to `offset + thickness` shows its label centred at
/// `t = offset + thickness / 2`, with `2 * t` of room for it — which is what
/// the defaults solve for:
///
/// * free offset: the band is as thick as the label is tall, pushed out far
///   enough that the label fits across it;
/// * pinned offset (`cornerOffset: 0` fills the corner): the band thickens
///   instead, since it can no longer move.
class _CornerBandLayout extends MultiChildLayoutDelegate {
  _CornerBandLayout({
    required this.isTop,
    required this.isLeft,
    required this.gap,
    this.offset,
    this.thickness,
  });

  final bool isTop;
  final bool isLeft;

  /// Padding between the label and the band's edges.
  final double gap;

  final double? offset;
  final double? thickness;

  @override
  void performLayout(Size size) {
    final label = layoutChild(
      _CornerBandSlot.label,
      BoxConstraints.loose(size),
    );

    final span = label.width + gap * 2;
    final double bandOffset;
    final double bandThickness;

    if (offset != null) {
      bandOffset = offset!;
      bandThickness = thickness ??
          math.max(label.height + gap * 2, span - bandOffset * 2);
    } else {
      bandThickness = thickness ?? label.height + gap * 2;
      // Clear of the corner, but never so close that the label overruns the
      // band's ends.
      bandOffset = math.max(span / 2 - bandThickness / 2, bandThickness / 2);
    }

    final centre = bandOffset + bandThickness / 2;
    final band = layoutChild(
      _CornerBandSlot.band,
      // Long enough to reach both card edges; the surplus is clipped away.
      BoxConstraints.tight(
        Size(math.max(centre * 2, span) * 1.5, bandThickness),
      ),
    );

    // Walk in from the corner along the diagonal.
    final corner = Offset(isLeft ? 0 : size.width, isTop ? 0 : size.height);
    final step = Offset(isLeft ? 1 : -1, isTop ? 1 : -1) / math.sqrt2;
    final anchor = corner + step * centre;

    positionChild(
      _CornerBandSlot.band,
      anchor - Offset(band.width, band.height) / 2,
    );
    positionChild(
      _CornerBandSlot.label,
      anchor - Offset(label.width, label.height) / 2,
    );
  }

  @override
  bool shouldRelayout(_CornerBandLayout oldDelegate) =>
      oldDelegate.isTop != isTop ||
      oldDelegate.isLeft != isLeft ||
      oldDelegate.gap != gap ||
      oldDelegate.offset != offset ||
      oldDelegate.thickness != thickness;
}

enum _RibbonCut { tailEnd, tailStart, tailBottom, tailTop }

/// Rectangle with a triangular notch cut into one side — the swallowtail end
/// of a flag, or the foot of a bookmark.
@immutable
class _RibbonShape extends ShapeBorder {
  const _RibbonShape({
    required this.cut,
    required this.notch,
    this.side = BorderSide.none,
  });

  final _RibbonCut cut;
  final double notch;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  Path _path(Rect r) {
    final path = Path();
    switch (cut) {
      case _RibbonCut.tailEnd:
        path
          ..moveTo(r.left, r.top)
          ..lineTo(r.right, r.top)
          ..lineTo(r.right - notch, r.center.dy)
          ..lineTo(r.right, r.bottom)
          ..lineTo(r.left, r.bottom);
      case _RibbonCut.tailStart:
        path
          ..moveTo(r.right, r.top)
          ..lineTo(r.left, r.top)
          ..lineTo(r.left + notch, r.center.dy)
          ..lineTo(r.left, r.bottom)
          ..lineTo(r.right, r.bottom);
      case _RibbonCut.tailBottom:
        path
          ..moveTo(r.left, r.top)
          ..lineTo(r.right, r.top)
          ..lineTo(r.right, r.bottom)
          ..lineTo(r.center.dx, r.bottom - notch)
          ..lineTo(r.left, r.bottom);
      case _RibbonCut.tailTop:
        path
          ..moveTo(r.left, r.bottom)
          ..lineTo(r.right, r.bottom)
          ..lineTo(r.right, r.top)
          ..lineTo(r.center.dx, r.top + notch)
          ..lineTo(r.left, r.top);
    }
    return path..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(_path(rect.deflate(side.width / 2)), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) =>
      _RibbonShape(cut: cut, notch: notch * t, side: side.scale(t));

  @override
  bool operator ==(Object other) =>
      other is _RibbonShape &&
      other.cut == cut &&
      other.notch == notch &&
      other.side == side;

  @override
  int get hashCode => Object.hash(cut, notch, side);
}
