import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/db/interfaces/contact_repository.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/interaction_repository.dart';
import 'package:monica_companion/db/models/contact.dart';
import 'package:monica_companion/db/models/interaction.dart';
import 'package:monica_companion/db/repositories/sqlite_contact_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_interaction_repository.dart';

class MockDatabaseInterface extends Mock implements DatabaseInterface {}

void main() {
  group('Contact-Interaction Integration Tests', () {
    late MockDatabaseInterface mockDatabase;
    late ContactRepository contactRepository;
    late InteractionRepository interactionRepository;

    setUp(() {
      mockDatabase = MockDatabaseInterface();
      contactRepository = SqliteContactRepository(mockDatabase);
      interactionRepository = SqliteInteractionRepository(mockDatabase);
    });

    group('Cross-Entity Data Consistency', () {
      testWidgets(
        'should maintain data consistency when creating contact and interactions',
        (WidgetTester tester) async {
          // Arrange
          const String contactName = 'John Doe';
          const String contactEmail = 'john.doe@example.com';
          final DateTime testDate = DateTime(2024, 1, 15, 14, 30);

          final Contact testContact = Contact(
            id: 1,
            name: contactName,
            email: contactEmail,
            createdAt: testDate,
          );

          final List<Interaction> expectedInteractions = <Interaction>[
            Interaction(
              id: 1,
              contactId: 1,
              type: 'call',
              date: testDate.toIso8601String(),
              duration: 300,
              notes: 'Initial contact call',
              createdAt: testDate,
            ),
            Interaction(
              id: 2,
              contactId: 1,
              type: 'message',
              date: testDate.add(const Duration(hours: 1)).toIso8601String(),
              notes: 'Follow-up message',
              createdAt: testDate.add(const Duration(hours: 1)),
            ),
          ];

          // Mock contact creation and retrieval
          when(
            () => mockDatabase.rawInsert(any(), any()),
          ).thenAnswer((_) async => 1);

          when(() => mockDatabase.rawQuery(any(), any())).thenAnswer((
            Invocation invocation,
          ) async {
            final List<dynamic> args =
                invocation.positionalArguments[1] as List<dynamic>;
            if (args.contains(contactEmail)) {
              return <Map<String, dynamic>>[testContact.toMap()];
            }
            if (args.contains(1)) {
              return expectedInteractions
                  .map((Interaction i) => i.toMap())
                  .toList();
            }
            return <Map<String, dynamic>>[];
          });

          // Act - Create contact and interactions
          await contactRepository.insert(testContact);
          for (final Interaction interaction in expectedInteractions) {
            await interactionRepository.insert(interaction);
          }

          // Verify data consistency
          final List<Contact> retrievedContacts = await contactRepository
              .findByEmail(contactEmail);
          final List<Interaction> retrievedInteractions =
              await interactionRepository.findByContactId(1);

          // Assert
          expect(retrievedContacts, hasLength(1));
          expect(retrievedContacts.first.name, contactName);
          expect(retrievedContacts.first.email, contactEmail);

          expect(retrievedInteractions, hasLength(2));
          expect(
            retrievedInteractions.every((Interaction i) => i.contactId == 1),
            isTrue,
          );

          // Verify proper method calls were made
          verify(
            () => mockDatabase.rawInsert(any(), any()),
          ).called(greaterThan(0));
          verify(() => mockDatabase.rawQuery(any(), any())).called(2);
        },
      );

      testWidgets('should handle referential integrity constraints', (
        WidgetTester tester,
      ) async {
        // Arrange
        const int nonExistentContactId = 999;

        final Interaction orphanedInteraction = Interaction(
          contactId: nonExistentContactId,
          type: 'call',
          date: DateTime.now().toIso8601String(),
          createdAt: DateTime.now(),
        );

        // Mock database constraint violation
        when(() => mockDatabase.rawInsert(any(), any())).thenThrow(
          Exception('FOREIGN KEY constraint failed: no such contact_id'),
        );

        // Act & Assert - Should throw appropriate exception for referential integrity violation
        await expectLater(
          interactionRepository.insert(orphanedInteraction),
          throwsA(
            isA<DatabaseException>()
                .having(
                  (DatabaseException e) => e.message,
                  'message',
                  'Failed to insert entity: Exception: FOREIGN KEY constraint failed: no such contact_id',
                )
                .having((DatabaseException e) => e.code, 'code', isNull),
          ),
        );

        verify(() => mockDatabase.rawInsert(any(), any())).called(1);
      });

      testWidgets('should handle bulk operations with data consistency', (
        WidgetTester tester,
      ) async {
        // Arrange
        const int contactId = 1;
        final List<Interaction> bulkInteractions = List<Interaction>.generate(
          5,
          (int index) => Interaction(
            id: index + 1,
            contactId: contactId,
            type: 'bulk_message',
            date: DateTime.now()
                .add(Duration(minutes: index))
                .toIso8601String(),
            notes: 'Bulk interaction ${index + 1}',
            createdAt: DateTime.now().add(Duration(minutes: index)),
          ),
        );

        // Mock bulk insertion and retrieval
        when(
          () => mockDatabase.rawInsert(any(), any()),
        ).thenAnswer((_) async => 1);

        when(() => mockDatabase.rawQuery(any(), any())).thenAnswer(
          (_) async =>
              bulkInteractions.map((Interaction i) => i.toMap()).toList(),
        );

        // Act - Bulk create interactions
        for (final Interaction interaction in bulkInteractions) {
          await interactionRepository.insert(interaction);
        }

        final List<Interaction> retrievedInteractions =
            await interactionRepository.findByContactId(contactId);

        // Assert
        expect(retrievedInteractions, hasLength(5));
        expect(
          retrievedInteractions.every(
            (Interaction i) => i.contactId == contactId,
          ),
          isTrue,
        );
        expect(
          retrievedInteractions.every(
            (Interaction i) => i.type == 'bulk_message',
          ),
          isTrue,
        );

        // Verify bulk operations executed correctly
        verify(() => mockDatabase.rawInsert(any(), any())).called(5);
        verify(() => mockDatabase.rawQuery(any(), any())).called(1);
      });
    });

    group('Error Handling and Recovery', () {
      testWidgets(
        'should handle database timeout gracefully across repositories',
        (WidgetTester tester) async {
          // Arrange
          when(
            () => mockDatabase.rawQuery(any(), any()),
          ).thenThrow(Exception('database is locked'));

          when(
            () => mockDatabase.rawExecute(any(), any()),
          ).thenThrow(Exception('database is locked'));

          // Act & Assert - Both repositories should handle timeout consistently
          await expectLater(
            contactRepository.findByEmail('test@example.com'),
            throwsA(
              isA<DatabaseException>()
                  .having(
                    (DatabaseException e) => e.message,
                    'message',
                    'Database is currently busy. Please try again.',
                  )
                  .having(
                    (DatabaseException e) => e.code,
                    'code',
                    'DATABASE_BUSY',
                  ),
            ),
          );

          await expectLater(
            interactionRepository.findByContactId(1),
            throwsA(
              isA<DatabaseException>()
                  .having(
                    (DatabaseException e) => e.message,
                    'message',
                    'Database is currently busy. Please try again.',
                  )
                  .having(
                    (DatabaseException e) => e.code,
                    'code',
                    'DATABASE_BUSY',
                  ),
            ),
          );
        },
      );

      testWidgets(
        'should recover from partial failures in multi-repository operations',
        (WidgetTester tester) async {
          // Arrange
          final Contact testContact = Contact(
            name: 'Recovery Test',
            email: 'recovery@test.com',
            createdAt: DateTime.now(),
          );

          // Mock contact creation success
          when(
            () => mockDatabase.rawInsert(any(), any()),
          ).thenAnswer((_) async => 1);

          // Act - Contact creation should succeed
          await expectLater(contactRepository.insert(testContact), completes);

          // Mock interaction creation failure
          when(
            () => mockDatabase.rawInsert(any(), any()),
          ).thenThrow(Exception('Temporary failure'));

          // Interaction creation should fail with proper error handling
          await expectLater(
            interactionRepository.insert(
              Interaction(
                contactId: 1,
                type: 'test',
                date: DateTime.now().toIso8601String(),
                createdAt: DateTime.now(),
              ),
            ),
            throwsA(isA<DatabaseException>()),
          );

          // Assert - Verify operations were attempted
          verify(
            () => mockDatabase.rawInsert(any(), any()),
          ).called(greaterThan(0));
        },
      );
    });
  });
}
