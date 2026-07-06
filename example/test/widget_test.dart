import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows component list', (WidgetTester tester) async {
    await tester.pumpWidget(const BcUiExampleApp());

    expect(find.text('BC UI Components'), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
  });
}
