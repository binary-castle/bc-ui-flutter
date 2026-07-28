#!/usr/bin/env python3
"""Generates the brand-mark vector table for bc_ui's BCBrandLogo.

Monochrome glyphs come from simple-icons (CC0-1.0); full-colour marks come
from Iconify's `logos` set (CC0-1.0).
"""
import re
import subprocess

# (enum name, label, simple-icons slug, iconify logos slug or None if the
#  mark is monochrome by design)
PROVIDERS = [
    ("google", "Google", "google", "google-icon"),
    ("apple", "Apple", "apple", None),
    ("github", "GitHub", "github", None),
    ("facebook", "Facebook", "facebook", "facebook"),
    ("microsoft", "Microsoft", "microsoft", "microsoft-icon"),
    ("x", "X", "x", None),
    ("discord", "Discord", "discord", "discord-icon"),
    ("slack", "Slack", "slack", "slack-icon"),
    ("notion", "Notion", "notion", None),
    ("linear", "Linear", "linear", None),
]

SI = "https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/{}.svg"
IC = "https://api.iconify.design/logos/{}.svg"


def fetch(url):
    return subprocess.run(
        ["curl", "-sS", "--max-time", "30", url],
        capture_output=True, text=True, check=True,
    ).stdout


def view_box(svg):
    m = re.search(r'viewBox="([\d.\- ]+)"', svg)
    _, _, w, h = m.group(1).split()
    return float(w), float(h)


def paths(svg):
    out = []
    for tag in re.findall(r"<path\b[^>]*>", svg):
        d = re.search(r' d="([^"]+)"', tag).group(1)
        fill = re.search(r' fill="([^"]+)"', tag)
        out.append((fill.group(1) if fill else None, d))
    return out


def dart_color(hex_str):
    h = hex_str.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return "0xFF" + h.upper()


rows = []
for name, label, si_slug, ic_slug in PROVIDERS:
    mono_svg = fetch(SI.format(si_slug))
    mw, mh = view_box(mono_svg)
    mono = paths(mono_svg)
    assert len(mono) == 1, (name, len(mono))
    parts = [
        f"  BCSocialProvider.{name}: _BrandMark(",
        f"    label: '{label}',",
        f"    monoSize: Size({mw}, {mh}),",
        f"    monoPath:\n        '{mono[0][1]}',",
    ]
    if ic_slug:
        color_svg = fetch(IC.format(ic_slug))
        cw, ch = view_box(color_svg)
        parts.append(f"    colorSize: const Size({cw}, {ch}),")
        parts.append("    colorPaths: [")
        for fill, d in paths(color_svg):
            fill = dart_color(fill) if fill else "0xFF000000"
            parts.append(f"      (\n        Color({fill}),\n        '{d}',\n      ),")
        parts.append("    ],")
    parts.append("  ),")
    rows.append("\n".join(parts))

print("\n".join(rows))
