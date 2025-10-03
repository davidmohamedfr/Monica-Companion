import 'package:flutter/material.dart';
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

      // Verify the app loaded correctly with navigation bar
      expect(find.byType(NavigationBar), findsOneWidget);
      // Verify navigation tabs are present
      expect(find.text('Contacts'), findsWidgets);
      expect(find.text('Interactions'), findsWidgets);
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('navigation should work correctly', (
      WidgetTester tester,
    ) async {
      // Launch the app using the same method as working tests
      app.main();
      await tester.pumpAndSettle();

      // Verify main navigation bar is displayed
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify we can navigate between tabs
      final interactionsTab = find.text('Interactions').last;
      await tester.tap(interactionsTab);
      await tester.pumpAndSettle();

      // Verify interactions screen is displayed
      expect(find.text('Interactions Screen - Coming Soon'), findsOneWidget);
    });
  });
}
