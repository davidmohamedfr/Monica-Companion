import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/reminder.dart';

void main() {
  group('Reminder Model', () {
    const int testContactId = 1;
    const String testTitle = 'Call for birthday wishes';
    const String testDescription = 'Remember to call John for his birthday celebration';
    const String testDueDate = '2024-01-15T09:00:00.000Z';
    const ReminderFrequency testFrequency = ReminderFrequency.yearly;
    const bool testActive = false;

    test('should create Reminder with required fields', () {
      const Reminder reminder = Reminder(
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
      );

      expect(reminder.contactId, testContactId);
      expect(reminder.title, testTitle);
      expect(reminder.dueDate, testDueDate);
      expect(reminder.active, true); // Default value
      expect(reminder.id, isNull);
      expect(reminder.description, isNull);
      expect(reminder.frequency, isNull);
      expect(reminder.createdAt, isNull);
    });

    test('should create Reminder with all fields', () {
      final DateTime now = DateTime.now();
      final Reminder reminder = Reminder(
        id: 1,
        contactId: testContactId,
        title: testTitle,
        description: testDescription,
        dueDate: testDueDate,
        frequency: testFrequency,
        active: testActive,
        createdAt: now,
      );

      expect(reminder.id, 1);
      expect(reminder.contactId, testContactId);
      expect(reminder.title, testTitle);
      expect(reminder.description, testDescription);
      expect(reminder.dueDate, testDueDate);
      expect(reminder.frequency, testFrequency);
      expect(reminder.active, testActive);
      expect(reminder.createdAt, now);
    });

    test('should convert Reminder to Map correctly', () {
      final DateTime now = DateTime.now();
      final Reminder reminder = Reminder(
        id: 1,
        contactId: testContactId,
        title: testTitle,
        description: testDescription,
        dueDate: testDueDate,
        frequency: testFrequency,
        active: testActive,
        createdAt: now,
      );

      final Map<String, dynamic> map = reminder.toMap();

      expect(map['id'], 1);
      expect(map['contact_id'], testContactId);
      expect(map['title'], testTitle);
      expect(map['description'], testDescription);
      expect(map['due_date'], testDueDate);
      expect(map['frequency'], 'yearly'); // Enum value as string
      expect(map['active'], 0); // Boolean stored as int (false = 0)
      expect(map['created_at'], now.toIso8601String());
    });

    test('should create Reminder from Map correctly', () {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'title': testTitle,
        'description': testDescription,
        'due_date': testDueDate,
        'frequency': 'yearly',
        'active': 0,
        'created_at': now.toIso8601String(),
      };

      final Reminder reminder = Reminder.fromMap(map);

      expect(reminder.id, 1);
      expect(reminder.contactId, testContactId);
      expect(reminder.title, testTitle);
      expect(reminder.description, testDescription);
      expect(reminder.dueDate, testDueDate);
      expect(reminder.frequency, ReminderFrequency.yearly);
      expect(reminder.active, false);
      expect(reminder.createdAt, now);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'title': testTitle,
        'due_date': testDueDate,
        'description': null,
        'frequency': null,
        'active': null,
        'created_at': null,
      };

      final Reminder reminder = Reminder.fromMap(map);

      expect(reminder.id, 1);
      expect(reminder.contactId, testContactId);
      expect(reminder.title, testTitle);
      expect(reminder.dueDate, testDueDate);
      expect(reminder.description, isNull);
      expect(reminder.frequency, isNull);
      expect(reminder.active, true); // null treated as true (default)
      expect(reminder.createdAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      const Reminder original = Reminder(
        id: 1,
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
        frequency: ReminderFrequency.once,
        active: true,
      );

      final Reminder updated = original.copyWith(
        title: 'Updated reminder title',
        description: testDescription,
        frequency: testFrequency,
        active: testActive,
      );

      expect(updated.id, 1);
      expect(updated.contactId, testContactId);
      expect(updated.title, 'Updated reminder title');
      expect(updated.dueDate, testDueDate);
      expect(updated.description, testDescription);
      expect(updated.frequency, testFrequency);
      expect(updated.active, testActive);
      expect(original.title, testTitle); // Original should be unchanged
      expect(original.frequency, ReminderFrequency.once); // Original should be unchanged
      expect(original.active, true); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const Reminder reminder1 = Reminder(
        id: 1,
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
        frequency: testFrequency,
      );

      const Reminder reminder2 = Reminder(
        id: 1,
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
        frequency: testFrequency,
      );

      const Reminder reminder3 = Reminder(
        id: 2,
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
        frequency: testFrequency,
      );

      expect(reminder1, equals(reminder2));
      expect(reminder1, isNot(equals(reminder3)));
      expect(reminder1.hashCode, equals(reminder2.hashCode));
    });

    test('should handle ReminderFrequency enum correctly', () {
      const Map<ReminderFrequency, String> frequencyMap = {
        ReminderFrequency.once: 'once',
        ReminderFrequency.daily: 'daily',
        ReminderFrequency.weekly: 'weekly',
        ReminderFrequency.monthly: 'monthly',
        ReminderFrequency.yearly: 'yearly',
      };

      for (final MapEntry<ReminderFrequency, String> entry in frequencyMap.entries) {
        final Reminder reminder = Reminder(
          contactId: testContactId,
          title: testTitle,
          dueDate: testDueDate,
          frequency: entry.key,
        );

        final Map<String, dynamic> map = reminder.toMap();
        expect(map['frequency'], entry.value);

        final Reminder fromMap = Reminder.fromMap(map);
        expect(fromMap.frequency, entry.key);
      }
    });

    test('should handle boolean active field correctly', () {
      // Test true value
      const Reminder activeReminder = Reminder(
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
        active: true,
      );

      final Map<String, dynamic> activeMap = activeReminder.toMap();
      expect(activeMap['active'], 1);

      final Reminder activeFromMap = Reminder.fromMap(activeMap);
      expect(activeFromMap.active, true);

      // Test false value
      const Reminder inactiveReminder = Reminder(
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
        active: false,
      );

      final Map<String, dynamic> inactiveMap = inactiveReminder.toMap();
      expect(inactiveMap['active'], 0);

      final Reminder inactiveFromMap = Reminder.fromMap(inactiveMap);
      expect(inactiveFromMap.active, false);
    });

    test('should handle null frequency in serialization', () {
      const Reminder reminder = Reminder(
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
        frequency: null,
      );

      final Map<String, dynamic> map = reminder.toMap();
      expect(map['frequency'], isNull);

      final Reminder fromMap = Reminder.fromMap(map);
      expect(fromMap.frequency, isNull);
    });

    test('should use default active value when not specified', () {
      const Reminder reminder = Reminder(
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
      );

      expect(reminder.active, true);

      final Map<String, dynamic> map = reminder.toMap();
      expect(map['active'], 1);
    });

    test('should handle ReminderFrequency.fromString correctly', () {
      expect(ReminderFrequency.fromString('once'), ReminderFrequency.once);
      expect(ReminderFrequency.fromString('daily'), ReminderFrequency.daily);
      expect(ReminderFrequency.fromString('weekly'), ReminderFrequency.weekly);
      expect(ReminderFrequency.fromString('monthly'), ReminderFrequency.monthly);
      expect(ReminderFrequency.fromString('yearly'), ReminderFrequency.yearly);
      expect(ReminderFrequency.fromString('invalid'), ReminderFrequency.once); // Default fallback
    });

    test('should handle active conversion from different int values', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'title': testTitle,
        'due_date': testDueDate,
        'description': testDescription,
        'frequency': 'once',
        'active': 0,
        'created_at': null,
      };

      // Test with 0 (should be false)
      final Reminder reminder0 = Reminder.fromMap(map);
      expect(reminder0.active, false);

      // Test with 1 (should be true)
      map['active'] = 1;
      final Reminder reminder1 = Reminder.fromMap(map);
      expect(reminder1.active, true);

      // Test with other positive int (should be true, != 0 means true)
      map['active'] = 5;
      final Reminder reminder5 = Reminder.fromMap(map);
      expect(reminder5.active, true);
    });

    test('should handle different due date formats', () {
      const List<String> dueDates = [
        '2024-01-15T09:00:00.000Z',
        '2024-12-25T00:00:00.000Z',
        '2025-06-30T18:30:00.000Z',
      ];

      for (final String dueDate in dueDates) {
        final Reminder reminder = Reminder(
          contactId: testContactId,
          title: testTitle,
          dueDate: dueDate,
        );

        expect(reminder.dueDate, dueDate);

        final Map<String, dynamic> map = reminder.toMap();
        final Reminder fromMap = Reminder.fromMap(map);

        expect(fromMap.dueDate, dueDate);
      }
    });

    test('should handle various reminder titles', () {
      const List<String> titles = [
        'Birthday reminder',
        'Anniversary call',
        'Check in with friend',
        'Send thank you note',
        'Schedule meeting',
      ];

      for (final String title in titles) {
        final Reminder reminder = Reminder(
          contactId: testContactId,
          title: title,
          dueDate: testDueDate,
        );

        expect(reminder.title, title);

        final Map<String, dynamic> map = reminder.toMap();
        final Reminder fromMap = Reminder.fromMap(map);

        expect(fromMap.title, title);
      }
    });

    test('should handle long descriptions', () {
      const String longDescription = 'This is a comprehensive reminder description that provides detailed information '
          'about what needs to be done, when it should be done, and any special considerations that might be '
          'relevant for completing the task successfully.';

      final Reminder reminder = Reminder(
        contactId: testContactId,
        title: testTitle,
        dueDate: testDueDate,
        description: longDescription,
      );

      final Map<String, dynamic> map = reminder.toMap();
      final Reminder fromMap = Reminder.fromMap(map);

      expect(fromMap.description, longDescription);
    });

    test('should handle edge case where active is 0 in database but should default to true', () {
      // This tests the specific logic where active defaults to true unless explicitly set to 0
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'title': testTitle,
        'due_date': testDueDate,
        'active': 0, // Explicitly false
        'created_at': null,
      };

      final Reminder reminder = Reminder.fromMap(map);
      expect(reminder.active, false);

      // Test that null defaults to true
      map['active'] = null;
      final Reminder reminderNull = Reminder.fromMap(map);
      expect(reminderNull.active, true);
    });
  });
}