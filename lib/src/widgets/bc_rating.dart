import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';

enum BCRatingSize { sm, md, lg }

/// A star (or custom-icon) rating control.
///
/// Interactive when [onChanged] is provided (tap to set; tap a star's left
/// half for a half value when [allowHalf] is true); otherwise read-only and
/// able to render fractional values like 3.7. Supports any [max], custom
/// [icon] and colors — e.g. red hearts.
class BCRating extends StatelessWidget {
  const BCRating({
    super.key,
    required this.value,
    this.max = 5,
    this.onChanged,
    this.size = BCRatingSize.md,
    this.itemSize,
    this.spacing = 4,
    this.color,
    this.emptyColor,
    this.icon = Icons.star_rounded,
    this.allowHalf = false,
  });

  final double value;
  final int max;

  /// Tap handler; when null the rating is read-only.
  final ValueChanged<double>? onChanged;

  final BCRatingSize size;

  /// Overrides the [size] preset.
  final double? itemSize;

  final double spacing;

  /// Filled color. Defaults to the warning (amber) token.
  final Color? color;

  /// Unfilled color. Defaults to a muted translucent tint.
  final Color? emptyColor;

  final IconData icon;

  /// Allow half-value selection when interactive.
  final bool allowHalf;

  double get _resolvedSize =>
      itemSize ??
      switch (size) {
        BCRatingSize.sm => 20,
        BCRatingSize.md => 28,
        BCRatingSize.lg => 36,
      };

  bool get _interactive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final filled = color ?? bc.warning;
    final empty = emptyColor ?? bc.muted.withValues(alpha: 0.35);
    final dimension = _resolvedSize;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < max; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          _star(context, i, dimension, filled, empty),
        ],
      ],
    );
  }

  Widget _star(
    BuildContext context,
    int index,
    double dimension,
    Color filled,
    Color empty,
  ) {
    final fraction = (value - index).clamp(0.0, 1.0);

    Widget star = SizedBox(
      width: dimension,
      height: dimension,
      child: Stack(
        children: [
          Icon(icon, size: dimension, color: empty),
          if (fraction > 0)
            ClipRect(
              clipper: _FractionClipper(fraction),
              child: Icon(icon, size: dimension, color: filled),
            ),
        ],
      ),
    );

    if (!_interactive) return star;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        final isLeftHalf = details.localPosition.dx < dimension / 2;
        final next = index + (allowHalf && isLeftHalf ? 0.5 : 1.0);
        onChanged!(next);
      },
      child: star,
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  const _FractionClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_FractionClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
