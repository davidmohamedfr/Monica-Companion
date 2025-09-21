import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:monica_companion/main.dart';
import 'helpers/integration_test_helpers.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestHelpers.setupIntegrationTest();

  group('App Integration Tests', () {
    testWidgets('app should start without crashing', (
      WidgetTester tester,
    ) async {
      // Launch the actual Monica app
      await tester.pumpWidget(const MonicaApp());

      await IntegrationTestHelpers.waitForAppToLoad(tester);

      // Verify the app loaded correctly with actual UI elements
      expect(find.text('Monica Companion'), findsOneWidget);
      expect(find.text('Development Build'), findsOneWidget);

      // Take screenshot for test documentation
      await IntegrationTestHelpers.takeScreenshot(binding, 'app_startup');
    });

    testWidgets('configuration display should work correctly', (
      WidgetTester tester,
    ) async {
      // Launch the actual Monica app
      await tester.pumpWidget(const MonicaApp());

      await IntegrationTestHelpers.waitForAppToLoad(tester);

      // Verify main UI elements are displayed
      expect(find.text('Monica Companion'), findsOneWidget);
      expect(find.text('Development Build'), findsOneWidget);

      // Verify tagline and description exist
      expect(
        find.text('Personal relationships, perfectly managed'),
        findsOneWidget,
      );
      expect(find.textContaining('Environment:'), findsOneWidget);

      await IntegrationTestHelpers.takeScreenshot(
        binding,
        'configuration_display',
      );
    });
  });
}
