import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monica_companion/main.dart' as app;
import 'helpers/integration_test_helpers.dart';

void main() {
  // Setup: Uses setupWithPermissions() because tests call app.main()
  // which handles AppInitializationService internally
  setUpAll(() async {
    await IntegrationTestHelpers.setupWithPermissions();
  });

  group('App Integration Tests', () {
    testWidgets('app should start without crashing', (
      WidgetTester tester,
    ) async {
      // Launch the app using the same method as working tests
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for app to fully initialize
      await tester.pump();
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
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for app to fully initialize
      await tester.pump();
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
