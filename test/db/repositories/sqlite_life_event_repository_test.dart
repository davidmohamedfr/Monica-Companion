import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/models/life_event.dart';
import 'package:monica_companion/db/repositories/sqlite_life_event_repository.dart';

class MockDatabaseInterface extends Mock implements DatabaseInterface {}

void main() {
  late SqliteLifeEventRepository repository;
  late MockDatabaseInterface mockDatabase;

  const int testContactId = 123;
  const int testLifeEventId = 456;
  const String testEventType = 'birthday';
  final DateTime testDate = DateTime(2024, 1, 15, 10, 30);
  final DateTime futureDate = DateTime(2024, 1, 20, 10, 30);

  final List<Map<String, dynamic>> mockDatabaseResponse =
      <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'contact_id': testContactId,
          'event_type': 'birthday',
          'date': testDate.toIso8601String(),
          'description': "John's 30th birthday",
          'importance': 5,
          'created_at': testDate
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        },
        <String, dynamic>{
          'id': 2,
          'contact_id': testContactId,
          'event_type': 'anniversary',
          'date': futureDate.toIso8601String(),
          'description': 'Wedding anniversary',
          'importance': 4,
          'created_at': testDate.toIso8601String(),
        },
      ];

  final List<LifeEvent> expectedLifeEvents = <LifeEvent>[
    LifeEvent(
      id: 1,
      contactId: testContactId,
      eventType: 'birthday',
      date: testDate.toIso8601String(),
      description: "John's 30th birthday",
      importance: 5,
      createdAt: testDate.subtract(const Duration(days: 1)),
    ),
    LifeEvent(
      id: 2,
      contactId: testContactId,
      eventType: 'anniversary',
      date: futureDate.toIso8601String(),
      description: 'Wedding anniversary',
      importance: 4,
      createdAt: testDate,
    ),
  ];

  setUp(() {
    mockDatabase = MockDatabaseInterface();
    repository = SqliteLifeEventRepository(mockDatabase);
  });

  group('SqliteLifeEventRepository - findByContactId', () {
    testWidgets('should return life events for valid contact ID '
        'ordered by date descending', (WidgetTester tester) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => mockDatabaseResponse);

      final List<LifeEvent> result = await repository.findByContactId(
        testContactId,
      );

      expect(result, hasLength(2));
      expect(result, equals(expectedLifeEvents));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT * FROM life_events
        WHERE contact_id = ?
        ORDER BY date DESC
      ''',
          <dynamic>[testContactId],
        ),
      ).called(1);
    });

    testWidgets(
      'should return empty list when no life events found for contact',
      (WidgetTester tester) async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final List<LifeEvent> result = await repository.findByContactId(
          testContactId,
        );

        expect(result, isEmpty);
      },
    );

    testWidgets('should throw DatabaseException when database query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Database connection failed'));

      expect(
        () => repository.findByContactId(testContactId),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );
    });
  });

  group('SqliteLifeEventRepository - findByEventType', () {
    testWidgets('should return life events with specific event type '
        'ordered by date descending', (WidgetTester tester) async {
      final List<Map<String, dynamic>> birthdayEvents = mockDatabaseResponse
          .where(
            (Map<String, dynamic> event) =>
                event['event_type'] == testEventType,
          )
          .toList();
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => birthdayEvents);

      final List<LifeEvent> result = await repository.findByEventType(
        testEventType,
      );

      expect(result, hasLength(1));
      expect(result.first.eventType, equals(testEventType));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT * FROM life_events
        WHERE event_type = ?
        ORDER BY date DESC
      ''',
          <dynamic>[testEventType],
        ),
      ).called(1);
    });

    testWidgets(
      'should return empty list when no events found for event type',
      (WidgetTester tester) async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final List<LifeEvent> result = await repository.findByEventType(
          'graduation',
        );

        expect(result, isEmpty);
      },
    );

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Event type query failed'));

      expect(
        () => repository.findByEventType(testEventType),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );
    });
  });

  group('SqliteLifeEventRepository - findByDateRange', () {
    testWidgets(
      'should return life events within date range ordered by date descending',
      (WidgetTester tester) async {
        final DateTime startDate = DateTime(2024, 1, 10);
        final DateTime endDate = DateTime(2024, 1, 25);
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => mockDatabaseResponse);

        final List<LifeEvent> result = await repository.findByDateRange(
          startDate,
          endDate,
        );

        expect(result, hasLength(2));
        verify(
          () => mockDatabase.rawQuery(
            '''
        SELECT * FROM life_events
        WHERE date BETWEEN ? AND ?
        ORDER BY date DESC
      ''',
            <dynamic>[startDate.toIso8601String(), endDate.toIso8601String()],
          ),
        ).called(1);
      },
    );

    testWidgets('should return empty list when no events found in date range', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<LifeEvent> result = await repository.findByDateRange(
        DateTime(2025),
        DateTime(2025, 1, 31),
      );

      expect(result, isEmpty);
    });

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Date range query failed'));

      expect(
        () => repository.findByDateRange(
          DateTime.now(),
          DateTime.now().add(const Duration(days: 7)),
        ),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );
    });
  });

  group('SqliteLifeEventRepository - findByImportance', () {
    testWidgets('should return life events with specific importance '
        'ordered by date descending', (WidgetTester tester) async {
      const int targetImportance = 5;
      final List<Map<String, dynamic>> highImportanceEvents =
          mockDatabaseResponse
              .where(
                (Map<String, dynamic> event) =>
                    event['importance'] == targetImportance,
              )
              .toList();
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => highImportanceEvents);

      final List<LifeEvent> result = await repository.findByImportance(
        targetImportance,
      );

      expect(result, hasLength(1));
      expect(result.first.importance, equals(targetImportance));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT * FROM life_events
        WHERE importance = ?
        ORDER BY date DESC
      ''',
          <dynamic>[targetImportance],
        ),
      ).called(1);
    });

    testWidgets(
      'should return empty list when no events found with specified importance',
      (WidgetTester tester) async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final List<LifeEvent> result = await repository.findByImportance(1);

        expect(result, isEmpty);
      },
    );

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Importance query failed'));

      expect(
        () => repository.findByImportance(5),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );
    });
  });

  group('SqliteLifeEventRepository - findUpcomingEvents', () {
    testWidgets('should return upcoming events within specified days '
        'ordered by date ascending', (WidgetTester tester) async {
      const int daysAhead = 7;
      final List<Map<String, dynamic>> upcomingEventsResponse =
          <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 3,
              'contact_id': testContactId,
              'event_type': 'meeting',
              'date': DateTime.now()
                  .add(const Duration(days: 2))
                  .toIso8601String(),
              'description': 'Upcoming meeting',
              'importance': 3,
              'created_at': DateTime.now().toIso8601String(),
            },
          ];
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => upcomingEventsResponse);

      final List<LifeEvent> result = await repository.findUpcomingEvents(
        daysAhead,
      );

      expect(result, hasLength(1));
      verify(
        () => mockDatabase.rawQuery('''
        SELECT * FROM life_events
        WHERE date BETWEEN ? AND ?
        ORDER BY date ASC
      ''', any()),
      ).called(1);
    });

    testWidgets('should return empty list when no upcoming events found', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<LifeEvent> result = await repository.findUpcomingEvents(7);

      expect(result, isEmpty);
    });

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Upcoming events query failed'));

      expect(
        () => repository.findUpcomingEvents(7),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );
    });
  });

  group('SqliteLifeEventRepository - findByImportanceRange', () {
    testWidgets('should return life events within importance range '
        'ordered by importance and date', (WidgetTester tester) async {
      const int minImportance = 3;
      const int maxImportance = 5;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => mockDatabaseResponse);

      final List<LifeEvent> result = await repository.findByImportanceRange(
        minImportance,
        maxImportance,
      );

      expect(result, hasLength(2));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT * FROM life_events
        WHERE importance BETWEEN ? AND ?
        ORDER BY importance DESC, date DESC
      ''',
          <dynamic>[minImportance, maxImportance],
        ),
      ).called(1);
    });

    testWidgets(
      'should return empty list when no events found in importance range',
      (WidgetTester tester) async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final List<LifeEvent> result = await repository.findByImportanceRange(
          1,
          2,
        );

        expect(result, isEmpty);
      },
    );

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Importance range query failed'));

      expect(
        () => repository.findByImportanceRange(1, 5),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );
    });
  });

  group('SqliteLifeEventRepository - countByContactId', () {
    testWidgets('should return correct count of life events for contact', (
      WidgetTester tester,
    ) async {
      when(() => mockDatabase.rawQuery(any(), any())).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          <String, dynamic>{'count': 7},
        ],
      );

      final int result = await repository.countByContactId(testContactId);

      expect(result, equals(7));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT COUNT(*) as count FROM life_events
        WHERE contact_id = ?
      ''',
          <dynamic>[testContactId],
        ),
      ).called(1);
    });

    testWidgets('should return zero when no life events found for contact', (
      WidgetTester tester,
    ) async {
      when(() => mockDatabase.rawQuery(any(), any())).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          <String, dynamic>{'count': 0},
        ],
      );

      final int result = await repository.countByContactId(testContactId);

      expect(result, equals(0));
    });

    testWidgets('should throw DatabaseException when count query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Count query failed'));

      expect(
        () => repository.countByContactId(testContactId),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );
    });
  });

  group('SqliteLifeEventRepository - fromMap', () {
    testWidgets('should correctly convert database map to LifeEvent model', (
      WidgetTester tester,
    ) async {
      final Map<String, dynamic> lifeEventMap = <String, dynamic>{
        'id': testLifeEventId,
        'contact_id': testContactId,
        'event_type': 'graduation',
        'date': testDate.toIso8601String(),
        'description': 'College graduation ceremony',
        'importance': 4,
        'created_at': testDate.toIso8601String(),
      };

      final LifeEvent result = repository.fromMap(lifeEventMap);

      expect(result.id, equals(testLifeEventId));
      expect(result.contactId, equals(testContactId));
      expect(result.eventType, equals('graduation'));
      expect(result.date, equals(testDate.toIso8601String()));
      expect(result.description, equals('College graduation ceremony'));
      expect(result.importance, equals(4));
      expect(result.createdAt, equals(testDate));
    });

    testWidgets(
      'should handle null values correctly when converting from map',
      (WidgetTester tester) async {
        final Map<String, dynamic> lifeEventMap = <String, dynamic>{
          'id': null,
          'contact_id': testContactId,
          'event_type': 'birthday',
          'date': testDate.toIso8601String(),
          'description': null,
          'importance': null,
          'created_at': null,
        };

        final LifeEvent result = repository.fromMap(lifeEventMap);

        expect(result.id, isNull);
        expect(result.contactId, equals(testContactId));
        expect(result.eventType, equals('birthday'));
        expect(result.date, equals(testDate.toIso8601String()));
        expect(result.description, isNull);
        expect(result.importance, equals(1)); // Default value
        expect(result.createdAt, isNull);
      },
    );
  });
}
