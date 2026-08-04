import 'package:bc_ui/bc_ui.dart';
import 'package:bc_ui/src/data/bc_country_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: BCTheme.light(),
    home: Scaffold(
      body: Center(
        child: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    ),
  );
}

/// Raises the on-screen keyboard and returns the y of its top edge.
double _showKeyboard(WidgetTester tester, {double height = 300}) {
  final ratio = tester.view.devicePixelRatio;
  tester.view.viewInsets = FakeViewPadding(bottom: height * ratio);
  addTearDown(tester.view.resetViewInsets);
  return tester.view.physicalSize.height / ratio - height;
}

/// Metrics of a notched phone — 402x874 at 3x with a 59pt status bar.
void _useNotchedPhone(WidgetTester tester) {
  const ratio = 3.0;
  const notch = FakeViewPadding(top: 59 * ratio, bottom: 34 * ratio);
  tester.view.devicePixelRatio = ratio;
  tester.view.physicalSize = const Size(402 * ratio, 874 * ratio);
  tester.view.viewPadding = notch;
  tester.view.padding = notch;
  addTearDown(tester.view.reset);
}

/// Types into the field the way a keyboard does — one edit at a time, so the
/// formatter sees every intermediate state. `enterText` replaces wholesale.
Future<void> _type(WidgetTester tester, String digits, {Finder? field}) async {
  final target = field ?? find.byType(EditableText).first;
  await tester.tap(target);
  await tester.pump();
  final state = tester.state<EditableTextState>(target);
  for (final ch in digits.split('')) {
    final current = state.textEditingValue;
    final at = current.selection.end < 0
        ? current.text.length
        : current.selection.end;
    final next = current.text.substring(0, at) + ch + current.text.substring(at);
    state.updateEditingValue(TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: at + 1),
    ));
    await tester.pump();
  }
}

String _text(WidgetTester tester, {Finder? field}) => tester
    .widget<EditableText>(field ?? find.byType(EditableText).first)
    .controller
    .text;

void main() {
  group('BCPhoneNumber', () {
    test('parses an international number into country and nsn', () {
      final value = BCPhoneNumber.parse('+8801712345678');
      expect(value.isoCode, IsoCode.BD);
      expect(value.nsn, '1712345678');
      expect(value.e164, '+8801712345678');
      expect(value.isValid, isTrue);
    });

    test('strips the trunk prefix from a national number', () {
      final value = BCPhoneNumber.parse('01712-345678', country: IsoCode.BD);
      expect(value.nsn, '1712345678');
      expect(value.e164, '+8801712345678');
    });

    test('never throws on input no country owns', () {
      for (final input in ['', '+9', '+', 'abc', '0']) {
        expect(
          () => BCPhoneNumber.parse(input, country: IsoCode.BD),
          returnsNormally,
          reason: 'parse("$input")',
        );
        expect(() => BCPhoneNumber.parse(input), returnsNormally,
            reason: 'parse("$input") with no country');
      }
      expect(BCPhoneNumber.parse('').isEmpty, isTrue);
    });

    test('validity is pattern-checked, not just length', () {
      const real = BCPhoneNumber(isoCode: IsoCode.US, nsn: '2015550123');
      const fake = BCPhoneNumber(isoCode: IsoCode.US, nsn: '5550000000');
      const partial = BCPhoneNumber(isoCode: IsoCode.US, nsn: '201');
      expect(real.isValid, isTrue);
      expect(fake.isValid, isFalse, reason: '10 digits but not a real number');
      expect(partial.isValid, isFalse);
    });

    test('equality ignores formatting', () {
      final a = BCPhoneNumber.parse('(201) 555-0123', country: IsoCode.US);
      final b = BCPhoneNumber.parse('2015550123', country: IsoCode.US);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('an empty number has an empty e164, not a bare dial code', () {
      const value = BCPhoneNumber(isoCode: IsoCode.BD, nsn: '');
      expect(value.e164, '');
      expect(value.international, '');
      expect(value.isValid, isFalse);
    });

    test('flagEmoji builds a regional indicator pair', () {
      expect(BCPhoneField.flagEmoji(IsoCode.BD), '\u{1F1E7}\u{1F1E9}');
      expect(BCPhoneField.flagEmoji(IsoCode.US), '\u{1F1FA}\u{1F1F8}');
    });

    test('mainCountryForDialCode resolves the shared +1 block', () {
      expect(mainCountryForDialCode('1'), IsoCode.US);
      expect(mainCountryForDialCode('44'), IsoCode.GB);
      expect(mainCountryForDialCode('880'), IsoCode.BD);
      expect(mainCountryForDialCode('999999'), isNull);
    });

    test('every country has a name and a dial code', () {
      for (final isoCode in IsoCode.values) {
        expect(countryDisplayName(isoCode), isNot(isoCode.name),
            reason: '${isoCode.name} fell back to its alpha-2 code');
        expect(dialCodeOf(isoCode), isNotEmpty, reason: isoCode.name);
      }
    });

    test('formatting never throws for any country', () {
      for (final isoCode in IsoCode.values) {
        for (final nsn in ['1', '12', '1234', '123456789', '12345678901234']) {
          expect(() => formatNationalNsn(nsn, isoCode), returnsNormally,
              reason: '${isoCode.name} / $nsn');
        }
      }
    });
  });

  group('BCPhoneField rendering', () {
    testWidgets('shows the flag, the dial code and a divider', (tester) async {
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.BD)),
      );
      await tester.pump();

      expect(find.text('\u{1F1E7}\u{1F1E9}'), findsWidgets);
      expect(find.text('+880'), findsOneWidget);
      expect(find.byType(BCSeparator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('placeholder defaults to the country example number',
        (tester) async {
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.US)),
      );
      await tester.pump();
      expect(find.text(countryExampleNumber(IsoCode.US)!), findsOneWidget);
    });

    testWidgets('renders bare when it has no label, description or error',
        (tester) async {
      await tester.pumpWidget(_app(const BCPhoneField()));
      await tester.pump();
      expect(find.byType(BCLabel), findsNothing);
      expect(find.byType(BCFieldError), findsNothing);
    });

    testWidgets('label and description render', (tester) async {
      await tester.pumpWidget(_app(const BCPhoneField(
        label: 'Mobile',
        description: 'We only text you about deliveries.',
        isRequired: true,
      )));
      await tester.pump();
      // BCLabel is a Text.rich carrying 'Mobile' plus a styled ' *'.
      expect(find.textContaining('Mobile', findRichText: true), findsOneWidget);
      expect(find.text('We only text you about deliveries.'), findsOneWidget);
    });
  });

  group('BCPhoneField formatting', () {
    testWidgets('groups a US number as it is typed', (tester) async {
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.US)),
      );
      await tester.pump();

      await _type(tester, '2');
      expect(_text(tester), '(2');
      await _type(tester, '01');
      expect(_text(tester), '(201)');
      await _type(tester, '5');
      expect(_text(tester), '(201) 5');
      await _type(tester, '550123');
      expect(_text(tester), '(201) 555-0123');
    });

    testWidgets('drops the trunk prefix', (tester) async {
      BCPhoneNumber? seen;
      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.GB,
        onChanged: (value) => seen = value,
      )));
      await tester.pump();

      await _type(tester, '07400123456');
      expect(countryDigitsOnly(_text(tester)), '7400123456');
      expect(seen!.e164, '+447400123456');
      expect(seen!.isValid, isTrue);
    });

    testWidgets('ignores non-digits and folds eastern-arabic numerals',
        (tester) async {
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.US)),
      );
      await tester.pump();

      await tester.enterText(find.byType(EditableText), 'abc201-555.0123');
      await tester.pump();
      expect(_text(tester), '(201) 555-0123');

      await tester.enterText(find.byType(EditableText), '٢٠١');
      await tester.pump();
      expect(_text(tester), '(201)');
    });

    testWidgets('caret lands after the digit just typed', (tester) async {
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.US)),
      );
      await tester.pump();

      await _type(tester, '2015550123');
      final state = tester.state<EditableTextState>(find.byType(EditableText));

      // Insert a 9 right after the area code — offset 4 sits after the '1'
      // of '(201'.
      state.updateEditingValue(const TextEditingValue(
        text: '(2019) 555-0123',
        selection: TextSelection.collapsed(offset: 5),
      ));
      await tester.pump();

      expect(countryDigitsOnly(_text(tester)), '20195550123'.substring(0, 11));
      // Four digits precede the caret, so it must sit just after the fourth.
      final text = _text(tester);
      final offset = state.textEditingValue.selection.baseOffset;
      expect(countryDigitsOnly(text.substring(0, offset)).length, 4,
          reason: 'caret drifted: "$text" @ $offset');
    });

    testWidgets('backspacing a separator deletes the digit before it',
        (tester) async {
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.US)),
      );
      await tester.pump();

      await _type(tester, '201');
      expect(_text(tester), '(201)');

      final state = tester.state<EditableTextState>(find.byType(EditableText));
      // Backspace removes the ')' — a character the user never typed.
      state.updateEditingValue(const TextEditingValue(
        text: '(201',
        selection: TextSelection.collapsed(offset: 4),
      ));
      await tester.pump();

      expect(_text(tester), '(20',
          reason: 'the separator grew back and backspace did nothing');
    });

    testWidgets('caps the number at the longest nsn any country has',
        (tester) async {
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.US)),
      );
      await tester.pump();

      await tester.enterText(
          find.byType(EditableText), '1234567890123456789012345678901234567890');
      await tester.pump();
      expect(countryDigitsOnly(_text(tester)).length, lessThanOrEqualTo(17));
    });

    testWidgets('pasting an international number switches country',
        (tester) async {
      IsoCode? switchedTo;
      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.US,
        onCountryChanged: (iso) => switchedTo = iso,
      )));
      await tester.pump();

      await tester.enterText(find.byType(EditableText), '+447400123456');
      await tester.pump();
      await tester.pump();

      expect(switchedTo, IsoCode.GB);
      expect(find.text('+44'), findsOneWidget);
      expect(countryDigitsOnly(_text(tester)), '7400123456',
          reason: 'the dial code leaked into the number');
    });
  });

  group('BCPhoneField validation', () {
    testWidgets('reports validity on every keystroke', (tester) async {
      final seen = <bool>[];
      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.US,
        onChanged: (value) => seen.add(value.isValid),
      )));
      await tester.pump();

      await _type(tester, '2015550123');
      expect(seen.length, 10);
      expect(seen.sublist(0, 9), everyElement(isFalse));
      expect(seen.last, isTrue);
    });

    testWidgets('onValidityChanged fires only on a flip', (tester) async {
      final flips = <bool>[];
      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.US,
        onValidityChanged: flips.add,
      )));
      await tester.pump();

      await _type(tester, '2015550123');
      expect(flips, [true]);

      final state = tester.state<EditableTextState>(find.byType(EditableText));
      state.updateEditingValue(const TextEditingValue(
        text: '(201) 555-012',
        selection: TextSelection.collapsed(offset: 13),
      ));
      await tester.pump();
      expect(flips, [true, false]);
    });

    testWidgets('the message waits for blur, then clears on refocus',
        (tester) async {
      await tester.pumpWidget(_app(const Column(children: [
        BCPhoneField(initialCountry: IsoCode.US),
        BCInput(placeholder: 'somewhere else'),
      ])));
      await tester.pump();

      await _type(tester, '201');
      expect(find.text('Enter a valid phone number'), findsNothing,
          reason: 'a half-typed number is not an error yet');

      await tester.tap(find.byType(EditableText).last);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsOneWidget);

      await tester.tap(find.byType(EditableText).first);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsNothing);
    });

    testWidgets('an untouched or empty field is never wrong', (tester) async {
      await tester.pumpWidget(_app(const Column(children: [
        BCPhoneField(initialCountry: IsoCode.US),
        BCInput(placeholder: 'somewhere else'),
      ])));
      await tester.pump();

      await tester.tap(find.byType(EditableText).first);
      await tester.pump();
      await tester.tap(find.byType(EditableText).last);
      await tester.pumpAndSettle();

      expect(find.byType(BCFieldError), findsNothing);
    });

    testWidgets('a valid number blurs without complaint', (tester) async {
      await tester.pumpWidget(_app(const Column(children: [
        BCPhoneField(initialCountry: IsoCode.US),
        BCInput(placeholder: 'somewhere else'),
      ])));
      await tester.pump();

      await _type(tester, '2015550123');
      await tester.tap(find.byType(EditableText).last);
      await tester.pumpAndSettle();

      expect(find.byType(BCFieldError), findsNothing);
    });

    testWidgets('errorText beats the built-in message and shows immediately',
        (tester) async {
      await tester.pumpWidget(_app(const BCPhoneField(
        initialCountry: IsoCode.US,
        errorText: 'That number is already registered',
      )));
      await tester.pump();

      expect(find.text('That number is already registered'), findsOneWidget);
      expect(find.text('Enter a valid phone number'), findsNothing);
    });

    testWidgets('invalidNumberText: null stays silent but still reports',
        (tester) async {
      var lastValid = true;
      await tester.pumpWidget(_app(Column(children: [
        BCPhoneField(
          initialCountry: IsoCode.US,
          invalidNumberText: null,
          onChanged: (value) => lastValid = value.isValid,
        ),
        const BCInput(placeholder: 'somewhere else'),
      ])));
      await tester.pump();

      await _type(tester, '201');
      await tester.tap(find.byType(EditableText).last);
      await tester.pumpAndSettle();

      expect(find.byType(BCFieldError), findsNothing);
      expect(lastValid, isFalse);
    });

    testWidgets('isInvalid alone rings the field with no message',
        (tester) async {
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.US, isInvalid: true)),
      );
      await tester.pump();

      expect(find.byType(BCFieldError), findsNothing);
      expect(
        tester.widget<BCInput>(find.byType(BCInput)).isInvalid,
        isTrue,
      );
    });

    testWidgets('the error replaces the description rather than stacking',
        (tester) async {
      await tester.pumpWidget(_app(const BCPhoneField(
        initialCountry: IsoCode.US,
        description: 'Mobile numbers only',
        errorText: 'Nope',
      )));
      await tester.pump();

      expect(find.text('Nope'), findsOneWidget);
      expect(find.text('Mobile numbers only'), findsNothing);
    });
  });

  group('BCPhoneField country picker', () {
    testWidgets('picking a country updates the prefix and re-groups the number',
        (tester) async {
      BCPhoneNumber? seen;
      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.US,
        preferredCountries: const [IsoCode.GB],
        onChanged: (value) => seen = value,
      )));
      await tester.pump();

      await _type(tester, '2015550123');
      expect(_text(tester), '(201) 555-0123');

      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('United Kingdom').last);
      await tester.pumpAndSettle();

      expect(find.text('+44'), findsOneWidget);
      expect(countryDigitsOnly(_text(tester)), '2015550123',
          reason: 'switching country must not lose digits');
      expect(seen!.isoCode, IsoCode.GB);
      expect(seen!.e164, '+442015550123');
    });

    testWidgets('the +1 block is disambiguated by the picker, not the parser',
        (tester) async {
      BCPhoneNumber? seen;
      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.US,
        preferredCountries: const [IsoCode.CA],
        onChanged: (value) => seen = value,
      )));
      await tester.pump();

      // 201 is New Jersey, so the metadata's leading-digit patterns put this
      // number in the US.
      await _type(tester, '2015550123');
      expect(seen!.isoCode, IsoCode.US);
      expect(BCPhoneNumber.parse('+12015550123').isoCode, IsoCode.US);

      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Canada').last);
      await tester.pumpAndSettle();

      // The picker overrides the parser: both countries dial +1, and the user
      // is the only one who knows which of the 25 they meant.
      expect(seen!.isoCode, IsoCode.CA);
      expect(seen!.e164, '+12015550123');
    });

    testWidgets('a pick still lands when the blur error appeared first',
        (tester) async {
      // Opening the picker blurs the number, which can raise the validation
      // message. If that re-parented the field the picker would be unmounted
      // mid-sheet and the picked country silently dropped.
      BCPhoneNumber? seen;
      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.US,
        preferredCountries: const [IsoCode.CA],
        onChanged: (value) => seen = value,
      )));
      await tester.pump();

      await _type(tester, '201555');
      expect(seen!.isValid, isFalse);

      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();
      expect(find.byType(BCFieldError), findsOneWidget,
          reason: 'the setup for this test needs the error to be showing');

      await tester.tap(find.text('Canada').last);
      await tester.pumpAndSettle();

      expect(seen!.isoCode, IsoCode.CA);
    });

    testWidgets('preferred countries are pinned above the alphabetical rest',
        (tester) async {
      await tester.pumpWidget(_app(const BCPhoneField(
        initialCountry: IsoCode.BD,
        preferredCountries: [IsoCode.BD, IsoCode.GB],
      )));
      await tester.pump();

      await tester.tap(find.text('+880'));
      await tester.pumpAndSettle();

      final bd = tester.getTopLeft(find.text('Bangladesh').last).dy;
      final gb = tester.getTopLeft(find.text('United Kingdom').last).dy;
      final af = tester.getTopLeft(find.text('Afghanistan').last).dy;
      expect(bd, lessThan(gb));
      expect(gb, lessThan(af), reason: 'pinned countries must come first');
    });

    testWidgets('countries restricts the list', (tester) async {
      await tester.pumpWidget(_app(const BCPhoneField(
        initialCountry: IsoCode.BD,
        countries: [IsoCode.BD, IsoCode.IN, IsoCode.PK],
      )));
      await tester.pump();

      await tester.tap(find.text('+880'));
      await tester.pumpAndSettle();

      expect(find.text('Bangladesh'), findsWidgets);
      expect(find.text('India'), findsOneWidget);
      expect(find.text('Pakistan'), findsOneWidget);
      expect(find.text('United States'), findsNothing);
    });

    testWidgets('search matches the name and the dial code', (tester) async {
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.US)),
      );
      await tester.pump();

      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(BCSearchField), 'bangla');
      await tester.pumpAndSettle();
      expect(find.text('Bangladesh'), findsOneWidget);

      await tester.enterText(find.byType(BCSearchField), '+880');
      await tester.pumpAndSettle();
      expect(find.text('Bangladesh'), findsOneWidget);
    });

    testWidgets('formatCountryName renames rows', (tester) async {
      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.US,
        countries: const [IsoCode.US, IsoCode.GB],
        formatCountryName: (iso, name) => iso == IsoCode.US ? 'USA' : name,
      )));
      await tester.pump();

      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();
      expect(find.text('USA'), findsOneWidget);
      expect(find.text('United States'), findsNothing);
    });

    testWidgets('disabled opens nothing', (tester) async {
      await tester.pumpWidget(_app(const BCPhoneField(
        initialCountry: IsoCode.US,
        isDisabled: true,
      )));
      await tester.pump();

      await tester.tap(find.text('+1'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(BCSearchField), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('BCPhoneField overlays', () {
    testWidgets('the country sheet rides above the keyboard', (tester) async {
      _useNotchedPhone(tester);
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.US)),
      );
      await tester.pump();

      final keyboardTop = _showKeyboard(tester);
      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();

      final search = tester.getRect(find.byType(BCSearchField));
      expect(search.bottom, lessThanOrEqualTo(keyboardTop),
          reason: 'the search field is behind the keyboard');
      expect(search.top, greaterThan(59),
          reason: 'the sheet is under the status bar');
    });

    testWidgets('the popover list is wider than its inline trigger',
        (tester) async {
      await tester.pumpWidget(_app(const BCPhoneField(
        initialCountry: IsoCode.US,
        countryPresentation: BCSelectPresentation.popover,
      )));
      await tester.pump();

      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();

      // matchTriggerWidth: false — otherwise the ~95px flag button would
      // force a 95px list with an unusable search field.
      expect(tester.getSize(find.byType(BCSearchField)).width,
          greaterThan(200));
    });
  });

  group('BCPhoneField country detection', () {
    /// Sets the platform's preferred locales for the rest of the test, the way
    /// a device configured for that region reports them.
    void useLocales(WidgetTester tester, List<Locale> locales) {
      tester.platformDispatcher.localesTestValue = locales;
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    }

    testWidgets('opens on the device region by default', (tester) async {
      useLocales(tester, const [Locale('bn', 'BD')]);
      await tester.pumpWidget(_app(const BCPhoneField()));
      await tester.pump();

      expect(find.text('+880'), findsOneWidget);
    });

    testWidgets('skips locales carrying no usable region', (tester) async {
      // es_419 is UN M.49 for Latin America — not an ISO 3166-1 country.
      useLocales(tester, const [
        Locale('en'),
        Locale('es', '419'),
        Locale('es', 'MX'),
      ]);
      await tester.pumpWidget(_app(const BCPhoneField()));
      await tester.pump();

      expect(find.text('+52'), findsOneWidget, reason: 'should reach es_MX');
    });

    testWidgets('falls back when no locale carries a region', (tester) async {
      useLocales(tester, const [Locale('en')]);
      await tester.pumpWidget(_app(const BCPhoneField(
        fallbackCountry: IsoCode.BD,
      )));
      await tester.pump();

      expect(find.text('+880'), findsOneWidget);
    });

    testWidgets('an explicit initialCountry beats the device', (tester) async {
      useLocales(tester, const [Locale('bn', 'BD')]);
      await tester.pumpWidget(
        _app(const BCPhoneField(initialCountry: IsoCode.GB)),
      );
      await tester.pump();

      expect(find.text('+44'), findsOneWidget);
    });

    testWidgets('initialValue beats the device too', (tester) async {
      useLocales(tester, const [Locale('bn', 'BD')]);
      await tester.pumpWidget(_app(const BCPhoneField(
        initialValue: BCPhoneNumber(isoCode: IsoCode.GB, nsn: '7400123456'),
      )));
      await tester.pump();

      expect(find.text('+44'), findsOneWidget);
    });

    testWidgets('a detected country outside countries is clamped',
        (tester) async {
      useLocales(tester, const [Locale('en', 'US')]);
      await tester.pumpWidget(_app(const BCPhoneField(
        countries: [IsoCode.BD, IsoCode.IN],
      )));
      await tester.pump();

      expect(find.text('+1'), findsNothing);
      expect(find.text('+880'), findsOneWidget,
          reason: 'must land on an allowed country, not the detected one');
    });

    testWidgets('deviceCountry reads the platform region', (tester) async {
      useLocales(tester, const [Locale('en', 'GB')]);
      expect(BCPhoneField.deviceCountry(), IsoCode.GB);

      useLocales(tester, const [Locale('en')]);
      expect(BCPhoneField.deviceCountry(), isNull);
    });

    test('isoCodeFromAlpha2 rejects non-countries', () {
      expect(isoCodeFromAlpha2('BD'), IsoCode.BD);
      expect(isoCodeFromAlpha2('bd'), IsoCode.BD);
      expect(isoCodeFromAlpha2('419'), isNull);
      expect(isoCodeFromAlpha2('ZZ'), isNull);
      expect(isoCodeFromAlpha2(null), isNull);
      expect(isoCodeFromAlpha2(''), isNull);
    });
  });

  group('BCPhoneField plumbing', () {
    testWidgets('initialValue seeds both halves', (tester) async {
      await tester.pumpWidget(_app(const BCPhoneField(
        initialValue: BCPhoneNumber(isoCode: IsoCode.BD, nsn: '1712345678'),
        initialCountry: IsoCode.US,
      )));
      await tester.pump();

      expect(find.text('+880'), findsOneWidget,
          reason: 'initialValue.isoCode must beat initialCountry');
      expect(countryDigitsOnly(_text(tester)), '1712345678');
    });

    testWidgets('an external controller outlives the field', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.US,
        controller: controller,
      )));
      await tester.pump();
      await _type(tester, '201');
      expect(controller.text, '(201)');

      await tester.pumpWidget(_app(const SizedBox()));
      await tester.pump();

      expect(() => controller.text, returnsNormally);
      expect(controller.text, '(201)');
    });

    testWidgets('onSubmitted carries the parsed number', (tester) async {
      BCPhoneNumber? submitted;
      await tester.pumpWidget(_app(BCPhoneField(
        initialCountry: IsoCode.US,
        onSubmitted: (value) => submitted = value,
      )));
      await tester.pump();

      await _type(tester, '2015550123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted!.e164, '+12015550123');
      expect(submitted!.isValid, isTrue);
    });

    testWidgets('dropping the selected country from countries re-snaps it',
        (tester) async {
      IsoCode? changed;
      Widget build(List<IsoCode> countries) => _app(BCPhoneField(
            initialCountry: IsoCode.US,
            countries: countries,
            onCountryChanged: (iso) => changed = iso,
          ));

      await tester.pumpWidget(build(const [IsoCode.US, IsoCode.GB]));
      await tester.pump();
      expect(find.text('+1'), findsOneWidget);

      await tester.pumpWidget(build(const [IsoCode.GB, IsoCode.BD]));
      await tester.pump();

      expect(changed, IsoCode.GB);
      expect(find.text('+44'), findsOneWidget);
    });
  });
}
