import 'package:bc_ui/bc_ui.dart';
import 'package:bc_ui/src/painting/bc_svg_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: brightness == Brightness.light ? BCTheme.light() : BCTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('parseSvgPathData', () {
    test('absolute and relative line commands trace the same box', () {
      expect(
        parseSvgPathData('M0 0 H10 V10 H0 Z').getBounds(),
        const Rect.fromLTRB(0, 0, 10, 10),
      );
      expect(
        parseSvgPathData('m0 0h10v10h-10z').getBounds(),
        const Rect.fromLTRB(0, 0, 10, 10),
      );
    });

    test('implicit repeats after a moveto are line segments', () {
      expect(
        parseSvgPathData('M0 0 4 0 4 4').getBounds(),
        const Rect.fromLTRB(0, 0, 4, 4),
      );
    });

    test('reads packed numbers and packed arc flags', () {
      // "-.5.5" is two numbers, and the arc flags carry no separators.
      expect(
        parseSvgPathData('M1 1l-.5.5a1 1 0 011 1z').getBounds().isEmpty,
        isFalse,
      );
    });

    test('smooth curves reflect the previous control point', () {
      final smooth = parseSvgPathData('M0 0C0 10 10 10 10 0S20 -10 20 0');
      final explicit = parseSvgPathData('M0 0C0 10 10 10 10 0C10 -10 20 -10 20 0');
      expect(smooth.getBounds(), explicit.getBounds());
    });

    test('rejects data that does not start with a command', () {
      expect(() => parseSvgPathData('10 10'), throwsFormatException);
    });
  });

  group('BCBrandLogo', () {
    testWidgets('every provider paints in both themes', (tester) async {
      for (final provider in BCSocialProvider.values) {
        for (final brightness in Brightness.values) {
          await tester.pumpWidget(
            _app(BCBrandLogo(provider: provider), brightness: brightness),
          );
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: '${provider.name} failed to paint',
          );
        }
      }
    });

    testWidgets('fits the mark inside the requested square', (tester) async {
      await tester.pumpWidget(
        _app(const BCBrandLogo(provider: BCSocialProvider.google, size: 32)),
      );
      expect(
        tester.getSize(find.byType(BCBrandLogo)),
        const Size.square(32),
      );
    });
  });

  group('BCSocialAuthButton', () {
    testWidgets('labels itself with the provider name and fires onPressed',
        (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _app(
          BCSocialAuthButton(
            provider: BCSocialProvider.github,
            onPressed: () => pressed++,
          ),
        ),
      );

      expect(find.text('GitHub'), findsOneWidget);
      await tester.tap(find.byType(BCSocialAuthButton));
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });

    testWidgets('label overrides the provider name', (tester) async {
      await tester.pumpWidget(
        _app(
          const BCSocialAuthButton(
            provider: BCSocialProvider.google,
            label: 'Continue with Google',
          ),
        ),
      );

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Google'), findsNothing);
    });

    testWidgets('loading swaps the logo for a spinner and blocks presses',
        (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _app(
          BCSocialAuthButton(
            provider: BCSocialProvider.apple,
            isLoading: true,
            onPressed: () => pressed++,
          ),
        ),
      );

      expect(find.byType(BCSpinner), findsOneWidget);
      expect(find.byType(BCBrandLogo), findsNothing);

      await tester.tap(find.byType(BCSocialAuthButton));
      await tester.pump(const Duration(milliseconds: 300));
      expect(pressed, 0);
    });

    testWidgets('icon-only drops the label and stays square', (tester) async {
      await tester.pumpWidget(
        _app(
          const BCSocialAuthButton(
            provider: BCSocialProvider.slack,
            isIconOnly: true,
          ),
        ),
      );

      expect(find.text('Slack'), findsNothing);
      final size = tester.getSize(find.byType(BCSocialAuthButton));
      expect(size.width, size.height);
    });
  });
}
