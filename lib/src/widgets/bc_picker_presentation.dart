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
          // Flexible either way, so content that scrolls itself — the Select's
          // option list — learns how much room the panel actually has and
          // shrinks to it instead of running off the bottom of the screen.
          Flexible(
            child: scrollable ? SingleChildScrollView(child: child) : child,
          ),
        ],
      ),
    );
  }
}

/// Presents picker content in Flutter's modal sheet route, styled from bc_ui
/// tokens. Going through the real route is what supplies drag-to-dismiss,
/// fling velocity and a scrim that tracks the drag.
///
/// The sheet rides above the on-screen keyboard: `showModalBottomSheet` pins
/// its child to the bottom of the screen and does nothing about the keyboard,
/// so a sheet with a search field in it would otherwise open behind one. The
/// bottom view inset lifts the panel clear, and the top inset caps how tall it
/// may grow, which leaves the content — the search field and as many rows as
/// fit — in the band between the status bar and the keyboard.
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
    builder: (sheetContext) {
      // MediaQuery for the keyboard — reading it is also what rebuilds this
      // builder as the keyboard slides. The notch has to come off the view
      // instead: the sheet route strips the top padding from the MediaQuery it
      // hands its child, which would leave the cap below at zero and let a tall
      // sheet run up under the status bar.
      final media = MediaQuery.of(sheetContext);
      final view = View.of(sheetContext);

      return Padding(
        padding: EdgeInsets.only(
          // `viewPadding`: the notch is there whether or not the keyboard is.
          // Only caps the height — the sheet itself is bottom-aligned.
          top: view.viewPadding.top / view.devicePixelRatio + BCSpacing.sm,
          bottom: media.viewInsets.bottom,
        ),
        child: BCPickerPanel(
          showHandle: true,
          roundedTopOnly: true,
          scrollable: scrollable,
          // `padding`, not `viewPadding`, so the home indicator is only cleared
          // when the keyboard isn't already covering it.
          bottomInset: media.padding.bottom,
          child: builder(sheetContext),
        ),
      );
    },
  );
}
