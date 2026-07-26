import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BcUiExampleApp());
}

/// App-wide theme mode, toggled from the showcase app bar.
final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

class BcUiExampleApp extends StatelessWidget {
  const BcUiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // Default theme uses bundled Inter (no extra setup required).
          // Custom accent: BCThemeOverrides(accent: Color(0xFF0F766E))
          theme: BCTheme.light(),
          darkTheme: BCTheme.dark(),
          themeMode: mode,
          builder: (context, child) => BCToastProvider(child: child!),
          home: const ShowcaseHomeScreen(),
        );
      },
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () {
        themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
      },
    );
  }
}
