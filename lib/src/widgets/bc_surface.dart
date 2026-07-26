import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';

enum BCSurfaceVariant { defaultVariant, secondary, tertiary, transparent }

/// HeroUI Native Surface: the base container for non-overlay components
/// (surface.css) — 16px padding, 24px continuous corners, surface shadow.
class BCSurface extends StatelessWidget {
  const BCSurface({
    super.key,
    this.variant = BCSurfaceVariant.defaultVariant,
    this.padding,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
    required this.child,
  });

  final BCSurfaceVariant variant;

  /// Defaults to `EdgeInsets.all(16)`.
  final EdgeInsetsGeometry? padding;

  /// Defaults to [BCRadius.xxxl] (24).
  final double? borderRadius;

  final Clip clipBehavior;
  final double? width;
  final double? height;
  final Widget child;

  static Color backgroundColor(
    BCThemeExtension bc,
    BCSurfaceVariant variant,
  ) {
    return switch (variant) {
      BCSurfaceVariant.defaultVariant => bc.surface,
      BCSurfaceVariant.secondary => bc.surfaceSecondary,
      BCSurfaceVariant.tertiary => bc.surfaceTertiary,
      BCSurfaceVariant.transparent => const Color(0x00000000),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final hasShadow = variant != BCSurfaceVariant.transparent;
    final shape = BCShapes.continuous(borderRadius ?? BCRadius.xxxl);

    return Container(
      width: width,
      height: height,
      clipBehavior: clipBehavior,
      decoration: ShapeDecoration(
        color: backgroundColor(bc, variant),
        shape: shape,
        shadows: hasShadow ? bc.surfaceShadow.shadows : null,
      ),
      padding: padding ?? const EdgeInsets.all(BCSpacing.md),
      child: child,
    );
  }
}
