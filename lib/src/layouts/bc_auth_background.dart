import 'package:bc_ui/src/theme/color_schemes.dart';
import 'package:flutter/material.dart';

/// Decorative auth-screen background: base canvas, diagonal gradient, and
/// two circular accent blobs. Matches the medic-tw auth layout pattern.
///
/// Decoration layers ignore pointer events so taps pass through to [child].
class BCAuthBackground extends StatelessWidget {
  const BCAuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: BCColorSchemes.background(brightness)),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.14),
                    const Color(0xFF10B981).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -64,
          child: IgnorePointer(
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        Positioned(
          top: 160,
          left: -96,
          child: IgnorePointer(
            child: Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
