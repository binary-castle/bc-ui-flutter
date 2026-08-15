import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A modal with more fields than fit above a keyboard.
Widget _formDialog() {
  return BCDialogContent(
    width: double.infinity,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        const BCDialogTitle('Edit profile'),
        for (var i = 1; i <= 6; i++)
          BCTextField(
            children: [
              BCTextFieldLabel('Field $i'),
              BCTextFieldInput(hintText: 'Value $i'),
            ],
          ),
      ],
    ),
  );
}

Future<void> _open(
  WidgetTester tester, {
  required WidgetBuilder builder,
  bool isSwipeable = true,
  double keyboardInset = 0,
}) async {
  if (keyboardInset > 0) {
    // The route lives in the app's Overlay, above anything the test could
    // wrap `home` in — the keyboard has to come off the view itself.
    addTearDown(tester.view.reset);
    tester.view.viewInsets = FakeViewPadding(
      bottom: keyboardInset * tester.view.devicePixelRatio,
    );
  }

  await tester.pumpWidget(
    MaterialApp(
      theme: BCTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => BCDialog.show<void>(
                context,
                builder: builder,
                isSwipeable: isSwipeable,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

/// Logical height of the test view.
double _screen(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

/// Vertical span the dialog surface occupies right now.
Rect _surface(WidgetTester tester) =>
    tester.getRect(find.byType(BCDialogContent));

void main() {
  testWidgets('short dialog is centered and does not scroll', (tester) async {
    await _open(
      tester,
      builder: (_) => const BCDialogContent(
        width: double.infinity,
        child: BCDialogTitle('Delete file?'),
      ),
    );

    final scrollable = tester.widget<SingleChildScrollView>(
      find.ancestor(
        of: find.byType(BCDialogContent),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(scrollable.physics, isA<NeverScrollableScrollPhysics>());
    expect(_surface(tester).center.dy, closeTo(_screen(tester) / 2, 1));
  });

  testWidgets('a tap beside the dialog still reaches the barrier', (
    tester,
  ) async {
    await _open(
      tester,
      builder: (_) => const BCDialogContent(
        width: double.infinity,
        child: BCDialogTitle('Delete file?'),
      ),
    );

    // Above the dialog: inside the full-screen scroller, outside the surface.
    await tester.tapAt(Offset(4, _surface(tester).top - 40));
    await tester.pumpAndSettle();
    expect(find.byType(BCDialogContent), findsNothing);
  });

  testWidgets('keyboard lifts the dialog clear of the inset', (tester) async {
    await _open(
      tester,
      builder: (_) => const BCDialogContent(
        width: double.infinity,
        child: BCDialogTitle('Delete file?'),
      ),
      keyboardInset: 300,
    );

    final screen = _screen(tester);
    // Centered in what is left above the keyboard, and fully above it.
    expect(_surface(tester).center.dy, closeTo((screen - 300) / 2, 1));
    expect(_surface(tester).bottom, lessThan(screen - 300));
  });

  testWidgets('a form taller than the room scrolls to reach its last field', (
    tester,
  ) async {
    await _open(tester, builder: (_) => _formDialog(), keyboardInset: 300);

    final scrollable = find.ancestor(
      of: find.byType(BCDialogContent),
      matching: find.byType(SingleChildScrollView),
    );
    // Overflowing content hands the drags back to the scroller.
    expect(
      tester.widget<SingleChildScrollView>(scrollable).physics,
      isA<ClampingScrollPhysics>(),
    );

    final screen = _screen(tester);
    final last = find.text('Field 6').first;
    expect(tester.getRect(last).top, greaterThan(screen - 300));

    // A point inside the dialog, in the band the keyboard leaves.
    await tester.dragFrom(const Offset(400, 100), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.byType(BCDialogContent), findsOneWidget);
    expect(tester.getRect(last).bottom, lessThanOrEqualTo(screen - 300));
  });

  testWidgets('a swipe over scrollable content scrolls instead of dismissing', (
    tester,
  ) async {
    await _open(tester, builder: (_) => _formDialog(), keyboardInset: 300);

    final first = find.text('Field 1').first;
    await tester.dragFrom(const Offset(400, 100), const Offset(0, -1000));
    await tester.pumpAndSettle();
    final bottomed = tester.getRect(first).top;

    // Downwards over scrollable content: back up the list, not off the screen.
    // Had the swipe taken the drag instead, the dialog would have sprung back
    // to exactly where it started once the finger left.
    await tester.dragFrom(const Offset(400, 100), const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(find.byType(BCDialogContent), findsOneWidget);
    expect(tester.getRect(first).top, greaterThan(bottomed + 60));
  });

  testWidgets('focusing a covered field scrolls it into view', (tester) async {
    await _open(tester, builder: (_) => _formDialog(), keyboardInset: 300);

    final screen = _screen(tester);
    final field = find.byType(EditableText).last;
    // Starts out under the keyboard — it can't even be tapped there, which is
    // the bug: reaching it has to come from the focus, or from a scroll.
    expect(tester.getRect(field).top, greaterThan(screen - 300));

    tester.widget<EditableText>(field).focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(tester.getRect(field).bottom, lessThanOrEqualTo(screen - 300));
  });

  testWidgets('a downward swipe carries the dialog and dismisses it', (
    tester,
  ) async {
    await _open(
      tester,
      builder: (_) => const BCDialogContent(
        width: double.infinity,
        child: BCDialogTitle('Delete file?'),
      ),
    );

    final start = _surface(tester).top;
    final gesture = await tester.startGesture(_surface(tester).center);
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump();

    // Tracks the finger 1:1 while it is held — not a gesture that merely
    // triggers the close animation.
    expect(_surface(tester).top, closeTo(start + 40, 1));
    expect(find.byType(BCDialogContent), findsOneWidget);

    await gesture.moveBy(const Offset(0, 80));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(BCDialogContent), findsNothing);
  });

  testWidgets('an abandoned swipe springs back', (tester) async {
    await _open(
      tester,
      builder: (_) => const BCDialogContent(
        width: double.infinity,
        child: BCDialogTitle('Delete file?'),
      ),
    );

    final start = _surface(tester).top;
    final gesture = await tester.startGesture(_surface(tester).center);
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(BCDialogContent), findsOneWidget);
    expect(_surface(tester).top, closeTo(start, 1));
  });

  testWidgets('an upward swipe is rubber-banded and never dismisses', (
    tester,
  ) async {
    await _open(
      tester,
      builder: (_) => const BCDialogContent(
        width: double.infinity,
        child: BCDialogTitle('Delete file?'),
      ),
    );

    final start = _surface(tester).top;
    final gesture = await tester.startGesture(_surface(tester).center);
    await gesture.moveBy(const Offset(0, -400));
    await tester.pump();

    final lift = start - _surface(tester).top;
    expect(lift, greaterThan(0));
    expect(lift, lessThanOrEqualTo(40));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(BCDialogContent), findsOneWidget);
  });

  testWidgets('isSwipeable false keeps the dialog put', (tester) async {
    await _open(
      tester,
      isSwipeable: false,
      builder: (_) => const BCDialogContent(
        width: double.infinity,
        child: BCDialogTitle('Delete file?'),
      ),
    );

    final start = _surface(tester).top;
    await tester.drag(find.byType(BCDialogContent), const Offset(0, 200));
    await tester.pumpAndSettle();

    expect(find.byType(BCDialogContent), findsOneWidget);
    expect(_surface(tester).top, closeTo(start, 1));
  });
}
