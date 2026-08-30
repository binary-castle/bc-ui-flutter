import 'dart:ui' as ui;

import 'package:bc_ui/bc_ui.dart';
import 'package:bc_ui/src/theme/component_themes/skeleton_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The skeleton base is translucent by design, so what matters is the colour
/// it composites to over the surface beneath it. Every check here samples the
/// painted pixel rather than the widget's declared colours.

const _lightSurface = Color(0xFFFFFFFF);
const _darkSurface = Color(0xFF18181B);

/// Light `muted`, the token the base is derived from. Painting this solid was
/// the original bug: it is darker than every surface in the palette.
const _lightMuted = Color(0xFF71717A);

final _boundaryKey = GlobalKey();

Widget _app({
  required ThemeData theme,
  required Color surface,
  required BCSkeletonVariant variant,
}) {
  return MaterialApp(
    theme: theme,
    home: Center(
      child: RepaintBoundary(
        key: _boundaryKey,
        child: ColoredBox(
          color: surface,
          // Keyed per variant so switching variants rebuilds the state
          // rather than cross-fading through BCSkeleton's AnimatedSwitcher,
          // which would dim the sample while the new child fades in.
          child: BCSkeleton(
            key: ValueKey(variant),
            width: 100,
            height: 100,
            variant: variant,
          ),
        ),
      ),
    ),
  );
}

/// Red channel of the centre pixel. The palette's neutrals are near-grey, so
/// one channel is enough to order them by lightness.
/// Rasterising has to happen through [WidgetTester.runAsync]: `toByteData`
/// never completes inside the test binding's fake-async zone.
Future<int> _centreRed(WidgetTester tester) async {
  final boundary =
      _boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  final red = await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final offset =
          ((image.height ~/ 2) * image.width + (image.width ~/ 2)) * 4;
      return bytes!.getUint8(offset);
    } finally {
      image.dispose();
    }
  });

  return red!;
}

/// How far the brightest point of the sweep clears the unanimated base, in
/// red-channel steps. Measured against the base in the same theme so the
/// check survives a palette resync.
Future<int> _shimmerPeakOverBase(
  WidgetTester tester,
  ThemeData theme,
  Color surface,
) async {
  await tester.pumpWidget(
    _app(theme: theme, surface: surface, variant: BCSkeletonVariant.none),
  );
  await tester.pump();
  final base = await _centreRed(tester);

  await tester.pumpWidget(
    _app(theme: theme, surface: surface, variant: BCSkeletonVariant.shimmer),
  );

  // The band travels from -width to the screen edge over 1500ms, so it only
  // overlaps a 100px skeleton for the first ~330ms of the cycle. Sample that
  // window densely; coarser steps straddle the gradient's peak and under-read
  // the sweep by two thirds.
  var peak = base;
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 10));
    final sample = await _centreRed(tester);
    if (sample > peak) peak = sample;
  }

  return peak - base;
}

/// Lays a text skeleton (or the text it replaces) in a fixed-width column so
/// heights can be compared directly.
Widget _textApp(Widget child, {TextScaler scaler = TextScaler.noScaling}) {
  return MaterialApp(
    theme: BCTheme.light(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: scaler),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 300, child: child),
        ),
      ),
    ),
  );
}

Finder _bars() => find.descendant(
  of: find.byType(BCSkeleton),
  matching: find.byType(ClipRRect),
);

void main() {
  testWidgets('base fill keeps its 30% alpha instead of painting solid muted', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        theme: BCTheme.light(),
        surface: _lightSurface,
        variant: BCSkeletonVariant.none,
      ),
    );
    await tester.pump();

    // muted #71717A at 30% over white composites to ~#D4D4D7.
    expect(await _centreRed(tester), closeTo(212, 2));
  });

  testWidgets('base fill is far lighter than the raw muted token', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        theme: BCTheme.light(),
        surface: _lightSurface,
        variant: BCSkeletonVariant.none,
      ),
    );
    await tester.pump();

    // Guards the regression directly: withValues(alpha:) replaces alpha
    // rather than scaling it, which repainted the base as solid muted.
    expect(await _centreRed(tester), greaterThan(_lightMuted.r * 255 + 50));
  });

  testWidgets('dark base composites to a low-contrast fill on surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        theme: BCTheme.dark(),
        surface: _darkSurface,
        variant: BCSkeletonVariant.none,
      ),
    );
    await tester.pump();

    // muted #9F9FA9 at 30% over #18181B composites to ~#404046.
    expect(await _centreRed(tester), closeTo(64, 2));
  });

  testWidgets('pulse modulates within the base alpha, never beyond it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        theme: BCTheme.light(),
        surface: _lightSurface,
        variant: BCSkeletonVariant.pulse,
      ),
    );

    // Effective alpha sweeps 0.15 -> 0.30, i.e. ~#E9 down to ~#D4 over white.
    // Before the fix it swept 0.5 -> 1.0, bottoming out near muted itself.
    final samples = <int>[];
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 125));
      samples.add(await _centreRed(tester));
    }

    expect(samples.reduce((a, b) => a < b ? a : b), greaterThanOrEqualTo(210));
    expect(samples.reduce((a, b) => a > b ? a : b), lessThanOrEqualTo(236));
  });

  testWidgets('shimmer band reads lighter than the base in light mode', (
    tester,
  ) async {
    expect(
      await _shimmerPeakOverBase(tester, BCTheme.light(), _lightSurface),
      greaterThan(15),
    );
  });

  testWidgets('shimmer band reads lighter than the base in dark mode', (
    tester,
  ) async {
    // The old formula lerped toward the near-black background, which left the
    // dark band darker than the base it swept over — an inverted sweep.
    expect(
      await _shimmerPeakOverBase(tester, BCTheme.dark(), _darkSurface),
      greaterThan(15),
    );
  });

  testWidgets('text skeleton stands exactly as tall as the text it replaces', (
    tester,
  ) async {
    for (final type in BCTextType.values) {
      await tester.pumpWidget(_textApp(const BCText('Hg')));
      final textHeight = tester.getSize(find.byType(BCText)).height;

      await tester.pumpWidget(_textApp(BCSkeleton.text(type: type)));
      final skeletonHeight = tester.getSize(find.byType(BCSkeleton)).height;

      await tester.pumpWidget(_textApp(BCText('Hg', type: type)));
      final typedTextHeight = tester.getSize(find.byType(BCText)).height;

      // The whole point of the constructor: no shift when content arrives.
      expect(
        skeletonHeight,
        typedTextHeight,
        reason: 'height mismatch for $type (body reference $textHeight)',
      );
    }
  });

  testWidgets('a multi-line block is exactly its line count tall', (
    tester,
  ) async {
    await tester.pumpWidget(_textApp(const BCSkeleton.text()));
    final one = tester.getSize(find.byType(BCSkeleton)).height;

    await tester.pumpWidget(_textApp(const BCSkeleton.text(lines: 3)));
    final three = tester.getSize(find.byType(BCSkeleton)).height;

    expect(three, closeTo(one * 3, 0.01));
    expect(_bars(), findsNWidgets(3));
  });

  testWidgets('only a wrapped paragraph gets a short last line', (
    tester,
  ) async {
    await tester.pumpWidget(_textApp(const BCSkeleton.text()));
    expect(tester.getSize(_bars().first).width, 300);

    await tester.pumpWidget(_textApp(const BCSkeleton.text(lines: 3)));
    expect(tester.getSize(_bars().at(0)).width, 300);
    expect(tester.getSize(_bars().at(1)).width, 300);
    expect(
      tester.getSize(_bars().at(2)).width,
      300 * BCSkeletonTheme.defaultLastLineFraction,
    );
  });

  testWidgets('lastLineFraction overrides the ragged edge', (tester) async {
    await tester.pumpWidget(
      _textApp(const BCSkeleton.text(lines: 2, lastLineFraction: 0.25)),
    );

    expect(tester.getSize(_bars().at(1)).width, 300 * 0.25);
  });

  testWidgets('the block tracks the reader text size', (tester) async {
    await tester.pumpWidget(_textApp(const BCSkeleton.text(lines: 2)));
    final normal = tester.getSize(find.byType(BCSkeleton)).height;

    await tester.pumpWidget(
      _textApp(
        const BCSkeleton.text(lines: 2),
        scaler: const TextScaler.linear(2),
      ),
    );
    final scaled = tester.getSize(find.byType(BCSkeleton)).height;

    // A hand-sized bar cannot do this, which is why the constructor exists.
    expect(scaled, closeTo(normal * 2, 0.01));
  });

  testWidgets('the bar sits shorter than its line box, leaving the leading', (
    tester,
  ) async {
    await tester.pumpWidget(_textApp(const BCSkeleton.text()));

    final lineBox = tester.getSize(find.byType(BCSkeleton)).height;
    final bar = tester.getSize(_bars().first).height;

    expect(bar, lessThan(lineBox));
    expect(bar, greaterThan(lineBox * 0.4));
  });

  testWidgets('width bounds the block where the parent does not', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BCTheme.light(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: BCSkeleton.text(width: 120),
        ),
      ),
    );

    expect(tester.getSize(_bars().first).width, 120);
  });

  testWidgets('the text constructor swaps to its child', (tester) async {
    await tester.pumpWidget(
      _textApp(
        const BCSkeleton.text(isLoading: false, child: BCText('loaded')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('loaded'), findsOneWidget);
    expect(_bars(), findsNothing);
  });
}
