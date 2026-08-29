import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../theme/theme_extensions.dart';
import '../tokens/bc_motion.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';
import '../tokens/bc_typography.dart';
import 'bc_pressable.dart';
import 'bc_separator.dart';

/// An entry in a [BCNavDrawer]: a destination, a section label, or a rule.
sealed class BCNavDrawerItem {
  const BCNavDrawerItem();
}

/// A selectable destination. Only these count towards `selectedIndex`.
class BCNavDrawerDestination extends BCNavDrawerItem {
  const BCNavDrawerDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount,
    this.showDot = false,
    this.isDisabled = false,
  });

  final Widget icon;

  /// Optional distinct icon for the selected state (defaults to [icon]).
  final Widget? selectedIcon;

  final String label;
  final int? badgeCount;
  final bool showDot;
  final bool isDisabled;
}

/// A muted heading above a group of destinations.
class BCNavDrawerSection extends BCNavDrawerItem {
  const BCNavDrawerSection(this.label);

  final String label;
}

/// A hairline rule between groups.
class BCNavDrawerDivider extends BCNavDrawerItem {
  const BCNavDrawerDivider();
}

enum BCNavDrawerVariant {
  /// Sits inline in the layout on large windows — square trailing edge.
  standard,

  /// Slides over the content — rounded trailing corners and overlay shadow.
  /// Pass it to `Scaffold.drawer`.
  modal,
}

/// Vertical navigation for expanded and larger windows, or as a slide-over on
/// compact ones (Material 3 "navigation drawer", styled from bc_ui tokens).
///
/// [items] mixes destinations with section labels and dividers;
/// `selectedIndex` counts destinations only, so inserting a label never
/// shifts your indices.
///
/// ```dart
/// Scaffold(
///   drawer: BCNavDrawer(
///     variant: BCNavDrawerVariant.modal,
///     selectedIndex: index,
///     onDestinationSelected: (i) => setState(() => index = i),
///     header: const Text('Mailbox'),
///     items: const [
///       BCNavDrawerSection('Inbox'),
///       BCNavDrawerDestination(icon: Icon(Icons.inbox), label: 'All mail', badgeCount: 12),
///       BCNavDrawerDivider(),
///       BCNavDrawerDestination(icon: Icon(Icons.settings), label: 'Settings'),
///     ],
///   ),
/// );
/// ```
class BCNavDrawer extends StatelessWidget {
  const BCNavDrawer({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.variant = BCNavDrawerVariant.standard,
    this.header,
    this.footer,
    this.width = 320,
    this.showIndicator = true,
    this.backgroundColor,
    this.closeOnSelect = true,
  });

  final List<BCNavDrawerItem> items;

  /// Index among the [BCNavDrawerDestination] entries only.
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  final BCNavDrawerVariant variant;

  /// Above the items — a product name, an account row, a search field.
  final Widget? header;

  /// Below the items, pinned to the bottom edge.
  final Widget? footer;

  final double width;

  /// Paints the accent-soft pill behind the selected destination.
  final bool showIndicator;

  final Color? backgroundColor;

  /// Pops the enclosing route (the `Scaffold` drawer) after a selection.
  /// Only applies to [BCNavDrawerVariant.modal].
  final bool closeOnSelect;

  bool get _isModal => variant == BCNavDrawerVariant.modal;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    // Destination ordinals, so section labels never shift the indices.
    var ordinal = 0;
    final rows = <Widget>[];
    for (final item in items) {
      switch (item) {
        case BCNavDrawerDestination():
          rows.add(_destination(context, bc, item, ordinal));
          ordinal++;
        case BCNavDrawerSection():
          rows.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(
                BCSpacing.lg,
                BCSpacing.md,
                BCSpacing.lg,
                BCSpacing.sm,
              ),
              child: Text(
                item.label,
                style: BCTypography.textSm.copyWith(
                  color: bc.muted,
                  fontWeight: BCTypography.medium,
                ),
              ),
            ),
          );
        case BCNavDrawerDivider():
          rows.add(
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: BCSpacing.md,
                vertical: BCSpacing.sm,
              ),
              child: BCSeparator(),
            ),
          );
      }
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              BCSpacing.lg,
              BCSpacing.lg,
              BCSpacing.lg,
              BCSpacing.sm,
            ),
            child: DefaultTextStyle(
              style: BCTypography.textLg.copyWith(
                color: bc.foreground,
                fontWeight: BCTypography.semiBold,
              ),
              child: header!,
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: BCSpacing.sm),
            children: rows,
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              BCSpacing.md,
              BCSpacing.sm,
              BCSpacing.md,
              BCSpacing.md,
            ),
            child: footer,
          ),
      ],
    );

    final background = backgroundColor ?? (_isModal ? bc.overlay : bc.background);

    if (!_isModal) {
      return Container(
        width: width,
        decoration: BoxDecoration(
          color: background,
          border: Border(
            right: BorderSide(color: bc.border, width: bc.borderWidth),
          ),
        ),
        child: SafeArea(right: false, child: content),
      );
    }

    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: background,
        shape: BCShapes.continuousFrom(
          const BorderRadiusDirectional.horizontal(
            end: Radius.circular(BCRadius.xxxl),
          ).resolve(Directionality.of(context)),
          side: bc.overlayShadow.innerBorder ?? BorderSide.none,
        ),
        shadows: bc.overlayShadow.shadows,
      ),
      child: SafeArea(right: false, child: content),
    );
  }

  Widget _destination(
    BuildContext context,
    BCThemeExtension bc,
    BCNavDrawerDestination destination,
    int index,
  ) {
    final selected = index == selectedIndex;
    final color = destination.isDisabled
        ? bc.muted
        : (selected ? bc.accent : bc.foreground);

    final row = AnimatedContainer(
      duration: BCMotion.timingDuration,
      curve: BCMotion.timingCurve,
      height: 56,
      margin: const EdgeInsets.symmetric(
        horizontal: BCSpacing.md,
        vertical: 2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: BCSpacing.md),
      decoration: ShapeDecoration(
        color: selected && showIndicator
            ? bc.accentSoft
            : const Color(0x00000000),
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          _withBadge(
            bc,
            destination,
            IconTheme.merge(
              data: IconThemeData(color: color, size: 24),
              child:
                  (selected ? destination.selectedIcon : null) ?? destination.icon,
            ),
          ),
          const SizedBox(width: BCSpacing.md),
          Expanded(
            child: Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BCTypography.textSm.copyWith(
                color: color,
                fontWeight:
                    selected ? BCTypography.semiBold : BCTypography.medium,
              ),
            ),
          ),
          if (destination.badgeCount != null && destination.badgeCount! > 0)
            Text(
              '${destination.badgeCount}',
              style: BCTypography.textSm.copyWith(
                color: selected ? bc.accent : bc.muted,
                fontWeight: BCTypography.medium,
              ),
            ),
        ],
      ),
    );

    if (destination.isDisabled) {
      return Opacity(opacity: bc.opacityDisabled, child: row);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: BCPressable(
        feedback: BCPressFeedback.none,
        onPressed: () {
          onDestinationSelected(index);
          if (_isModal && closeOnSelect) Navigator.maybePop(context);
        },
        child: row,
      ),
    );
  }

  /// The count is rendered as trailing text (Material's drawer pattern), so
  /// only the dot needs an overlay on the icon.
  Widget _withBadge(
    BCThemeExtension bc,
    BCNavDrawerDestination destination,
    Widget icon,
  ) {
    if (!destination.showDot ||
        (destination.badgeCount != null && destination.badgeCount! > 0)) {
      return icon;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        PositionedDirectional(
          top: -2,
          end: -2,
          child: Container(
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
