import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/models/task.dart';
import 'package:monica_companion/db/repositories/sqlite_task_repository.dart';

class MockDatabaseInterface extends Mock implements DatabaseInterface {}

void main() {
  late SqliteTaskRepository repository;
  late MockDatabaseInterface mockDatabase;

  const int testContactId = 123;
  const int testTaskId = 456;
  final DateTime testDate = DateTime(2024, 1, 15, 10, 30);
  final DateTime futureDate = DateTime(2024, 1, 20, 10, 30);

  final List<Map<String, dynamic>> mockDatabaseResponse =
      <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'contact_id': testContactId,
          'title': 'High Priority Task',
          'description': 'Important task description',
          'due_date': testDate.toIso8601String(),
          'completed': 0,
          'priority': 5,
          'created_at': testDate
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        },
        <String, dynamic>{
          'id': 2,
          'contact_id': testContactId,
          'title': 'Medium Priority Task',
          'description': 'Regular task description',
          'due_date': futureDate.toIso8601String(),
          'completed': 1,
          'priority': 3,
          'created_at': testDate.toIso8601String(),
        },
      ];

  final List<Task> expectedTasks = <Task>[
    Task(
      id: 1,
      contactId: testContactId,
      title: 'High Priority Task',
      description: 'Important task description',
      dueDate: testDate.toIso8601String(),
      priority: 5,
      createdAt: testDate.subtract(const Duration(days: 1)),
    ),
    Task(
      id: 2,
      contactId: testContactId,
      title: 'Medium Priority Task',
      description: 'Regular task description',
      dueDate: futureDate.toIso8601String(),
      completed: true,
      priority: 3,
      createdAt: testDate,
    ),
  ];

  setUp(() {
    mockDatabase = MockDatabaseInterface();
    repository = SqliteTaskRepository(mockDatabase);
  });

  group('SqliteTaskRepository - findByContactId', () {
    testWidgets(
      'should return tasks for valid contact ID ordered by priority and due date',
      (WidgetTester tester) async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => mockDatabaseResponse);

        final List<Task> result = await repository.findByContactId(
          testContactId,
        );

        expect(result, hasLength(2));
        expect(result, equals(expectedTasks));
        verify(
          () => mockDatabase.rawQuery(
            '''
        SELECT * FROM tasks
        WHERE contact_id = ?
        ORDER BY priority DESC, due_date ASC, created_at DESC
      ''',
            <dynamic>[testContactId],
          ),
        ).called(1);
      },
    );

    testWidgets('should return empty list when no tasks found for contact', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Task> result = await repository.findByContactId(testContactId);

      expect(result, isEmpty);
    });

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

  group('SqliteTaskRepository - findCompleted', () {
    testWidgets('should return completed tasks ordered by creation date', (
      WidgetTester tester,
    ) async {
      final List<Map<String, dynamic>> completedTasksResponse =
          mockDatabaseResponse
              .where((Map<String, dynamic> task) => task['completed'] == 1)
              .toList();
      when(
        () => mockDatabase.rawQuery(any()),
      ).thenAnswer((_) async => completedTasksResponse);

      final List<Task> result = await repository.findCompleted();

      expect(result, hasLength(1));
      expect(result.first.completed, isTrue);
      verify(
        () => mockDatabase.rawQuery('''
        SELECT * FROM tasks
        WHERE completed = 1
        ORDER BY created_at DESC
      '''),
      ).called(1);
    });

    testWidgets('should return empty list when no completed tasks found', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Task> result = await repository.findCompleted();

      expect(result, isEmpty);
    });

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any()),
      ).thenThrow(Exception('Query execution failed'));

      expect(
        () => repository.findCompleted(),
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

  group('SqliteTaskRepository - findPending', () {
    testWidgets(
      'should return pending tasks ordered by priority and due date',
      (WidgetTester tester) async {
        final List<Map<String, dynamic>> pendingTasksResponse =
            mockDatabaseResponse
                .where((Map<String, dynamic> task) => task['completed'] == 0)
                .toList();
        when(
          () => mockDatabase.rawQuery(any()),
        ).thenAnswer((_) async => pendingTasksResponse);

        final List<Task> result = await repository.findPending();

        expect(result, hasLength(1));
        expect(result.first.completed, isFalse);
        verify(
          () => mockDatabase.rawQuery('''
        SELECT * FROM tasks
        WHERE completed = 0
        ORDER BY priority DESC, due_date ASC, created_at DESC
      '''),
        ).called(1);
      },
    );

    testWidgets('should return empty list when no pending tasks found', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Task> result = await repository.findPending();

      expect(result, isEmpty);
    });

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any()),
      ).thenThrow(Exception('Database error'));

      expect(
        () => repository.findPending(),
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

  group('SqliteTaskRepository - findByPriority', () {
    testWidgets(
      'should return tasks with specific priority ordered by due date',
      (WidgetTester tester) async {
        const int targetPriority = 5;
        final List<Map<String, dynamic>> priorityTasksResponse =
            mockDatabaseResponse
                .where(
                  (Map<String, dynamic> task) =>
                      task['priority'] == targetPriority,
                )
                .toList();
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => priorityTasksResponse);

        final List<Task> result = await repository.findByPriority(
          targetPriority,
        );

        expect(result, hasLength(1));
        expect(result.first.priority, equals(targetPriority));
        verify(
          () => mockDatabase.rawQuery(
            '''
        SELECT * FROM tasks
        WHERE priority = ?
        ORDER BY due_date ASC, created_at DESC
      ''',
            <dynamic>[targetPriority],
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should return empty list when no tasks found with specified priority',
      (WidgetTester tester) async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final List<Task> result = await repository.findByPriority(1);

        expect(result, isEmpty);
      },
    );

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Priority query failed'));

      expect(
        () => repository.findByPriority(5),
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

  group('SqliteTaskRepository - findOverdue', () {
    testWidgets(
      'should return overdue incomplete tasks ordered by due date and priority',
      (WidgetTester tester) async {
        final DateTime pastDate = DateTime.now().subtract(
          const Duration(days: 5),
        );
        final List<Map<String, dynamic>> overdueTasksResponse =
            <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 3,
                'contact_id': testContactId,
                'title': 'Overdue Task',
                'description': 'This task is overdue',
                'due_date': pastDate.toIso8601String(),
                'completed': 0,
                'priority': 4,
                'created_at': pastDate.toIso8601String(),
              },
            ];
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => overdueTasksResponse);

        final List<Task> result = await repository.findOverdue();

        expect(result, hasLength(1));
        expect(result.first.completed, isFalse);
        expect(
          DateTime.parse(result.first.dueDate!).isBefore(DateTime.now()),
          isTrue,
        );
        verify(
          () => mockDatabase.rawQuery('''
        SELECT * FROM tasks
        WHERE completed = 0 AND due_date IS NOT NULL AND due_date < ?
        ORDER BY due_date ASC, priority DESC
      ''', any()),
        ).called(1);
      },
    );

    testWidgets('should return empty list when no overdue tasks found', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Task> result = await repository.findOverdue();

      expect(result, isEmpty);
    });

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Overdue query failed'));

      expect(
        () => repository.findOverdue(),
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

  group('SqliteTaskRepository - findByDateRange', () {
    testWidgets(
      'should return tasks within date range ordered by due date and priority',
      (WidgetTester tester) async {
        final DateTime startDate = DateTime(2024, 1, 10);
        final DateTime endDate = DateTime(2024, 1, 25);
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => mockDatabaseResponse);

        final List<Task> result = await repository.findByDateRange(
          startDate,
          endDate,
        );

        expect(result, hasLength(2));
        verify(
          () => mockDatabase.rawQuery(
            '''
        SELECT * FROM tasks
        WHERE due_date BETWEEN ? AND ?
        ORDER BY due_date ASC, priority DESC
      ''',
            <dynamic>[startDate.toIso8601String(), endDate.toIso8601String()],
          ),
        ).called(1);
      },
    );

    testWidgets('should return empty list when no tasks found in date range', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Task> result = await repository.findByDateRange(
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

  group('SqliteTaskRepository - findByPriorityRange', () {
    testWidgets(
      'should return tasks within priority range ordered by priority and due date',
      (WidgetTester tester) async {
        const int minPriority = 3;
        const int maxPriority = 5;
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => mockDatabaseResponse);

        final List<Task> result = await repository.findByPriorityRange(
          minPriority,
          maxPriority,
        );

        expect(result, hasLength(2));
        verify(
          () => mockDatabase.rawQuery(
            '''
        SELECT * FROM tasks
        WHERE priority BETWEEN ? AND ?
        ORDER BY priority DESC, due_date ASC, created_at DESC
      ''',
            <dynamic>[minPriority, maxPriority],
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should return empty list when no tasks found in priority range',
      (WidgetTester tester) async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final List<Task> result = await repository.findByPriorityRange(1, 2);

        expect(result, isEmpty);
      },
    );

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Priority range query failed'));

      expect(
        () => repository.findByPriorityRange(1, 5),
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

  group('SqliteTaskRepository - findUpcoming', () {
    testWidgets(
      'should return upcoming incomplete tasks within specified days',
      (WidgetTester tester) async {
        const int daysAhead = 7;
        final List<Map<String, dynamic>> upcomingTasksResponse =
            mockDatabaseResponse
                .where((Map<String, dynamic> task) => task['completed'] == 0)
                .toList();
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => upcomingTasksResponse);

        final List<Task> result = await repository.findUpcoming(daysAhead);

        expect(result, hasLength(1));
        expect(result.first.completed, isFalse);
        verify(
          () => mockDatabase.rawQuery('''
        SELECT * FROM tasks
        WHERE completed = 0 AND due_date BETWEEN ? AND ?
        ORDER BY due_date ASC, priority DESC
      ''', any()),
        ).called(1);
      },
    );

    testWidgets('should return empty list when no upcoming tasks found', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Task> result = await repository.findUpcoming(7);

      expect(result, isEmpty);
    });

    testWidgets('should throw DatabaseException when query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Upcoming tasks query failed'));

      expect(
        () => repository.findUpcoming(7),
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

  group('SqliteTaskRepository - countByContactId', () {
    testWidgets('should return correct count of tasks for contact', (
      WidgetTester tester,
    ) async {
      when(() => mockDatabase.rawQuery(any(), any())).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          <String, dynamic>{'count': 5},
        ],
      );

      final int result = await repository.countByContactId(testContactId);

      expect(result, equals(5));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT COUNT(*) as count FROM tasks
        WHERE contact_id = ?
      ''',
          <dynamic>[testContactId],
        ),
      ).called(1);
    });

    testWidgets('should return zero when no tasks found for contact', (
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

  group('SqliteTaskRepository - countCompletedByContactId', () {
    testWidgets('should return correct count of completed tasks for contact', (
      WidgetTester tester,
    ) async {
      when(() => mockDatabase.rawQuery(any(), any())).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          <String, dynamic>{'count': 3},
        ],
      );

      final int result = await repository.countCompletedByContactId(
        testContactId,
      );

      expect(result, equals(3));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT COUNT(*) as count FROM tasks
        WHERE contact_id = ? AND completed = 1
      ''',
          <dynamic>[testContactId],
        ),
      ).called(1);
    });

    testWidgets(
      'should return zero when no completed tasks found for contact',
      (WidgetTester tester) async {
        when(() => mockDatabase.rawQuery(any(), any())).thenAnswer(
          (_) async => <Map<String, dynamic>>[
            <String, dynamic>{'count': 0},
          ],
        );

        final int result = await repository.countCompletedByContactId(
          testContactId,
        );

        expect(result, equals(0));
      },
    );

    testWidgets('should throw DatabaseException when count query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Completed count query failed'));

      expect(
        () => repository.countCompletedByContactId(testContactId),
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

  group('SqliteTaskRepository - countPendingByContactId', () {
    testWidgets('should return correct count of pending tasks for contact', (
      WidgetTester tester,
    ) async {
      when(() => mockDatabase.rawQuery(any(), any())).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          <String, dynamic>{'count': 2},
        ],
      );

      final int result = await repository.countPendingByContactId(
        testContactId,
      );

      expect(result, equals(2));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT COUNT(*) as count FROM tasks
        WHERE contact_id = ? AND completed = 0
      ''',
          <dynamic>[testContactId],
        ),
      ).called(1);
    });

    testWidgets('should return zero when no pending tasks found for contact', (
      WidgetTester tester,
    ) async {
      when(() => mockDatabase.rawQuery(any(), any())).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          <String, dynamic>{'count': 0},
        ],
      );

      final int result = await repository.countPendingByContactId(
        testContactId,
      );

      expect(result, equals(0));
    });

    testWidgets('should throw DatabaseException when count query fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenThrow(Exception('Pending count query failed'));

      expect(
        () => repository.countPendingByContactId(testContactId),
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

  group('SqliteTaskRepository - fromMap', () {
    testWidgets('should correctly convert database map to Task model', (
      WidgetTester tester,
    ) async {
      final Map<String, dynamic> taskMap = <String, dynamic>{
        'id': testTaskId,
        'contact_id': testContactId,
        'title': 'Test Task',
        'description': 'Test Description',
        'due_date': testDate.toIso8601String(),
        'completed': 1,
        'priority': 4,
        'created_at': testDate.toIso8601String(),
      };

      final Task result = repository.fromMap(taskMap);

      expect(result.id, equals(testTaskId));
      expect(result.contactId, equals(testContactId));
      expect(result.title, equals('Test Task'));
      expect(result.description, equals('Test Description'));
      expect(result.dueDate, equals(testDate.toIso8601String()));
      expect(result.completed, isTrue);
      expect(result.priority, equals(4));
      expect(result.createdAt, equals(testDate));
    });

    testWidgets(
      'should handle null values correctly when converting from map',
      (WidgetTester tester) async {
        final Map<String, dynamic> taskMap = <String, dynamic>{
          'id': null,
          'contact_id': testContactId,
          'title': 'Test Task',
          'description': null,
          'due_date': null,
          'completed': 0,
          'priority': null,
          'created_at': null,
        };

        final Task result = repository.fromMap(taskMap);

        expect(result.id, isNull);
        expect(result.contactId, equals(testContactId));
        expect(result.title, equals('Test Task'));
        expect(result.description, isNull);
        expect(result.dueDate, isNull);
        expect(result.completed, isFalse);
        expect(result.priority, equals(1)); // Default value
        expect(result.createdAt, isNull);
      },
    );
  });
}
