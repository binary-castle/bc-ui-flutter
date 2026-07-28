import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';

import '../extensions/context_extension.dart';
import '../tokens/bc_radius.dart';
import '../tokens/bc_shapes.dart';
import '../tokens/bc_spacing.dart';

/// How a picker field surfaces its content.
///
/// Shared by [BCDateField], [BCTimeField] and [BCDateTimePicker] so the three
/// behave the same way whichever one a screen happens to use.
enum BCPickerPresentation {
  /// Anchored under the field, matching its width.
  popover,

  /// Centered modal over a dimmed backdrop.
  dialog,

  /// Flutter's modal sheet route — drag-to-dismiss included.
  bottomSheet,
}

/// Former name of [BCPickerPresentation], from when only the date-and-time
/// picker had presentations.
@Deprecated('Renamed to BCPickerPresentation; all three pickers share it.')
typedef BCDateTimePickerPresentation = BCPickerPresentation;

/// Overlay chrome around picker content shown in a popover or a sheet:
/// overlay surface, continuous corners and the overlay shadow.
///
/// Internal to the picker widgets — not exported from `bc_ui.dart`.
class BCPickerPanel extends StatelessWidget {
  const BCPickerPanel({
    super.key,
    required this.child,
    this.showHandle = false,
    this.bottomInset = 0,
    this.roundedTopOnly = false,
    this.scrollable = false,
  });

  final Widget child;

  /// Grab handle above the content, for sheets.
  final bool showHandle;

  /// Extra bottom padding, used to carry the home-indicator inset *inside*
  /// a sheet so its surface stays flush with the screen edge.
  final double bottomInset;

  /// Sheets round only their top corners.
  final bool roundedTopOnly;

  /// Lets tall content (a calendar) scroll instead of overflowing when the
  /// popover or sheet has less room than the content wants. Leave false for
  /// wheel content: an outer vertical scroller would steal the spin drags.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final bc = context.bcTheme;

    return Container(
      width: roundedTopOnly ? double.infinity : null,
      padding: EdgeInsets.fromLTRB(
        BCSpacing.sm,
        BCSpacing.sm,
        BCSpacing.sm,
        BCSpacing.sm + bottomInset,
      ),
      decoration: ShapeDecoration(
        color: bc.overlay,
        shape: roundedTopOnly
            ? BCShapes.continuousFrom(
                const BorderRadius.vertical(
                  top: Radius.circular(BCRadius.xxxl),
                ),
                side: bc.overlayShadow.innerBorder ?? BorderSide.none,
              )
            : BCShapes.continuous(
                BCRadius.xxxl,
                side: bc.overlayShadow.innerBorder ?? BorderSide.none,
              ),
        shadows: bc.overlayShadow.shadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle)
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: BCSpacing.sm),
              decoration: ShapeDecoration(
                color: bc.separator,
                shape: BCShapes.continuous(BCRadius.full),
              ),
            ),
          if (scrollable)
            Flexible(child: SingleChildScrollView(child: child))
          else
            child,
        ],
      ),
    );
  }
}

/// Presents picker content in Flutter's modal sheet route, styled from bc_ui
/// tokens. Going through the real route is what supplies drag-to-dismiss,
/// fling velocity and a scrim that tracks the drag.
///
/// Internal to the picker widgets — not exported from `bc_ui.dart`.
Future<T?> showBCPickerSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool scrollable = false,
}) {
  final bc = context.bcTheme;

  return showModalBottomSheet<T>(
    context: context,
    // The panel paints the surface, so the route's own is invisible.
    backgroundColor: const Color(0x00000000),
    barrierColor: bc.backdrop,
    elevation: 0,
    isScrollControlled: true,
    builder: (sheetContext) => BCPickerPanel(
      showHandle: true,
      roundedTopOnly: true,
      scrollable: scrollable,
      bottomInset: MediaQuery.viewPaddingOf(sheetContext).bottom,
      child: builder(sheetContext),
    ),
  );
}
