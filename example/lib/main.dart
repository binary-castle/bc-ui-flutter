import 'package:bc_ui/bc_ui.dart';
import 'package:example/showcase/showcase_home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BcUiExampleApp());
}

/// Builds [BCTheme] inside [build] so [GoogleFonts] runs after binding init.
class BcUiExampleApp extends StatelessWidget {
  const BcUiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: BCTheme.light(
        overrides: const BCThemeOverrides(
          primary: Color(0xFF0F766E),
          secondary: Color(0xFF7C3AED),
        ),
      ),
      darkTheme: BCTheme.dark(),
      home: const ShowcaseHomeScreen(),
    );
  }
}
