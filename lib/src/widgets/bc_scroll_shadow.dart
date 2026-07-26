import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_motion.dart';

/// HeroUI Native ScrollShadow: fades the edges of a scrollable while more
/// content is available in that direction (200ms fade, scroll-shadow
/// sources). Wrap the scrollable; the shadows are painted over its edges in
/// the container color (defaults to the `background` token).
class BCScrollShadow extends StatefulWidget {
  const BCScrollShadow({
    super.key,
    required this.child,
    this.size = 40,
    this.color,
    this.direction = Axis.vertical,
  });

  final Widget child;

  /// Extent of the fade gradient.
  final double size;

  /// Defaults to the theme `background` color.
  final Color? color;

  final Axis direction;

  @override
  State<BCScrollShadow> createState() => _BCScrollShadowState();
}

class _BCScrollShadowState extends State<BCScrollShadow> {
  bool _showStart = false;
  bool _showEnd = true;

  bool _handleNotification(ScrollNotification notification) {
    if (notification.metrics.axis != widget.direction) return false;
    final metrics = notification.metrics;
    final showStart = metrics.extentBefore > 1;
    final showEnd = metrics.extentAfter > 1;
    if (showStart != _showStart || showEnd != _showEnd) {
      setState(() {
        _showStart = showStart;
        _showEnd = showEnd;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.bcTheme.background;
    final vertical = widget.direction == Axis.vertical;

    Widget shadow({required bool start, required bool visible}) {
      final begin = vertical
          ? (start ? Alignment.topCenter : Alignment.bottomCenter)
          : (start ? Alignment.centerLeft : Alignment.centerRight);
      final end = vertical
          ? (start ? Alignment.bottomCenter : Alignment.topCenter)
          : (start ? Alignment.centerRight : Alignment.centerLeft);

      return Positioned(
        top: vertical ? (start ? 0 : null) : 0,
        bottom: vertical ? (start ? null : 0) : 0,
        left: vertical ? 0 : (start ? 0 : null),
        right: vertical ? 0 : (start ? null : 0),
        height: vertical ? widget.size : null,
        width: vertical ? null : widget.size,
        child: IgnorePointer(
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: BCMotion.scrollShadowDuration,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: begin,
                  end: end,
                  colors: [color, color.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: Stack(
        children: [
          widget.child,
          shadow(start: true, visible: _showStart),
          shadow(start: false, visible: _showEnd),
        ],
      ),
    );
  }
}
