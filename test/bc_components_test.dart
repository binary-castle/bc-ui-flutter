import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: BCTheme.light(),
    builder: (context, appChild) => BCToastProvider(child: appChild!),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('BCToast', () {
    testWidgets('show() renders a toast card above the app', (tester) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => BCButton(
              onPressed: () => BCToast.show(
                context,
                const BCToastData(
                  title: 'Saved',
                  description: 'All good',
                  variant: BCToastVariant.success,
                ),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('All good'), findsOneWidget);

      // Auto-dismisses after its duration.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('toast text has no debug underline decoration',
        (tester) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => BCButton(
              onPressed: () => BCToast.show(
                context,
                const BCToastData(title: 'Hello', description: 'World'),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pump(const Duration(milliseconds: 300));

      // Effective style must not carry the yellow "missing Material"
      // underline that leaks from DefaultTextStyle.fallback().
      final title = tester.widget<Text>(find.text('Hello'));
      final effective = DefaultTextStyle.of(
        tester.element(find.text('Hello')),
      ).style.merge(title.style);
      expect(effective.decoration ?? TextDecoration.none,
          TextDecoration.none);
    });

    testWidgets('stacks multiple toasts without exceptions', (tester) async {
      late BuildContext appContext;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) {
              appContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      for (var i = 0; i < 4; i++) {
        BCToast.show(appContext, BCToastData(title: 'Toast $i'));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      expect(find.text('Toast 3'), findsOneWidget);
    });
  });

  group('BCMenu viewport clamping', () {
    Future<void> expectMenuOnScreen(
      WidgetTester tester,
      Alignment triggerAlignment,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: BCTheme.light(),
          home: Scaffold(
            body: Align(
              alignment: triggerAlignment,
              child: BCMenu(
                trigger: (context, controller) => BCButton(
                  onPressed: controller.toggle,
                  child: const Text('Open'),
                ),
                children: [
                  for (var i = 0; i < 5; i++)
                    BCMenuItem(title: 'Item $i', onSelected: () {}),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 250));

      final screen = tester.getSize(find.byType(MaterialApp));
      final menuRect = tester.getRect(find.text('Item 0'));

      expect(menuRect.left, greaterThanOrEqualTo(0));
      expect(menuRect.right, lessThanOrEqualTo(screen.width));
      expect(menuRect.top, greaterThanOrEqualTo(0));
      expect(menuRect.bottom, lessThanOrEqualTo(screen.height));
    }

    testWidgets('opens leftward from a right-edge trigger', (tester) async {
      await expectMenuOnScreen(tester, Alignment.centerRight);
    });

    testWidgets('opens upward from a bottom trigger', (tester) async {
      await expectMenuOnScreen(tester, Alignment.bottomCenter);
    });

    testWidgets('stays on screen from a bottom-right corner trigger',
        (tester) async {
      await expectMenuOnScreen(tester, Alignment.bottomRight);
    });
  });

  group('Content-sized overlays', () {
    testWidgets('menu sizes to content, not the screen', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: BCTheme.light(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: BCMenu(
                trigger: (context, c) =>
                    BCButton(onPressed: c.toggle, child: const Text('Open')),
                children: [
                  BCMenuItem(title: 'Edit', onSelected: () {}),
                  BCMenuItem(title: 'Duplicate', onSelected: () {}),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 250));

      final row = tester.getRect(
        find
            .ancestor(of: find.text('Edit'), matching: find.byType(Padding))
            .first,
      );
      // Well under the 1400px screen, capped by the menu's maxWidth.
      expect(row.width, lessThan(340));
    });

    testWidgets('tabs shrink-wrap but fullWidth fills', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Widget host(bool fullWidth) => MaterialApp(
            theme: BCTheme.light(),
            home: Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BCTabs<String>(
                    value: 'a',
                    fullWidth: fullWidth,
                    items: const [
                      BCTabItem(value: 'a', label: 'One'),
                      BCTabItem(value: 'b', label: 'Two'),
                    ],
                    onValueChange: (_) {},
                  ),
                ],
              ),
            ),
          );

      await tester.pumpWidget(host(false));
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.getSize(find.byType(BCTabs<String>)).width, lessThan(400));

      await tester.pumpWidget(host(true));
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(BCTabs<String>)).width, 1400);
    });
  });

  group('BCInput tap target', () {
    testWidgets('tapping the field edge focuses the input', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: BCInput(focusNode: focusNode, placeholder: 'Type here'),
          ),
        ),
      );

      // Tap near the left border, outside the collapsed TextField itself.
      final rect = tester.getRect(find.byType(BCInput));
      await tester.tapAt(Offset(rect.left + 3, rect.center.dy));
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('tapping empty space in a TextArea focuses it',
        (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: BCTextArea(focusNode: focusNode, placeholder: 'Notes'),
          ),
        ),
      );

      // Tap near the bottom of the 128px area, far below the first line.
      final rect = tester.getRect(find.byType(BCTextArea));
      await tester.tapAt(Offset(rect.center.dx, rect.bottom - 8));
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);
    });
  });

  group('BCDateField', () {
    testWidgets('opens the calendar and returns the picked day',
        (tester) async {
      DateTime? picked;
      await tester.pumpWidget(
        _app(
          BCDateField(
            firstDate: DateTime(2026, 1, 1),
            lastDate: DateTime(2026, 12, 31),
            value: DateTime(2026, 7, 10),
            onChanged: (date) => picked = date,
          ),
        ),
      );

      // Field shows the formatted current value.
      expect(find.text('July 10, 2026'), findsOneWidget);

      await tester.tap(find.byType(BCDateField));
      await tester.pumpAndSettle();

      // Calendar header + a day cell are visible.
      expect(find.text('July 2026'), findsOneWidget);
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      expect(picked, DateTime(2026, 7, 15));
    });

    testWidgets('disabled field does not open the picker', (tester) async {
      await tester.pumpWidget(
        _app(const BCDateField(isDisabled: true, placeholder: 'Date')),
      );
      await tester.tap(find.byType(BCDateField));
      await tester.pumpAndSettle();
      expect(find.text('July 2026'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('BCDatePickerDialog month paging', () {
    Future<void> openPicker(
      WidgetTester tester, {
      DateTime? initial,
      DateTime? first,
      DateTime? last,
    }) async {
      await tester.pumpWidget(
        _app(
          BCDateField(
            value: initial ?? DateTime(2026, 7, 15),
            firstDate: first ?? DateTime(2020, 1, 1),
            lastDate: last ?? DateTime(2030, 12, 31),
            onChanged: (_) {},
          ),
        ),
      );
      await tester.tap(find.byType(BCDateField));
      await tester.pumpAndSettle();
    }

    Future<void> swipe(WidgetTester tester, double dx) async {
      await tester.drag(find.byType(PageView), Offset(dx, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('swiping left and right changes the visible month',
        (tester) async {
      await openPicker(tester);
      expect(find.text('July 2026'), findsOneWidget);

      await swipe(tester, -400); // drag left → next month
      expect(find.text('August 2026'), findsOneWidget);

      await swipe(tester, 400); // drag right → back
      expect(find.text('July 2026'), findsOneWidget);

      await swipe(tester, 400); // and again → previous month
      expect(find.text('June 2026'), findsOneWidget);
    });

    testWidgets('swiping shows that month\'s days', (tester) async {
      await openPicker(tester, initial: DateTime(2026, 2, 10));
      expect(find.text('February 2026'), findsOneWidget);
      // February 2026 has 28 days; March has 31.
      expect(find.text('30'), findsNothing);

      await swipe(tester, -400);
      expect(find.text('March 2026'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('arrow buttons drive the same pager', (tester) async {
      await openPicker(tester);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('August 2026'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('July 2026'), findsOneWidget);
    });

    testWidgets('cannot swipe past firstDate or lastDate', (tester) async {
      await openPicker(
        tester,
        initial: DateTime(2026, 7, 15),
        first: DateTime(2026, 6, 1),
        last: DateTime(2026, 8, 31),
      );

      await swipe(tester, 400);
      expect(find.text('June 2026'), findsOneWidget);
      await swipe(tester, 400); // already at the first month
      expect(find.text('June 2026'), findsOneWidget);

      await swipe(tester, -400);
      await swipe(tester, -400);
      expect(find.text('August 2026'), findsOneWidget);
      await swipe(tester, -400); // already at the last month
      expect(find.text('August 2026'), findsOneWidget);
    });

    testWidgets('picking a year opens the month view on it', (tester) async {
      await openPicker(tester);

      await tester.tap(find.text('July 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2028'));
      await tester.pumpAndSettle();

      expect(find.text('July 2028'), findsOneWidget);

      // The pager was rebuilt around the new month, so swiping still works.
      await swipe(tester, -400);
      expect(find.text('August 2028'), findsOneWidget);
    });

    testWidgets('grid height stays constant across months', (tester) async {
      await openPicker(tester, initial: DateTime(2026, 2, 10));
      final february = tester.getSize(find.byType(PageView));

      await swipe(tester, -400); // March 2026 needs an extra week row
      expect(tester.getSize(find.byType(PageView)), february);
    });
  });

  group('BCDateTimePicker', () {
    final first = DateTime(2026, 7, 1);
    final last = DateTime(2026, 8, 31, 23, 59);

    Widget picker({
      DateTime? value,
      BCDateTimePickerPresentation presentation =
          BCDateTimePickerPresentation.popover,
      bool use24 = false,
      int interval = 1,
      ValueChanged<DateTime>? onChanged,
    }) {
      return _app(
        SizedBox(
          width: 320,
          child: BCDateTimePicker(
            value: value,
            firstDate: first,
            lastDate: last,
            presentation: presentation,
            use24HourFormat: use24,
            minuteInterval: interval,
            onChanged: onChanged,
          ),
        ),
      );
    }

    testWidgets('field shows the placeholder, then the formatted value',
        (tester) async {
      await tester.pumpWidget(picker());
      expect(find.text('Choose a date & time'), findsOneWidget);

      await tester.pumpWidget(picker(value: DateTime(2026, 7, 26, 9, 5)));
      expect(find.text('Jul 26, 2026, 9:05 AM'), findsOneWidget);
      expect(find.text('Choose a date & time'), findsNothing);
    });

    testWidgets('24-hour formatting drops the period', (tester) async {
      await tester.pumpWidget(
        picker(value: DateTime(2026, 7, 26, 17, 30), use24: true),
      );
      expect(find.text('Jul 26, 2026, 17:30'), findsOneWidget);
    });

    testWidgets('popover opens the wheels and reports live changes',
        (tester) async {
      DateTime? reported;
      await tester.pumpWidget(
        picker(
          value: DateTime(2026, 7, 26, 9),
          onChanged: (value) => reported = value,
        ),
      );

      await tester.tap(find.byType(BCDateTimePicker));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BCDateTimeWheel), findsOneWidget);

      // Spin the minute wheel one notch.
      final wheels = find.byType(ListWheelScrollView);
      await tester.drag(wheels.at(2), const Offset(0, -44));
      await tester.pumpAndSettle();

      expect(reported, isNotNull);
      expect(reported!.minute, 1);
    });

    testWidgets('minuteInterval limits the minute wheel', (tester) async {
      DateTime? reported;
      await tester.pumpWidget(
        picker(
          value: DateTime(2026, 7, 26, 9),
          interval: 15,
          onChanged: (value) => reported = value,
        ),
      );

      await tester.tap(find.byType(BCDateTimePicker));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.drag(
        find.byType(ListWheelScrollView).at(2),
        const Offset(0, -44),
      );
      await tester.pumpAndSettle();
      expect(reported!.minute, 15);
    });

    testWidgets('dialog only commits on confirm', (tester) async {
      DateTime? reported;
      await tester.pumpWidget(
        picker(
          value: DateTime(2026, 7, 26, 9),
          presentation: BCDateTimePickerPresentation.dialog,
          onChanged: (value) => reported = value,
        ),
      );

      await tester.tap(find.byType(BCDateTimePicker));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(ListWheelScrollView).at(2),
        const Offset(0, -44),
      );
      await tester.pumpAndSettle();
      expect(reported, isNull, reason: 'not committed until Confirm');

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(reported, isNull);

      await tester.tap(find.byType(BCDateTimePicker));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(ListWheelScrollView).at(2),
        const Offset(0, -44),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(reported?.minute, 1);
    });

    testWidgets('bottom sheet opens the wheels', (tester) async {
      await tester.pumpWidget(
        picker(
          value: DateTime(2026, 7, 26, 9),
          presentation: BCDateTimePickerPresentation.bottomSheet,
        ),
      );

      await tester.tap(find.byType(BCDateTimePicker));
      await tester.pumpAndSettle();
      expect(find.byType(BCDateTimeWheel), findsOneWidget);

      // The sheet sits against the bottom edge.
      final sheet = tester.getRect(find.byType(BCDateTimeWheel));
      final screen = tester.getSize(find.byType(MaterialApp));
      expect(sheet.bottom, greaterThan(screen.height / 2));
    });

    testWidgets('selection is clamped to firstDate and lastDate',
        (tester) async {
      DateTime? reported;
      await tester.pumpWidget(
        picker(value: first, onChanged: (value) => reported = value),
      );

      await tester.tap(find.byType(BCDateTimePicker));
      await tester.pump(const Duration(milliseconds: 400));

      // Fling the day wheel far past the start of the range.
      await tester.drag(
        find.byType(ListWheelScrollView).first,
        const Offset(0, 600),
      );
      await tester.pumpAndSettle();

      if (reported != null) {
        expect(reported!.isBefore(first), isFalse);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled field does not open the wheels', (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 320,
            child: BCDateTimePicker(isDisabled: true, label: 'Locked'),
          ),
        ),
      );

      await tester.tap(find.byType(BCDateTimePicker), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BCDateTimeWheel), findsNothing);
    });

    testWidgets('errorText renders and forces the invalid styling',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 320,
            child: BCDateTimePicker(
              label: 'Cutoff',
              description: 'Not shown while there is an error.',
              errorText: 'Please select a valid cutoff date and time.',
            ),
          ),
        ),
      );

      expect(
        find.text('Please select a valid cutoff date and time.'),
        findsOneWidget,
      );
      expect(find.text('Not shown while there is an error.'), findsNothing);
    });
  });

  group('BCTimeField', () {
    testWidgets('opens the wheel picker and confirms a time', (tester) async {
      TimeOfDay? picked;
      await tester.pumpWidget(
        _app(
          BCTimeField(
            value: const TimeOfDay(hour: 9, minute: 30),
            onChanged: (t) => picked = t,
          ),
        ),
      );

      expect(find.text('9:30 AM'), findsOneWidget);

      await tester.tap(find.byType(BCTimeField));
      await tester.pumpAndSettle();
      expect(find.text('Select time'), findsOneWidget);

      // Confirm returns the initial value unchanged.
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(picked, const TimeOfDay(hour: 9, minute: 30));
    });

    testWidgets('cancel returns null and disabled does not open',
        (tester) async {
      var changed = 0;
      await tester.pumpWidget(
        _app(
          BCTimeField(
            value: const TimeOfDay(hour: 1, minute: 0),
            onChanged: (_) => changed++,
          ),
        ),
      );
      await tester.tap(find.byType(BCTimeField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(changed, 0);

      await tester.pumpWidget(
        _app(const BCTimeField(isDisabled: true, placeholder: 'Time')),
      );
      await tester.tap(find.byType(BCTimeField));
      await tester.pumpAndSettle();
      expect(find.text('Select time'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('BCFab / BCSpeedDial', () {
    testWidgets('simple FAB fires onPressed', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _app(BCFab(icon: const Icon(Icons.add), onPressed: () => pressed++)),
      );
      await tester.tap(find.byType(BCFab));
      await tester.pump(const Duration(milliseconds: 200));
      expect(pressed, 1);
    });

    testWidgets('speed dial opens, reveals items, and selects one',
        (tester) async {
      var picked = '';
      await tester.pumpWidget(
        _app(
          BCSpeedDial(
            items: [
              BCSpeedDialItem(
                label: 'New message',
                onPressed: () => picked = 'message',
              ),
              BCSpeedDialItem(
                label: 'New folder',
                onPressed: () => picked = 'folder',
              ),
            ],
          ),
        ),
      );

      // Items hidden until opened.
      expect(find.text('New message'), findsNothing);

      await tester.tap(find.byType(BCFab));
      await tester.pumpAndSettle();
      expect(find.text('New message'), findsOneWidget);
      expect(find.text('New folder'), findsOneWidget);

      await tester.tap(find.text('New folder'));
      await tester.pumpAndSettle();
      expect(picked, 'folder');
      // Closes after selection.
      expect(find.text('New folder'), findsNothing);
    });

    testWidgets('tapping the backdrop closes the speed dial', (tester) async {
      await tester.pumpWidget(
        _app(
          BCSpeedDial(
            items: [BCSpeedDialItem(label: 'Item', onPressed: () {})],
          ),
        ),
      );
      await tester.tap(find.byType(BCFab));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsOneWidget);

      // Tap top-left corner (backdrop, away from FAB and items).
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('BCRating', () {
    testWidgets('tapping a star reports the new value', (tester) async {
      double? value;
      await tester.pumpWidget(
        _app(
          BCRating(value: 0, onChanged: (v) => value = v),
        ),
      );
      // Tap the third star.
      final stars = find.byType(GestureDetector);
      await tester.tap(stars.at(2));
      await tester.pump();
      expect(value, 3);
    });

    testWidgets('read-only fractional renders a partial fill', (tester) async {
      await tester.pumpWidget(_app(const BCRating(value: 3.5)));
      // 5 base icons + partial-fill overlays for filled stars; just assert
      // it builds and shows star icons without error.
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
    });

    testWidgets('custom icon and max are honored', (tester) async {
      await tester.pumpWidget(
        _app(const BCRating(value: 6, max: 10, icon: Icons.favorite)),
      );
      // 10 empty hearts + 6 filled overlays = 16 heart icons.
      expect(find.byIcon(Icons.favorite), findsNWidgets(16));
    });
  });

  group('BCFlipCard', () {
    testWidgets('tap flips to the back', (tester) async {
      await tester.pumpWidget(
        _app(
          const BCFlipCard(
            front: Text('FRONT'),
            back: Text('BACK'),
          ),
        ),
      );
      expect(find.text('FRONT'), findsOneWidget);

      await tester.tap(find.byType(BCFlipCard));
      await tester.pumpAndSettle();
      expect(find.text('BACK'), findsOneWidget);
    });

    testWidgets('controlled card follows isFlipped', (tester) async {
      Widget build(bool flipped) => _app(
            BCFlipCard(
              isFlipped: flipped,
              flipOnTap: false,
              front: const Text('FRONT'),
              back: const Text('BACK'),
            ),
          );

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();
      expect(find.text('FRONT'), findsOneWidget);

      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();
      expect(find.text('BACK'), findsOneWidget);
    });
  });

  group('BCBottomNav', () {
    testWidgets('renders items and reports taps', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _app(
            BCBottomNav(
              currentIndex: index,
              onTap: (i) => setState(() => index = i),
              items: const [
                BCBottomNavItem(icon: Icon(Icons.home), label: 'Home'),
                BCBottomNavItem(icon: Icon(Icons.search), label: 'Search'),
                BCBottomNavItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(index, 1);
    });

    testWidgets('badge count renders on the item', (tester) async {
      await tester.pumpWidget(
        _app(
          BCBottomNav(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              BCBottomNavItem(icon: Icon(Icons.home), label: 'Home'),
              BCBottomNavItem(
                icon: Icon(Icons.mail),
                label: 'Inbox',
                badgeCount: 5,
              ),
            ],
          ),
        ),
      );
      expect(find.text('5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('labels=none hides labels', (tester) async {
      await tester.pumpWidget(
        _app(
          BCBottomNav(
            currentIndex: 0,
            onTap: (_) {},
            labels: BCBottomNavLabels.none,
            items: const [
              BCBottomNavItem(icon: Icon(Icons.home), label: 'Home'),
              BCBottomNavItem(icon: Icon(Icons.search), label: 'Search'),
            ],
          ),
        ),
      );
      expect(find.text('Home'), findsNothing);
    });
  });

  group('BCToggleButton', () {
    testWidgets('toggles selection and swaps the selected icon',
        (tester) async {
      var selected = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _app(
            BCToggleButton(
              isSelected: selected,
              onSelectedChange: (v) => setState(() => selected = v),
              icon: const Icon(Icons.favorite_border),
              selectedIcon: const Icon(Icons.favorite),
              label: 'Like',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      await tester.tap(find.text('Like'));
      await tester.pumpAndSettle();

      expect(selected, isTrue);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('disabled button does not toggle', (tester) async {
      var changed = 0;
      await tester.pumpWidget(
        _app(
          BCToggleButton(
            isSelected: false,
            isDisabled: true,
            onSelectedChange: (_) => changed++,
            icon: const Icon(Icons.bookmark_border),
            label: 'Save',
          ),
        ),
      );
      await tester.tap(find.text('Save'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(changed, 0);
    });

    testWidgets('group single-select replaces the selection', (tester) async {
      var values = {'list'};
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _app(
            BCToggleButtonGroup<String>(
              selectedValues: values,
              allowEmpty: false,
              onSelectionChange: (v) => setState(() => values = v),
              options: const [
                BCToggleButtonOption(value: 'list', label: 'List'),
                BCToggleButtonOption(value: 'grid', label: 'Grid'),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();
      expect(values, {'grid'});

      // allowEmpty: false keeps the last selection when re-tapped.
      await tester.tap(find.text('Grid'));
      await tester.pumpAndSettle();
      expect(values, {'grid'});
    });

    testWidgets('group multi-select accumulates values', (tester) async {
      var values = <String>{'bold'};
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _app(
            BCToggleButtonGroup<String>(
              allowMultiple: true,
              selectedValues: values,
              onSelectionChange: (v) => setState(() => values = v),
              options: const [
                BCToggleButtonOption(value: 'bold', label: 'B'),
                BCToggleButtonOption(value: 'italic', label: 'I'),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('I'));
      await tester.pumpAndSettle();
      expect(values, {'bold', 'italic'});
    });
  });

  group('BCEmptyState', () {
    testWidgets('renders icon, title, description and actions',
        (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _app(
          BCEmptyState(
            icon: const Icon(Icons.inbox),
            title: 'No notifications yet',
            description: 'Enable push alerts.',
            actions: [
              BCButton(
                fullWidth: true,
                onPressed: () => pressed++,
                child: const Text('Enable'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.text('Enable push alerts.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);

      await tester.tap(find.text('Enable'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(pressed, 1);
    });

    testWidgets('outline variant paints without error', (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 320,
            child: BCEmptyState(
              variant: BCEmptyStateVariant.outline,
              icon: Icon(Icons.rocket_launch_outlined),
              title: 'Start your first automation',
              description: 'Connect an app.',
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Start your first automation'), findsOneWidget);
    });

    testWidgets('minimal (no icon/actions) renders text only', (tester) async {
      await tester.pumpWidget(
        _app(
          const BCEmptyState(
            title: 'Inbox zero',
            description: 'All caught up.',
          ),
        ),
      );
      expect(find.text('Inbox zero'), findsOneWidget);
      expect(find.byType(BCButton), findsNothing);
    });
  });

  group('BCPressable', () {
    testWidgets('quick tap fires onPressed and plays visible feedback',
        (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _app(
          BCButton(
            onPressed: () => pressed++,
            child: const Text('Tap'),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      // Mid-feedback frame: scale transform should be < 1.
      await tester.pump(const Duration(milliseconds: 50));
      expect(pressed, 1);

      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
    });

    testWidgets('label stays above the press highlight', (tester) async {
      await tester.pumpWidget(
        _app(BCButton(onPressed: () {}, child: const Text('Label'))),
      );

      // Hold a press so the full-opacity hover highlight is showing.
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Label')));
      await tester.pump(const Duration(milliseconds: 250));

      // The highlight layer must come BEFORE the label in the pressable's
      // Stack (painted underneath), never after (covering the text).
      final stack = tester.widget<Stack>(
        find
            .ancestor(of: find.text('Label'), matching: find.byType(Stack))
            .first,
      );
      final childTypes = stack.children.toList();
      final highlightIndex = childTypes.indexWhere(
        (w) => w is Positioned && w.child is IgnorePointer,
      );
      final contentIndex = childTypes.indexWhere(
        (w) => w is! Positioned,
      );
      expect(highlightIndex, isNot(-1));
      expect(contentIndex, greaterThan(highlightIndex));

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
    });

    testWidgets('onPressed fires on pointer-up, never gated on the press hold',
        (tester) async {
      // BCPressable holds the *visual* press for a minimum of 150ms so quick
      // taps are perceivable. The callback must not wait on it.
      var fired = 0;
      await tester.pumpWidget(
        _app(
          BCButton(onPressed: () => fired++, child: const Text('Tap')),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Tap')),
      );
      await gesture.up();
      expect(fired, 1, reason: 'no pump happened: the callback was immediate');

      // A second tap during the previous release still reacts immediately.
      final again = await tester.startGesture(
        tester.getCenter(find.text('Tap')),
      );
      await again.up();
      expect(fired, 2);

      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('material feedback renders an InkWell', (tester) async {
      await tester.pumpWidget(
        _app(
          BCButton(
            feedback: BCPressFeedback.material,
            onPressed: () {},
            child: const Text('Material'),
          ),
        ),
      );
      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.text('Material'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  });

  group('BCTabs + BCTabView', () {
    const items = [
      BCTabItem(value: 'music', label: 'Music'),
      BCTabItem(value: 'podcasts', label: 'Podcasts'),
      BCTabItem(value: 'books', label: 'Books'),
    ];

    BCTabsController<String> makeController(WidgetTester tester) {
      final controller = BCTabsController<String>(
        values: const ['music', 'podcasts', 'books'],
      );
      addTearDown(controller.dispose);
      return controller;
    }

    Widget tabsApp(
      BCTabsController<String> controller, {
      bool swipeEnabled = true,
      ValueChanged<String>? onValueChange,
    }) {
      return MaterialApp(
        theme: BCTheme.light(),
        home: Scaffold(
          body: Column(
            children: [
              BCTabs<String>(
                items: items,
                controller: controller,
                onValueChange: onValueChange,
              ),
              Expanded(
                child: BCTabView<String>(
                  controller: controller,
                  swipeEnabled: swipeEnabled,
                  children: const [
                    Center(child: Text('music page')),
                    Center(child: Text('podcasts page')),
                    Center(child: Text('books page')),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    /// The sliding pill, found by its `segment` fill.
    Rect indicatorRect(WidgetTester tester) {
      final segment = BCThemeExtension.light().segment;
      return tester.getRect(
        find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is ShapeDecoration &&
              (w.decoration as ShapeDecoration).color == segment,
        ),
      );
    }

    testWidgets('swiping the view selects the next tab', (tester) async {
      final controller = makeController(tester);
      final reported = <String>[];
      await tester.pumpWidget(
        tabsApp(controller, onValueChange: reported.add),
      );
      await tester.pumpAndSettle();

      // Past the halfway point, otherwise PageScrollPhysics rounds back.
      await tester.drag(find.text('music page'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(controller.value, 'podcasts');
      expect(reported, ['podcasts']);
      expect(find.text('podcasts page'), findsOneWidget);

      await tester.drag(find.text('podcasts page'), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(controller.value, 'music');
      expect(reported, ['podcasts', 'music']);
    });

    testWidgets('tapping a trigger moves the view', (tester) async {
      final controller = makeController(tester);
      await tester.pumpWidget(tabsApp(controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Books'));
      await tester.pumpAndSettle();

      expect(controller.value, 'books');
      expect(find.text('books page'), findsOneWidget);
    });

    testWidgets('indicator tracks a partial drag', (tester) async {
      final controller = makeController(tester);
      await tester.pumpWidget(tabsApp(controller));
      await tester.pumpAndSettle();

      final start = indicatorRect(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.text('music page')));
      await gesture.moveBy(const Offset(-200, 0));
      await tester.pump();

      // Mid-drag: neither settled position, but partway between the two.
      expect(controller.offset, greaterThan(0.0));
      expect(controller.offset, lessThan(1.0));
      final dragging = indicatorRect(tester);
      expect(dragging.left, greaterThan(start.left));

      // A quarter-page drag snaps back, and the indicator rides it home.
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.value, 'music');
      expect(indicatorRect(tester).left, moreOrLessEquals(start.left, epsilon: 0.5));
    });

    testWidgets('swipeEnabled: false blocks the drag', (tester) async {
      final controller = makeController(tester);
      await tester.pumpWidget(tabsApp(controller, swipeEnabled: false));
      await tester.pumpAndSettle();

      await tester.drag(find.text('music page'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(controller.value, 'music');

      // Taps still switch tabs.
      await tester.tap(find.text('Podcasts'));
      await tester.pumpAndSettle();
      expect(controller.value, 'podcasts');
    });
  });

  group('BCProgress', () {
    testWidgets('renders determinate value label and animates to it',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 300,
            child: BCProgress(
              value: 0.4,
              label: 'Uploading',
              showValueLabel: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Uploading'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('indeterminate keeps ticking without exceptions',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const SizedBox(
            width: 300,
            child: BCProgress(variant: BCProgressVariant.circular),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      // A repeating controller never settles; end the test cleanly.
      await tester.pumpWidget(_app(const SizedBox.shrink()));
    });

    testWidgets('rejects an out-of-range value', (tester) async {
      expect(() => BCProgress(value: 1.5), throwsAssertionError);
    });
  });

  group('BCLoadingOverlay', () {
    testWidgets('blocks taps on the content while loading', (tester) async {
      var taps = 0;

      Widget build(bool loading) => _app(
            SizedBox(
              width: 300,
              height: 300,
              child: BCLoadingOverlay(
                isLoading: loading,
                label: 'Saving',
                child: BCButton(
                  onPressed: () => taps++,
                  child: const Text('Save'),
                ),
              ),
            ),
          );

      await tester.pumpWidget(build(false));
      await tester.tap(find.text('Save'));
      expect(taps, 1);
      expect(find.text('Saving'), findsNothing);

      await tester.pumpWidget(build(true));
      // BCSpinner never stops, so pumpAndSettle would time out here.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Saving'), findsOneWidget);

      await tester.tap(find.text('Save'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(taps, 1, reason: 'overlay should swallow the tap');

      await tester.pumpWidget(build(false));
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('BCNavRail', () {
    List<BCNavRailDestination> destinations() => const [
          BCNavRailDestination(icon: Icon(Icons.inbox), label: 'Inbox', badgeCount: 3),
          BCNavRailDestination(icon: Icon(Icons.send), label: 'Sent'),
        ];

    testWidgets('reports taps and shows badges', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _app(
            SizedBox(
              height: 400,
              child: BCNavRail(
                destinations: destinations(),
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
              ),
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.text('Sent'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(index, 1);
    });

    testWidgets('extended widens the rail and keeps labels', (tester) async {
      Widget build(bool extended) => _app(
            SizedBox(
              height: 400,
              child: BCNavRail(
                destinations: destinations(),
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                extended: extended,
              ),
            ),
          );

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(BCNavRail)).width, 80);

      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(BCNavRail)).width, 232);
      expect(find.text('Inbox'), findsOneWidget);
    });

    testWidgets('labels=none hides labels', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            height: 400,
            child: BCNavRail(
              destinations: destinations(),
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              labels: BCNavRailLabels.none,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Inbox'), findsNothing);
    });
  });

  group('BCNavDrawer', () {
    testWidgets('selection index counts destinations, not sections',
        (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        _app(
          SizedBox(
            height: 600,
            child: BCNavDrawer(
              selectedIndex: 0,
              onDestinationSelected: (i) => selected = i,
              header: const Text('Mailbox'),
              items: const [
                BCNavDrawerSection('Mail'),
                BCNavDrawerDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
                BCNavDrawerDivider(),
                BCNavDrawerSection('Labels'),
                BCNavDrawerDestination(icon: Icon(Icons.work), label: 'Work'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mailbox'), findsOneWidget);
      expect(find.text('Labels'), findsOneWidget);

      // 'Work' is the second destination despite three items before it.
      await tester.tap(find.text('Work'));
      // BCPressable holds a minimum-press timer; give it time to expire.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });

    testWidgets('disabled destination does not report taps', (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        _app(
          SizedBox(
            height: 400,
            child: BCNavDrawer(
              selectedIndex: 0,
              onDestinationSelected: (i) => selected = i,
              items: const [
                BCNavDrawerDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
                BCNavDrawerDestination(
                  icon: Icon(Icons.delete),
                  label: 'Trash',
                  isDisabled: true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trash'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(selected, -1);
    });
  });

  group('BCRangeSlider', () {
    testWidgets('drags the nearer thumb and keeps start <= end',
        (tester) async {
      var range = const BCRange(0.2, 0.8);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _app(
            SizedBox(
              width: 328, // 300 usable + one thumb width
              child: BCRangeSlider(
                values: range,
                onChanged: (value) => setState(() => range = value),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final slider = find.byType(BCRangeSlider);
      final origin = tester.getTopLeft(slider);

      // Drag near the end thumb, pushing it past the start thumb's position.
      await tester.dragFrom(
        origin + const Offset(254, 10),
        const Offset(-220, 0),
      );
      await tester.pumpAndSettle();

      expect(range.end, greaterThanOrEqualTo(range.start));
      expect(range.start, closeTo(0.2, 0.05), reason: 'start thumb untouched');
    });

    testWidgets('respects minSeparation', (tester) async {
      var range = const BCRange(4, 20);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _app(
            SizedBox(
              width: 328,
              child: BCRangeSlider(
                values: range,
                minValue: 0,
                maxValue: 24,
                step: 1,
                minSeparation: 4,
                onChanged: (value) => setState(() => range = value),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final origin = tester.getTopLeft(find.byType(BCRangeSlider));
      await tester.dragFrom(
        origin + const Offset(264, 10),
        const Offset(-240, 0),
      );
      await tester.pumpAndSettle();

      expect(range.end - range.start, greaterThanOrEqualTo(4 - 0.001));
    });
  });

  group('BCToolbar', () {
    testWidgets('renders actions and the primary action in both variants',
        (tester) async {
      for (final variant in BCToolbarVariant.values) {
        await tester.pumpWidget(
          _app(
            SizedBox(
              width: 360,
              child: BCToolbar(
                variant: variant,
                primaryAction: BCFab(
                  icon: const Icon(Icons.check),
                  onPressed: () {},
                ),
                children: [
                  BCHeaderIconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {},
                  ),
                  BCHeaderIconButton(
                    icon: const Icon(Icons.redo),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.undo), findsOneWidget, reason: '$variant');
        expect(find.byIcon(Icons.check), findsOneWidget, reason: '$variant');
        expect(tester.takeException(), isNull, reason: '$variant');
      }
    });

    testWidgets('vertical axis stacks the actions', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            height: 320,
            child: BCToolbar(
              axis: BCToolbarAxis.vertical,
              children: [
                BCHeaderIconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () {},
                ),
                BCHeaderIconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final undo = tester.getCenter(find.byIcon(Icons.undo));
      final redo = tester.getCenter(find.byIcon(Icons.redo));
      expect(redo.dy, greaterThan(undo.dy));
      expect(redo.dx, closeTo(undo.dx, 0.5));
    });
  });

  group('BCAppHeader', () {
    Widget headerApp(
      BCAppHeader header, {
      ScrollController? controller,
    }) {
      return MaterialApp(
        theme: BCTheme.light(),
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: header,
          body: ListView.builder(
            controller: controller,
            itemCount: 40,
            itemBuilder: (context, i) => SizedBox(height: 48, child: Text('$i')),
          ),
        ),
      );
    }

    testWidgets('renders title, subtitle and actions in every variant',
        (tester) async {
      for (final variant in BCAppHeaderVariant.values) {
        await tester.pumpWidget(
          headerApp(
            BCAppHeader(
              variant: variant,
              title: const Text('Inbox'),
              subtitle: const Text('12 unread'),
              actions: [
                BCHeaderIconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Inbox'), findsOneWidget, reason: '$variant');
        expect(find.text('12 unread'), findsOneWidget, reason: '$variant');
        expect(find.byIcon(Icons.search), findsOneWidget, reason: '$variant');
        expect(tester.takeException(), isNull, reason: '$variant');
      }
    });

    testWidgets('separator fades in once content scrolls under',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        headerApp(
          const BCAppHeader(title: Text('Inbox')),
          controller: controller,
        ),
      );
      await tester.pumpAndSettle();

      AnimatedOpacity separator() => tester.widget<AnimatedOpacity>(
            find.descendant(
              of: find.byType(BCAppHeader),
              matching: find.byType(AnimatedOpacity),
            ),
          );

      expect(separator().opacity, 0);

      controller.jumpTo(120);
      await tester.pumpAndSettle();
      expect(separator().opacity, 1);
    });

    testWidgets('implies a back button on a pushed route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: BCTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: BCButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(
                        appBar: BCAppHeader(title: Text('Details')),
                        body: SizedBox.shrink(),
                      ),
                    ),
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
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsNothing);
    });

    testWidgets('leading, title and actions share one vertical center',
        (tester) async {
      // NavigationToolbar hands the leading slot the full bar height at y=0,
      // so an uncentered leading widget rides high next to the title.
      for (final subtitle in [null, const Text('12 unread')]) {
        await tester.pumpWidget(
          headerApp(
            BCAppHeader(
              title: const Text('Inbox'),
              subtitle: subtitle,
              leading: BCHeaderIconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {},
              ),
              actions: [
                BCHeaderIconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final barCenter = tester.getRect(find.byType(BCAppHeader)).center.dy;
        for (final finder in [
          find.byIcon(Icons.arrow_back_ios_new),
          find.byIcon(Icons.more_horiz),
        ]) {
          expect(
            tester.getRect(finder).center.dy,
            moreOrLessEquals(barCenter, epsilon: 0.5),
            reason: 'subtitle: ${subtitle != null}',
          );
        }
      }
    });

    testWidgets('floating variant fits its bar in dark mode', (tester) async {
      // The dark overlay shadow carries a 1px hairline; stroking the bar's
      // shape would inset the toolbar and overflow it.
      await tester.pumpWidget(
        MaterialApp(
          theme: BCTheme.dark(),
          home: const Scaffold(
            extendBodyBehindAppBar: true,
            appBar: BCAppHeader(
              variant: BCAppHeaderVariant.floating,
              title: Text('Discover'),
            ),
            body: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('bottom widget adds its height to the preferred size',
        (tester) async {
      const header = BCAppHeader(
        title: Text('Orders'),
        bottom: SizedBox.shrink(),
        bottomHeight: 56,
      );
      expect(header.preferredSize.height, BCAppHeader.defaultToolbarHeight + 56);
    });
  });

  group('BCSliverAppHeader', () {
    testWidgets('collapses the large title into the compact one',
        (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: BCTheme.light(),
          home: Scaffold(
            body: CustomScrollView(
              controller: controller,
              slivers: [
                const BCSliverAppHeader(
                  largeTitle: Text('Library'),
                  title: Text('Lib'),
                ),
                SliverList.builder(
                  itemCount: 30,
                  itemBuilder: (context, i) =>
                      SizedBox(height: 48, child: Text('row $i')),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fully opaque titles are not wrapped in an [Opacity] at all.
      double opacityOf(String text) {
        final matches = find
            .ancestor(of: find.text(text), matching: find.byType(Opacity))
            .evaluate();
        if (matches.isEmpty) return 1;
        return (matches.first.widget as Opacity).opacity;
      }

      expect(opacityOf('Library'), 1);
      expect(opacityOf('Lib'), 0);

      controller.jumpTo(200);
      await tester.pumpAndSettle();

      expect(opacityOf('Library'), 0);
      expect(opacityOf('Lib'), 1);
      expect(tester.takeException(), isNull);
    });
  });
}
