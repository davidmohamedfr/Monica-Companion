import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/config/app_config.dart';
import 'package:monica_companion/core/config/environment.dart';
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

    testWidgets('should display welcome screen on startup', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      expect(find.text('Monica Companion'), findsWidgets);
      expect(find.text('Development Build'), findsOneWidget);
    });

    testWidgets('should display app branding', (WidgetTester tester) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(
        find.text('Personal relationships, perfectly managed'),
        findsOneWidget,
      );
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

  group('Welcome Screen', () {
    testWidgets('should display welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Welcome to Monica Companion'),
        findsOneWidget,
      );
    });

    testWidgets('should display environment info', (WidgetTester tester) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      expect(find.text('Development Build'), findsOneWidget);
      expect(find.textContaining('Environment:'), findsOneWidget);
    });

    testWidgets('should display contacts navigation button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      expect(find.text('View Contacts'), findsOneWidget);
      expect(find.byIcon(Icons.contacts), findsOneWidget);
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
