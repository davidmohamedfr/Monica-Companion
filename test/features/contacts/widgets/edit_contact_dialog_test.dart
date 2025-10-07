import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:monica_companion/features/contacts/widgets/edit_contact_dialog.dart';
import 'package:provider/provider.dart';

import '../../../helpers/test_helpers.dart';
import '../../../mocks/mock_services.dart';

void main() {
  group('EditContactDialog Tests', () {
    late Contact testContact;

    setUpAll(() {
      TestHelpers.setupMockFallbacks();
      registerFallbackValue(const Contact(id: 'fallback-id', name: 'Fallback'));
    });

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

    testWidgets('should return updated contact when saved (legacy test)', (
      WidgetTester tester,
    ) async {
      Contact? result;
      final MockContactsRepository mockRepository = MockContactsRepository();

      // Mock successful save
      when(
        () => mockRepository.updateDeviceContact(any()),
      ).thenAnswer((_) async {});

      // Arrange & Act
      await tester.pumpWidget(
        Provider<ContactsRepository>.value(
          value: mockRepository,
          child: MaterialApp(
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

    group('Phase 3: Persistence with User Feedback', () {
      late MockContactsRepository mockRepository;

      setUp(() {
        mockRepository = MockContactsRepository();
      });

      Widget buildTestWidget({required Contact contact}) =>
          Provider<ContactsRepository>.value(
            value: mockRepository,
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (BuildContext context) => ElevatedButton(
                    onPressed: () {
                      showDialog<Contact>(
                        context: context,
                        builder: (BuildContext dialogContext) =>
                            EditContactDialog(contact: contact),
                      );
                    },
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
          );

      testWidgets('should show loading indicator when saving', (
        WidgetTester tester,
      ) async {
        // Arrange - make save operation slow to observe loading state
        when(() => mockRepository.updateDeviceContact(any())).thenAnswer((
          _,
        ) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        await tester.pumpWidget(buildTestWidget(contact: testContact));
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Act - tap save
        await tester.tap(find.text('Save'));
        await tester.pump(); // Start the async operation

        // Assert - loading indicator should be visible
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Clean up - wait for the operation to complete
        await tester.pumpAndSettle();
      });

      testWidgets('should disable save button during loading', (
        WidgetTester tester,
      ) async {
        // Arrange - make save operation slow
        when(() => mockRepository.updateDeviceContact(any())).thenAnswer((
          _,
        ) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        await tester.pumpWidget(buildTestWidget(contact: testContact));
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Act - tap save
        await tester.tap(find.text('Save'));
        await tester.pump(); // Start the async operation

        // Assert - save button should be disabled (onPressed is null)
        // During loading, the button shows CircularProgressIndicator instead of "Save"
        final FilledButton saveButton = tester.widget<FilledButton>(
          find.byType(FilledButton),
        );
        expect(saveButton.onPressed, isNull);

        // Clean up - wait for the operation to complete
        await tester.pumpAndSettle();
      });

      testWidgets('should close dialog with updated contact on success', (
        WidgetTester tester,
      ) async {
        Contact? result;

        // Arrange - successful save
        when(
          () => mockRepository.updateDeviceContact(any()),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(
          Provider<ContactsRepository>.value(
            value: mockRepository,
            child: MaterialApp(
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
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Update name
        await tester.enterText(
          find.widgetWithText(TextFormField, 'John Doe').first,
          'Jane Doe Updated',
        );

        // Act - tap save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - dialog closed with updated contact
        expect(find.byType(EditContactDialog), findsNothing);
        expect(result, isNotNull);
        expect(result!.name, equals('Jane Doe Updated'));
        verify(() => mockRepository.updateDeviceContact(any())).called(1);
      });

      testWidgets(
        'should show error SnackBar and keep dialog open on permission error',
        (WidgetTester tester) async {
          // Arrange - permission error
          when(() => mockRepository.updateDeviceContact(any())).thenThrow(
            const ContactsPermissionException('Contacts permission denied'),
          );

          await tester.pumpWidget(buildTestWidget(contact: testContact));
          await tester.tap(find.text('Open Dialog'));
          await tester.pumpAndSettle();

          // Act - tap save
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          // Assert - SnackBar shows error message
          expect(find.byType(SnackBar), findsOneWidget);
          expect(find.text('Contacts permission denied'), findsOneWidget);

          // Dialog should still be open
          expect(find.byType(EditContactDialog), findsOneWidget);
        },
      );

      testWidgets('should show error SnackBar and keep dialog open on error', (
        WidgetTester tester,
      ) async {
        // Arrange - generic error
        when(
          () => mockRepository.updateDeviceContact(any()),
        ).thenThrow(Exception('Failed to save contact'));

        await tester.pumpWidget(buildTestWidget(contact: testContact));
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Act - tap save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - SnackBar shows error message
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Failed to save contact'), findsOneWidget);

        // Dialog should still be open
        expect(find.byType(EditContactDialog), findsOneWidget);
      });

      testWidgets('should allow retry after error', (
        WidgetTester tester,
      ) async {
        // Arrange - first attempt fails, second succeeds
        var attemptCount = 0;
        when(() => mockRepository.updateDeviceContact(any())).thenAnswer((_) {
          attemptCount++;
          if (attemptCount == 1) {
            throw Exception('Network error');
          }
          return Future<void>.value();
        });

        await tester.pumpWidget(buildTestWidget(contact: testContact));
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Act - first attempt (fails)
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - error shown, dialog still open
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.byType(EditContactDialog), findsOneWidget);

        // Wait for SnackBar to disappear (or pump several frames)
        await tester.pump(const Duration(seconds: 5));

        // Act - retry (succeeds)
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - dialog closed after successful retry
        expect(find.byType(EditContactDialog), findsNothing);
        verify(() => mockRepository.updateDeviceContact(any())).called(2);
      });

      testWidgets('should call repository with updated contact data', (
        WidgetTester tester,
      ) async {
        Contact? savedContact;

        // Arrange - capture the contact being saved
        when(() => mockRepository.updateDeviceContact(any())).thenAnswer((
          Invocation invocation,
        ) {
          savedContact = invocation.positionalArguments[0] as Contact;
          return Future<void>.value();
        });

        await tester.pumpWidget(buildTestWidget(contact: testContact));
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Update all fields - find fields by their index
        final List<TextFormField> fields = tester
            .widgetList<TextFormField>(find.byType(TextFormField))
            .toList();

        // Name field (index 0)
        await tester.enterText(find.byWidget(fields[0]), 'Jane Smith');

        // Phone field (index 1)
        await tester.enterText(find.byWidget(fields[1]), '+9876543210');

        // Email field (index 2)
        await tester.enterText(
          find.byWidget(fields[2]),
          'jane.smith@example.com',
        );

        // Notes field (index 3)
        await tester.enterText(find.byWidget(fields[3]), 'Updated notes');

        // Act - save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - repository called with correct data
        expect(savedContact, isNotNull);
        expect(savedContact!.name, equals('Jane Smith'));
        expect(savedContact!.phone, equals('+9876543210'));
        expect(savedContact!.email, equals('jane.smith@example.com'));
        expect(savedContact!.notes, equals('Updated notes'));
        expect(savedContact!.id, equals(testContact.id));
      });
    });
  });
}
