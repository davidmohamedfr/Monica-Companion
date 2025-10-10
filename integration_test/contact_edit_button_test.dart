import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monica_companion/main.dart' as app;

import 'helpers/integration_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    ..framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  // Disable overflow errors for this test
  IntegrationTestHelpers.disableOverflowErrors();

  group('Contact Edit Button E2E Test', () {
    testWidgets('Edit button should be enabled when WRITE_CONTACTS granted', (
      WidgetTester tester,
    ) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      debugPrint('🚀 App launched successfully');

      // Wait for contacts to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Find first contact
      final Finder contactItems = find.byType(ListTile);
      final int contactCount = contactItems.evaluate().length;
      debugPrint('Found $contactCount contacts on device');

      if (contactCount == 0) {
        debugPrint('⚠️ No contacts found - cannot test edit button');
        return;
      }

      // If we reach here, we have contacts
      expect(contactItems, findsWidgets);
      debugPrint('✅ Verified contact widgets exist');

      // Tap on first contact to open detail screen
      debugPrint('👆 Tapping first contact...');
      await tester.tap(contactItems.first);
      await tester.pumpAndSettle();

      debugPrint('📱 Contact detail screen opened');

      // Look for edit button in AppBar
      final Finder editButton = find.byIcon(Icons.edit);

      if (editButton.evaluate().isEmpty) {
        debugPrint('❌ ISSUE FOUND: Edit button not visible at all');
        debugPrint('   This means the button is conditionally hidden');
        debugPrint('   Checking why...');

        // Check for any IconButton in AppBar
        final Finder allIconButtons = find.byType(IconButton);
        debugPrint(
          '   Found ${allIconButtons.evaluate().length} IconButtons in AppBar',
        );

        // Try to find the disabled block button (issue #65)
        final Finder blockButton = find.byIcon(Icons.block);
        expect(blockButton, findsOneWidget);
        debugPrint('   ✅ Found "block" button (issue #65)');

        debugPrint('');
        debugPrint('🔍 DIAGNOSIS:');
        debugPrint('   Edit button is NOT rendered because condition failed:');
        debugPrint('   if (!_isCheckingReadOnly && !_isReadOnly)');
        debugPrint('');
        debugPrint('   Either:');
        debugPrint('   - _isCheckingReadOnly is true (still loading)');
        debugPrint('   - _isReadOnly is true (contact marked read-only)');
        debugPrint('');
        debugPrint('💡 Need to check ContactsRepository.isContactReadOnly()');
        debugPrint('   and PermissionService.isReadOnlyMode() chain');

        fail('Edit button not rendered - contact is read-only');
      } else {
        debugPrint('✅ Edit button found in AppBar');

        // Find the IconButton that contains the edit icon
        final Finder iconButtonFinder = find.ancestor(
          of: editButton,
          matching: find.byType(IconButton),
        );

        expect(iconButtonFinder, findsOneWidget);

        // Check if button is enabled
        final IconButton editButtonWidget = tester.widget<IconButton>(
          iconButtonFinder,
        );

        if (editButtonWidget.onPressed == null) {
          debugPrint('❌ ISSUE: Edit button is DISABLED');
          fail('Edit button exists but is disabled');
        } else {
          debugPrint('✅ Edit button is ENABLED');

          // Try tapping it
          await tester.tap(iconButtonFinder);
          await tester.pumpAndSettle();

          // Should open edit dialog
          final Finder editDialog = find.byType(AlertDialog);
          expect(editDialog, findsOneWidget);

          debugPrint('✅ Edit dialog opened successfully');
          debugPrint('🎉 TEST PASSED: Edit button works correctly!');
        }
      }
    });
  });
}
