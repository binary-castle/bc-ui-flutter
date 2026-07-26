import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_typography.dart';

/// Visual container style for [BCEmptyState].
enum BCEmptyStateVariant {
  /// Plain centered content (no surrounding border).
  plain,

  /// Content wrapped in a dashed-border rounded card.
  outline,
}

/// A placeholder shown when there's no content to display — empty inboxes,
/// zero search results, first-run prompts, and so on.
///
/// Compose it from an optional visual ([icon] rendered in a muted circle, or
/// a fully custom [illustration]), a [title], an optional [description], and
/// any number of [actions] (buttons) stacked below.
///
/// This component is bc_ui-specific — heroui-native has no equivalent.
class BCEmptyState extends StatelessWidget {
  const BCEmptyState({
    super.key,
    this.icon,
    this.illustration,
    required this.title,
    this.description,
    this.actions = const [],
    this.variant = BCEmptyStateVariant.plain,
    this.padding,
    this.maxContentWidth = 400,
  });

  /// Icon shown inside a muted circular badge. Ignored when [illustration]
  /// is provided.
  final Widget? icon;

  /// Fully custom visual shown above the title, replacing the [icon] badge.
  final Widget? illustration;

  final String title;
  final String? description;

  /// Buttons stacked (full-width) below the text, in order.
  final List<Widget> actions;

  final BCEmptyStateVariant variant;

  /// Content padding. Defaults to `EdgeInsets.all(32)` for [outline], none
  /// otherwise.
  final EdgeInsetsGeometry? padding;

  /// Caps the content width so text and full-width buttons stay tidy on
  /// wide screens.
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    final Widget? media = illustration ??
        (icon == null
            ? null
            : Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: bc.defaultColor,
                  shape: BoxShape.circle,
                ),
                child: IconTheme.merge(
                  data: IconThemeData(color: bc.muted, size: 28),
                  child: Center(child: icon),
                ),
              ));

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (media != null) ...[
          Center(child: media),
          const SizedBox(height: 20),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: BCTypography.textXl.copyWith(
            color: bc.foreground,
            fontWeight: BCTypography.semiBold,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: BCTypography.textBase.copyWith(color: bc.muted),
          ),
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 24),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            actions[i],
          ],
        ],
      ],
    );

    final constrained = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: content,
      ),
    );

    if (variant == BCEmptyStateVariant.outline) {
      return DecoratedBox(
        decoration: _DashedBorderDecoration(
          color: bc.border,
          radius: BCRadius.xxxl,
          strokeWidth: bc.borderWidth,
          dashLength: 6,
          gapLength: 5,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(32),
          child: constrained,
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: constrained,
    );
  }
}

/// Paints a dashed rounded-rectangle border (Flutter has no built-in dashed
/// border). Used by [BCEmptyState]'s outline variant.
class _DashedBorderDecoration extends Decoration {
  const _DashedBorderDecoration({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    this.dashLength = 6,
    this.gapLength = 5,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DashedBorderPainter(this);
  }
}

class _DashedBorderPainter extends BoxPainter {
  _DashedBorderPainter(this.decoration);

  final _DashedBorderDecoration decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null || size.isEmpty) return;

    final rect = offset & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(decoration.strokeWidth / 2),
      Radius.circular(decoration.radius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = decoration.strokeWidth
      ..color = decoration.color;

    final source = Path()..addRRect(rrect);
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + decoration.dashLength;
        dashed.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + decoration.gapLength;
      }
    }
    canvas.drawPath(dashed, paint);
  }
}

/// Helper for a HeroUI-style overlapping avatar-group illustration, matching
/// the "With avatar group" empty-state design. Purely decorative.
class BCEmptyStateAvatarCluster extends StatelessWidget {
  const BCEmptyStateAvatarCluster({
    super.key,
    this.size = 64,
    this.overlap = 24,
  });

  final double size;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    const gradients = [
      [Color(0xFF60A5FA), Color(0xFF7C3AED)],
      [Color(0xFF34D399), Color(0xFF10B981)],
      [Color(0xFFF472B6), Color(0xFFDB2777)],
    ];

    return SizedBox(
      height: size,
      width: size * 3 - overlap * 2,
      child: Stack(
        children: [
          for (var i = 0; i < gradients.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradients[i],
                  ),
                  shape: CircleBorder(
                    side: BorderSide(
                      color: context.bcTheme.background,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
