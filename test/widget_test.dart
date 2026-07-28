import 'package:flutter_test/flutter_test.dart';
import 'package:imh_erp/main.dart';

void main() {
  testWidgets('ERP App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const ImhErpApp());
    expect(find.byType(ImhErpApp), findsOneWidget);
  });
}
