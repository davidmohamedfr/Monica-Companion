import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:monica_mobile_app/main.dart';
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
      expect(find.text('Environment Configuration'), findsOneWidget);
      expect(find.text('Feature Flags'), findsOneWidget);

      // Take screenshot for test documentation
      await IntegrationTestHelpers.takeScreenshot(binding, 'app_startup');
    });

    testWidgets('configuration display should work correctly', (
      WidgetTester tester,
    ) async {
      // Launch the actual Monica app
      await tester.pumpWidget(const MonicaApp());

      await IntegrationTestHelpers.waitForAppToLoad(tester);

      // Verify configuration sections are displayed
      expect(find.text('Environment Configuration'), findsOneWidget);
      expect(find.text('Feature Flags'), findsOneWidget);

      // Verify some configuration items exist
      expect(find.text('Environment:'), findsOneWidget);
      expect(find.text('App Name:'), findsOneWidget);

      await IntegrationTestHelpers.takeScreenshot(
        binding,
        'configuration_display',
      );
    });
  });
}
