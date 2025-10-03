import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/config/app_config.dart';
import 'package:monica_companion/core/config/environment.dart';
import 'package:monica_companion/features/navigation/widgets/bottom_navigation_bar.dart';
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

  group('App Initialization', () {
    test('should launch app without crashing', () {
      expect(() => const MonicaApp(), returnsNormally);
    });

    testWidgets('should display main navigation on startup', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      expect(find.byType(MonicaBottomNavigationBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    test('should initialize app config without error', () {
      expect(() => AppConfig.packageName, returnsNormally);
      expect(AppConfig.packageName, isNotEmpty);
      expect(
        AppConfig.packageName,
        startsWith('fr.m0hdaCorp.monica_companion'),
      );
    });
  });

  group('Navigation', () {
    testWidgets('should display 3 navigation tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Find navigation bar and check its destinations
      expect(find.byType(MonicaBottomNavigationBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Check that we have exactly 3 navigation destinations
      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.destinations.length, equals(3));
    });

    testWidgets('should use Material 3 navigation bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  group('Visual Theme', () {
    testWidgets('should apply Material 3 theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MonicaApp());

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
    });

    testWidgets('should use Monica brand color', (WidgetTester tester) async {
      await tester.pumpWidget(const MonicaApp());

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      final ColorScheme? colorScheme = app.theme?.colorScheme;

      expect(colorScheme, isNotNull);
      expect(
        colorScheme!.primary.toARGB32(),
        equals(const Color(0xFF6366F1).toARGB32()),
      );
    });
  });

  group('Error Handling', () {
    test('should handle invalid environment configuration', () {
      expect(() {
        EnvironmentConfig.currentEnvironment.name;
      }, returnsNormally);

      expect(EnvironmentConfig.currentEnvironment.name, isNotEmpty);
    });
  });

  group('Layout', () {
    testWidgets('should implement Scaffold layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
  });
}
