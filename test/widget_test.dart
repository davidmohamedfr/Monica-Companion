import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/main.dart';
import 'package:monica_companion/services/service_locator.dart';

import '../test/helpers/test_helpers.dart';

void main() {
  setUp(() async {
    await TestHelpers.setupServiceLocatorForTests();
  });

  tearDown(() {
    ServiceLocator.instance.clear();
  });

  testWidgets('App launches and displays welcome screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MonicaApp());
    await tester.pumpAndSettle();

    // Verify welcome screen is displayed
    expect(find.text('Monica Companion'), findsWidgets);
    expect(find.text('View Contacts'), findsOneWidget);
  });
}
