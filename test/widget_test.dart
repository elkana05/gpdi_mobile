import 'package:flutter_test/flutter_test.dart';
import 'package:gpdi_mobile/main.dart';

void main() {
  testWidgets('app opens to home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GPdISibuleleApp());
    await tester.pumpAndSettle();

    expect(find.text('GPdI Sibulele'), findsOneWidget);
    expect(find.text('Syalom, selamat melayani!'), findsOneWidget);
  });
}
