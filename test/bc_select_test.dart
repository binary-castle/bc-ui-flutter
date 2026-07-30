import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<BCSelectItem<String>> _fruits([int count = 3]) => [
      for (var i = 0; i < count; i++)
        BCSelectItem(value: 'v$i', label: 'Fruit $i'),
    ];

/// Raises the on-screen keyboard for the rest of the test and returns the
/// y-coordinate of its top edge — nothing the user needs to see may sit below
/// it.
double _showKeyboard(WidgetTester tester, {double height = 300}) {
  final ratio = tester.view.devicePixelRatio;
  tester.view.viewInsets = FakeViewPadding(bottom: height * ratio);
  addTearDown(tester.view.resetViewInsets);
  return tester.view.physicalSize.height / ratio - height;
}

/// Gives the test view the metrics of a notched phone — 402x874 at 3x, with a
/// 59pt status bar — so safe-area behaviour can be asserted the way it lands on
/// a real device rather than on the default 800x600 inset-free surface.
void _useNotchedPhone(WidgetTester tester) {
  const ratio = 3.0;
  const notch = FakeViewPadding(top: 59 * ratio, bottom: 34 * ratio);
  tester.view.devicePixelRatio = ratio;
  tester.view.physicalSize = const Size(402 * ratio, 874 * ratio);
  tester.view.viewPadding = notch;
  tester.view.padding = notch;
  addTearDown(tester.view.reset);
}

/// Hosts a select and keeps its value, the way a real form would.
class _Host extends StatefulWidget {
  const _Host({required this.build});

  final BCSelect<String> Function(String? value, ValueChanged<String> onChange)
      build;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: BCTheme.light(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: widget.build(
              _value,
              (value) => setState(() => _value = value),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('BCSelect', () {
    testWidgets('popover picks a value and closes', (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(),
            value: value,
            onValueChange: onChange,
          ),
        ),
      );

      expect(find.text('Select an option'), findsOneWidget);
      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('Fruit 1'), findsOneWidget);

      await tester.tap(find.text('Fruit 1'));
      await tester.pumpAndSettle();
      // Only the trigger keeps the label once the list is gone.
      expect(find.text('Fruit 1'), findsOneWidget);
      expect(find.text('Fruit 0'), findsNothing);
    });

    testWidgets('the built-in search filters the list', (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: const [
              BCSelectItem(value: 'ap', label: 'Apple'),
              BCSelectItem(value: 'ba', label: 'Banana'),
              BCSelectItem(value: 'ch', label: 'Cherry', description: 'red'),
            ],
            isSearchable: true,
            value: value,
            onValueChange: onChange,
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      expect(find.byType(BCSearchField), findsOneWidget);

      await tester.enterText(find.byType(BCSearchField), 'an');
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);

      // Descriptions are searched too.
      await tester.enterText(find.byType(BCSearchField), 'red');
      await tester.pumpAndSettle();
      expect(find.text('Cherry'), findsOneWidget);

      await tester.enterText(find.byType(BCSearchField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No results'), findsOneWidget);
    });

    testWidgets('onSearch replaces the filter and is debounced',
        (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(),
            value: value,
            onValueChange: onChange,
            searchDebounce: const Duration(milliseconds: 100),
            onSearch: (query) async {
              calls++;
              return [BCSelectItem(value: 'r', label: 'Remote $query')];
            },
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(BCSearchField), 'a');
      await tester.pump(const Duration(milliseconds: 40));
      await tester.enterText(find.byType(BCSearchField), 'ap');
      await tester.pumpAndSettle();

      // Two keystrokes inside the debounce window, one lookup.
      expect(calls, 1);
      expect(find.text('Remote ap'), findsOneWidget);
      expect(find.text('Fruit 0'), findsNothing);
    });

    testWidgets('onLoadMore fires near the end, once per page',
        (tester) async {
      var pages = 0;
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(40),
            value: value,
            onValueChange: onChange,
            onLoadMore: () => pages++,
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      expect(pages, 0);

      await tester.drag(find.text('Fruit 1'), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(pages, 1);

      // Still at the end, so no second request for the same page.
      await tester.drag(find.text('Fruit 39'), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(pages, 1);
    });

    testWidgets('isLoadingMore shows a spinner under the list',
        (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(),
            value: value,
            onValueChange: onChange,
            onLoadMore: () {},
            isLoadingMore: true,
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(BCSpinner), findsOneWidget);
    });

    testWidgets('bottomSheet presentation opens a sheet and commits',
        (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(),
            value: value,
            onValueChange: onChange,
            presentation: BCSelectPresentation.bottomSheet,
            listLabel: 'Pick a fruit',
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('Pick a fruit'), findsOneWidget);

      await tester.tap(find.text('Fruit 2'));
      await tester.pumpAndSettle();
      expect(find.text('Pick a fruit'), findsNothing);
      expect(find.text('Fruit 2'), findsOneWidget);
    });

    testWidgets('wheel presentation commits only on Done', (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(6),
            value: value,
            onValueChange: onChange,
            presentation: BCSelectPresentation.wheel,
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);

      // Dismissing without Done leaves the value alone.
      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();
      expect(find.text('Select an option'), findsOneWidget);

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(ListWheelScrollView),
        const Offset(0, -88),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Select an option'), findsNothing);
      expect(find.text('Fruit 2'), findsOneWidget);
    });

    testWidgets('the trigger keeps the label after an async search swap',
        (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            // The picked item is not in `items` at all, as with a remote
            // lookup whose results are transient.
            items: const [],
            value: value,
            onValueChange: onChange,
            searchDebounce: Duration.zero,
            onSearch: (query) async => [
              const BCSelectItem(value: 'x', label: 'Remote pick'),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(BCSearchField), 'r');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remote pick'));
      await tester.pumpAndSettle();

      expect(find.text('Remote pick'), findsOneWidget);
    });

    testWidgets('rows render leading and trailing slots', (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: const [
              BCSelectItem(
                value: 'a',
                label: 'Ada',
                leading: Icon(Icons.person),
                trailing: Text(r'$12'),
              ),
            ],
            value: value,
            onValueChange: onChange,
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text(r'$12'), findsOneWidget);
      // The prefix sits before the label, the suffix after.
      expect(
        tester.getCenter(find.byIcon(Icons.person)).dx,
        lessThan(tester.getCenter(find.text('Ada')).dx),
      );
      expect(
        tester.getCenter(find.text(r'$12')).dx,
        greaterThan(tester.getCenter(find.text('Ada')).dx),
      );
    });

    testWidgets('item onTap runs alongside the value change', (tester) async {
      var taps = 0;
      String? committed;
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: [
              BCSelectItem(value: 'a', label: 'Ada', onTap: () => taps++),
            ],
            value: value,
            onValueChange: (value) {
              committed = value;
              onChange(value);
            },
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ada'));
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(committed, 'a');
    });

    testWidgets('a disabled row cannot be picked', (tester) async {
      String? committed;
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: const [
              BCSelectItem(value: 'a', label: 'Ada', isDisabled: true),
              BCSelectItem(value: 'b', label: 'Grace'),
            ],
            value: value,
            onValueChange: (value) {
              committed = value;
              onChange(value);
            },
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ada'));
      await tester.pumpAndSettle();
      expect(committed, isNull);

      await tester.tap(find.text('Grace'));
      await tester.pumpAndSettle();
      expect(committed, 'b');
    });

    testWidgets('itemBuilder replaces the row and is told the selection',
        (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(),
            value: value ?? 'v1',
            onValueChange: onChange,
            itemBuilder: (context, item, isSelected) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text('${item.label}${isSelected ? ' ✓' : ''}'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();

      expect(find.text('Fruit 1 ✓'), findsOneWidget);
      expect(find.text('Fruit 0'), findsOneWidget);
      // The default row's check indicator is gone — the builder owns it now.
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(find.text('Fruit 2'));
      await tester.pumpAndSettle();
      expect(find.text('Fruit 2'), findsOneWidget);
    });

    testWidgets('popover keeps the search field and the rows above the '
        'keyboard', (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(20),
            value: value,
            onValueChange: onChange,
            isSearchable: true,
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();

      final keyboardTop = _showKeyboard(tester);
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byType(BCSearchField)).bottom,
        lessThanOrEqualTo(keyboardTop),
      );
      expect(
        tester.getRect(find.byType(ListView)).bottom,
        lessThanOrEqualTo(keyboardTop),
      );
      // Still a usable list, not a sliver of one.
      expect(find.text('Fruit 0'), findsOneWidget);
    });

    testWidgets('the sheet rides above the keyboard', (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(20),
            value: value,
            onValueChange: onChange,
            presentation: BCSelectPresentation.bottomSheet,
            isSearchable: true,
            listLabel: 'Fruits',
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();

      final keyboardTop = _showKeyboard(tester);
      await tester.pumpAndSettle();

      final list = tester.getRect(find.byType(ListView));
      expect(tester.getRect(find.text('Fruits')).top, greaterThan(0));
      expect(
        tester.getRect(find.byType(BCSearchField)).bottom,
        lessThanOrEqualTo(keyboardTop),
      );
      expect(list.bottom, lessThanOrEqualTo(keyboardTop));
      // Enough of the list survives the keyboard to be worth scrolling.
      expect(list.height, greaterThan(100));
      expect(find.text('Fruit 0'), findsOneWidget);
    });

    testWidgets('the sheet keeps its header clear of the status bar',
        (tester) async {
      _useNotchedPhone(tester);
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            // Long enough that the sheet wants more height than the band above
            // the keyboard has, which is when it used to grow up under the
            // notch and take the handle and the title with it.
            items: _fruits(30),
            value: value,
            onValueChange: onChange,
            presentation: BCSelectPresentation.bottomSheet,
            isSearchable: true,
            listLabel: 'Fruits',
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();

      final keyboardTop = _showKeyboard(tester, height: 336);
      await tester.pumpAndSettle();

      // The header survives: title first, then the search field, then the rows.
      final title = tester.getRect(find.text('Fruits'));
      final search = tester.getRect(find.byType(BCSearchField));
      expect(title.top, greaterThanOrEqualTo(59));
      expect(search.top, greaterThan(title.bottom));
      expect(
        tester.getRect(find.byType(ListView)).bottom,
        lessThanOrEqualTo(keyboardTop),
      );
    });

    testWidgets('a sheet whose list is still empty stays on screen',
        (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            // An async lookup starts with nothing to show — the sheet is at
            // its shortest here, and used to open entirely behind the keyboard.
            items: const [],
            value: value,
            onValueChange: onChange,
            presentation: BCSelectPresentation.bottomSheet,
            searchDebounce: Duration.zero,
            onSearch: (query) async => _fruits(2),
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();

      final keyboardTop = _showKeyboard(tester);
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.text('No results')).bottom,
        lessThanOrEqualTo(keyboardTop),
      );

      await tester.enterText(find.byType(BCSearchField), 'f');
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.text('Fruit 1')).bottom,
        lessThanOrEqualTo(keyboardTop),
      );
    });

    testWidgets('disabled does not open', (tester) async {
      await tester.pumpWidget(
        _Host(
          build: (value, onChange) => BCSelect<String>(
            items: _fruits(),
            value: value,
            onValueChange: onChange,
            isDisabled: true,
          ),
        ),
      );

      await tester.tap(find.byType(BCSelect<String>));
      await tester.pumpAndSettle();
      expect(find.text('Fruit 0'), findsNothing);
    });
  });
}
