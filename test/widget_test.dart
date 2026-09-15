import 'package:flutter_test/flutter_test.dart';
import 'package:stayease/main.dart';

void main() {
  testWidgets('StayEase Splash Screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StayEaseApp());

    // Verify presence of branding
    expect(find.text('SANCTUARY MODE'), findsOneWidget);
    expect(find.text('TAP TO ENTER CONCIERGE'), findsOneWidget);
  });
}
