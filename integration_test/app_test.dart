import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monica_companion/core/services/app_initialization_service.dart';

import 'package:monica_companion/main.dart';
import 'helpers/integration_test_helpers.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestHelpers.setupIntegrationTest();

  setUpAll(() async {
    // Initialize app services before running tests
    await AppInitializationService.instance.initialize();
  });

  group('App Integration Tests', () {
    testWidgets('app should start without crashing', (
      WidgetTester tester,
    ) async {
      // Launch the actual Monica app
      await tester.pumpWidget(const MonicaApp());

      await IntegrationTestHelpers.waitForAppToLoad(tester);

      // Verify the app loaded correctly with actual UI elements
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.search),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.add),
        ),
        findsOneWidget,
      );

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
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.search),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.add),
        ),
        findsOneWidget,
      );

      // Verify navigation elements exist in bottom navigation
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Calls'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Sync'),
        ),
        findsOneWidget,
      );

      await IntegrationTestHelpers.takeScreenshot(
        binding,
        'configuration_display',
      );
    });
  });
}
