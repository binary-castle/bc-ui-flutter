import 'package:bc_ui/bc_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BCTheme', () {
    test('light theme registers BCThemeExtension with heroui tokens', () {
      final theme = BCTheme.light();
      final ext = theme.extension<BCThemeExtension>();

      expect(ext, isNotNull);
      // Anchor values validated against heroui-native's published palette.
      expect(ext!.accent, const Color(0xFF0485F7));
      expect(ext.success, const Color(0xFF17C964));
      expect(ext.warning, const Color(0xFFF5A524));
      expect(ext.foreground, const Color(0xFF18181B));
      expect(ext.background, const Color(0xFFF5F5F5));
      expect(ext.backdrop, const Color(0x33000000));
      expect(theme.scaffoldBackgroundColor, ext.background);
      expect(theme.colorScheme.primary, ext.accent);
    });

    test('dark theme uses dark palette and inset overlay hairline', () {
      final theme = BCTheme.dark();
      final ext = theme.extension<BCThemeExtension>()!;

      expect(ext.background, const Color(0xFF060607));
      expect(ext.surface, const Color(0xFF18181B));
      expect(ext.surfaceShadow.isEmpty, isTrue);
      expect(ext.overlayShadow.innerBorder, isNotNull);
      expect(ext.overlayShadow.innerBorder!.color, const Color(0x33FFFFFF));
    });

    test('accent override recomputes derived accent tokens', () {
      final theme = BCTheme.light(
        overrides: const BCThemeOverrides(accent: Color(0xFF0F766E)),
      );
      final ext = theme.extension<BCThemeExtension>()!;

      expect(ext.accent, const Color(0xFF0F766E));
      expect(ext.focus, const Color(0xFF0F766E));
      expect(ext.accentSoft.a, closeTo(0.15, 0.01));
      expect(ext.accentSoft.withValues(alpha: 1), const Color(0xFF0F766E));
      // Untouched tokens keep the default palette.
      expect(ext.danger, BCColorsLight.danger);
    });

    test('extension lerp interpolates between light and dark', () {
      final light = BCThemeExtension.light();
      final dark = BCThemeExtension.dark();

      final mid = light.lerp(dark, 1.0);
      expect(mid.background, dark.background);
      expect(light.lerp(dark, 0.0).background, light.background);
    });
  });
}
