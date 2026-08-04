#!/usr/bin/env python3
"""Generates the country-name table for bc_ui's BCPhoneField.

Names are the ISO 3166-1 English short forms from i18n-iso-countries (MIT).

The iso code list is read from the resolved `phone_numbers_parser` rather than
hard-coded, so the table can never name a country the parser does not know or
miss one it does. Run `flutter pub get` first — this reads
`.dart_tool/package_config.json`.

Prints the map rows to stdout; paste them between the BEGIN/END GENERATED
markers in `lib/src/data/bc_country_data.dart`. Exits non-zero if any country
is left unnamed rather than shipping a bare alpha-2 code.

Usage:
    python3 tool/gen_country_data.py
"""
import json
import subprocess
import sys
import urllib.parse

SRC = "https://cdn.jsdelivr.net/npm/i18n-iso-countries@7/langs/en.json"

# Not in ISO 3166-1 proper, so i18n-iso-countries has no name for them.
# phone_numbers_parser carries them anyway, each with a real dial code.
EXTRA = {
    "AC": "Ascension Island",
    "TA": "Tristan da Cunha",
    "XK": "Kosovo",
}

# Shorter than the official forms, which do not fit a picker row and are not
# what anyone searches for. "Korea (Republic of)" is nobody's mental model.
OVERRIDES = {
    "BO": "Bolivia",
    "BN": "Brunei",
    "CD": "Congo (DRC)",
    "CG": "Congo (Republic)",
    "CI": "Cote d'Ivoire",
    "CN": "China",
    "FK": "Falkland Islands",
    "FM": "Micronesia",
    "GB": "United Kingdom",
    "GM": "Gambia",
    "IR": "Iran",
    "KP": "North Korea",
    "KR": "South Korea",
    "LA": "Laos",
    "MD": "Moldova",
    "MK": "North Macedonia",
    "PS": "Palestine",
    "RU": "Russia",
    "MF": "Saint Martin",
    "SX": "Sint Maarten",
    "SY": "Syria",
    "TW": "Taiwan",
    "TZ": "Tanzania",
    "US": "United States",
    "VA": "Vatican City",
    "VE": "Venezuela",
    "VG": "British Virgin Islands",
    "VI": "U.S. Virgin Islands",
    "VN": "Vietnam",
}


def iso_codes():
    """The IsoCode enum values, in declaration order, from the resolved package."""
    with open(".dart_tool/package_config.json") as f:
        cfg = json.load(f)
    try:
        root = next(
            p["rootUri"] for p in cfg["packages"]
            if p["name"] == "phone_numbers_parser"
        )
    except StopIteration:
        sys.exit("phone_numbers_parser is not resolved - run `flutter pub get`.")

    if root.startswith("file:"):
        root = urllib.parse.urlparse(root).path

    with open(f"{root}/lib/src/iso_codes/iso_code.dart") as f:
        src = f.read()
    body = src[src.index("{") + 1:src.index(";")]
    return [c.strip() for c in body.split(",") if c.strip()]


def english_names():
    out = subprocess.run(
        ["curl", "-sS", "--max-time", "30", SRC],
        capture_output=True, text=True, check=True,
    ).stdout
    return json.loads(out)["countries"]


def main():
    codes = iso_codes()
    names = english_names()

    missing = []
    rows = []
    for code in codes:
        name = OVERRIDES.get(code) or EXTRA.get(code)
        if not name:
            entry = names.get(code)
            # i18n-iso-countries gives a list when a country has aliases; the
            # first one is the short form.
            name = entry[0] if isinstance(entry, list) else entry
        if not name:
            missing.append(code)
            continue
        escaped = name.replace("\\", "\\\\").replace("'", "\\'")
        rows.append("  IsoCode.%s: '%s'," % (code, escaped))

    for row in rows:
        print(row)

    if missing:
        print("\nNo English name for: %s" % ", ".join(missing), file=sys.stderr)
        return 1
    print("\n%d countries named." % len(rows), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
