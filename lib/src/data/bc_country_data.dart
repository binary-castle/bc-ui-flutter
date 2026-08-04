// Country lookups behind BCPhoneField. Internal — not exported from
// `widgets.dart` or `bc_ui.dart`, so none of this is public API.
//
// Dial codes, formatting rules and example numbers all come from
// `phone_numbers_parser` (libPhoneNumber metadata). The only thing the package
// does not carry is display names, which `tool/gen_country_data.py` generates
// into the table at the bottom of this file.

import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// The parser gives up past this, so formatting beyond it is wasted work.
const int kMaxNsnDigits = 17;

/// The country's flag as a regional-indicator emoji pair — `IsoCode.BD`
/// becomes 🇧🇩.
///
/// Alpha-2 letters map to U+1F1E6..U+1F1FF and a pair of them is a flag on
/// both platforms bc_ui targets. `AC`, `TA` and `XK` have no assigned flag and
/// render as two boxed letters instead, as does every flag on Windows — it
/// still reads, so nothing here gates on it.
String countryFlagEmoji(IsoCode isoCode) {
  const indicatorA = 0x1F1E6;
  const letterA = 0x41;
  final code = isoCode.name; // always two uppercase ASCII letters
  return String.fromCharCodes([
    indicatorA + (code.codeUnitAt(0) - letterA),
    indicatorA + (code.codeUnitAt(1) - letterA),
  ]);
}

/// Dial code without the plus — `880` for Bangladesh.
String dialCodeOf(IsoCode isoCode) =>
    metadataByIsoCode[isoCode]?.countryCode ?? '';

/// The trunk prefix a country writes in front of a local number — `0` for the
/// UK. Not part of the international form, so it is stripped as you type.
String? nationalPrefixOf(IsoCode isoCode) =>
    metadataByIsoCode[isoCode]?.nationalPrefix;

/// The country a dial code belongs to when several share it.
///
/// `+1` covers 25 countries; `isMainCountryForDialCode` picks the US out of
/// them. It is set on exactly one member of each of the 12 shared dial codes
/// and on nobody else, so the single-candidate case has to return early.
IsoCode? mainCountryForDialCode(String dialCode) {
  final candidates = countryCodeToIsoCode[dialCode];
  if (candidates == null || candidates.isEmpty) return null;
  if (candidates.length == 1) return candidates.first;
  for (final isoCode in candidates) {
    if (metadataByIsoCode[isoCode]?.isMainCountryForDialCode ?? false) {
      return isoCode;
    }
  }
  return candidates.first;
}

/// English display name, falling back to the alpha-2 code for a country the
/// name table has not caught up with.
String countryDisplayName(IsoCode isoCode) =>
    _countryNames[isoCode] ?? isoCode.name;

/// The [IsoCode] for an alpha-2 region code, or null when nothing matches.
///
/// A locale's region is not always a country: `es_419` is UN M.49 for Latin
/// America and `en_001` is "world", neither of which has an ISO 3166-1
/// counterpart. Those come back null rather than throwing.
IsoCode? isoCodeFromAlpha2(String? code) {
  if (code == null || code.length != 2) return null;
  return _isoCodeByName[code.toUpperCase()];
}

final Map<String, IsoCode> _isoCodeByName = {
  for (final isoCode in IsoCode.values) isoCode.name: isoCode,
};

/// Digits only, with fullwidth and eastern-arabic numerals folded to ASCII.
///
/// The parser normalises the same way internally, so what the field shows and
/// what it parses can never disagree.
String countryDigitsOnly(String text) {
  const starts = [0x30, 0xFF10, 0x0660, 0x06F0];
  final out = StringBuffer();
  for (final rune in text.runes) {
    for (final start in starts) {
      if (rune >= start && rune <= start + 9) {
        out.writeCharCode(0x30 + rune - start);
        break;
      }
    }
  }
  return out.toString();
}

/// Groups an nsn the way the country writes it — `(201) 555-0123` — tolerating
/// one that is still being typed.
String formatNationalNsn(String nsn, IsoCode isoCode) =>
    _format(nsn, isoCode, NsnFormat.national);

/// Groups an nsn for international display — `1712-345678`, no dial code.
String formatNsnInternational(String nsn, IsoCode isoCode) =>
    _format(nsn, isoCode, NsnFormat.international);

/// An example mobile number for the country, national-formatted. Used as the
/// default placeholder so the shape expected is visible before anything is
/// typed.
String? countryExampleNumber(IsoCode isoCode) {
  final mobile = metadataExamplesByIsoCode[isoCode]?.mobile;
  if (mobile == null || mobile.isEmpty) return null;
  final formatted = formatNationalNsn(mobile, isoCode);
  return formatted.isEmpty ? null : formatted;
}

String _format(String nsn, IsoCode isoCode, NsnFormat format) {
  if (nsn.isEmpty) return '';
  try {
    final formatted = PhoneNumberFormatter.formatNsn(nsn, isoCode, format);
    return formatted.isEmpty ? nsn : formatted;
  } catch (_) {
    // formatNsn pads an incomplete number with 9s and then trims them back off
    // by indexing the last character — with no emptiness guard, so a format
    // rule that drops digits can empty the string first and throw a RangeError.
    // Ungrouped digits beat a crash mid-keystroke.
    return nsn;
  }
}

// --- BEGIN GENERATED: python3 tool/gen_country_data.py ---
const Map<IsoCode, String> _countryNames = {
  IsoCode.AC: 'Ascension Island',
  IsoCode.AD: 'Andorra',
  IsoCode.AE: 'United Arab Emirates',
  IsoCode.AF: 'Afghanistan',
  IsoCode.AG: 'Antigua and Barbuda',
  IsoCode.AI: 'Anguilla',
  IsoCode.AL: 'Albania',
  IsoCode.AM: 'Armenia',
  IsoCode.AO: 'Angola',
  IsoCode.AR: 'Argentina',
  IsoCode.AS: 'American Samoa',
  IsoCode.AT: 'Austria',
  IsoCode.AU: 'Australia',
  IsoCode.AW: 'Aruba',
  IsoCode.AX: 'Åland Islands',
  IsoCode.AZ: 'Azerbaijan',
  IsoCode.BA: 'Bosnia and Herzegovina',
  IsoCode.BB: 'Barbados',
  IsoCode.BD: 'Bangladesh',
  IsoCode.BE: 'Belgium',
  IsoCode.BF: 'Burkina Faso',
  IsoCode.BG: 'Bulgaria',
  IsoCode.BH: 'Bahrain',
  IsoCode.BI: 'Burundi',
  IsoCode.BJ: 'Benin',
  IsoCode.BL: 'Saint Barthélemy',
  IsoCode.BM: 'Bermuda',
  IsoCode.BN: 'Brunei',
  IsoCode.BO: 'Bolivia',
  IsoCode.BQ: 'Bonaire, Sint Eustatius and Saba',
  IsoCode.BR: 'Brazil',
  IsoCode.BS: 'Bahamas',
  IsoCode.BT: 'Bhutan',
  IsoCode.BW: 'Botswana',
  IsoCode.BY: 'Belarus',
  IsoCode.BZ: 'Belize',
  IsoCode.CA: 'Canada',
  IsoCode.CC: 'Cocos (Keeling) Islands',
  IsoCode.CD: 'Congo (DRC)',
  IsoCode.CF: 'Central African Republic',
  IsoCode.CG: 'Congo (Republic)',
  IsoCode.CH: 'Switzerland',
  IsoCode.CI: 'Cote d\'Ivoire',
  IsoCode.CK: 'Cook Islands',
  IsoCode.CL: 'Chile',
  IsoCode.CM: 'Cameroon',
  IsoCode.CN: 'China',
  IsoCode.CO: 'Colombia',
  IsoCode.CR: 'Costa Rica',
  IsoCode.CU: 'Cuba',
  IsoCode.CV: 'Cape Verde',
  IsoCode.CW: 'Curaçao',
  IsoCode.CX: 'Christmas Island',
  IsoCode.CY: 'Cyprus',
  IsoCode.CZ: 'Czech Republic',
  IsoCode.DE: 'Germany',
  IsoCode.DJ: 'Djibouti',
  IsoCode.DK: 'Denmark',
  IsoCode.DM: 'Dominica',
  IsoCode.DO: 'Dominican Republic',
  IsoCode.DZ: 'Algeria',
  IsoCode.EC: 'Ecuador',
  IsoCode.EE: 'Estonia',
  IsoCode.EG: 'Egypt',
  IsoCode.EH: 'Western Sahara',
  IsoCode.ER: 'Eritrea',
  IsoCode.ES: 'Spain',
  IsoCode.ET: 'Ethiopia',
  IsoCode.FI: 'Finland',
  IsoCode.FJ: 'Fiji',
  IsoCode.FK: 'Falkland Islands',
  IsoCode.FM: 'Micronesia',
  IsoCode.FO: 'Faroe Islands',
  IsoCode.FR: 'France',
  IsoCode.GA: 'Gabon',
  IsoCode.GB: 'United Kingdom',
  IsoCode.GD: 'Grenada',
  IsoCode.GE: 'Georgia',
  IsoCode.GF: 'French Guiana',
  IsoCode.GG: 'Guernsey',
  IsoCode.GH: 'Ghana',
  IsoCode.GI: 'Gibraltar',
  IsoCode.GL: 'Greenland',
  IsoCode.GM: 'Gambia',
  IsoCode.GN: 'Guinea',
  IsoCode.GP: 'Guadeloupe',
  IsoCode.GQ: 'Equatorial Guinea',
  IsoCode.GR: 'Greece',
  IsoCode.GT: 'Guatemala',
  IsoCode.GU: 'Guam',
  IsoCode.GW: 'Guinea-Bissau',
  IsoCode.GY: 'Guyana',
  IsoCode.HK: 'Hong Kong',
  IsoCode.HN: 'Honduras',
  IsoCode.HR: 'Croatia',
  IsoCode.HT: 'Haiti',
  IsoCode.HU: 'Hungary',
  IsoCode.ID: 'Indonesia',
  IsoCode.IE: 'Ireland',
  IsoCode.IL: 'Israel',
  IsoCode.IM: 'Isle of Man',
  IsoCode.IN: 'India',
  IsoCode.IO: 'British Indian Ocean Territory',
  IsoCode.IQ: 'Iraq',
  IsoCode.IR: 'Iran',
  IsoCode.IS: 'Iceland',
  IsoCode.IT: 'Italy',
  IsoCode.JE: 'Jersey',
  IsoCode.JM: 'Jamaica',
  IsoCode.JO: 'Jordan',
  IsoCode.JP: 'Japan',
  IsoCode.KE: 'Kenya',
  IsoCode.KG: 'Kyrgyzstan',
  IsoCode.KH: 'Cambodia',
  IsoCode.KI: 'Kiribati',
  IsoCode.KM: 'Comoros',
  IsoCode.KN: 'Saint Kitts and Nevis',
  IsoCode.KP: 'North Korea',
  IsoCode.KR: 'South Korea',
  IsoCode.KW: 'Kuwait',
  IsoCode.KY: 'Cayman Islands',
  IsoCode.KZ: 'Kazakhstan',
  IsoCode.LA: 'Laos',
  IsoCode.LB: 'Lebanon',
  IsoCode.LC: 'Saint Lucia',
  IsoCode.LI: 'Liechtenstein',
  IsoCode.LK: 'Sri Lanka',
  IsoCode.LR: 'Liberia',
  IsoCode.LS: 'Lesotho',
  IsoCode.LT: 'Lithuania',
  IsoCode.LU: 'Luxembourg',
  IsoCode.LV: 'Latvia',
  IsoCode.LY: 'Libya',
  IsoCode.MA: 'Morocco',
  IsoCode.MC: 'Monaco',
  IsoCode.MD: 'Moldova',
  IsoCode.ME: 'Montenegro',
  IsoCode.MF: 'Saint Martin',
  IsoCode.MG: 'Madagascar',
  IsoCode.MH: 'Marshall Islands',
  IsoCode.MK: 'North Macedonia',
  IsoCode.ML: 'Mali',
  IsoCode.MM: 'Myanmar',
  IsoCode.MN: 'Mongolia',
  IsoCode.MO: 'Macao',
  IsoCode.MP: 'Northern Mariana Islands',
  IsoCode.MQ: 'Martinique',
  IsoCode.MR: 'Mauritania',
  IsoCode.MS: 'Montserrat',
  IsoCode.MT: 'Malta',
  IsoCode.MU: 'Mauritius',
  IsoCode.MV: 'Maldives',
  IsoCode.MW: 'Malawi',
  IsoCode.MX: 'Mexico',
  IsoCode.MY: 'Malaysia',
  IsoCode.MZ: 'Mozambique',
  IsoCode.NA: 'Namibia',
  IsoCode.NC: 'New Caledonia',
  IsoCode.NE: 'Niger',
  IsoCode.NF: 'Norfolk Island',
  IsoCode.NG: 'Nigeria',
  IsoCode.NI: 'Nicaragua',
  IsoCode.NL: 'Netherlands',
  IsoCode.NO: 'Norway',
  IsoCode.NP: 'Nepal',
  IsoCode.NR: 'Nauru',
  IsoCode.NU: 'Niue',
  IsoCode.NZ: 'New Zealand',
  IsoCode.OM: 'Oman',
  IsoCode.PA: 'Panama',
  IsoCode.PE: 'Peru',
  IsoCode.PF: 'French Polynesia',
  IsoCode.PG: 'Papua New Guinea',
  IsoCode.PH: 'Philippines',
  IsoCode.PK: 'Pakistan',
  IsoCode.PL: 'Poland',
  IsoCode.PM: 'Saint Pierre and Miquelon',
  IsoCode.PR: 'Puerto Rico',
  IsoCode.PS: 'Palestine',
  IsoCode.PT: 'Portugal',
  IsoCode.PW: 'Palau',
  IsoCode.PY: 'Paraguay',
  IsoCode.QA: 'Qatar',
  IsoCode.RE: 'Reunion',
  IsoCode.RO: 'Romania',
  IsoCode.RS: 'Serbia',
  IsoCode.RU: 'Russia',
  IsoCode.RW: 'Rwanda',
  IsoCode.SA: 'Saudi Arabia',
  IsoCode.SB: 'Solomon Islands',
  IsoCode.SC: 'Seychelles',
  IsoCode.SD: 'Sudan',
  IsoCode.SE: 'Sweden',
  IsoCode.SG: 'Singapore',
  IsoCode.SH: 'Saint Helena',
  IsoCode.SI: 'Slovenia',
  IsoCode.SJ: 'Svalbard and Jan Mayen',
  IsoCode.SK: 'Slovakia',
  IsoCode.SL: 'Sierra Leone',
  IsoCode.SM: 'San Marino',
  IsoCode.SN: 'Senegal',
  IsoCode.SO: 'Somalia',
  IsoCode.SR: 'Suriname',
  IsoCode.SS: 'South Sudan',
  IsoCode.ST: 'Sao Tome and Principe',
  IsoCode.SV: 'El Salvador',
  IsoCode.SX: 'Sint Maarten',
  IsoCode.SY: 'Syria',
  IsoCode.SZ: 'Eswatini',
  IsoCode.TA: 'Tristan da Cunha',
  IsoCode.TC: 'Turks and Caicos Islands',
  IsoCode.TD: 'Chad',
  IsoCode.TG: 'Togo',
  IsoCode.TH: 'Thailand',
  IsoCode.TJ: 'Tajikistan',
  IsoCode.TK: 'Tokelau',
  IsoCode.TL: 'Timor-Leste',
  IsoCode.TM: 'Turkmenistan',
  IsoCode.TN: 'Tunisia',
  IsoCode.TO: 'Tonga',
  IsoCode.TR: 'Türkiye',
  IsoCode.TT: 'Trinidad and Tobago',
  IsoCode.TV: 'Tuvalu',
  IsoCode.TW: 'Taiwan',
  IsoCode.TZ: 'Tanzania',
  IsoCode.UA: 'Ukraine',
  IsoCode.UG: 'Uganda',
  IsoCode.US: 'United States',
  IsoCode.UY: 'Uruguay',
  IsoCode.UZ: 'Uzbekistan',
  IsoCode.VA: 'Vatican City',
  IsoCode.VC: 'Saint Vincent and the Grenadines',
  IsoCode.VE: 'Venezuela',
  IsoCode.VG: 'British Virgin Islands',
  IsoCode.VI: 'U.S. Virgin Islands',
  IsoCode.VN: 'Vietnam',
  IsoCode.VU: 'Vanuatu',
  IsoCode.WF: 'Wallis and Futuna',
  IsoCode.WS: 'Samoa',
  IsoCode.XK: 'Kosovo',
  IsoCode.YE: 'Yemen',
  IsoCode.YT: 'Mayotte',
  IsoCode.ZA: 'South Africa',
  IsoCode.ZM: 'Zambia',
  IsoCode.ZW: 'Zimbabwe',
};
// --- END GENERATED ---
