import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/screens/contact_detail_screen.dart';
import 'package:monica_companion/features/shared/widgets/empty_state_widget.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ContactDetailScreen Tests', () {
    late Contact testContact;

    setUpAll(TestHelpers.setupMockFallbacks);

    setUp(() {
      testContact = const Contact(
        id: 'test-id-123',
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john.doe@example.com',
      );
    });

    testWidgets('should display contact name in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: ContactDetailScreen(contact: testContact)),
      );

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have scrollable content area', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: ContactDetailScreen(contact: testContact)),
      );

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have back button when navigated to', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          ContactDetailScreen(contact: testContact),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      // Tap button to navigate
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('should display Recent Interactions section header', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: ContactDetailScreen(contact: testContact)),
      );

      // Assert
      expect(find.text('Recent Interactions'), findsOneWidget);
    });

    testWidgets('should display empty state for interactions', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: ContactDetailScreen(contact: testContact)),
      );

      // Assert
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No interactions yet'), findsOneWidget);
    });

    testWidgets('should display interactions section below contact info', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: ContactDetailScreen(contact: testContact)),
      );
      await tester.pumpAndSettle();

      // Assert
      final Finder contactInfo = find.byType(CircleAvatar);
      final Finder interactionsHeader = find.text('Recent Interactions');

      expect(contactInfo, findsOneWidget);
      expect(interactionsHeader, findsOneWidget);

      // Verify interactions section is below contact info
      final double contactInfoY = tester.getTopLeft(contactInfo).dy;
      final double interactionsY = tester.getTopLeft(interactionsHeader).dy;

      expect(interactionsY, greaterThan(contactInfoY));
    });
  });
}
