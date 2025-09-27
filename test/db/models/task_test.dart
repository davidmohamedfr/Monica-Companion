import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/task.dart';

void main() {
  group('Task Model', () {
    const int testContactId = 1;
    const String testTitle = 'Call John about dinner plans';
    const String testDescription =
        'Need to confirm time and location for Saturday dinner';
    const String testDueDate = '2024-01-20T18:00:00.000Z';
    const bool testCompleted = true;
    const int testPriority = 4;

    test('should create Task with required fields', () {
      const Task task = Task(contactId: testContactId, title: testTitle);

      expect(task.contactId, testContactId);
      expect(task.title, testTitle);
      expect(task.completed, false); // Default value
      expect(task.priority, 1); // Default value
      expect(task.id, isNull);
      expect(task.description, isNull);
      expect(task.dueDate, isNull);
      expect(task.createdAt, isNull);
    });

    test('should create Task with all fields', () {
      final DateTime now = DateTime.now();
      final Task task = Task(
        id: 1,
        contactId: testContactId,
        title: testTitle,
        description: testDescription,
        dueDate: testDueDate,
        completed: testCompleted,
        priority: testPriority,
        createdAt: now,
      );

      expect(task.id, 1);
      expect(task.contactId, testContactId);
      expect(task.title, testTitle);
      expect(task.description, testDescription);
      expect(task.dueDate, testDueDate);
      expect(task.completed, testCompleted);
      expect(task.priority, testPriority);
      expect(task.createdAt, now);
    });

    test('should convert Task to Map correctly', () {
      final DateTime now = DateTime.now();
      final Task task = Task(
        id: 1,
        contactId: testContactId,
        title: testTitle,
        description: testDescription,
        dueDate: testDueDate,
        completed: testCompleted,
        priority: testPriority,
        createdAt: now,
      );

      final Map<String, dynamic> map = task.toMap();

      expect(map['id'], 1);
      expect(map['contact_id'], testContactId);
      expect(map['title'], testTitle);
      expect(map['description'], testDescription);
      expect(map['due_date'], testDueDate);
      expect(map['completed'], 1); // Boolean stored as int
      expect(map['priority'], testPriority);
      expect(map['created_at'], now.toIso8601String());
    });

    test('should create Task from Map correctly', () {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'title': testTitle,
        'description': testDescription,
        'due_date': testDueDate,
        'completed': 1,
        'priority': testPriority,
        'created_at': now.toIso8601String(),
      };

      final Task task = Task.fromMap(map);

      expect(task.id, 1);
      expect(task.contactId, testContactId);
      expect(task.title, testTitle);
      expect(task.description, testDescription);
      expect(task.dueDate, testDueDate);
      expect(task.completed, true);
      expect(task.priority, testPriority);
      expect(task.createdAt, now);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'title': testTitle,
        'description': null,
        'due_date': null,
        'completed': null,
        'priority': null,
        'created_at': null,
      };

      final Task task = Task.fromMap(map);

      expect(task.id, 1);
      expect(task.contactId, testContactId);
      expect(task.title, testTitle);
      expect(task.description, isNull);
      expect(task.dueDate, isNull);
      expect(task.completed, false); // null treated as false
      expect(task.priority, 1); // Default value when null
      expect(task.createdAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      const Task original = Task(
        id: 1,
        contactId: testContactId,
        title: testTitle,
      );

      final Task updated = original.copyWith(
        title: 'Updated task title',
        description: testDescription,
        completed: testCompleted,
        priority: testPriority,
      );

      expect(updated.id, 1);
      expect(updated.contactId, testContactId);
      expect(updated.title, 'Updated task title');
      expect(updated.description, testDescription);
      expect(updated.completed, testCompleted);
      expect(updated.priority, testPriority);
      expect(original.title, testTitle); // Original should be unchanged
      expect(original.completed, false); // Original should be unchanged
      expect(original.priority, 1); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const Task task1 = Task(
        id: 1,
        contactId: testContactId,
        title: testTitle,
        completed: testCompleted,
        priority: testPriority,
      );

      const Task task2 = Task(
        id: 1,
        contactId: testContactId,
        title: testTitle,
        completed: testCompleted,
        priority: testPriority,
      );

      const Task task3 = Task(
        id: 2,
        contactId: testContactId,
        title: testTitle,
        completed: testCompleted,
        priority: testPriority,
      );

      expect(task1, equals(task2));
      expect(task1, isNot(equals(task3)));
      expect(task1.hashCode, equals(task2.hashCode));
    });

    test('should handle boolean completed field correctly', () {
      // Test true value
      const Task completedTask = Task(
        contactId: testContactId,
        title: testTitle,
        completed: true,
      );

      final Map<String, dynamic> completedMap = completedTask.toMap();
      expect(completedMap['completed'], 1);

      final Task completedFromMap = Task.fromMap(completedMap);
      expect(completedFromMap.completed, true);

      // Test false value
      const Task pendingTask = Task(contactId: testContactId, title: testTitle);

      final Map<String, dynamic> pendingMap = pendingTask.toMap();
      expect(pendingMap['completed'], 0);

      final Task pendingFromMap = Task.fromMap(pendingMap);
      expect(pendingFromMap.completed, false);
    });

    test('should handle priority levels correctly', () {
      const List<int> priorityLevels = <int>[1, 2, 3, 4, 5];

      for (final int priority in priorityLevels) {
        final Task task = Task(
          contactId: testContactId,
          title: testTitle,
          priority: priority,
        );

        expect(task.priority, priority);

        final Map<String, dynamic> map = task.toMap();
        final Task fromMap = Task.fromMap(map);

        expect(fromMap.priority, priority);
      }
    });

    test('should use default values when not specified', () {
      const Task task = Task(contactId: testContactId, title: testTitle);

      expect(task.completed, false);
      expect(task.priority, 1);

      final Map<String, dynamic> map = task.toMap();
      expect(map['completed'], 0);
      expect(map['priority'], 1);
    });

    test('should handle completed conversion from different int values', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'title': testTitle,
        'description': testDescription,
        'due_date': testDueDate,
        'completed': 0,
        'priority': testPriority,
        'created_at': null,
      };

      // Test with 0 (should be false)
      final Task task0 = Task.fromMap(map);
      expect(task0.completed, false);

      // Test with 1 (should be true)
      map['completed'] = 1;
      final Task task1 = Task.fromMap(map);
      expect(task1.completed, true);

      // Test with other positive int (should be false, only 1 is true)
      map['completed'] = 5;
      final Task task5 = Task.fromMap(map);
      expect(task5.completed, false);
    });

    test('should handle various due date formats', () {
      const List<String> dueDates = <String>[
        '2024-01-20T18:00:00.000Z',
        '2024-12-25T00:00:00.000Z',
        '2025-06-15T12:30:00.000Z',
      ];

      for (final String dueDate in dueDates) {
        final Task task = Task(
          contactId: testContactId,
          title: testTitle,
          dueDate: dueDate,
        );

        expect(task.dueDate, dueDate);

        final Map<String, dynamic> map = task.toMap();
        expect(map['due_date'], dueDate);

        final Task fromMap = Task.fromMap(map);
        expect(fromMap.dueDate, dueDate);
      }
    });

    test('should handle edge case priority values', () {
      // Test minimum and maximum priority values
      const List<int> edgePriorities = <int>[0, 1, 5, 10];

      for (final int priority in edgePriorities) {
        final Task task = Task(
          contactId: testContactId,
          title: testTitle,
          priority: priority,
        );

        final Map<String, dynamic> map = task.toMap();
        final Task fromMap = Task.fromMap(map);

        expect(fromMap.priority, priority);
      }
    });
  });
}
