import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/interaction_repository.dart';
import 'package:monica_companion/db/models/interaction.dart';
import 'package:monica_companion/db/repositories/sqlite_interaction_repository.dart';

class MockDatabaseInterface extends Mock implements DatabaseInterface {}

void main() {
  late MockDatabaseInterface mockDatabase;
  late InteractionRepository repository;

  setUp(() {
    mockDatabase = MockDatabaseInterface();
    repository = SqliteInteractionRepository(mockDatabase);
  });

  group('SqliteInteractionRepository', () {
    group('findByContactId', () {
      const int testContactId = 123;
      final DateTime testDate = DateTime(2024, 1, 15, 14, 30);

      final List<Interaction> expectedInteractions = <Interaction>[
        Interaction(
          id: 1,
          contactId: testContactId,
          type: 'call',
          date: testDate.toIso8601String(),
          duration: 300, // 5 minutes
          notes: 'Discussed project timeline',
          location: 'Office',
          createdAt: testDate,
        ),
        Interaction(
          id: 2,
          contactId: testContactId,
          type: 'message',
          date: testDate.subtract(const Duration(days: 1)).toIso8601String(),
          notes: 'Quick check-in message',
          createdAt: testDate.subtract(const Duration(days: 1)),
        ),
      ];

      final List<Map<String, dynamic>> mockDatabaseResponse =
          expectedInteractions
              .map((Interaction interaction) => interaction.toMap())
              .toList();

      testWidgets(
        'should return interactions for valid contact ID ordered by date descending',
        (WidgetTester tester) async {
          // Arrange
          when(
            () => mockDatabase.rawQuery(any(), any()),
          ).thenAnswer((_) async => mockDatabaseResponse);

          // Act
          final List<Interaction> result = await repository.findByContactId(
            testContactId,
          );

          // Assert
          expect(result, hasLength(2));
          expect(result, equals(expectedInteractions));

          // Verify correct SQL query was executed
          verify(
            () => mockDatabase.rawQuery(
              '''
        SELECT * FROM interactions
        WHERE contact_id = ?
        ORDER BY date DESC
      ''',
              <dynamic>[testContactId],
            ),
          ).called(1);
        },
      );

      testWidgets(
        'should return empty list when no interactions found for contact',
        (WidgetTester tester) async {
          // Arrange
          const int nonExistentContactId = 999;
          when(
            () => mockDatabase.rawQuery(any(), any()),
          ).thenAnswer((_) async => <Map<String, dynamic>>[]);

          // Act
          final List<Interaction> result = await repository.findByContactId(
            nonExistentContactId,
          );

          // Assert
          expect(result, isEmpty);
          verify(
            () => mockDatabase.rawQuery(any(), <dynamic>[nonExistentContactId]),
          ).called(1);
        },
      );

      testWidgets('should throw DatabaseException when database query fails', (
        WidgetTester tester,
      ) async {
        // Arrange
        const String errorMessage = 'Database connection lost';
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenThrow(Exception(errorMessage));

        // Act & Assert
        expect(
          () => repository.findByContactId(testContactId),
          throwsA(
            isA<DatabaseException>()
                .having(
                  (DatabaseException e) => e.message,
                  'message',
                  'An unexpected error occurred. Please try again.',
                )
                .having(
                  (DatabaseException e) => e.code,
                  'code',
                  'UNKNOWN_ERROR',
                ),
          ),
        );

        verify(
          () => mockDatabase.rawQuery(any(), <dynamic>[testContactId]),
        ).called(1);
      });

      testWidgets('should handle valid data with missing optional fields', (
        WidgetTester tester,
      ) async {
        // Arrange
        final List<Map<String, dynamic>> dataWithNulls = <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'contact_id': testContactId,
            'type': 'call',
            'date': testDate.toIso8601String(),
            'duration': null,
            'notes': null,
            'location': null,
            'created_at': testDate.toIso8601String(),
            'updated_at': null,
          },
        ];

        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => dataWithNulls);

        // Act
        final List<Interaction> result = await repository.findByContactId(
          testContactId,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result.first.id, 1);
        expect(result.first.contactId, testContactId);
        expect(result.first.type, 'call');
        expect(result.first.date, testDate.toIso8601String());
        expect(result.first.duration, isNull);
        expect(result.first.notes, isNull);
        expect(result.first.location, isNull);
      });

      testWidgets('should handle large result sets efficiently', (
        WidgetTester tester,
      ) async {
        // Arrange
        final List<Map<String, dynamic>> largeDataset =
            List<Map<String, dynamic>>.generate(
              100,
              (int index) => Interaction(
                id: index + 1,
                contactId: testContactId,
                type: 'message',
                date: testDate
                    .subtract(Duration(days: index))
                    .toIso8601String(),
                notes: 'Interaction $index',
                createdAt: testDate.subtract(Duration(days: index)),
              ).toMap(),
            );

        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => largeDataset);

        // Act
        final List<Interaction> result = await repository.findByContactId(
          testContactId,
        );

        // Assert
        expect(result, hasLength(100));
        expect(result.first.id, 1);
        expect(result.last.id, 100);

        // Verify all interactions belong to the correct contact
        for (final Interaction interaction in result) {
          expect(interaction.contactId, testContactId);
        }
      });
    });
  });
}
