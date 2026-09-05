import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Cartly app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CartlyApp());

    expect(find.text('Cartly'), findsOneWidget);
    expect(find.text('Shopping List'), findsOneWidget);
  });
}