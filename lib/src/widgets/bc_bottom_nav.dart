import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

/// A single destination in a [BCBottomNav].
class BCBottomNavItem {
  const BCBottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount,
    this.showDot = false,
  });

  final Widget icon;

  /// Optional distinct icon for the selected state (defaults to [icon]).
  final Widget? activeIcon;

  final String label;

  /// Shows a small count badge on the icon when non-null and > 0.
  final int? badgeCount;

  /// Shows a small dot badge (ignored when [badgeCount] is set).
  final bool showDot;
}

/// How labels are displayed in a [BCBottomNav].
enum BCBottomNavLabels { all, selected, none }

enum BCBottomNavVariant {
  /// Full-width bar attached to the bottom with a top hairline.
  standard,

  /// Detached, rounded, floating bar with an overlay shadow.
  floating,
}

/// A bottom navigation bar styled to the bc_ui / heroui design system.
///
/// Drop-in like Material's bottom nav ([items] + [currentIndex] + [onTap]),
/// but built from bc_ui tokens: surface background, accent selection with an
/// accent-soft pill indicator, muted inactive items, press feedback, and
/// optional badges. Place it in `Scaffold.bottomNavigationBar`.
class BCBottomNav extends StatelessWidget {
  const BCBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.variant = BCBottomNavVariant.standard,
    this.labels = BCBottomNavLabels.all,
    this.showIndicator = true,
  }) : assert(items.length >= 2, 'BCBottomNav needs at least 2 items');

  final List<BCBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final BCBottomNavVariant variant;
  final BCBottomNavLabels labels;

  /// Shows the accent-soft pill behind the selected icon.
  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final isFloating = variant == BCBottomNavVariant.floating;

    final row = Row(
      children: [
        for (var i = 0; i < items.length; i++)
          Expanded(child: _item(context, bc, items[i], i)),
      ],
    );

    if (isFloating) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: bc.surface,
            shape: BCShapes.continuous(
              BCRadius.xxxl,
              side: bc.overlayShadow.innerBorder ?? BorderSide.none,
            ),
            shadows: bc.overlayShadow.shadows,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: row,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bc.surface,
        border: Border(top: BorderSide(color: bc.border, width: bc.borderWidth)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8 + bottomInset),
        child: row,
      ),
    );
  }

  Widget _item(
    BuildContext context,
    BCThemeExtension bc,
    BCBottomNavItem item,
    int index,
  ) {
    final selected = index == currentIndex;
    final color = selected ? bc.accent : bc.muted;

    final showLabel = switch (labels) {
      BCBottomNavLabels.all => true,
      BCBottomNavLabels.selected => selected,
      BCBottomNavLabels.none => false,
    };

    final icon = IconTheme.merge(
      data: IconThemeData(color: color, size: 24),
      child: (selected ? item.activeIcon : null) ?? item.icon,
    );

    return BCPressable(
      feedback: BCPressFeedback.none,
      onPressed: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: ShapeDecoration(
                color: selected && showIndicator
                    ? bc.accentSoft
                    : const Color(0x00000000),
                shape: const StadiumBorder(),
              ),
              child: _iconWithBadge(bc, item, icon),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: showLabel
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BCTypography.textXs.copyWith(
                          color: color,
                          fontWeight: BCTypography.medium,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconWithBadge(
    BCThemeExtension bc,
    BCBottomNavItem item,
    Widget icon,
  ) {
    final hasCount = item.badgeCount != null && item.badgeCount! > 0;
    if (!hasCount && !item.showDot) return icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -4,
          right: -8,
          child: hasCount
              ? Container(
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: bc.danger,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
                    style: BCTypography.textXs.copyWith(
                      color: bc.dangerForeground,
                      fontWeight: BCTypography.semiBold,
                      height: 1,
                    ),
                  ),
                )
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: bc.danger,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ],
    );
  }
}
