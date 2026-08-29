import 'dart:async';

import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../data/bc_country_data.dart';
import '../extensions/context_extension.dart';
import '../tokens/bc_spacing.dart';
import '../tokens/bc_typography.dart';
import 'bc_input.dart';
import 'bc_pressable.dart';
import 'bc_select.dart';
import 'bc_separator.dart';
import 'field_parts/bc_description.dart';
import 'field_parts/bc_field_error.dart';
import 'field_parts/bc_label.dart';

export 'bc_input.dart' show BCInputVariant;
export 'package:phone_numbers_parser/phone_numbers_parser.dart' show IsoCode;

/// A phone number as a country plus a national significant number.
///
/// The [nsn] is always in its international form: digits only, no trunk
/// prefix (a UK number is `7400123456`, not `07400123456`) and no dial code.
@immutable
class BCPhoneNumber {
  const BCPhoneNumber({required this.isoCode, required this.nsn});

  /// Reads a number in any shape — `+8801712345678`, or `01712-345678` with
  /// [country] set — and never throws: an unreadable string comes back as the
  /// digits it could salvage, under [country] (or [IsoCode.US] when none was
  /// given).
  factory BCPhoneNumber.parse(String text, {IsoCode? country}) {
    final fallback = country ?? IsoCode.US;
    final digits = countryDigitsOnly(text);
    if (digits.isEmpty) return BCPhoneNumber(isoCode: fallback, nsn: '');

    try {
      final parsed = text.trimLeft().startsWith('+')
          ? PhoneNumber.parse(text)
          : PhoneNumber.parse(digits, destinationCountry: fallback);
      // The parser hands back the un-stripped national number when it could
      // not validate, so a trunk prefix can still be sitting on the front.
      final prefix = nationalPrefixOf(parsed.isoCode);
      var nsn = parsed.nsn;
      if (prefix != null &&
          prefix.isNotEmpty &&
          nsn.length > prefix.length &&
          nsn.startsWith(prefix)) {
        nsn = nsn.substring(prefix.length);
      }
      return BCPhoneNumber(isoCode: parsed.isoCode, nsn: nsn);
    } on PhoneNumberException {
      return BCPhoneNumber(isoCode: fallback, nsn: digits);
    }
  }

  /// The country this number belongs to.
  ///
  /// Authoritative, and deliberately so: `+1` covers 25 countries and no
  /// parser can tell a US number from a Canadian one. Whatever the picker says
  /// wins.
  final IsoCode isoCode;

  /// National significant number — digits only.
  final String nsn;

  /// Dial code without the plus — `880` for Bangladesh.
  String get dialCode => dialCodeOf(isoCode);

  /// `+8801712345678`. Empty while [nsn] is.
  String get e164 => nsn.isEmpty ? '' : '+$dialCode$nsn';

  /// Grouped the way the country writes it — `(201) 555-0123`. Falls back to
  /// bare digits for a number too incomplete to group.
  String get national => formatNationalNsn(nsn, isoCode);

  /// `+880 1712-345678`.
  String get international =>
      nsn.isEmpty ? '' : '+$dialCode ${formatNsnInternational(nsn, isoCode)}';

  bool get isEmpty => nsn.isEmpty;

  /// Length *and* pattern, checked against libPhoneNumber's metadata — so
  /// `+1 555 000 0000` comes back false where a digit-count check would not.
  bool get isValid =>
      nsn.isNotEmpty && PhoneNumber(isoCode: isoCode, nsn: nsn).isValid();

  BCPhoneNumber copyWith({IsoCode? isoCode, String? nsn}) =>
      BCPhoneNumber(isoCode: isoCode ?? this.isoCode, nsn: nsn ?? this.nsn);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BCPhoneNumber && other.isoCode == isoCode && other.nsn == nsn;

  @override
  int get hashCode => Object.hash(isoCode, nsn);

  @override
  String toString() =>
      'BCPhoneNumber(${isoCode.name}, $e164${isValid ? '' : ', invalid'})';
}

/// An international phone field: a country picker in the field's prefix, and a
/// number that groups itself as you type.
///
/// You type freely — nothing is blocked and nothing is rewritten out from
/// under you except the grouping. Validity is reported on every keystroke
/// through [onChanged]'s [BCPhoneNumber.isValid]; the message only surfaces
/// once focus leaves, or when the caller sets [errorText].
///
/// The country's trunk prefix is not part of an international number, so it is
/// dropped as you type: a UK user's leading `0` will not appear. That is
/// correct — `+44 7400 123456`, never `+44 07400 123456` — but it does mean
/// the first keystroke can look like it did nothing.
///
/// ```dart
/// BCPhoneField(
///   label: 'Mobile',
///   isRequired: true,
///   initialCountry: IsoCode.BD,
///   preferredCountries: const [IsoCode.BD, IsoCode.US, IsoCode.GB],
///   onChanged: (value) => setState(() => _phone = value),
/// )
/// ```
class BCPhoneField extends StatefulWidget {
  const BCPhoneField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onValidityChanged,
    this.onSubmitted,
    this.initialCountry,
    this.fallbackCountry = IsoCode.US,
    this.onCountryChanged,
    this.countries,
    this.preferredCountries = const <IsoCode>[],
    this.countryPresentation = BCSelectPresentation.bottomSheet,
    this.countryListLabel = 'Select a country',
    this.countrySearchPlaceholder = 'Search',
    this.formatCountryName,
    this.label,
    this.description,
    this.errorText,
    this.invalidNumberText = 'Enter a valid phone number',
    this.placeholder,
    this.isRequired = false,
    this.isInvalid = false,
    this.isDisabled = false,
    this.variant = BCInputVariant.primary,
    this.inline = false,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  }) : assert(
          countryPresentation != BCSelectPresentation.wheel,
          'A 245-row wheel cannot be spun to a country — use popover or '
          'bottomSheet, both of which search.',
        );

  /// Seeds the field. Its [BCPhoneNumber.isoCode] wins over [initialCountry].
  ///
  /// Read the value back through [onChanged] — like every other text input in
  /// the library this field is uncontrolled, because rebuilding it with
  /// re-grouped text would move the caret out from under the user.
  final BCPhoneNumber? initialValue;

  /// Fires on every keystroke and on every country change, with validity
  /// already computed.
  final ValueChanged<BCPhoneNumber>? onChanged;

  /// Fires only when validity flips, so a submit button can be driven straight
  /// from it without mirroring state.
  final ValueChanged<bool>? onValidityChanged;

  /// The keyboard's action key.
  final ValueChanged<BCPhoneNumber>? onSubmitted;

  /// Country the field opens on. Ignored when [initialValue] is set.
  ///
  /// Null — the default — reads the device's region, so a phone set to
  /// Bangladesh opens on Bangladesh. Resolved once when the field is created;
  /// changing the device region later does not move a field already on screen.
  final IsoCode? initialCountry;

  /// Used when [initialCountry] is null and the device reports no region the
  /// parser recognises — a bare `en` locale, or a UN M.49 region like
  /// `es_419`.
  final IsoCode fallbackCountry;

  /// Fires when a country is picked, and when pasting an international number
  /// changes it.
  final ValueChanged<IsoCode>? onCountryChanged;

  /// Restricts and orders the picker. Null — or an empty list — offers every
  /// country `phone_numbers_parser` knows, sorted by name.
  final List<IsoCode>? countries;

  /// Pinned above the rest, in the order given — the two or three countries
  /// your users actually live in.
  final List<IsoCode> preferredCountries;

  /// How the country list opens. The sheet is the default: it has room for
  /// 245 rows and it lifts the search field clear of the keyboard.
  final BCSelectPresentation countryPresentation;

  /// Title above the country list, and the sheet's header.
  final String countryListLabel;

  final String countrySearchPlaceholder;

  /// Renames countries — your own localisation, or 'United States' shortened
  /// to 'USA'. Defaults are the English ISO 3166-1 short forms.
  final String Function(IsoCode isoCode, String defaultName)? formatCountryName;

  /// Rendered above the field.
  final String? label;

  /// Muted helper text under the field. Replaced by the error when there is
  /// one.
  final String? description;

  /// Your error — from a server, say. Always beats the field's own
  /// [invalidNumberText], and forces the invalid styling on its own.
  final String? errorText;

  /// Shown under the field when a non-empty number fails validation and focus
  /// leaves. Set it to null to keep the field silent and report validity only
  /// through [onChanged].
  final String? invalidNumberText;

  /// Defaults to an example number for the selected country, so the shape
  /// expected is visible before anything is typed.
  final String? placeholder;

  final bool isRequired;

  /// Forces the invalid ring without a message, the way every other bc_ui
  /// field takes it.
  final bool isInvalid;

  final bool isDisabled;
  final BCInputVariant variant;

  /// Lays the field out as a row of an iOS grouped form: no box, no shadow,
  /// no focus ring, and the label beside the number rather than above it.
  ///
  /// Made to be dropped straight into a `CupertinoFormSection`'s children.
  /// The section draws the row background and the hairlines between rows, so
  /// the field must not draw its own; the row padding is the (20, 6, 6, 6)
  /// SwiftUI's `Form` uses, which is what `CupertinoFormRow` uses too, so
  /// this field and the native rows beside it line up. Do not wrap it in a
  /// `CupertinoFormRow` as well — you would get that padding twice.
  ///
  /// [variant] is ignored while this is on, and the country button drops its
  /// divider: that hairline marks the edge of a box, and a form row has none.
  ///
  /// ```dart
  /// CupertinoFormSection.insetGrouped(
  ///   header: const Text('CONTACT'),
  ///   children: [
  ///     CupertinoTextFormFieldRow(prefix: const Text('Name')),
  ///     BCPhoneField(
  ///       label: 'Mobile',
  ///       inline: true,
  ///       initialCountry: IsoCode.BD,
  ///       onChanged: (value) => setState(() => _phone = value),
  ///     ),
  ///   ],
  /// )
  /// ```
  final bool inline;

  /// Holds the *formatted national part* — `(201) 555-0123`, never the dial
  /// code. Create and dispose it yourself; the field only reads and rewrites
  /// it. Use [onChanged] for the number you send to a server.
  final TextEditingController? controller;

  /// Focus for the number, not for the country button. Blur on this node is
  /// what surfaces the validation message.
  final FocusNode? focusNode;

  final TextInputAction? textInputAction;
  final bool autofocus;

  /// The country's flag as a regional-indicator emoji pair — [IsoCode.BD]
  /// becomes 🇧🇩.
  static String flagEmoji(IsoCode isoCode) => countryFlagEmoji(isoCode);

  /// The device's region — `en_GB` gives [IsoCode.GB]. What [initialCountry]
  /// uses when you leave it null.
  ///
  /// Walks the platform's preferred locales in order and takes the first
  /// region the parser knows, so a device set to `es_419, es_MX` still
  /// resolves to Mexico. Null when none of them carry a usable region.
  ///
  /// This is the phone's *configured* region, not where it physically is —
  /// the same thing a web page gets from `navigator.language`, and the same
  /// caveat: a US-configured phone abroad still reports US. Treat it as a
  /// better starting guess than a hardcoded default, not as a location.
  static IsoCode? deviceCountry() {
    for (final locale in WidgetsBinding.instance.platformDispatcher.locales) {
      final isoCode = isoCodeFromAlpha2(locale.countryCode);
      if (isoCode != null) return isoCode;
    }
    return null;
  }

  @override
  State<BCPhoneField> createState() => _BCPhoneFieldState();
}

class _BCPhoneFieldState extends State<BCPhoneField> {
  TextEditingController? _internalController;
  FocusNode? _internalFocus;

  late IsoCode _isoCode;
  List<BCSelectItem<IsoCode>> _countryItems = const [];

  String _lastText = '';
  bool _lastValid = false;
  bool _hasFocus = false;

  /// Set on blur, cleared on focus. Nothing is said about a number until the
  /// user has finished with it.
  bool _showBlurError = false;

  /// A field nobody has touched is not wrong, it is empty.
  bool _isDirty = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocus ??= FocusNode());

  BCPhoneNumber get _value => BCPhoneNumber(
        isoCode: _isoCode,
        nsn: countryDigitsOnly(_controller.text),
      );

  @override
  void initState() {
    super.initState();
    _isoCode = widget.initialValue?.isoCode ??
        widget.initialCountry ??
        BCPhoneField.deviceCountry() ??
        widget.fallbackCountry;
    _clampCountry();
    _rebuildCountryItems();

    final seed = widget.initialValue;
    if (seed != null && seed.nsn.isNotEmpty) {
      _controller.text = formatNationalNsn(seed.nsn, _isoCode);
    }
    _lastText = _controller.text;
    _lastValid = _value.isValid;

    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(BCPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)
          ?.removeListener(_handleTextChanged);
      _controller.addListener(_handleTextChanged);
      _lastText = _controller.text;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocus)
          ?.removeListener(_handleFocusChanged);
      _focusNode.addListener(_handleFocusChanged);
    }
    if (!_listEquals(oldWidget.countries, widget.countries) ||
        !_listEquals(oldWidget.preferredCountries, widget.preferredCountries) ||
        oldWidget.formatCountryName != widget.formatCountryName) {
      final before = _isoCode;
      _clampCountry();
      _rebuildCountryItems();
      // The allowed list dropped the selected country; the field would
      // otherwise keep reporting one the picker can no longer show.
      if (before != _isoCode) {
        _reformatForCountry();
        widget.onCountryChanged?.call(_isoCode);
      }
    }
  }

  @override
  void dispose() {
    (widget.controller ?? _internalController)
        ?.removeListener(_handleTextChanged);
    (widget.focusNode ?? _internalFocus)?.removeListener(_handleFocusChanged);
    _internalController?.dispose();
    _internalFocus?.dispose();
    super.dispose();
  }

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// The countries the picker may offer. An empty list means no restriction,
  /// so a caller filtering a list down to nothing gets everything rather than
  /// a field with no country at all.
  List<IsoCode> get _allowed {
    final countries = widget.countries;
    return countries == null || countries.isEmpty
        ? IsoCode.values
        : countries;
  }

  void _clampCountry() {
    final allowed = _allowed;
    if (!allowed.contains(_isoCode)) _isoCode = allowed.first;
  }

  String _countryName(IsoCode isoCode) {
    final name = countryDisplayName(isoCode);
    return widget.formatCountryName?.call(isoCode, name) ?? name;
  }

  void _rebuildCountryItems() {
    final all = _allowed;
    final pinned = <IsoCode>[
      for (final isoCode in widget.preferredCountries)
        if (all.contains(isoCode)) isoCode,
    ];
    final rest = <IsoCode>[
      for (final isoCode in all)
        if (!pinned.contains(isoCode)) isoCode,
    ]..sort((a, b) => _countryName(a).compareTo(_countryName(b)));

    _countryItems = [
      for (final isoCode in [...pinned, ...rest])
        BCSelectItem<IsoCode>(
          value: isoCode,
          label: _countryName(isoCode),
          description: '+${dialCodeOf(isoCode)}',
          leading: Text(
            countryFlagEmoji(isoCode),
            style: const TextStyle(fontSize: 20, height: 1.2),
          ),
        ),
    ];
  }

  void _handleTextChanged() {
    // The listener also fires for caret moves, which are not value changes.
    if (_controller.text == _lastText) return;
    _lastText = _controller.text;
    _isDirty = true;
    _emit();
  }

  void _emit() {
    final value = _value;
    widget.onChanged?.call(value);
    if (value.isValid != _lastValid) {
      _lastValid = value.isValid;
      widget.onValidityChanged?.call(value.isValid);
    }
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus == _hasFocus) return;
    final value = _value;
    setState(() {
      _hasFocus = _focusNode.hasFocus;
      // Judged on the way out, forgiven on the way back in — a half-typed
      // number is not an error while it is still being typed. An empty field
      // is never wrong here; that is isRequired's business, and the caller's.
      _showBlurError =
          !_hasFocus && _isDirty && !value.isEmpty && !value.isValid;
    });
  }

  void _handleCountryChanged(IsoCode isoCode) {
    if (isoCode == _isoCode) return;
    setState(() => _isoCode = isoCode);
    _reformatForCountry();
    widget.onCountryChanged?.call(isoCode);
  }

  /// Formatters only run on edits, so text already in the field has to be
  /// re-grouped by hand when the country changes.
  void _reformatForCountry() {
    final digits = countryDigitsOnly(_controller.text);
    final formatted = formatNationalNsn(digits, _isoCode);
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
    // The assignment above notifies the controller, which emits — but only if
    // the text actually changed. The country changed either way.
    if (formatted == _lastText) _emit();
    _lastText = formatted;
  }

  void _adoptDetectedCountry(IsoCode isoCode) {
    if (!mounted || isoCode == _isoCode) return;
    if (!_allowed.contains(isoCode)) return;
    setState(() => _isoCode = isoCode);
    widget.onCountryChanged?.call(isoCode);
  }

  /// What SwiftUI's `Form` pads a row by, and so `CupertinoFormRow` too —
  /// an inline field lines up with the native rows above and below it.
  static const EdgeInsetsDirectional _inlineRowPadding =
      EdgeInsetsDirectional.fromSTEB(20, 6, 6, 6);

  /// An iOS form row is 44 tall, 6 of which is padding at either end.
  static const double _inlineFieldHeight = 32;

  /// The caller's error always wins: it knows things the field cannot, like
  /// 'this number is already registered'.
  String? get _effectiveError =>
      widget.errorText ??
      (_showBlurError ? widget.invalidNumberText : null);

  bool get _invalid => widget.isInvalid || _effectiveError != null;

  Widget _buildCountryTrigger(BuildContext context, bool isOpen) {
    final bc = context.bcTheme;

    return Padding(
      // BCInput supplies the 12 on the left; this is the gap to the number,
      // the same one BCSearchField puts after its icon.
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            countryFlagEmoji(_isoCode),
            style: const TextStyle(fontSize: 20, height: 1.2),
          ),
          const SizedBox(width: 6),
          Text(
            '+${dialCodeOf(_isoCode)}',
            style: BCTypography.textBase.copyWith(color: bc.foreground),
          ),
          AnimatedRotation(
            turns: isOpen ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Icon(Icons.keyboard_arrow_down, size: 18, color: bc.muted),
          ),
          // The divider marks the edge of the boxed field's prefix. A form
          // row has no box to divide, and iOS draws nothing there.
          if (!widget.inline) ...[
            const SizedBox(width: 8),
            // A vertical BCSeparator is height: double.infinity, and the Row
            // hands its children unbounded height — it needs a bounded box.
            const SizedBox(
              height: 24,
              child: BCSeparator(orientation: BCSeparatorOrientation.vertical),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = _effectiveError;

    final Widget field = BCInput(
      controller: _controller,
      focusNode: _focusNode,
      variant: widget.inline ? BCInputVariant.plain : widget.variant,
      minHeight: widget.inline ? _inlineFieldHeight : 48,
      placeholder: widget.placeholder ?? countryExampleNumber(_isoCode),
      isInvalid: _invalid,
      isDisabled: widget.isDisabled,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.phone,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: [
        _BCPhoneNumberFormatter(
          isoCode: _isoCode,
          onCountryDetected: _adoptDetectedCountry,
        ),
      ],
      onSubmitted: (_) => widget.onSubmitted?.call(_value),
      prefix: Semantics(
        button: true,
        label: 'Country: ${_countryName(_isoCode)}, '
            '+${dialCodeOf(_isoCode)}',
        child: Listener(
          // Drops the number keyboard before the country sheet arrives. A
          // Listener never enters the gesture arena, so it cannot steal the
          // tap from the Select's own BCPressable.
          onPointerDown: (_) => _focusNode.unfocus(),
          child: BCSelect<IsoCode>(
            items: _countryItems,
            value: _isoCode,
            onValueChange: _handleCountryChanged,
            isDisabled: widget.isDisabled,
            isSearchable: true,
            listLabel: widget.countryListLabel,
            searchPlaceholder: widget.countrySearchPlaceholder,
            presentation: widget.countryPresentation,
            matchTriggerWidth: false,
            triggerFeedback: BCPressFeedback.highlight,
            triggerBuilder: (context, selected, isOpen) =>
                _buildCountryTrigger(context, isOpen),
          ),
        ),
      ),
    );

    final Widget? label = widget.label == null
        ? null
        : BCLabel(
            widget.label!,
            isRequired: widget.isRequired,
            isInvalid: _invalid,
            isDisabled: widget.isDisabled,
          );

    final Widget? footer = error != null
        ? BCFieldError(error)
        : widget.description != null
            ? BCDescription(widget.description!, isDisabled: widget.isDisabled)
            : null;

    // Always the same shape, even with nothing above or below the field.
    // The blur error appears and disappears mid-interaction, and swapping
    // between a bare field and a wrapped one would re-parent the subtree —
    // unmounting the country picker while its sheet was still open, so the
    // pick came back to a dead State and was dropped on the floor. Both
    // layouts below keep the field at a fixed position for the same reason.
    if (widget.inline) {
      return Padding(
        padding: _inlineRowPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Natural width, the way an iOS row's prefix sits — the
                // number then takes whatever is left, as its value does.
                if (label != null) ...[
                  label,
                  // What an iOS row leaves between its prefix and its value.
                  const SizedBox(width: BCSpacing.sm),
                ],
                Expanded(child: field),
              ],
            ),
            if (footer != null) ...[
              const SizedBox(height: BCSpacing.xs),
              footer,
            ],
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          label,
          const SizedBox(height: BCSpacing.sm),
        ],
        field,
        if (footer != null) ...[
          const SizedBox(height: BCSpacing.sm),
          footer,
        ],
      ],
    );
  }
}

/// Re-groups the national number as it is typed, keeping the caret where the
/// finger left it.
class _BCPhoneNumberFormatter extends TextInputFormatter {
  const _BCPhoneNumberFormatter({
    required this.isoCode,
    required this.onCountryDetected,
  });

  final IsoCode isoCode;

  /// Fired when a pasted `+…` number implies a different country.
  final ValueChanged<IsoCode> onCountryDetected;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final caret = newValue.selection.end.clamp(0, text.length);

    var digits = countryDigitsOnly(text);
    var digitsBeforeCaret = countryDigitsOnly(text.substring(0, caret)).length;

    if (text.trimLeft().startsWith('+') && digits.length > 1) {
      // Someone pasted an international number. Adopt its country and keep
      // only the national part — the prefix already shows the dial code.
      try {
        final parsed = PhoneNumber.parse(text);
        if (parsed.isoCode != isoCode) {
          // The engine is mid-edit; changing the widget's country has to wait
          // for the frame to finish.
          scheduleMicrotask(() => onCountryDetected(parsed.isoCode));
        }
        digits = parsed.nsn;
        digitsBeforeCaret = digits.length;
      } on PhoneNumberException {
        // '+9' and friends: no country owns that code yet. Fall through and
        // treat what was typed as national digits.
        digits = _stripTrunkPrefix(digits, () => digitsBeforeCaret,
            (v) => digitsBeforeCaret = v);
      }
    } else {
      digits = _stripTrunkPrefix(
          digits, () => digitsBeforeCaret, (v) => digitsBeforeCaret = v);
    }

    // Deleting a separator has to eat the digit in front of it. Without this
    // the formatter puts the separator straight back and backspace looks
    // broken — the classic 'my delete key does nothing' bug.
    final isDeletion = text.length < oldValue.text.length;
    if (isDeletion &&
        digits.length == countryDigitsOnly(oldValue.text).length &&
        digitsBeforeCaret > 0 &&
        digitsBeforeCaret <= digits.length) {
      digits = digits.substring(0, digitsBeforeCaret - 1) +
          digits.substring(digitsBeforeCaret);
      digitsBeforeCaret -= 1;
    }

    if (digits.length > kMaxNsnDigits) {
      digits = digits.substring(0, kMaxNsnDigits);
      digitsBeforeCaret = digitsBeforeCaret.clamp(0, kMaxNsnDigits);
    }

    final formatted = formatNationalNsn(digits, isoCode);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _caretAfterDigit(formatted, digitsBeforeCaret),
      ),
      // Rewriting the text while a composing range points into the old one
      // throws on Android. A digits-only field never legitimately composes.
      composing: TextRange.empty,
    );
  }

  /// The trunk prefix is not part of an international number: a UK number
  /// beside `+44` is `7400 123456`, never `07400 123456`.
  String _stripTrunkPrefix(
    String digits,
    int Function() getCaret,
    void Function(int) setCaret,
  ) {
    final prefix = nationalPrefixOf(isoCode);
    if (prefix == null || prefix.isEmpty || !digits.startsWith(prefix)) {
      return digits;
    }
    final stripped = digits.substring(prefix.length);
    setCaret((getCaret() - prefix.length).clamp(0, stripped.length));
    return stripped;
  }

  /// Character offset sitting just after the [count]th digit of [formatted].
  ///
  /// Character offsets do not survive re-grouping; digit counts do, so the
  /// caret is restored by counting rather than by arithmetic on the old
  /// offset.
  static int _caretAfterDigit(String formatted, int count) {
    if (count <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      final unit = formatted.codeUnitAt(i);
      if (unit >= 0x30 && unit <= 0x39) {
        seen++;
        if (seen == count) return i + 1;
      }
    }
    return formatted.length;
  }
}
