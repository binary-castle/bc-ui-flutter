import 'dart:ui';

/// HeroUI Native semantic color palettes, precomputed from the oklch source
/// tokens in heroui-native/src/styles/variables.css and the color-mix(in
/// oklab, ...) formulas in theme.css. Regenerate with the gen_colors.py
/// script if upstream tokens change — do not hand-edit individual values.
///
/// Naming note: `defaultColor` corresponds to HeroUI's `default` token
/// (`default` is a reserved word in Dart).

abstract final class BCColorsLight {
  static const Color background = Color(0xFFF5F5F5);
  static const Color foreground = Color(0xFF18181B);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceForeground = Color(0xFF18181B);
  static const Color surfaceHover = Color(0xFFEAEAEA);
  static const Color surfaceSecondary = Color(0xFFEFEFF0);
  static const Color surfaceSecondaryForeground = Color(0xFF18181B);
  static const Color surfaceTertiary = Color(0xFFEAEAEB);
  static const Color surfaceTertiaryForeground = Color(0xFF18181B);
  static const Color overlay = Color(0xFFFFFFFF);
  static const Color overlayForeground = Color(0xFF18181B);
  static const Color backdrop = Color(0x33000000);
  static const Color muted = Color(0xFF71717A);
  static const Color accent = Color(0xFF0485F7);
  static const Color accentForeground = Color(0xFFFCFCFC);
  static const Color segment = Color(0xFFFFFFFF);
  static const Color segmentForeground = Color(0xFF18181B);
  static const Color border = Color(0xFFDEDEE0);
  static const Color separator = Color(0xFFAAAAAD);
  static const Color focus = Color(0xFF0485F7);
  static const Color link = Color(0xFF18181B);
  static const Color defaultColor = Color(0xFFEBEBEC);
  static const Color defaultForeground = Color(0xFF18181B);
  static const Color success = Color(0xFF17C964);
  static const Color successForeground = Color(0xFF18181B);
  static const Color warning = Color(0xFFF5A524);
  static const Color warningForeground = Color(0xFF18181B);
  static const Color danger = Color(0xFFFF383C);
  static const Color dangerForeground = Color(0xFFFCFCFC);
  static const Color field = Color(0xFFFFFFFF);
  static const Color fieldForeground = Color(0xFF18181B);
  static const Color fieldPlaceholder = Color(0xFF71717A);
  static const Color fieldBorder = Color(0x00000000);
  static const Color backgroundSecondary = Color(0xFFEBEBEB);
  static const Color backgroundTertiary = Color(0xFFE1E1E1);
  static const Color backgroundInverse = Color(0xFF18181B);
  static const Color defaultHover = Color(0xFFE1E1E2);
  static const Color accentHover = Color(0xFF3592F9);
  static const Color successHover = Color(0xFF21B55D);
  static const Color warningHover = Color(0xFFDC952A);
  static const Color dangerHover = Color(0xFFFF5551);
  static const Color fieldHover = Color(0xEBF9F9F9);
  static const Color fieldFocus = Color(0xFFFFFFFF);
  static const Color fieldBorderHover = Color(0x1A18181B);
  static const Color fieldBorderFocus = Color(0x3818181B);
  static const Color defaultSoft = Color(0x80EBEBEC);
  static const Color defaultSoftForeground = Color(0xFF18181B);
  static const Color defaultSoftHover = Color(0x99EBEBEC);
  static const Color accentSoft = Color(0x260485F7);
  static const Color accentSoftForeground = Color(0xFF1A6EC6);
  static const Color accentSoftHover = Color(0x330485F7);
  static const Color dangerSoft = Color(0x26FF383C);
  static const Color dangerSoftForeground = Color(0xFFCC3738);
  static const Color dangerSoftHover = Color(0x33FF383C);
  static const Color warningSoft = Color(0x26F5A524);
  static const Color warningSoftForeground = Color(0xFFA0702E);
  static const Color warningSoftHover = Color(0x33F5A524);
  static const Color successSoft = Color(0x2617C964);
  static const Color successSoftForeground = Color(0xFF2A8F4E);
  static const Color successSoftHover = Color(0x3317C964);
  static const Color separatorSecondary = Color(0xFFD8D8D8);
  static const Color separatorTertiary = Color(0xFFCDCDCE);
  static const Color borderSecondary = Color(0xFFC6C6C7);
  static const Color borderTertiary = Color(0xFFA8A8A9);
}

abstract final class BCColorsDark {
  static const Color background = Color(0xFF060607);
  static const Color foreground = Color(0xFFFCFCFC);
  static const Color surface = Color(0xFF18181B);
  static const Color surfaceForeground = Color(0xFFFCFCFC);
  static const Color surfaceHover = Color(0xFF27272A);
  static const Color surfaceSecondary = Color(0xFF232325);
  static const Color surfaceSecondaryForeground = Color(0xFFFCFCFC);
  static const Color surfaceTertiary = Color(0xFF262728);
  static const Color surfaceTertiaryForeground = Color(0xFFFCFCFC);
  static const Color overlay = Color(0xFF18181B);
  static const Color overlayForeground = Color(0xFFFCFCFC);
  static const Color backdrop = Color(0x33000000);
  static const Color muted = Color(0xFF9F9FA9);
  static const Color accent = Color(0xFF0485F7);
  static const Color accentForeground = Color(0xFFFCFCFC);
  static const Color segment = Color(0xFF46464C);
  static const Color segmentForeground = Color(0xFFFCFCFC);
  static const Color border = Color(0xFF28282C);
  static const Color separator = Color(0xFF47474B);
  static const Color focus = Color(0xFF0485F7);
  static const Color link = Color(0xFFFCFCFC);
  static const Color defaultColor = Color(0xFF27272A);
  static const Color defaultForeground = Color(0xFFFCFCFC);
  static const Color success = Color(0xFF17C964);
  static const Color successForeground = Color(0xFF18181B);
  static const Color warning = Color(0xFFF7B750);
  static const Color warningForeground = Color(0xFF18181B);
  static const Color danger = Color(0xFFDB3B3E);
  static const Color dangerForeground = Color(0xFFFCFCFC);
  static const Color field = Color(0xFF18181B);
  static const Color fieldForeground = Color(0xFFFCFCFC);
  static const Color fieldPlaceholder = Color(0xFF9F9FA9);
  static const Color fieldBorder = Color(0x00000000);
  static const Color backgroundSecondary = Color(0xFF0C0C0E);
  static const Color backgroundTertiary = Color(0xFF131316);
  static const Color backgroundInverse = Color(0xFFFCFCFC);
  static const Color defaultHover = Color(0xFF2E2E31);
  static const Color accentHover = Color(0xFF3592F9);
  static const Color successHover = Color(0xFF21B55D);
  static const Color warningHover = Color(0xFFDEA54C);
  static const Color dangerHover = Color(0xFFE15451);
  static const Color fieldHover = Color(0xEB1C1C1F);
  static const Color fieldFocus = Color(0xFF18181B);
  static const Color fieldBorderHover = Color(0x1AFCFCFC);
  static const Color fieldBorderFocus = Color(0x38FCFCFC);
  static const Color defaultSoft = Color(0x8027272A);
  static const Color defaultSoftForeground = Color(0xFFFCFCFC);
  static const Color defaultSoftHover = Color(0x9927272A);
  static const Color accentSoft = Color(0x260485F7);
  static const Color accentSoftForeground = Color(0xFF509FFA);
  static const Color accentSoftHover = Color(0x330485F7);
  static const Color dangerSoft = Color(0x26DB3B3E);
  static const Color dangerSoftForeground = Color(0xFFE76964);
  static const Color dangerSoftHover = Color(0x33DB3B3E);
  static const Color warningSoft = Color(0x26F7B750);
  static const Color warningSoftForeground = Color(0xFFFAD094);
  static const Color warningSoftHover = Color(0x33F7B750);
  static const Color successSoft = Color(0x2617C964);
  static const Color successSoftForeground = Color(0xFF7ADA93);
  static const Color successSoftHover = Color(0x3317C964);
  static const Color separatorSecondary = Color(0xFF343437);
  static const Color separatorTertiary = Color(0xFF3C3C3F);
  static const Color borderSecondary = Color(0xFF434345);
  static const Color borderTertiary = Color(0xFF5C5C5F);
}

