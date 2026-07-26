import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../tokens/app_shadows.dart';
import '../tokens/bc_colors.dart';

/// The full HeroUI Native semantic token set as a Flutter [ThemeExtension].
///
/// Every widget in bc_ui reads its colors from this extension via
/// `context.bcTheme`. The 64 color slots mirror the `--color-*` variables in
/// heroui-native (theme.css / use-theme-color.ts); `defaultColor` corresponds
/// to HeroUI's `default` token.
class BCThemeExtension extends ThemeExtension<BCThemeExtension> {
  const BCThemeExtension({
    required this.background,
    required this.foreground,
    required this.surface,
    required this.surfaceForeground,
    required this.surfaceHover,
    required this.surfaceSecondary,
    required this.surfaceSecondaryForeground,
    required this.surfaceTertiary,
    required this.surfaceTertiaryForeground,
    required this.overlay,
    required this.overlayForeground,
    required this.backdrop,
    required this.muted,
    required this.accent,
    required this.accentForeground,
    required this.segment,
    required this.segmentForeground,
    required this.border,
    required this.separator,
    required this.focus,
    required this.link,
    required this.defaultColor,
    required this.defaultForeground,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.danger,
    required this.dangerForeground,
    required this.field,
    required this.fieldForeground,
    required this.fieldPlaceholder,
    required this.fieldBorder,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.backgroundInverse,
    required this.defaultHover,
    required this.accentHover,
    required this.successHover,
    required this.warningHover,
    required this.dangerHover,
    required this.fieldHover,
    required this.fieldFocus,
    required this.fieldBorderHover,
    required this.fieldBorderFocus,
    required this.defaultSoft,
    required this.defaultSoftForeground,
    required this.defaultSoftHover,
    required this.accentSoft,
    required this.accentSoftForeground,
    required this.accentSoftHover,
    required this.dangerSoft,
    required this.dangerSoftForeground,
    required this.dangerSoftHover,
    required this.warningSoft,
    required this.warningSoftForeground,
    required this.warningSoftHover,
    required this.successSoft,
    required this.successSoftForeground,
    required this.successSoftHover,
    required this.separatorSecondary,
    required this.separatorTertiary,
    required this.borderSecondary,
    required this.borderTertiary,
    required this.surfaceShadow,
    required this.overlayShadow,
    required this.fieldShadow,
    this.borderWidth = 1,
    this.opacityDisabled = 0.5,
  });

  final Color background;
  final Color foreground;
  final Color surface;
  final Color surfaceForeground;
  final Color surfaceHover;
  final Color surfaceSecondary;
  final Color surfaceSecondaryForeground;
  final Color surfaceTertiary;
  final Color surfaceTertiaryForeground;
  final Color overlay;
  final Color overlayForeground;
  final Color backdrop;
  final Color muted;
  final Color accent;
  final Color accentForeground;
  final Color segment;
  final Color segmentForeground;
  final Color border;
  final Color separator;
  final Color focus;
  final Color link;
  final Color defaultColor;
  final Color defaultForeground;
  final Color success;
  final Color successForeground;
  final Color warning;
  final Color warningForeground;
  final Color danger;
  final Color dangerForeground;
  final Color field;
  final Color fieldForeground;
  final Color fieldPlaceholder;
  final Color fieldBorder;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color backgroundInverse;
  final Color defaultHover;
  final Color accentHover;
  final Color successHover;
  final Color warningHover;
  final Color dangerHover;
  final Color fieldHover;
  final Color fieldFocus;
  final Color fieldBorderHover;
  final Color fieldBorderFocus;
  final Color defaultSoft;
  final Color defaultSoftForeground;
  final Color defaultSoftHover;
  final Color accentSoft;
  final Color accentSoftForeground;
  final Color accentSoftHover;
  final Color dangerSoft;
  final Color dangerSoftForeground;
  final Color dangerSoftHover;
  final Color warningSoft;
  final Color warningSoftForeground;
  final Color warningSoftHover;
  final Color successSoft;
  final Color successSoftForeground;
  final Color successSoftHover;
  final Color separatorSecondary;
  final Color separatorTertiary;
  final Color borderSecondary;
  final Color borderTertiary;

  final BCShadowSet surfaceShadow;
  final BCShadowSet overlayShadow;
  final BCShadowSet fieldShadow;

  /// `--border-width`.
  final double borderWidth;

  /// `--opacity-disabled`.
  final double opacityDisabled;

  /// Default light palette.
  factory BCThemeExtension.light({Color? accent}) {
    const ext = BCThemeExtension(
      background: BCColorsLight.background,
      foreground: BCColorsLight.foreground,
      surface: BCColorsLight.surface,
      surfaceForeground: BCColorsLight.surfaceForeground,
      surfaceHover: BCColorsLight.surfaceHover,
      surfaceSecondary: BCColorsLight.surfaceSecondary,
      surfaceSecondaryForeground: BCColorsLight.surfaceSecondaryForeground,
      surfaceTertiary: BCColorsLight.surfaceTertiary,
      surfaceTertiaryForeground: BCColorsLight.surfaceTertiaryForeground,
      overlay: BCColorsLight.overlay,
      overlayForeground: BCColorsLight.overlayForeground,
      backdrop: BCColorsLight.backdrop,
      muted: BCColorsLight.muted,
      accent: BCColorsLight.accent,
      accentForeground: BCColorsLight.accentForeground,
      segment: BCColorsLight.segment,
      segmentForeground: BCColorsLight.segmentForeground,
      border: BCColorsLight.border,
      separator: BCColorsLight.separator,
      focus: BCColorsLight.focus,
      link: BCColorsLight.link,
      defaultColor: BCColorsLight.defaultColor,
      defaultForeground: BCColorsLight.defaultForeground,
      success: BCColorsLight.success,
      successForeground: BCColorsLight.successForeground,
      warning: BCColorsLight.warning,
      warningForeground: BCColorsLight.warningForeground,
      danger: BCColorsLight.danger,
      dangerForeground: BCColorsLight.dangerForeground,
      field: BCColorsLight.field,
      fieldForeground: BCColorsLight.fieldForeground,
      fieldPlaceholder: BCColorsLight.fieldPlaceholder,
      fieldBorder: BCColorsLight.fieldBorder,
      backgroundSecondary: BCColorsLight.backgroundSecondary,
      backgroundTertiary: BCColorsLight.backgroundTertiary,
      backgroundInverse: BCColorsLight.backgroundInverse,
      defaultHover: BCColorsLight.defaultHover,
      accentHover: BCColorsLight.accentHover,
      successHover: BCColorsLight.successHover,
      warningHover: BCColorsLight.warningHover,
      dangerHover: BCColorsLight.dangerHover,
      fieldHover: BCColorsLight.fieldHover,
      fieldFocus: BCColorsLight.fieldFocus,
      fieldBorderHover: BCColorsLight.fieldBorderHover,
      fieldBorderFocus: BCColorsLight.fieldBorderFocus,
      defaultSoft: BCColorsLight.defaultSoft,
      defaultSoftForeground: BCColorsLight.defaultSoftForeground,
      defaultSoftHover: BCColorsLight.defaultSoftHover,
      accentSoft: BCColorsLight.accentSoft,
      accentSoftForeground: BCColorsLight.accentSoftForeground,
      accentSoftHover: BCColorsLight.accentSoftHover,
      dangerSoft: BCColorsLight.dangerSoft,
      dangerSoftForeground: BCColorsLight.dangerSoftForeground,
      dangerSoftHover: BCColorsLight.dangerSoftHover,
      warningSoft: BCColorsLight.warningSoft,
      warningSoftForeground: BCColorsLight.warningSoftForeground,
      warningSoftHover: BCColorsLight.warningSoftHover,
      successSoft: BCColorsLight.successSoft,
      successSoftForeground: BCColorsLight.successSoftForeground,
      successSoftHover: BCColorsLight.successSoftHover,
      separatorSecondary: BCColorsLight.separatorSecondary,
      separatorTertiary: BCColorsLight.separatorTertiary,
      borderSecondary: BCColorsLight.borderSecondary,
      borderTertiary: BCColorsLight.borderTertiary,
      surfaceShadow: BCShadows.surfaceLight,
      overlayShadow: BCShadows.overlayLight,
      fieldShadow: BCShadows.fieldLight,
    );
    if (accent == null) return ext;
    return ext._withAccent(accent);
  }

  /// Default dark palette.
  factory BCThemeExtension.dark({Color? accent}) {
    const ext = BCThemeExtension(
      background: BCColorsDark.background,
      foreground: BCColorsDark.foreground,
      surface: BCColorsDark.surface,
      surfaceForeground: BCColorsDark.surfaceForeground,
      surfaceHover: BCColorsDark.surfaceHover,
      surfaceSecondary: BCColorsDark.surfaceSecondary,
      surfaceSecondaryForeground: BCColorsDark.surfaceSecondaryForeground,
      surfaceTertiary: BCColorsDark.surfaceTertiary,
      surfaceTertiaryForeground: BCColorsDark.surfaceTertiaryForeground,
      overlay: BCColorsDark.overlay,
      overlayForeground: BCColorsDark.overlayForeground,
      backdrop: BCColorsDark.backdrop,
      muted: BCColorsDark.muted,
      accent: BCColorsDark.accent,
      accentForeground: BCColorsDark.accentForeground,
      segment: BCColorsDark.segment,
      segmentForeground: BCColorsDark.segmentForeground,
      border: BCColorsDark.border,
      separator: BCColorsDark.separator,
      focus: BCColorsDark.focus,
      link: BCColorsDark.link,
      defaultColor: BCColorsDark.defaultColor,
      defaultForeground: BCColorsDark.defaultForeground,
      success: BCColorsDark.success,
      successForeground: BCColorsDark.successForeground,
      warning: BCColorsDark.warning,
      warningForeground: BCColorsDark.warningForeground,
      danger: BCColorsDark.danger,
      dangerForeground: BCColorsDark.dangerForeground,
      field: BCColorsDark.field,
      fieldForeground: BCColorsDark.fieldForeground,
      fieldPlaceholder: BCColorsDark.fieldPlaceholder,
      fieldBorder: BCColorsDark.fieldBorder,
      backgroundSecondary: BCColorsDark.backgroundSecondary,
      backgroundTertiary: BCColorsDark.backgroundTertiary,
      backgroundInverse: BCColorsDark.backgroundInverse,
      defaultHover: BCColorsDark.defaultHover,
      accentHover: BCColorsDark.accentHover,
      successHover: BCColorsDark.successHover,
      warningHover: BCColorsDark.warningHover,
      dangerHover: BCColorsDark.dangerHover,
      fieldHover: BCColorsDark.fieldHover,
      fieldFocus: BCColorsDark.fieldFocus,
      fieldBorderHover: BCColorsDark.fieldBorderHover,
      fieldBorderFocus: BCColorsDark.fieldBorderFocus,
      defaultSoft: BCColorsDark.defaultSoft,
      defaultSoftForeground: BCColorsDark.defaultSoftForeground,
      defaultSoftHover: BCColorsDark.defaultSoftHover,
      accentSoft: BCColorsDark.accentSoft,
      accentSoftForeground: BCColorsDark.accentSoftForeground,
      accentSoftHover: BCColorsDark.accentSoftHover,
      dangerSoft: BCColorsDark.dangerSoft,
      dangerSoftForeground: BCColorsDark.dangerSoftForeground,
      dangerSoftHover: BCColorsDark.dangerSoftHover,
      warningSoft: BCColorsDark.warningSoft,
      warningSoftForeground: BCColorsDark.warningSoftForeground,
      warningSoftHover: BCColorsDark.warningSoftHover,
      successSoft: BCColorsDark.successSoft,
      successSoftForeground: BCColorsDark.successSoftForeground,
      successSoftHover: BCColorsDark.successSoftHover,
      separatorSecondary: BCColorsDark.separatorSecondary,
      separatorTertiary: BCColorsDark.separatorTertiary,
      borderSecondary: BCColorsDark.borderSecondary,
      borderTertiary: BCColorsDark.borderTertiary,
      surfaceShadow: BCShadows.surfaceDark,
      overlayShadow: BCShadows.overlayDark,
      fieldShadow: BCShadows.fieldDark,
    );
    if (accent == null) return ext;
    return ext._withAccent(accent);
  }

  /// Recomputes the accent-derived tokens for a custom accent color using
  /// sRGB lerp approximations of HeroUI's oklab color-mix formulas.
  BCThemeExtension _withAccent(Color newAccent) {
    return copyWith(
      accent: newAccent,
      focus: newAccent,
      accentHover: Color.lerp(newAccent, accentForeground, 0.1)!,
      accentSoft: newAccent.withValues(alpha: 0.15),
      accentSoftForeground: Color.lerp(newAccent, foreground, 0.2)!,
      accentSoftHover: newAccent.withValues(alpha: 0.20),
    );
  }

  @override
  BCThemeExtension copyWith({
    Color? background,
    Color? foreground,
    Color? surface,
    Color? surfaceForeground,
    Color? surfaceHover,
    Color? surfaceSecondary,
    Color? surfaceSecondaryForeground,
    Color? surfaceTertiary,
    Color? surfaceTertiaryForeground,
    Color? overlay,
    Color? overlayForeground,
    Color? backdrop,
    Color? muted,
    Color? accent,
    Color? accentForeground,
    Color? segment,
    Color? segmentForeground,
    Color? border,
    Color? separator,
    Color? focus,
    Color? link,
    Color? defaultColor,
    Color? defaultForeground,
    Color? success,
    Color? successForeground,
    Color? warning,
    Color? warningForeground,
    Color? danger,
    Color? dangerForeground,
    Color? field,
    Color? fieldForeground,
    Color? fieldPlaceholder,
    Color? fieldBorder,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? backgroundInverse,
    Color? defaultHover,
    Color? accentHover,
    Color? successHover,
    Color? warningHover,
    Color? dangerHover,
    Color? fieldHover,
    Color? fieldFocus,
    Color? fieldBorderHover,
    Color? fieldBorderFocus,
    Color? defaultSoft,
    Color? defaultSoftForeground,
    Color? defaultSoftHover,
    Color? accentSoft,
    Color? accentSoftForeground,
    Color? accentSoftHover,
    Color? dangerSoft,
    Color? dangerSoftForeground,
    Color? dangerSoftHover,
    Color? warningSoft,
    Color? warningSoftForeground,
    Color? warningSoftHover,
    Color? successSoft,
    Color? successSoftForeground,
    Color? successSoftHover,
    Color? separatorSecondary,
    Color? separatorTertiary,
    Color? borderSecondary,
    Color? borderTertiary,
    BCShadowSet? surfaceShadow,
    BCShadowSet? overlayShadow,
    BCShadowSet? fieldShadow,
    double? borderWidth,
    double? opacityDisabled,
  }) {
    return BCThemeExtension(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      surface: surface ?? this.surface,
      surfaceForeground: surfaceForeground ?? this.surfaceForeground,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceSecondaryForeground: surfaceSecondaryForeground ?? this.surfaceSecondaryForeground,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      surfaceTertiaryForeground: surfaceTertiaryForeground ?? this.surfaceTertiaryForeground,
      overlay: overlay ?? this.overlay,
      overlayForeground: overlayForeground ?? this.overlayForeground,
      backdrop: backdrop ?? this.backdrop,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      segment: segment ?? this.segment,
      segmentForeground: segmentForeground ?? this.segmentForeground,
      border: border ?? this.border,
      separator: separator ?? this.separator,
      focus: focus ?? this.focus,
      link: link ?? this.link,
      defaultColor: defaultColor ?? this.defaultColor,
      defaultForeground: defaultForeground ?? this.defaultForeground,
      success: success ?? this.success,
      successForeground: successForeground ?? this.successForeground,
      warning: warning ?? this.warning,
      warningForeground: warningForeground ?? this.warningForeground,
      danger: danger ?? this.danger,
      dangerForeground: dangerForeground ?? this.dangerForeground,
      field: field ?? this.field,
      fieldForeground: fieldForeground ?? this.fieldForeground,
      fieldPlaceholder: fieldPlaceholder ?? this.fieldPlaceholder,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      backgroundInverse: backgroundInverse ?? this.backgroundInverse,
      defaultHover: defaultHover ?? this.defaultHover,
      accentHover: accentHover ?? this.accentHover,
      successHover: successHover ?? this.successHover,
      warningHover: warningHover ?? this.warningHover,
      dangerHover: dangerHover ?? this.dangerHover,
      fieldHover: fieldHover ?? this.fieldHover,
      fieldFocus: fieldFocus ?? this.fieldFocus,
      fieldBorderHover: fieldBorderHover ?? this.fieldBorderHover,
      fieldBorderFocus: fieldBorderFocus ?? this.fieldBorderFocus,
      defaultSoft: defaultSoft ?? this.defaultSoft,
      defaultSoftForeground: defaultSoftForeground ?? this.defaultSoftForeground,
      defaultSoftHover: defaultSoftHover ?? this.defaultSoftHover,
      accentSoft: accentSoft ?? this.accentSoft,
      accentSoftForeground: accentSoftForeground ?? this.accentSoftForeground,
      accentSoftHover: accentSoftHover ?? this.accentSoftHover,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      dangerSoftForeground: dangerSoftForeground ?? this.dangerSoftForeground,
      dangerSoftHover: dangerSoftHover ?? this.dangerSoftHover,
      warningSoft: warningSoft ?? this.warningSoft,
      warningSoftForeground: warningSoftForeground ?? this.warningSoftForeground,
      warningSoftHover: warningSoftHover ?? this.warningSoftHover,
      successSoft: successSoft ?? this.successSoft,
      successSoftForeground: successSoftForeground ?? this.successSoftForeground,
      successSoftHover: successSoftHover ?? this.successSoftHover,
      separatorSecondary: separatorSecondary ?? this.separatorSecondary,
      separatorTertiary: separatorTertiary ?? this.separatorTertiary,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      borderTertiary: borderTertiary ?? this.borderTertiary,
      surfaceShadow: surfaceShadow ?? this.surfaceShadow,
      overlayShadow: overlayShadow ?? this.overlayShadow,
      fieldShadow: fieldShadow ?? this.fieldShadow,
      borderWidth: borderWidth ?? this.borderWidth,
      opacityDisabled: opacityDisabled ?? this.opacityDisabled,
    );
  }

  @override
  BCThemeExtension lerp(BCThemeExtension? other, double t) {
    if (other == null) return this;
    return BCThemeExtension(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceForeground: Color.lerp(surfaceForeground, other.surfaceForeground, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceSecondaryForeground: Color.lerp(surfaceSecondaryForeground, other.surfaceSecondaryForeground, t)!,
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      surfaceTertiaryForeground: Color.lerp(surfaceTertiaryForeground, other.surfaceTertiaryForeground, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      overlayForeground: Color.lerp(overlayForeground, other.overlayForeground, t)!,
      backdrop: Color.lerp(backdrop, other.backdrop, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground: Color.lerp(accentForeground, other.accentForeground, t)!,
      segment: Color.lerp(segment, other.segment, t)!,
      segmentForeground: Color.lerp(segmentForeground, other.segmentForeground, t)!,
      border: Color.lerp(border, other.border, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      link: Color.lerp(link, other.link, t)!,
      defaultColor: Color.lerp(defaultColor, other.defaultColor, t)!,
      defaultForeground: Color.lerp(defaultForeground, other.defaultForeground, t)!,
      success: Color.lerp(success, other.success, t)!,
      successForeground: Color.lerp(successForeground, other.successForeground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningForeground: Color.lerp(warningForeground, other.warningForeground, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerForeground: Color.lerp(dangerForeground, other.dangerForeground, t)!,
      field: Color.lerp(field, other.field, t)!,
      fieldForeground: Color.lerp(fieldForeground, other.fieldForeground, t)!,
      fieldPlaceholder: Color.lerp(fieldPlaceholder, other.fieldPlaceholder, t)!,
      fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      backgroundTertiary: Color.lerp(backgroundTertiary, other.backgroundTertiary, t)!,
      backgroundInverse: Color.lerp(backgroundInverse, other.backgroundInverse, t)!,
      defaultHover: Color.lerp(defaultHover, other.defaultHover, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      successHover: Color.lerp(successHover, other.successHover, t)!,
      warningHover: Color.lerp(warningHover, other.warningHover, t)!,
      dangerHover: Color.lerp(dangerHover, other.dangerHover, t)!,
      fieldHover: Color.lerp(fieldHover, other.fieldHover, t)!,
      fieldFocus: Color.lerp(fieldFocus, other.fieldFocus, t)!,
      fieldBorderHover: Color.lerp(fieldBorderHover, other.fieldBorderHover, t)!,
      fieldBorderFocus: Color.lerp(fieldBorderFocus, other.fieldBorderFocus, t)!,
      defaultSoft: Color.lerp(defaultSoft, other.defaultSoft, t)!,
      defaultSoftForeground: Color.lerp(defaultSoftForeground, other.defaultSoftForeground, t)!,
      defaultSoftHover: Color.lerp(defaultSoftHover, other.defaultSoftHover, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentSoftForeground: Color.lerp(accentSoftForeground, other.accentSoftForeground, t)!,
      accentSoftHover: Color.lerp(accentSoftHover, other.accentSoftHover, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      dangerSoftForeground: Color.lerp(dangerSoftForeground, other.dangerSoftForeground, t)!,
      dangerSoftHover: Color.lerp(dangerSoftHover, other.dangerSoftHover, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      warningSoftForeground: Color.lerp(warningSoftForeground, other.warningSoftForeground, t)!,
      warningSoftHover: Color.lerp(warningSoftHover, other.warningSoftHover, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      successSoftForeground: Color.lerp(successSoftForeground, other.successSoftForeground, t)!,
      successSoftHover: Color.lerp(successSoftHover, other.successSoftHover, t)!,
      separatorSecondary: Color.lerp(separatorSecondary, other.separatorSecondary, t)!,
      separatorTertiary: Color.lerp(separatorTertiary, other.separatorTertiary, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      borderTertiary: Color.lerp(borderTertiary, other.borderTertiary, t)!,
      surfaceShadow: BCShadowSet.lerp(surfaceShadow, other.surfaceShadow, t)!,
      overlayShadow: BCShadowSet.lerp(overlayShadow, other.overlayShadow, t)!,
      fieldShadow: BCShadowSet.lerp(fieldShadow, other.fieldShadow, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      opacityDisabled: lerpDouble(opacityDisabled, other.opacityDisabled, t)!,
    );
  }
}
