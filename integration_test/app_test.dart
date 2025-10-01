import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monica_companion/core/services/app_initialization_service.dart';

import 'package:monica_companion/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize app services before running tests
    await AppInitializationService.instance.initialize();
  });

  group('App Integration Tests', () {
    testWidgets('app should start without crashing', (
      WidgetTester tester,
    ) async {
      // Launch the app using the same method as working tests
      app.main();
      await tester.pumpAndSettle();

      // Verify the app loaded correctly with actual UI elements
      expect(find.text('Monica Companion'), findsOneWidget);
      expect(find.text('Development Build'), findsOneWidget);
    });

    testWidgets('configuration display should work correctly', (
      WidgetTester tester,
    ) async {
      // Launch the app using the same method as working tests
      app.main();
      await tester.pumpAndSettle();

      // Verify main UI elements are displayed
      expect(find.textContaining('Environment:'), findsOneWidget);
    });
  });
}
