import 'package:bc_ui/bc_ui.dart';
import 'package:example/main.dart';
import 'package:example/showcase/showcase_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(WidgetBuilder builder) {
  return MaterialApp(
    theme: BCTheme.light(),
    builder: (context, child) => BCToastProvider(child: child!),
    home: Builder(builder: builder),
  );
}

void main() {
  testWidgets('example app renders home screen', (tester) async {
    await tester.pumpWidget(const BcUiExampleApp());
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('BC UI Components'), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
  });

  for (final entry in componentRegistry) {
    testWidgets('${entry.title} showcase renders', (tester) async {
      await tester.pumpWidget(_host(entry.builder));
      // Allow entrance animations to start; avoid pumpAndSettle since
      // spinners/skeletons animate forever.
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
    });
  }
}
