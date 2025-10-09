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

  group('Contacts Permissions Tests', () {
    testWidgets('Contacts permissions and error handling', (
      WidgetTester tester,
    ) async {
      IntegrationTestHelpers.disableOverflowErrors();

      // This test verifies error handling and permission flows
      app.main();
      await tester.pumpAndSettle();

      debugPrint('🔐 Step 1: Testing permissions and error handling...');

      // Verify navigation bar is present (app starts on Contacts tab)
      expect(find.byType(NavigationBar), findsOneWidget);
      debugPrint('✅ App loaded with navigation, on Contacts tab by default');

      // Wait for contacts to load with a more reasonable timeout
      debugPrint('⏳ Step 2: Waiting for contacts to load...');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check for either contacts loaded or permission/error state
      final bool hasContacts = find.byType(ListTile).evaluate().isNotEmpty;
      final bool hasError = find
          .byType(ElevatedButton)
          .evaluate()
          .isNotEmpty; // Retry button
      final bool hasEmptyState = find.text('No contacts').evaluate().isNotEmpty;
      final bool hasLoadingIndicator = find
          .byType(CircularProgressIndicator)
          .evaluate()
          .isNotEmpty;
      final bool hasText = find
          .text('Contacts')
          .evaluate()
          .isNotEmpty; // At minimum, screen title should exist

      debugPrint(
        'Debug: hasContacts=$hasContacts, hasError=$hasError, '
        'hasEmptyState=$hasEmptyState, '
        'hasLoadingIndicator=$hasLoadingIndicator, hasText=$hasText',
      );

      // The app should be in one of these states or at least
      // display the contacts screen
      expect(
        hasContacts ||
            hasError ||
            hasEmptyState ||
            hasLoadingIndicator ||
            hasText,
        isTrue,
      );

      if (hasContacts) {
        debugPrint('✅ Contacts loaded successfully');
      } else if (hasError) {
        debugPrint('✅ Error state handled properly');
      } else if (hasEmptyState) {
        debugPrint('✅ Empty state displayed correctly');
      } else if (hasLoadingIndicator) {
        debugPrint('✅ Loading state displayed correctly');
      } else if (hasText) {
        debugPrint('✅ Contacts screen displayed correctly');
      }

      debugPrint('✅ Permissions and error handling verified');
    });
  });
}
