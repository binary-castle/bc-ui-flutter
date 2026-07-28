import 'dart:math' as math;

import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    theme: BCTheme.light(),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Center(
          child: SizedBox(width: 300, height: 200, child: child),
        ),
      ),
    ),
  );
}

/// A card that records taps, so the ribbon overlay can be proven inert.
class _TapCard extends StatelessWidget {
  const _TapCard(this.onTap);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(color: const Color(0xFFEEEEEE)),
    );
  }
}

/// The filled band of a corner ribbon.
final Finder _band = find
    .descendant(of: find.byType(BCRibbon), matching: find.byType(DecoratedBox))
    .first;

/// The clip that trims a ribbon to the card's corners — as opposed to the
/// decoration clip every filled shape carries.
final Finder _cardClip = find.byWidgetPredicate(
  (widget) => widget is ClipPath && widget.clipper is ShapeBorderClipper,
);

void main() {
  group('BCRibbon', () {
    testWidgets('every form renders its label over the card', (tester) async {
      for (final form in BCRibbonForm.values) {
        await tester.pumpWidget(
          _app(
            BCRibbon.label(
              'Hot Sale',
              form: form,
              child: const ColoredBox(color: Color(0xFFEEEEEE)),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.text('Hot Sale'),
          findsOneWidget,
          reason: '${form.name} did not render',
        );
        expect(tester.takeException(), isNull, reason: form.name);
      }
    });

    testWidgets('every variant and color paints', (tester) async {
      for (final variant in BCRibbonVariant.values) {
        for (final color in BCRibbonColor.values) {
          await tester.pumpWidget(
            _app(BCRibbon.label('Deal', variant: variant, color: color)),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$variant/$color');
        }
      }
    });

    testWidgets('the overlay does not steal taps from the card',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          BCRibbon.label(
            'Hot Sale',
            child: _TapCard(() => taps++),
          ),
        ),
      );

      // Tapping the ribbon itself must reach the card underneath.
      await tester.tapAt(tester.getCenter(find.text('Hot Sale')));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('position anchors the ribbon to the right corner',
        (tester) async {
      Future<Offset> cornerOf(BCRibbonPosition position) async {
        await tester.pumpWidget(
          _app(
            BCRibbon.label(
              'Deal',
              position: position,
              child: const ColoredBox(color: Color(0xFFEEEEEE)),
            ),
          ),
        );
        await tester.pump();
        return tester.getCenter(find.text('Deal'));
      }

      final topStart = await cornerOf(BCRibbonPosition.topStart);
      final card = tester.getCenter(find.byType(BCRibbon));
      expect(topStart.dx, lessThan(card.dx));
      expect(topStart.dy, lessThan(card.dy));

      final bottomEnd = await cornerOf(BCRibbonPosition.bottomEnd);
      expect(bottomEnd.dx, greaterThan(card.dx));
      expect(bottomEnd.dy, greaterThan(card.dy));
    });

    testWidgets('start/end follow the text direction', (tester) async {
      await tester.pumpWidget(
        _app(
          BCRibbon.label(
            'Deal',
            child: const ColoredBox(color: Color(0xFFEEEEEE)),
          ),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pump();

      // topStart in RTL means the top-right corner.
      expect(
        tester.getCenter(find.text('Deal')).dx,
        greaterThan(tester.getCenter(find.byType(BCRibbon)).dx),
      );
    });

    testWidgets('the corner band tilts to match its corner', (tester) async {
      Future<double> angleOf(BCRibbonPosition position) async {
        await tester.pumpWidget(
          _app(
            BCRibbon.label(
              'Deal',
              form: BCRibbonForm.corner,
              position: position,
              child: const ColoredBox(color: Color(0xFFEEEEEE)),
            ),
          ),
        );
        await tester.pump();
        final transform = tester
            .widget<Transform>(find.byType(Transform).first)
            .transform;
        return math.atan2(transform.getRow(1)[0], transform.getRow(0)[0]);
      }

      expect(await angleOf(BCRibbonPosition.topStart), closeTo(-math.pi / 4, 0.01));
      expect(await angleOf(BCRibbonPosition.topEnd), closeTo(math.pi / 4, 0.01));
      expect(
        await angleOf(BCRibbonPosition.bottomStart),
        closeTo(math.pi / 4, 0.01),
      );
      expect(
        await angleOf(BCRibbonPosition.bottomEnd),
        closeTo(-math.pi / 4, 0.01),
      );
    });

    testWidgets('the corner band grows with its label', (tester) async {
      Future<Offset> labelCentreFor(String text) async {
        await tester.pumpWidget(
          _app(
            BCRibbon.label(
              text,
              form: BCRibbonForm.corner,
              child: const ColoredBox(color: Color(0xFFEEEEEE)),
            ),
          ),
        );
        await tester.pump();
        return tester.getCenter(find.text(text));
      }

      final short = await labelCentreFor('New');
      final corner = tester.getTopLeft(find.byType(BCRibbon));
      final long = await labelCentreFor('Best Seller of the year');

      // A longer label needs a longer slice of the corner, so the band slides
      // away from it.
      expect(
        (long - corner).distance,
        greaterThan((short - corner).distance),
      );
    });

    testWidgets('cornerOffset 0 fills the corner instead of floating',
        (tester) async {
      Future<({double thickness, Offset centre})> bandFor(double? offset) async {
        await tester.pumpWidget(
          _app(
            BCRibbon.label(
              'Best Seller',
              form: BCRibbonForm.corner,
              cornerOffset: offset,
              child: const ColoredBox(color: Color(0xFFEEEEEE)),
            ),
          ),
        );
        await tester.pump();
        return (
          thickness: tester.getSize(_band).height,
          centre: tester.getCenter(_band),
        );
      }

      final floating = await bandFor(null);
      final corner = tester.getTopLeft(find.byType(BCRibbon));
      final filled = await bandFor(0);

      // Pinned to the corner the band cannot slide away, so it thickens
      // instead — and its near edge lands on the corner itself, which puts
      // its centre exactly half a thickness away.
      expect(filled.thickness, greaterThan(floating.thickness));
      expect(
        (filled.centre - corner).distance,
        closeTo(filled.thickness / 2, 1),
      );
      expect(
        (floating.centre - corner).distance,
        greaterThan(floating.thickness / 2 + 1),
      );
    });

    testWidgets('cornerThickness overrides the measured band', (tester) async {
      await tester.pumpWidget(
        _app(
          BCRibbon.label(
            'Sale',
            form: BCRibbonForm.corner,
            cornerThickness: 64,
            child: const ColoredBox(color: Color(0xFFEEEEEE)),
          ),
        ),
      );
      await tester.pump();
      expect(tester.getSize(_band).height, closeTo(64, 0.01));
    });

    testWidgets('the corner band is clipped to the card corners',
        (tester) async {
      await tester.pumpWidget(
        _app(
          BCRibbon.label(
            'Deal',
            form: BCRibbonForm.corner,
            child: const ColoredBox(color: Color(0xFFEEEEEE)),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.descendant(of: find.byType(BCRibbon), matching: _cardClip),
        findsOneWidget,
      );
    });

    testWidgets('an inset ribbon is not clipped, so it can overhang',
        (tester) async {
      Future<double> leftEdgeAt(double inset) async {
        await tester.pumpWidget(
          _app(
            BCRibbon.label(
              'Deal',
              inset: inset,
              child: const ColoredBox(color: Color(0xFFEEEEEE)),
            ),
          ),
        );
        await tester.pump();
        return tester.getTopLeft(find.text('Deal')).dx;
      }

      final flush = await leftEdgeAt(0);
      final overhanging = await leftEdgeAt(-8);

      // A negative inset pushes the ribbon out past the card, which only
      // works because inset forms are left unclipped.
      expect(overhanging, closeTo(flush - 8, 0.01));
      expect(
        find.descendant(of: find.byType(BCRibbon), matching: _cardClip),
        findsNothing,
      );
    });

    testWidgets('without a child it sizes itself to the label',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: BCTheme.light(),
          home: const Scaffold(
            body: Center(child: BCRibbon(label: Text('Hot Sale'))),
          ),
        ),
      );
      await tester.pump();

      final ribbon = tester.getSize(find.byType(BCRibbon));
      final label = tester.getSize(find.text('Hot Sale'));
      expect(ribbon.width, greaterThan(label.width));
      expect(ribbon.width, lessThan(label.width + 40));
    });

    testWidgets('sizes scale the label', (tester) async {
      final heights = <double>[];
      for (final size in BCRibbonSize.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: BCTheme.light(),
            home: Scaffold(
              body: Center(child: BCRibbon.label('Deal', size: size)),
            ),
          ),
        );
        await tester.pump();
        heights.add(tester.getSize(find.byType(BCRibbon)).height);
      }
      expect(heights[0], lessThan(heights[1]));
      expect(heights[1], lessThan(heights[2]));
    });
  });
}
