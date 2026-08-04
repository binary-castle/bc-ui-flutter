import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    theme: BCTheme.light(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: 300, child: child),
          ),
        ),
      ),
    ),
  );
}

/// Items `1..count`, each a `Q<n>` trigger over an `A<n>` body.
List<Widget> _items({int count = 3, Set<String> disabled = const {}}) {
  return [
    for (var i = 1; i <= count; i++)
      BCAccordionItem(
        value: '$i',
        isDisabled: disabled.contains('$i'),
        children: [
          BCAccordionTrigger(child: Text('Q$i')),
          BCAccordionContent(child: Text('A$i')),
        ],
      ),
  ];
}

/// Holds the expanded set the way a caller would, so `value` +
/// `onValueChange` can be exercised end to end.
class _Controlled extends StatefulWidget {
  const _Controlled({
    this.selectionMode = BCAccordionSelectionMode.single,
    this.variant = BCAccordionVariant.defaultVariant,
    this.isCollapsible = true,
    this.isDisabled = false,
    this.hideSeparator = false,
    this.itemCount = 3,
    this.disabledItems = const <String>{},
    this.onValueChange,
  });

  final BCAccordionSelectionMode selectionMode;
  final BCAccordionVariant variant;
  final bool isCollapsible;
  final bool isDisabled;
  final bool hideSeparator;
  final int itemCount;
  final Set<String> disabledItems;
  final ValueChanged<Set<String>>? onValueChange;

  @override
  State<_Controlled> createState() => _ControlledState();
}

class _ControlledState extends State<_Controlled> {
  Set<String> _value = const <String>{};

  @override
  Widget build(BuildContext context) {
    return BCAccordion(
      value: _value,
      onValueChange: (next) {
        widget.onValueChange?.call(next);
        setState(() => _value = next);
      },
      selectionMode: widget.selectionMode,
      variant: widget.variant,
      isCollapsible: widget.isCollapsible,
      isDisabled: widget.isDisabled,
      hideSeparator: widget.hideSeparator,
      children: _items(count: widget.itemCount, disabled: widget.disabledItems),
    );
  }
}

/// Taps a trigger, then lets BCPressable's minimum-press timer expire and the
/// expand/collapse spring settle.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

/// The chevrons, scoped to the accordion — MaterialApp's page transition
/// carries a [RotationTransition] of its own.
final Finder _chevrons = find.descendant(
  of: find.byType(BCAccordion),
  matching: find.byType(RotationTransition),
);

/// The chevron's rotation driver for the item at [index].
double _turns(WidgetTester tester, int index) {
  return tester.widget<RotationTransition>(_chevrons.at(index)).turns.value;
}

void main() {
  group('BCAccordion', () {
    testWidgets('renders every trigger and no content until expanded',
        (tester) async {
      await tester.pumpWidget(_app(const _Controlled()));
      await tester.pump();

      for (var i = 1; i <= 3; i++) {
        expect(find.text('Q$i'), findsOneWidget);
        expect(find.text('A$i'), findsNothing, reason: 'A$i started expanded');
      }
    });

    testWidgets('single selection expands one item and collapses the previous',
        (tester) async {
      await tester.pumpWidget(_app(const _Controlled()));
      await _tap(tester, find.text('Q1'));
      expect(find.text('A1'), findsOneWidget);

      await _tap(tester, find.text('Q2'));
      expect(find.text('A2'), findsOneWidget);
      expect(find.text('A1'), findsNothing);
    });

    testWidgets('tapping the open item collapses it', (tester) async {
      await tester.pumpWidget(_app(const _Controlled()));
      await _tap(tester, find.text('Q1'));
      expect(find.text('A1'), findsOneWidget);

      await _tap(tester, find.text('Q1'));
      expect(find.text('A1'), findsNothing);
    });

    testWidgets('isCollapsible false keeps the open item open', (tester) async {
      await tester.pumpWidget(_app(const _Controlled(isCollapsible: false)));
      await _tap(tester, find.text('Q1'));
      await _tap(tester, find.text('Q1'));
      expect(find.text('A1'), findsOneWidget);
    });

    testWidgets('multiple selection expands items independently',
        (tester) async {
      await tester.pumpWidget(
        _app(const _Controlled(selectionMode: BCAccordionSelectionMode.multiple)),
      );
      await _tap(tester, find.text('Q1'));
      await _tap(tester, find.text('Q2'));

      expect(find.text('A1'), findsOneWidget);
      expect(find.text('A2'), findsOneWidget);

      await _tap(tester, find.text('Q1'));
      expect(find.text('A1'), findsNothing);
      expect(find.text('A2'), findsOneWidget);
    });

    testWidgets('multiple selection with isCollapsible false never collapses',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const _Controlled(
            selectionMode: BCAccordionSelectionMode.multiple,
            isCollapsible: false,
          ),
        ),
      );
      await _tap(tester, find.text('Q1'));
      await _tap(tester, find.text('Q1'));
      expect(find.text('A1'), findsOneWidget);
    });

    testWidgets('onValueChange reports the next expanded set', (tester) async {
      final changes = <Set<String>>[];
      await tester.pumpWidget(
        _app(_Controlled(onValueChange: changes.add)),
      );

      await _tap(tester, find.text('Q1'));
      await _tap(tester, find.text('Q2'));
      await _tap(tester, find.text('Q2'));

      expect(changes, [
        {'1'},
        {'2'},
        <String>{},
      ]);
    });

    testWidgets('a controller drives the accordion and records taps',
        (tester) async {
      final controller = BCAccordionController(initialValue: const {'2'});
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _app(BCAccordion(controller: controller, children: _items())),
      );
      await tester.pump();
      expect(find.text('A2'), findsOneWidget);

      await _tap(tester, find.text('Q1'));
      expect(controller.value, {'1'});
      expect(find.text('A1'), findsOneWidget);
      expect(find.text('A2'), findsNothing);

      controller.collapseAll();
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);

      controller.expand('3');
      await tester.pumpAndSettle();
      expect(controller.isExpanded('3'), isTrue);
      expect(find.text('A3'), findsOneWidget);
    });

    testWidgets('the controller rejects in-place mutation of its value',
        (tester) async {
      final controller = BCAccordionController(initialValue: const {'1'});
      addTearDown(controller.dispose);
      expect(() => controller.value.add('2'), throwsUnsupportedError);
    });

    testWidgets('the indicator rotates -0.5 turns when expanded',
        (tester) async {
      await tester.pumpWidget(_app(const _Controlled()));
      await tester.pump();
      expect(_turns(tester, 0), closeTo(0, 0.001));

      await _tap(tester, find.text('Q1'));
      // Counter-clockwise: heroui animates [0, -180] degrees.
      expect(_turns(tester, 0), closeTo(-0.5, 0.001));
      expect(_turns(tester, 1), closeTo(0, 0.001));

      await _tap(tester, find.text('Q1'));
      expect(_turns(tester, 0), closeTo(0, 0.001));
    });

    testWidgets('a custom indicator is not rotated', (tester) async {
      await tester.pumpWidget(
        _app(
          BCAccordion(
            value: const {'1'},
            onValueChange: (_) {},
            children: const [
              BCAccordionItem(
                value: '1',
                children: [
                  BCAccordionTrigger(
                    indicator: BCAccordionIndicator(child: Text('+')),
                    child: Text('Q1'),
                  ),
                  BCAccordionContent(child: Text('A1')),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+'), findsOneWidget);
      expect(_chevrons, findsNothing);
    });

    testWidgets('content stays mounted while collapsing, then unmounts',
        (tester) async {
      await tester.pumpWidget(_app(const _Controlled()));
      await _tap(tester, find.text('Q1'));
      expect(find.text('A1'), findsOneWidget);

      await tester.tap(find.text('Q1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        find.text('A1'),
        findsOneWidget,
        reason: 'the body was dropped before the collapse could animate',
      );

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);
    });

    testWidgets('separators sit between items, never after the last',
        (tester) async {
      await tester.pumpWidget(_app(const _Controlled()));
      await tester.pump();
      expect(find.byType(BCSeparator), findsNWidgets(2));

      await tester.pumpWidget(_app(const _Controlled(hideSeparator: true)));
      await tester.pump();
      expect(find.byType(BCSeparator), findsNothing);
    });

    testWidgets('only the surface variant wraps the stack in a BCSurface',
        (tester) async {
      await tester.pumpWidget(_app(const _Controlled()));
      await tester.pump();
      expect(find.byType(BCSurface), findsNothing);

      await tester.pumpWidget(
        _app(const _Controlled(variant: BCAccordionVariant.surface)),
      );
      await tester.pump();
      expect(find.byType(BCSurface), findsOneWidget);
    });

    testWidgets('a disabled root ignores taps', (tester) async {
      final changes = <Set<String>>[];
      await tester.pumpWidget(
        _app(_Controlled(isDisabled: true, onValueChange: changes.add)),
      );

      await tester.tap(find.text('Q1'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
      expect(find.text('A1'), findsNothing);
    });

    testWidgets('a disabled item ignores taps while its siblings do not',
        (tester) async {
      final changes = <Set<String>>[];
      await tester.pumpWidget(
        _app(
          _Controlled(disabledItems: const {'1'}, onValueChange: changes.add),
        ),
      );

      await tester.tap(find.text('Q1'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(find.text('A1'), findsNothing);

      await _tap(tester, find.text('Q2'));
      expect(changes, [
        {'2'},
      ]);
      expect(find.text('A2'), findsOneWidget);
    });

    testWidgets('the item builder receives the expanded state', (tester) async {
      await tester.pumpWidget(
        _app(
          BCAccordion(
            value: const <String>{},
            onValueChange: (_) {},
            children: [
              BCAccordionItem(
                value: '1',
                builder: (context, isExpanded) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('open=$isExpanded'),
                    const BCAccordionTrigger(child: Text('Q1')),
                    const BCAccordionContent(child: Text('A1')),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('open=false'), findsOneWidget);
    });

    testWidgets('isExpandedOf reports the enclosing item state',
        (tester) async {
      await tester.pumpWidget(_app(const _ExpandedFlagAccordion()));
      await tester.pump();
      expect(find.text('open=false'), findsOneWidget);

      await _tap(tester, find.byType(BCAccordionTrigger));
      expect(find.text('open=true'), findsOneWidget);
    });

    testWidgets('reduced motion expands in a single frame', (tester) async {
      await tester.pumpWidget(
        _app(const _Controlled(), disableAnimations: true),
      );
      await tester.pump();

      await tester.tap(find.text('Q1'));
      await tester.pump();
      expect(find.text('A1'), findsOneWidget);
      expect(_turns(tester, 0), closeTo(-0.5, 0.001));

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    });

    testWidgets('expanding never overflows a bounded box', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: BCTheme.light(),
          home: const Scaffold(
            body: SizedBox(
              height: 200,
              child: SingleChildScrollView(child: _Controlled(itemCount: 4)),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Q1'));
      for (var frame = 0; frame < 20; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'frame $frame');
      }
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsOneWidget);
    });

    testWidgets('parts outside an accordion render without expanding',
        (tester) async {
      await tester.pumpWidget(
        _app(
          const BCAccordionItem(
            value: 'orphan',
            children: [
              BCAccordionTrigger(child: Text('Q1')),
              BCAccordionContent(child: Text('A1')),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Q1'), findsOneWidget);
      expect(find.text('A1'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    test('value and controller are mutually exclusive', () {
      final controller = BCAccordionController();
      addTearDown(controller.dispose);

      expect(
        () => BCAccordion(
          value: const <String>{},
          controller: controller,
          children: const [],
        ),
        throwsAssertionError,
      );
      expect(() => BCAccordion(children: const []), throwsAssertionError);
    });

    test('single selection rejects a value holding more than one item', () {
      expect(
        () => BCAccordion(value: const {'1', '2'}, children: const []),
        throwsAssertionError,
      );
      expect(
        () => BCAccordion(
          value: const {'1', '2'},
          selectionMode: BCAccordionSelectionMode.multiple,
          children: const [],
        ),
        returnsNormally,
      );
    });

    test('an item takes either children or builder', () {
      expect(() => BCAccordionItem(value: '1'), throwsAssertionError);
      expect(
        () => BCAccordionItem(
          value: '1',
          builder: (_, _) => const SizedBox.shrink(),
          children: const [],
        ),
        throwsAssertionError,
      );
    });
  });
}

/// Renders `BCAccordionItem.isExpandedOf` from inside the trigger, where the
/// item scope is in play.
class _ExpandedFlagAccordion extends StatefulWidget {
  const _ExpandedFlagAccordion();

  @override
  State<_ExpandedFlagAccordion> createState() => _ExpandedFlagAccordionState();
}

class _ExpandedFlagAccordionState extends State<_ExpandedFlagAccordion> {
  Set<String> _value = const <String>{};

  @override
  Widget build(BuildContext context) {
    return BCAccordion(
      value: _value,
      onValueChange: (next) => setState(() => _value = next),
      children: [
        BCAccordionItem(
          value: '1',
          children: [
            BCAccordionTrigger(
              child: Builder(
                builder: (context) =>
                    Text('open=${BCAccordionItem.isExpandedOf(context)}'),
              ),
            ),
            const BCAccordionContent(child: Text('A1')),
          ],
        ),
      ],
    );
  }
}
