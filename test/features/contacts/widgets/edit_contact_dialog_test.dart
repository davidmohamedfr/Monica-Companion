import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/widgets/edit_contact_dialog.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('EditContactDialog Tests', () {
    late Contact testContact;

    setUpAll(TestHelpers.setupMockFallbacks);

    setUp(() {
      testContact = const Contact(
        id: 'test-id-123',
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john.doe@example.com',
        notes: 'Test notes',
      );
    });

    testWidgets('should display dialog with pre-filled form fields', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () {
                  showDialog<Contact>(
                    context: context,
                    builder: (BuildContext context) =>
                        EditContactDialog(contact: testContact),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EditContactDialog), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('Test notes'), findsOneWidget);
    });

    testWidgets('should have name field marked as required', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () {
                  showDialog<Contact>(
                    context: context,
                    builder: (BuildContext context) =>
                        EditContactDialog(contact: testContact),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Clear name field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'John Doe').first,
        '',
      );

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert - error message should appear
      expect(find.textContaining('required'), findsOneWidget);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () {
                  showDialog<Contact>(
                    context: context,
                    builder: (BuildContext context) =>
                        EditContactDialog(contact: testContact),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Enter invalid email
      final Finder emailField = find.widgetWithText(
        TextFormField,
        'john.doe@example.com',
      );
      await tester.enterText(emailField, 'invalid-email');

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert - error message should appear
      expect(find.textContaining('valid email'), findsOneWidget);
    });

    testWidgets('should have Save and Cancel buttons', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () {
                  showDialog<Contact>(
                    context: context,
                    builder: (BuildContext context) =>
                        EditContactDialog(contact: testContact),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should close dialog when Cancel is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () {
                  showDialog<Contact>(
                    context: context,
                    builder: (BuildContext context) =>
                        EditContactDialog(contact: testContact),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - dialog should be closed
      expect(find.byType(EditContactDialog), findsNothing);
    });

    testWidgets('should return updated contact when saved', (
      WidgetTester tester,
    ) async {
      Contact? result;

      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<Contact>(
                    context: context,
                    builder: (BuildContext context) =>
                        EditContactDialog(contact: testContact),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Update name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'John Doe').first,
        'Jane Doe Updated',
      );

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNotNull);
      expect(result!.name, equals('Jane Doe Updated'));
      expect(result!.id, equals(testContact.id));
    });
  });
}
