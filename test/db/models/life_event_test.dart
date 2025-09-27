import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/life_event.dart';

void main() {
  group('LifeEvent Model', () {
    const int testContactId = 1;
    const String testEventType = 'birthday';
    const String testDate = '2024-01-15T00:00:00.000Z';
    const String testDescription = 'John\'s 30th birthday celebration';
    const int testImportance = 5;

    test('should create LifeEvent with required fields', () {
      const LifeEvent lifeEvent = LifeEvent(
        contactId: testContactId,
        eventType: testEventType,
        date: testDate,
      );

      expect(lifeEvent.contactId, testContactId);
      expect(lifeEvent.eventType, testEventType);
      expect(lifeEvent.date, testDate);
      expect(lifeEvent.importance, 1); // Default value
      expect(lifeEvent.id, isNull);
      expect(lifeEvent.description, isNull);
      expect(lifeEvent.createdAt, isNull);
    });

    test('should create LifeEvent with all fields', () {
      final DateTime now = DateTime.now();
      final LifeEvent lifeEvent = LifeEvent(
        id: 1,
        contactId: testContactId,
        eventType: testEventType,
        date: testDate,
        description: testDescription,
        importance: testImportance,
        createdAt: now,
      );

      expect(lifeEvent.id, 1);
      expect(lifeEvent.contactId, testContactId);
      expect(lifeEvent.eventType, testEventType);
      expect(lifeEvent.date, testDate);
      expect(lifeEvent.description, testDescription);
      expect(lifeEvent.importance, testImportance);
      expect(lifeEvent.createdAt, now);
    });

    test('should convert LifeEvent to Map correctly', () {
      final DateTime now = DateTime.now();
      final LifeEvent lifeEvent = LifeEvent(
        id: 1,
        contactId: testContactId,
        eventType: testEventType,
        date: testDate,
        description: testDescription,
        importance: testImportance,
        createdAt: now,
      );

      final Map<String, dynamic> map = lifeEvent.toMap();

      expect(map['id'], 1);
      expect(map['contact_id'], testContactId);
      expect(map['event_type'], testEventType);
      expect(map['date'], testDate);
      expect(map['description'], testDescription);
      expect(map['importance'], testImportance);
      expect(map['created_at'], now.toIso8601String());
    });

    test('should create LifeEvent from Map correctly', () {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'event_type': testEventType,
        'date': testDate,
        'description': testDescription,
        'importance': testImportance,
        'created_at': now.toIso8601String(),
      };

      final LifeEvent lifeEvent = LifeEvent.fromMap(map);

      expect(lifeEvent.id, 1);
      expect(lifeEvent.contactId, testContactId);
      expect(lifeEvent.eventType, testEventType);
      expect(lifeEvent.date, testDate);
      expect(lifeEvent.description, testDescription);
      expect(lifeEvent.importance, testImportance);
      expect(lifeEvent.createdAt, now);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'event_type': testEventType,
        'date': testDate,
        'description': null,
        'importance': null,
        'created_at': null,
      };

      final LifeEvent lifeEvent = LifeEvent.fromMap(map);

      expect(lifeEvent.id, 1);
      expect(lifeEvent.contactId, testContactId);
      expect(lifeEvent.eventType, testEventType);
      expect(lifeEvent.date, testDate);
      expect(lifeEvent.description, isNull);
      expect(lifeEvent.importance, 1); // Default value when null
      expect(lifeEvent.createdAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      const LifeEvent original = LifeEvent(
        id: 1,
        contactId: testContactId,
        eventType: testEventType,
        date: testDate,
        importance: 3,
      );

      final LifeEvent updated = original.copyWith(
        eventType: 'anniversary',
        description: testDescription,
        importance: testImportance,
      );

      expect(updated.id, 1);
      expect(updated.contactId, testContactId);
      expect(updated.eventType, 'anniversary');
      expect(updated.date, testDate);
      expect(updated.description, testDescription);
      expect(updated.importance, testImportance);
      expect(original.eventType, testEventType); // Original should be unchanged
      expect(original.importance, 3); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const LifeEvent lifeEvent1 = LifeEvent(
        id: 1,
        contactId: testContactId,
        eventType: testEventType,
        date: testDate,
        importance: testImportance,
      );

      const LifeEvent lifeEvent2 = LifeEvent(
        id: 1,
        contactId: testContactId,
        eventType: testEventType,
        date: testDate,
        importance: testImportance,
      );

      const LifeEvent lifeEvent3 = LifeEvent(
        id: 2,
        contactId: testContactId,
        eventType: testEventType,
        date: testDate,
        importance: testImportance,
      );

      expect(lifeEvent1, equals(lifeEvent2));
      expect(lifeEvent1, isNot(equals(lifeEvent3)));
      expect(lifeEvent1.hashCode, equals(lifeEvent2.hashCode));
    });

    test('should handle different event types', () {
      const List<String> eventTypes = ['birthday', 'anniversary', 'job_change', 'graduation', 'wedding'];

      for (final String eventType in eventTypes) {
        final LifeEvent lifeEvent = LifeEvent(
          contactId: testContactId,
          eventType: eventType,
          date: testDate,
        );

        expect(lifeEvent.eventType, eventType);

        final Map<String, dynamic> map = lifeEvent.toMap();
        expect(map['event_type'], eventType);

        final LifeEvent fromMap = LifeEvent.fromMap(map);
        expect(fromMap.eventType, eventType);
      }
    });

    test('should handle importance levels correctly', () {
      const List<int> importanceLevels = [1, 2, 3, 4, 5];

      for (final int importance in importanceLevels) {
        final LifeEvent lifeEvent = LifeEvent(
          contactId: testContactId,
          eventType: testEventType,
          date: testDate,
          importance: importance,
        );

        expect(lifeEvent.importance, importance);

        final Map<String, dynamic> map = lifeEvent.toMap();
        final LifeEvent fromMap = LifeEvent.fromMap(map);

        expect(fromMap.importance, importance);
      }
    });

    test('should use default importance when not specified', () {
      const LifeEvent lifeEvent = LifeEvent(
        contactId: testContactId,
        eventType: testEventType,
        date: testDate,
      );

      expect(lifeEvent.importance, 1);

      final Map<String, dynamic> map = lifeEvent.toMap();
      expect(map['importance'], 1);
    });
  });
}