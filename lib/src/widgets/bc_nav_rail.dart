import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_motion.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';

/// A destination in a [BCNavRail].
class BCNavRailDestination {
  const BCNavRailDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount,
    this.showDot = false,
  });

  final Widget icon;

  /// Optional distinct icon for the selected state (defaults to [icon]).
  final Widget? selectedIcon;

  final String label;

  /// Shows a small count badge on the icon when non-null and > 0.
  final int? badgeCount;

  /// Shows a small dot badge (ignored when [badgeCount] is set).
  final bool showDot;
}

/// How labels are displayed in a collapsed [BCNavRail].
enum BCNavRailLabels { all, selected, none }

/// Vertical navigation for medium and larger windows — the counterpart to
/// [BCBottomNav] on compact ones (Material 3 "navigation rail", styled from
/// bc_ui tokens).
///
/// Collapsed it is an 80px strip of icons with labels underneath; [extended]
/// widens it so icons and labels sit side by side in a pill. The width change
/// animates, so you can drive [extended] straight from a `LayoutBuilder`:
///
/// ```dart
/// LayoutBuilder(
///   builder: (context, constraints) => Row(
///     children: [
///       BCNavRail(
///         destinations: destinations,
///         selectedIndex: index,
///         onDestinationSelected: (i) => setState(() => index = i),
///         extended: constraints.maxWidth >= BCBreakpoints.lg,
///         leading: BCFab(icon: const Icon(Icons.add), onPressed: () {}),
///       ),
///       const Expanded(child: Body()),
///     ],
///   ),
/// );
/// ```
class BCNavRail extends StatelessWidget {
  const BCNavRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
    this.labels = BCNavRailLabels.all,
    this.leading,
    this.trailing,
    this.groupAlignment = -1,
    this.showIndicator = true,
    this.showSeparator = true,
    this.backgroundColor,
    this.width = 80,
    this.extendedWidth = 232,
  }) : assert(
         destinations.length >= 2,
         'BCNavRail needs at least 2 destinations',
       ),
       assert(
         groupAlignment >= -1 && groupAlignment <= 1,
         'groupAlignment must be between -1 (top) and 1 (bottom)',
       );

  final List<BCNavRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Widens the rail and moves labels beside their icons.
  final bool extended;

  /// Label visibility while collapsed; the extended rail always shows them.
  final BCNavRailLabels labels;

  /// Pinned above the destinations — typically a FAB or a menu button.
  final Widget? leading;

  /// Pinned below the destinations — settings, an avatar, a theme toggle.
  final Widget? trailing;

  /// Vertical placement of the destination group: -1 top, 0 center, 1 bottom.
  final double groupAlignment;

  /// Paints the accent-soft pill behind the selected destination.
  final bool showIndicator;

  /// Hairline border on the trailing edge, separating rail from content.
  final bool showSeparator;

  final Color? backgroundColor;
  final double width;
  final double extendedWidth;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return AnimatedContainer(
      duration: BCMotion.timingDuration,
      curve: BCMotion.timingCurve,
      width: extended ? extendedWidth : width,
      decoration: BoxDecoration(
        color: backgroundColor ?? bc.background,
        border: showSeparator
            ? Border(
                right: BorderSide(color: bc.border, width: bc.borderWidth),
              )
            : null,
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leading != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BCSpacing.sm,
                  BCSpacing.md,
                  BCSpacing.sm,
                  BCSpacing.sm,
                ),
                child: Align(
                  alignment: extended
                      ? AlignmentDirectional.centerStart
                      : Alignment.center,
                  child: leading,
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment(0, groupAlignment),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        _destination(context, bc, destinations[i], i),
                    ],
                  ),
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  BCSpacing.sm,
                  BCSpacing.sm,
                  BCSpacing.sm,
                  BCSpacing.md,
                ),
                child: Align(
                  alignment: extended
                      ? AlignmentDirectional.centerStart
                      : Alignment.center,
                  child: trailing,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _destination(
    BuildContext context,
    BCThemeExtension bc,
    BCNavRailDestination destination,
    int index,
  ) {
    final selected = index == selectedIndex;
    final color = selected ? bc.accent : bc.muted;

    final icon = IconTheme.merge(
      data: IconThemeData(color: color, size: 24),
      child: (selected ? destination.selectedIcon : null) ?? destination.icon,
    );

    final labelStyle = BCTypography.textXs.copyWith(
      color: color,
      fontWeight: selected ? BCTypography.semiBold : BCTypography.medium,
    );

    final indicatorColor = selected && showIndicator
        ? bc.accentSoft
        : const Color(0x00000000);

    final Widget body;
    if (extended) {
      body = AnimatedContainer(
        duration: BCMotion.timingDuration,
        curve: BCMotion.timingCurve,
        margin: const EdgeInsets.symmetric(
          horizontal: BCSpacing.md,
          vertical: BCSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: BCSpacing.md,
          vertical: 12,
        ),
        decoration: ShapeDecoration(
          color: indicatorColor,
          shape: const StadiumBorder(),
        ),
        // The rail's width animates but the row's content does not, so the
        // row is laid out at its final size and clipped on the way there.
        child: SizedBox(
          height: 24,
          child: ClipRect(
            child: OverflowBox(
              alignment: AlignmentDirectional.centerStart,
              minHeight: 24,
              maxHeight: 24,
              maxWidth: extendedWidth - BCSpacing.md * 4,
              child: Row(
                children: [
                  _withBadge(bc, destination, icon),
                  const SizedBox(width: BCSpacing.md),
                  Expanded(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BCTypography.textSm.copyWith(
                        color: color,
                        fontWeight: selected
                            ? BCTypography.semiBold
                            : BCTypography.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      final showLabel = switch (labels) {
        BCNavRailLabels.all => true,
        BCNavRailLabels.selected => selected,
        BCNavRailLabels.none => false,
      };

      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: BCSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: BCMotion.timingDuration,
              curve: BCMotion.timingCurve,
              padding: const EdgeInsets.symmetric(
                horizontal: BCSpacing.md,
                vertical: BCSpacing.xs,
              ),
              decoration: ShapeDecoration(
                color: indicatorColor,
                shape: const StadiumBorder(),
              ),
              child: _withBadge(bc, destination, icon),
            ),
            AnimatedSize(
              duration: BCMotion.timingDuration,
              curve: BCMotion.timingCurve,
              child: showLabel
                  ? Padding(
                      padding: const EdgeInsets.only(top: BCSpacing.xs),
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: BCPressable(
        feedback: BCPressFeedback.none,
        onPressed: () => onDestinationSelected(index),
        child: body,
      ),
    );
  }

  Widget _withBadge(
    BCThemeExtension bc,
    BCNavRailDestination destination,
    Widget icon,
  ) {
    final hasCount =
        destination.badgeCount != null && destination.badgeCount! > 0;
    if (!hasCount && !destination.showDot) return icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        PositionedDirectional(
          top: -4,
          end: -8,
          child: hasCount
              ? Container(
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: BCSpacing.xs),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: bc.danger,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    destination.badgeCount! > 99
                        ? '99+'
                        : '${destination.badgeCount}',
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
                  decoration: ShapeDecoration(
                    color: bc.danger,
                    shape: BCShapes.continuous(BCRadius.full),
                  ),
                ),
        ),
      ],
    );
  }
}
