import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/widgets/contact_info_section.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ContactInfoSection Tests', () {
    late Contact fullContact;
    late Contact minimalContact;
    late DateTime testDateTime;

    setUpAll(TestHelpers.setupMockFallbacks);

    setUp(() {
      testDateTime = TestHelpers.createMockDateTime(
        month: 6,
        day: 15,
        hour: 10,
        minute: 30,
      );

      fullContact = Contact(
        id: 'full-id',
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john@example.com',
        notes: 'Important client',
        isFavorite: true,
        lastContactedAt: testDateTime,
      );

      minimalContact = const Contact(id: 'minimal-id', name: 'Jane Smith');
    });

    testWidgets('should display contact avatar', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactInfoSection(contact: fullContact)),
        ),
      );

      // Assert
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should display initials when no photo', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactInfoSection(contact: minimalContact)),
        ),
      );

      // Assert
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('JS'), findsOneWidget);
    });

    testWidgets('should display favorite star for favorite contacts', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactInfoSection(contact: fullContact)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should display phone number with icon', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactInfoSection(contact: fullContact)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
    });

    testWidgets('should display email with icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactInfoSection(contact: fullContact)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('should display notes when present', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactInfoSection(contact: fullContact)),
        ),
      );

      // Assert
      expect(find.text('Important client'), findsOneWidget);
    });

    testWidgets('should hide optional fields when not present', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactInfoSection(contact: minimalContact)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.phone), findsNothing);
      expect(find.byIcon(Icons.email), findsNothing);
    });

    testWidgets('should display last contacted date when available', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ContactInfoSection(contact: fullContact)),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });
  });
}
