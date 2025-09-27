import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/interaction.dart';

void main() {
  group('Interaction Model', () {
    const int testContactId = 1;
    const String testType = 'call';
    const String testDate = '2024-01-15T10:30:00.000Z';
    const int testDuration = 300; // 5 minutes in seconds
    const String testNotes = 'Great conversation about work';
    const String testLocation = 'Coffee shop downtown';

    test('should create Interaction with required fields', () {
      const Interaction interaction = Interaction(
        contactId: testContactId,
        type: testType,
        date: testDate,
      );

      expect(interaction.contactId, testContactId);
      expect(interaction.type, testType);
      expect(interaction.date, testDate);
      expect(interaction.id, isNull);
      expect(interaction.duration, isNull);
      expect(interaction.notes, isNull);
      expect(interaction.location, isNull);
      expect(interaction.createdAt, isNull);
    });

    test('should create Interaction with all fields', () {
      final DateTime now = DateTime.now();
      final Interaction interaction = Interaction(
        id: 1,
        contactId: testContactId,
        type: testType,
        date: testDate,
        duration: testDuration,
        notes: testNotes,
        location: testLocation,
        createdAt: now,
      );

      expect(interaction.id, 1);
      expect(interaction.contactId, testContactId);
      expect(interaction.type, testType);
      expect(interaction.date, testDate);
      expect(interaction.duration, testDuration);
      expect(interaction.notes, testNotes);
      expect(interaction.location, testLocation);
      expect(interaction.createdAt, now);
    });

    test('should convert Interaction to Map correctly', () {
      final DateTime now = DateTime.now();
      final Interaction interaction = Interaction(
        id: 1,
        contactId: testContactId,
        type: testType,
        date: testDate,
        duration: testDuration,
        notes: testNotes,
        location: testLocation,
        createdAt: now,
      );

      final Map<String, dynamic> map = interaction.toMap();

      expect(map['id'], 1);
      expect(map['contact_id'], testContactId);
      expect(map['type'], testType);
      expect(map['date'], testDate);
      expect(map['duration'], testDuration);
      expect(map['notes'], testNotes);
      expect(map['location'], testLocation);
      expect(map['created_at'], now.toIso8601String());
    });

    test('should create Interaction from Map correctly', () {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'type': testType,
        'date': testDate,
        'duration': testDuration,
        'notes': testNotes,
        'location': testLocation,
        'created_at': now.toIso8601String(),
      };

      final Interaction interaction = Interaction.fromMap(map);

      expect(interaction.id, 1);
      expect(interaction.contactId, testContactId);
      expect(interaction.type, testType);
      expect(interaction.date, testDate);
      expect(interaction.duration, testDuration);
      expect(interaction.notes, testNotes);
      expect(interaction.location, testLocation);
      expect(interaction.createdAt, now);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'type': testType,
        'date': testDate,
        'duration': null,
        'notes': null,
        'location': null,
        'created_at': null,
      };

      final Interaction interaction = Interaction.fromMap(map);

      expect(interaction.id, 1);
      expect(interaction.contactId, testContactId);
      expect(interaction.type, testType);
      expect(interaction.date, testDate);
      expect(interaction.duration, isNull);
      expect(interaction.notes, isNull);
      expect(interaction.location, isNull);
      expect(interaction.createdAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      const Interaction original = Interaction(
        id: 1,
        contactId: testContactId,
        type: testType,
        date: testDate,
        duration: testDuration,
      );

      final Interaction updated = original.copyWith(
        type: 'message',
        notes: testNotes,
        location: testLocation,
      );

      expect(updated.id, 1);
      expect(updated.contactId, testContactId);
      expect(updated.type, 'message');
      expect(updated.date, testDate);
      expect(updated.duration, testDuration);
      expect(updated.notes, testNotes);
      expect(updated.location, testLocation);
      expect(original.type, testType); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const Interaction interaction1 = Interaction(
        id: 1,
        contactId: testContactId,
        type: testType,
        date: testDate,
        duration: testDuration,
      );

      const Interaction interaction2 = Interaction(
        id: 1,
        contactId: testContactId,
        type: testType,
        date: testDate,
        duration: testDuration,
      );

      const Interaction interaction3 = Interaction(
        id: 2,
        contactId: testContactId,
        type: testType,
        date: testDate,
        duration: testDuration,
      );

      expect(interaction1, equals(interaction2));
      expect(interaction1, isNot(equals(interaction3)));
      expect(interaction1.hashCode, equals(interaction2.hashCode));
    });

    test('should handle different interaction types', () {
      const List<String> types = ['call', 'message', 'meeting', 'email'];

      for (final String type in types) {
        final Interaction interaction = Interaction(
          contactId: testContactId,
          type: type,
          date: testDate,
        );

        expect(interaction.type, type);

        final Map<String, dynamic> map = interaction.toMap();
        expect(map['type'], type);

        final Interaction fromMap = Interaction.fromMap(map);
        expect(fromMap.type, type);
      }
    });

    test('should preserve duration precision', () {
      const List<int> durations = [0, 1, 60, 300, 3600, 7200];

      for (final int duration in durations) {
        final Interaction interaction = Interaction(
          contactId: testContactId,
          type: testType,
          date: testDate,
          duration: duration,
        );

        final Map<String, dynamic> map = interaction.toMap();
        final Interaction fromMap = Interaction.fromMap(map);

        expect(fromMap.duration, duration);
      }
    });
  });
}