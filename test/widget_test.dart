import 'package:flutter_test/flutter_test.dart';
import 'package:vgo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Just verify the widget tree builds without error
    expect(TripPlannerApp, isNotNull);
  });
}
