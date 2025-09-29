import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monica_companion/core/services/app_initialization_service.dart';
import 'package:monica_companion/features/calls/screens/calls_screen.dart';
import 'package:monica_companion/features/contacts/screens/contacts_screen.dart';
import 'package:monica_companion/features/navigation/screens/main_shell.dart';
import 'package:monica_companion/features/navigation/widgets/bottom_navigation_bar.dart';
import 'package:monica_companion/features/settings/screens/settings_screen.dart';
import 'package:monica_companion/features/sync/screens/sync_screen.dart';
import 'package:monica_companion/features/sync/widgets/sync_status_card.dart';
import 'package:monica_companion/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize app services before running tests
    await AppInitializationService.instance.initialize();
  });

  group('Navigation Flow Integration Tests', () {
    testWidgets('should navigate between all main tabs', (
      WidgetTester tester,
    ) async {
      // Start the app
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Verify we're on the main shell
      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(MonicaBottomNavigationBar), findsOneWidget);

      // Initially should be on Contacts tab with proper screen content
      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Contacts'),
        ),
        findsOneWidget,
      );
      // Check for contacts screen elements in AppBar
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

      // Navigate to Calls tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Calls'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CallsScreen), findsOneWidget);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Calls')),
        findsOneWidget,
      );
      expect(find.text('Calls Screen - Coming Soon'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.filter_list),
        ),
        findsOneWidget,
      );

      // Navigate to Settings tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );
      expect(find.byType(ListView), findsOneWidget); // Settings has a ListView
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Data & Sync'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      // Navigate to Sync tab
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Sync'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SyncScreen), findsOneWidget);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Sync')),
        findsOneWidget,
      );
      expect(find.byType(SyncStatusCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.refresh),
        ),
        findsOneWidget,
      );
      expect(find.text('Sync Screen - Coming Soon'), findsOneWidget);

      // Navigate back to Contacts
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Contacts'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Contacts'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should maintain navigation state across interactions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Navigate to Settings and verify content
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Data & Sync'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      // Navigate to Sync
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Sync'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Sync')),
        findsOneWidget,
      );

      // Navigate back to Settings
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      // Should still show Settings content
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Data & Sync'), findsOneWidget);
    });

    testWidgets('should handle rapid navigation changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Rapidly switch between tabs
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Calls'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Sync'),
        ),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Contacts'),
        ),
      );
      await tester.pumpAndSettle();

      // Should end up on Contacts tab
      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Contacts'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display proper app bar for each screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Contacts screen app bar
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Contacts'),
        ),
        findsOneWidget,
      );
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

      // Navigate to Calls
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Calls'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Calls')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.filter_list),
        ),
        findsOneWidget,
      );

      // Navigate to Settings
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.search),
        ),
        findsNothing,
      ); // Settings doesn't have search

      // Navigate to Sync
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Sync'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Sync')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.refresh),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should handle screen orientation changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Verify initial layout
      expect(find.byType(MainShell), findsOneWidget);

      // Change orientation to landscape
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpAndSettle();

      // Should still work in landscape
      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(MonicaBottomNavigationBar), findsOneWidget);

      // Navigate while in landscape
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );

      // Reset to portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('should handle navigation errors gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Test navigation resilience by rapid switching
      for (int i = 0; i < 5; i++) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Calls'),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Settings'),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Sync'),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Contacts'),
          ),
        );
      }
      await tester.pumpAndSettle();

      // Should still be functional and not show any error widgets
      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('should maintain state during screen rebuilds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);

      // Force a rebuild by pumping the widget again
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Navigate to Settings again after rebuild to verify state
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      // Should still be functional after rebuild
      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(MonicaBottomNavigationBar), findsOneWidget);
    });

    testWidgets('should handle accessibility navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Verify navigation elements have proper semantics
      final Finder navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);

      // Test that navigation items are accessible
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Contacts'),
          ),
        ),
        isNotNull,
      );
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Calls'),
          ),
        ),
        isNotNull,
      );
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Settings'),
          ),
        ),
        isNotNull,
      );
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Sync'),
          ),
        ),
        isNotNull,
      );

      // Navigate using semantics
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('should handle memory pressure during navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Simulate intensive navigation to test memory handling (reduced cycles)
      for (int cycle = 0; cycle < 5; cycle++) {
        // Navigate through all screens multiple times
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Calls'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Settings'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Sync'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Contacts'),
          ),
        );
        await tester.pumpAndSettle();

        // Force a frame to ensure memory cleanup
        await tester.pump();
      }

      // Should still be functional after intensive navigation
      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(find.byType(MonicaBottomNavigationBar), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('should validate app bar actions work correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Test Contacts screen actions in AppBar
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

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.search),
        ),
      );
      await tester.pump();
      // Should not crash (search not implemented yet)
      expect(find.byType(ContactsScreen), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.add),
        ),
      );
      await tester.pump();
      // Should not crash (add not implemented yet)
      expect(find.byType(ContactsScreen), findsOneWidget);

      // Test Calls screen actions
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Calls'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.filter_list),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.filter_list),
        ),
      );
      await tester.pump();
      // Should not crash (filter not implemented yet)
      expect(find.byType(CallsScreen), findsOneWidget);

      // Test Sync screen actions
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Sync'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.refresh),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.refresh),
        ),
      );
      await tester.pump();
      // Should not crash (manual sync not implemented yet)
      expect(find.byType(SyncScreen), findsOneWidget);
    });
  });
}
