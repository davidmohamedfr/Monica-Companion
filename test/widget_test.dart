// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/navigation/screens/main_shell.dart';
import 'package:monica_companion/main.dart';
import 'package:monica_companion/services/service_locator.dart';

import '../test/helpers/test_helpers.dart';
void main() {
  setUp(() async {
    // Setup service locator with mocks for all tests
    await TestHelpers.setupServiceLocatorForTests();
  });

  tearDown(() {
    // Clear service locator after each test
    ServiceLocator.instance.clear();
  });

  testWidgets('App launches and displays main navigation', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MonicaApp());
    await tester.pumpAndSettle();

    // Verify that our app displays the main navigation interface
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Contacts'), findsWidgets); // Should find in both app bar and navigation
  });
}
