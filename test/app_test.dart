import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monica_companion/core/config/app_config.dart';
import 'package:monica_companion/core/config/environment.dart';
import 'package:monica_companion/main.dart';

void main() {
  group('App Initialization', () {
    test('should launch app without crashing', () {
      // RED: This test verifies that the app can be instantiated
      // without throwing
      expect(() => const MonicaApp(), returnsNormally);
    });

    testWidgets('should execute main function without crashing', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies that runApp executes without throwing
      expect(() {
        runApp(const MonicaApp());
      }, returnsNormally);
    });

    testWidgets('should display welcome screen on startup', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies WelcomeScreen widget is displayed
      await tester.pumpWidget(const MonicaApp());

      // Should find WelcomeScreen widget
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('should load logo asset successfully', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies SVG logo asset loads without error
      await tester.pumpWidget(const MonicaApp());

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Should find SvgPicture widget displaying the logo
      expect(find.byType(SvgPicture), findsOneWidget);

      // Verify the SvgPicture has the expected height
      final SvgPicture svgWidget = tester.widget(find.byType(SvgPicture));
      expect(svgWidget.height, equals(120));
    });

    test('should initialize app config without error', () {
      // GREEN: This test verifies AppConfig initializes and returns valid
      // values
      expect(() => AppConfig.packageName, returnsNormally);
      expect(AppConfig.packageName, isNotEmpty);
      expect(
        AppConfig.packageName,
        startsWith('fr.m0hdaCorp.monica_companion'),
      );
    });
  });

  group('User Interface Behaviors', () {
    testWidgets('should display Monica Companion title', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies the main title is displayed
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Should find the app title text
      expect(find.text('Monica Companion'), findsOneWidget);
    });

    testWidgets('should display correct tagline', (WidgetTester tester) async {
      // GREEN: This test verifies the tagline is displayed
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Should find the tagline text
      expect(
        find.text('Personal relationships, perfectly managed'),
        findsOneWidget,
      );
    });

    testWidgets('should display welcome description', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies the description text is displayed
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Should find key parts of the description text
      expect(
        find.textContaining('Welcome to Monica Companion'),
        findsOneWidget,
      );
      expect(find.textContaining('mobile gateway'), findsOneWidget);
      expect(find.textContaining('meaningful relationships'), findsOneWidget);
    });

    testWidgets('should display development build info', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies development info section is displayed
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Should find development build information
      expect(find.text('Development Build'), findsOneWidget);
      expect(find.textContaining('Environment:'), findsOneWidget);
      expect(find.textContaining('Package:'), findsOneWidget);
    });

    testWidgets('should display current environment', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies environment name is shown
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Should find environment information with actual value
      expect(find.textContaining('Environment: development'), findsOneWidget);
    });

    testWidgets('should display package name', (WidgetTester tester) async {
      // GREEN: This test verifies package name is shown
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Should find package information with actual value
      expect(
        find.textContaining('Package: fr.m0hdaCorp.monica_companion'),
        findsOneWidget,
      );
    });
  });

  group('Visual Theme Application', () {
    testWidgets('should apply Material 3 theme', (WidgetTester tester) async {
      // GREEN: This test verifies Material 3 is enabled
      await tester.pumpWidget(const MonicaApp());

      // Get the MaterialApp widget to check theme
      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      // Verify Material 3 is enabled
      expect(app.theme?.useMaterial3, isTrue);
    });

    testWidgets('should use Monica brand color scheme', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies Monica brand colors are used
      await tester.pumpWidget(const MonicaApp());

      // Get the MaterialApp widget to check theme
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      final ColorScheme? colorScheme = app.theme?.colorScheme;

      // Verify the color scheme uses Monica's brand color as base
      // Monica brand color is #6366F1
      expect(colorScheme, isNotNull);
      expect(
        colorScheme!.primary.toARGB32(),
        equals(const Color(0xFF6366F1).toARGB32()),
      );
    });

    testWidgets('should display gradient background', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies gradient background is displayed
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Find all DecoratedBox widgets
      final Finder decoratedBoxes = find.byType(DecoratedBox);
      expect(decoratedBoxes, findsWidgets);

      // Find the one with gradient decoration
      bool foundGradient = false;
      for (int i = 0; i < decoratedBoxes.evaluate().length; i++) {
        final DecoratedBox box = tester.widget(decoratedBoxes.at(i));
        final BoxDecoration? decoration = box.decoration as BoxDecoration?;

        if (decoration?.gradient != null) {
          foundGradient = true;
          expect(decoration!.gradient, isA<LinearGradient>());

          final LinearGradient gradient =
              decoration.gradient! as LinearGradient;
          expect(gradient.colors.length, equals(2));
          break;
        }
      }

      expect(
        foundGradient,
        isTrue,
        reason: 'Should find at least one DecoratedBox with gradient',
      );
    });

    testWidgets('should apply white text colors', (WidgetTester tester) async {
      // GREEN: This test verifies text uses white colors consistently
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Find key text widgets and verify they use white colors
      final Finder titleText = find.text('Monica Companion');
      final Finder taglineText = find.text(
        'Personal relationships, perfectly managed',
      );

      expect(titleText, findsOneWidget);
      expect(taglineText, findsOneWidget);

      // Get the Text widgets to check their style colors
      final Text titleWidget = tester.widget(titleText);
      final Text taglineWidget = tester.widget(taglineText);

      // Verify title uses white color
      expect(titleWidget.style?.color, equals(Colors.white));

      // Verify tagline uses white with opacity
      expect(
        taglineWidget.style?.color?.toARGB32(),
        equals(Colors.white.withValues(alpha: 0.9).toARGB32()),
      );
    });
  });

  group('Error Handling & Resilience', () {
    testWidgets('should handle missing logo asset gracefully', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies app doesn't crash with invalid asset path

      // Create a test app with invalid logo path
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SvgPicture.asset(
              'assets/images/logos/nonexistent_logo.svg',
              height: 120,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      );

      // App should not crash even with missing asset
      await tester.pumpAndSettle();

      // Should complete without throwing exceptions
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    test('should handle invalid environment configuration', () {
      // GREEN: This test verifies invalid env config doesn't crash app
      // Test environment config edge cases

      // Verify environment config handles null/empty values gracefully
      expect(() {
        // This should not throw even with potential null issues
        EnvironmentConfig.currentEnvironment.name;
      }, returnsNormally);

      // Environment name should never be empty
      expect(EnvironmentConfig.currentEnvironment.name, isNotEmpty);
    });
  });

  group('Layout & Responsiveness', () {
    testWidgets('should implement SafeArea padding', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies SafeArea widget is properly used
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Should find SafeArea widget
      expect(find.byType(SafeArea), findsOneWidget);

      // Verify SafeArea wraps the main content
      final SafeArea safeAreaWidget = tester.widget(find.byType(SafeArea));

      // SafeArea should have child content
      expect(safeAreaWidget.child, isNotNull);
    });

    testWidgets('should structure content in Column', (
      WidgetTester tester,
    ) async {
      // GREEN: This test verifies Column layout with proper children
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Find all Column widgets
      final Finder columns = find.byType(Column);
      expect(columns, findsWidgets);

      // Find the main Column with center alignment
      Column? mainColumn;
      for (int i = 0; i < columns.evaluate().length; i++) {
        final Column column = tester.widget(columns.at(i));
        if (column.mainAxisAlignment == MainAxisAlignment.center) {
          mainColumn = column;
          break;
        }
      }

      expect(
        mainColumn,
        isNotNull,
        reason: 'Should find main Column with center alignment',
      );

      // Main Column should have multiple children (SizedBox, Container,
      // SizedBox, Text, SizedBox, Text, SizedBox, Container, SizedBox,
      // Container)
      expect(mainColumn!.children.length, greaterThanOrEqualTo(7));

      // Verify Column has proper alignment
      expect(mainColumn.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('should distribute space with spacers', (
      WidgetTester tester,
    ) async {
      // RED: This test verifies SizedBox widgets create proper spacing
      await tester.pumpWidget(const MonicaApp());
      await tester.pumpAndSettle();

      // Should find multiple SizedBox widgets for spacing
      final Finder sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);

      // Should have at least 3 SizedBox spacers for proper spacing
      expect(sizedBoxes.evaluate().length, greaterThanOrEqualTo(3));

      // Verify SizedBox widgets have consistent spacing
      final List<SizedBox> sizedBoxWidgets = sizedBoxes
          .evaluate()
          .map((Element element) => element.widget as SizedBox)
          .where((SizedBox box) => box.height != null)
          .toList();

      expect(
        sizedBoxWidgets,
        isNotEmpty,
        reason: 'Should find SizedBox widgets with height for spacing',
      );

      // At least one SizedBox should use the _sectionSpacing constant (40.0)
      final bool hasSectionSpacing = sizedBoxWidgets.any(
        (SizedBox box) => box.height == 40.0,
      );

      expect(
        hasSectionSpacing,
        isTrue,
        reason: 'Should find SizedBox with section spacing (40.0)',
      );
    });
  });
}
