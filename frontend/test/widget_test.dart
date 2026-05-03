import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Smoke test for ExpenseTrackerApp', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    expect(find.byType(ExpenseTrackerApp), findsOneWidget);
  });
}
