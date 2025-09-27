import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/navigation/screens/main_shell.dart';
import 'package:monica_companion/features/navigation/widgets/bottom_navigation_bar.dart';
import 'package:monica_companion/features/contacts/screens/contacts_screen.dart';
import 'package:monica_companion/features/calls/screens/calls_screen.dart';
import 'package:monica_companion/features/settings/screens/settings_screen.dart';
import 'package:monica_companion/features/sync/screens/sync_screen.dart';
import 'package:monica_companion/features/sync/widgets/sync_status_card.dart';
import 'package:monica_companion/services/service_locator.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUp(() async {
    // Setup service locator with mocks for all tests
    await TestHelpers.setupServiceLocatorForTests();
  });

  tearDown(() {
    // Clear service locator after each test
    ServiceLocator.instance.clear();
  });
  group('MainShell Widget Tests', () {
    testWidgets('should display MainShell with bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainShell(),
        ),
      );

      // Verify that MainShell is displayed
      expect(find.byType(MainShell), findsOneWidget);

      // Verify that bottom navigation bar is present
      expect(find.byType(MonicaBottomNavigationBar), findsOneWidget);

      // Verify navigation destinations are present within NavigationBar
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Contacts')), findsOneWidget);
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Calls')), findsOneWidget);
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Settings')), findsOneWidget);
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Sync')), findsOneWidget);
    });

    testWidgets('should switch between tabs when navigation items are tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainShell(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially should show Contacts screen (check app bar title and screen type)
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Contacts')), findsOneWidget);
      expect(find.byType(ContactsScreen), findsOneWidget);

      // Tap on Calls tab
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Calls')));
      await tester.pumpAndSettle();

      // Should now show Calls screen with proper content
      expect(find.byType(CallsScreen), findsOneWidget);
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Calls')), findsOneWidget);
      expect(find.text('Calls Screen - Coming Soon'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);

      // Tap on Settings tab
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Settings')));
      await tester.pumpAndSettle();

      // Should now show Settings screen with proper content
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Settings')), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Data & Sync'), findsOneWidget);

      // Tap on Sync tab
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Sync')));
      await tester.pumpAndSettle();

      // Should now show Sync screen with proper content
      expect(find.byType(SyncScreen), findsOneWidget);
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Sync')), findsOneWidget);
      expect(find.byType(SyncStatusCard), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should maintain navigation state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainShell(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Settings')));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Settings')), findsOneWidget);

      // Navigate to Calls
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Calls')));
      await tester.pumpAndSettle();

      expect(find.byType(CallsScreen), findsOneWidget);
      expect(find.text('Calls Screen - Coming Soon'), findsOneWidget);

      // Navigate back to Settings
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Settings')));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Settings')), findsOneWidget);
    });

    testWidgets('should handle navigation resilience during screen transitions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainShell(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all screens can be navigated to without crashes
      final List<String> screens = ['Calls', 'Settings', 'Sync', 'Contacts'];

      for (final String screen in screens) {
        await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(screen)));
        await tester.pumpAndSettle();

        // Verify navigation worked and screen is displayed
        expect(find.byType(MainShell), findsOneWidget);
        expect(find.byType(MonicaBottomNavigationBar), findsOneWidget);
        expect(find.descendant(of: find.byType(AppBar), matching: find.text(screen)), findsOneWidget);

        // Verify no error widgets are present
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });

    testWidgets('should maintain proper state after rapid navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainShell(),
        ),
      );

      // Don't wait for settle to simulate rapid tapping
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Calls')));
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Settings')));
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Sync')));
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Contacts')));

      // Now wait for everything to settle
      await tester.pumpAndSettle();

      // Should end up on the last tapped screen (Contacts)
      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Contacts')), findsOneWidget);
      expect(find.byType(MainShell), findsOneWidget);
    });
  });

  group('MonicaBottomNavigationBar Widget Tests', () {
    testWidgets('should display all navigation destinations', (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MonicaBottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (int index) => selectedIndex = index,
            ),
          ),
        ),
      );

      // Verify all navigation items are present
      // Since currentIndex is 0, Contacts should show selected icon
      expect(find.byIcon(Icons.contacts), findsOneWidget);
      expect(find.byIcon(Icons.call_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.sync_outlined), findsOneWidget);

      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Contacts')), findsOneWidget);
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Calls')), findsOneWidget);
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Settings')), findsOneWidget);
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('Sync')), findsOneWidget);
    });

    testWidgets('should call onTap callback when navigation item is tapped', (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MonicaBottomNavigationBar(
              currentIndex: 0,
              onTap: (int index) => tappedIndex = index,
            ),
          ),
        ),
      );

      // Tap on Calls tab (index 1)
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Calls')));
      await tester.pump();

      expect(tappedIndex, 1);
    });
  });
}