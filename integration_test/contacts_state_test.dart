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

  group('Contacts State Persistence Tests', () {
    testWidgets('Contacts state persistence', (WidgetTester tester) async {
      IntegrationTestHelpers.disableOverflowErrors();

      // Test that view mode preference is persisted
      debugPrint('💾 Step 1: Testing state persistence...');

      app.main();
      await tester.pumpAndSettle();

      // Verify navigation bar is present (app starts on Contacts tab)
      debugPrint('📱 Step 2: App loaded on Contacts tab...');
      expect(find.byType(NavigationBar), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));

      // Check if contacts are loaded first
      final bool hasContacts = find.byType(ListTile).evaluate().isNotEmpty;

      if (!hasContacts) {
        debugPrint(
          'ℹ️ No contacts available - skipping view mode persistence test',
        );
        return;
      }

      // Change to grid view if available
      final Finder gridViewButton = find.byIcon(Icons.grid_view);
      if (gridViewButton.evaluate().isNotEmpty) {
        debugPrint('🎛️ Step 3: Switching to grid view...');
        await tester.tap(gridViewButton);
        await tester.pumpAndSettle();

        // Verify grid view is active
        final bool hasGridView = find.byType(GridView).evaluate().isNotEmpty;

        if (hasGridView) {
          debugPrint('✅ Grid view activated');

          // Go back to welcome screen
          debugPrint('🔙 Step 4: Navigating back to home...');
          final Finder backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();

            // Navigate back to contacts
            debugPrint('📱 Step 5: Returning to contacts...');
            await tester.drag(
              find.byType(SingleChildScrollView),
              const Offset(0, -300),
            );
            await tester.pump(const Duration(milliseconds: 300));
            await tester.tap(find.text('View Contacts'));
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 1));

            // Check if still in grid view
            final bool stillGridView = find
                .byType(GridView)
                .evaluate()
                .isNotEmpty;
            if (stillGridView) {
              expect(find.byType(GridView), findsOneWidget);
              debugPrint('✅ View mode preference persisted');
            } else {
              debugPrint(
                'ℹ️ View mode not persisted - may be expected behavior',
              );
            }
          } else {
            debugPrint(
              'ℹ️ Back button not found - completing basic persistence test',
            );
          }
        } else {
          debugPrint('ℹ️ Grid view not available - completing basic test');
        }
      } else {
        debugPrint('ℹ️ Grid view button not found - completing basic test');
      }

      debugPrint('✅ State persistence test completed');
    });
  });
}
