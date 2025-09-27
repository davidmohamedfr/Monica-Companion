import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/activity.dart';

void main() {
  group('Activity Model', () {
    const String testTitle = 'Dinner at Italian Restaurant';
    const String testDescription = 'Great evening with friends at Luigi\'s';
    const String testDate = '2024-01-15T19:00:00.000Z';
    const String testLocation = 'Luigi\'s Italian Restaurant';
    const List<int> testParticipants = [1, 2, 3];

    test('should create Activity with required fields', () {
      const Activity activity = Activity(
        title: testTitle,
        date: testDate,
      );

      expect(activity.title, testTitle);
      expect(activity.date, testDate);
      expect(activity.participants, const <int>[]); // Default empty list
      expect(activity.id, isNull);
      expect(activity.description, isNull);
      expect(activity.location, isNull);
      expect(activity.createdAt, isNull);
    });

    test('should create Activity with all fields', () {
      final DateTime now = DateTime.now();
      final Activity activity = Activity(
        id: 1,
        title: testTitle,
        description: testDescription,
        date: testDate,
        location: testLocation,
        participants: testParticipants,
        createdAt: now,
      );

      expect(activity.id, 1);
      expect(activity.title, testTitle);
      expect(activity.description, testDescription);
      expect(activity.date, testDate);
      expect(activity.location, testLocation);
      expect(activity.participants, testParticipants);
      expect(activity.createdAt, now);
    });

    test('should convert Activity to Map correctly', () {
      final DateTime now = DateTime.now();
      final Activity activity = Activity(
        id: 1,
        title: testTitle,
        description: testDescription,
        date: testDate,
        location: testLocation,
        participants: testParticipants,
        createdAt: now,
      );

      final Map<String, dynamic> map = activity.toMap();

      expect(map['id'], 1);
      expect(map['title'], testTitle);
      expect(map['description'], testDescription);
      expect(map['date'], testDate);
      expect(map['location'], testLocation);
      expect(map['participants'], '1,2,3'); // Stored as comma-separated string
      expect(map['created_at'], now.toIso8601String());
    });

    test('should create Activity from Map correctly', () {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'title': testTitle,
        'description': testDescription,
        'date': testDate,
        'location': testLocation,
        'participants': '1,2,3',
        'created_at': now.toIso8601String(),
      };

      final Activity activity = Activity.fromMap(map);

      expect(activity.id, 1);
      expect(activity.title, testTitle);
      expect(activity.description, testDescription);
      expect(activity.date, testDate);
      expect(activity.location, testLocation);
      expect(activity.participants, testParticipants);
      expect(activity.createdAt, now);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'title': testTitle,
        'date': testDate,
        'description': null,
        'location': null,
        'participants': null,
        'created_at': null,
      };

      final Activity activity = Activity.fromMap(map);

      expect(activity.id, 1);
      expect(activity.title, testTitle);
      expect(activity.date, testDate);
      expect(activity.description, isNull);
      expect(activity.location, isNull);
      expect(activity.participants, const <int>[]); // null becomes empty list
      expect(activity.createdAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      const Activity original = Activity(
        id: 1,
        title: testTitle,
        date: testDate,
        participants: [1, 2],
      );

      final Activity updated = original.copyWith(
        title: 'Updated Activity Title',
        description: testDescription,
        location: testLocation,
        participants: testParticipants,
      );

      expect(updated.id, 1);
      expect(updated.title, 'Updated Activity Title');
      expect(updated.date, testDate);
      expect(updated.description, testDescription);
      expect(updated.location, testLocation);
      expect(updated.participants, testParticipants);
      expect(original.title, testTitle); // Original should be unchanged
      expect(original.participants, [1, 2]); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const Activity activity1 = Activity(
        id: 1,
        title: testTitle,
        date: testDate,
        participants: testParticipants,
      );

      const Activity activity2 = Activity(
        id: 1,
        title: testTitle,
        date: testDate,
        participants: testParticipants,
      );

      const Activity activity3 = Activity(
        id: 2,
        title: testTitle,
        date: testDate,
        participants: testParticipants,
      );

      expect(activity1, equals(activity2));
      expect(activity1, isNot(equals(activity3)));
      expect(activity1.hashCode, equals(activity2.hashCode));
    });

    test('should handle empty participants list', () {
      const Activity activity = Activity(
        title: testTitle,
        date: testDate,
        participants: <int>[],
      );

      final Map<String, dynamic> map = activity.toMap();
      expect(map['participants'], '');

      final Activity fromMap = Activity.fromMap(map);
      expect(fromMap.participants, const <int>[]);
    });

    test('should handle single participant', () {
      const List<int> singleParticipant = [42];
      const Activity activity = Activity(
        title: testTitle,
        date: testDate,
        participants: singleParticipant,
      );

      final Map<String, dynamic> map = activity.toMap();
      expect(map['participants'], '42');

      final Activity fromMap = Activity.fromMap(map);
      expect(fromMap.participants, singleParticipant);
    });

    test('should handle multiple participants', () {
      const List<int> manyParticipants = [1, 5, 10, 15, 20, 25];
      const Activity activity = Activity(
        title: testTitle,
        date: testDate,
        participants: manyParticipants,
      );

      final Map<String, dynamic> map = activity.toMap();
      expect(map['participants'], '1,5,10,15,20,25');

      final Activity fromMap = Activity.fromMap(map);
      expect(fromMap.participants, manyParticipants);
    });

    test('should handle empty string participants in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'title': testTitle,
        'date': testDate,
        'participants': '',
        'created_at': null,
      };

      final Activity activity = Activity.fromMap(map);
      expect(activity.participants, const <int>[]);
    });

    test('should handle round-trip serialization with participants', () {
      const List<List<int>> participantLists = [
        <int>[],
        [1],
        [1, 2],
        [1, 2, 3, 4, 5],
        [100, 200, 300],
      ];

      for (final List<int> participants in participantLists) {
        final Activity original = Activity(
          title: testTitle,
          date: testDate,
          participants: participants,
        );

        final Map<String, dynamic> map = original.toMap();
        final Activity restored = Activity.fromMap(map);

        expect(restored.participants, participants);
        expect(restored.title, testTitle);
        expect(restored.date, testDate);
      }
    });

    test('should handle different activity types', () {
      const List<String> activityTitles = [
        'Movie Night',
        'Coffee Meeting',
        'Birthday Party',
        'Business Lunch',
        'Weekend Trip',
      ];

      for (final String title in activityTitles) {
        final Activity activity = Activity(
          title: title,
          date: testDate,
        );

        expect(activity.title, title);

        final Map<String, dynamic> map = activity.toMap();
        final Activity fromMap = Activity.fromMap(map);

        expect(fromMap.title, title);
      }
    });

    test('should handle different date formats', () {
      const List<String> dateFormats = [
        '2024-01-15T19:00:00.000Z',
        '2024-12-31T23:59:59.999Z',
        '2025-06-15T12:00:00.000Z',
      ];

      for (final String date in dateFormats) {
        final Activity activity = Activity(
          title: testTitle,
          date: date,
        );

        expect(activity.date, date);

        final Map<String, dynamic> map = activity.toMap();
        final Activity fromMap = Activity.fromMap(map);

        expect(fromMap.date, date);
      }
    });

    test('should handle various locations', () {
      const List<String> locations = [
        'Central Park',
        'Home',
        'Office Conference Room',
        'The Coffee Bean & Tea Leaf',
        'Virtual (Zoom)',
      ];

      for (final String location in locations) {
        final Activity activity = Activity(
          title: testTitle,
          date: testDate,
          location: location,
        );

        expect(activity.location, location);

        final Map<String, dynamic> map = activity.toMap();
        final Activity fromMap = Activity.fromMap(map);

        expect(fromMap.location, location);
      }
    });

    test('should handle long descriptions', () {
      const String longDescription = 'This was an amazing evening where we all gathered together for a wonderful time. '
          'We started with appetizers and drinks, then moved on to the main course which was absolutely delicious. '
          'The conversation flowed naturally and everyone seemed to really enjoy themselves. '
          'It was one of those perfect nights that you remember for years to come.';

      final Activity activity = Activity(
        title: testTitle,
        date: testDate,
        description: longDescription,
      );

      final Map<String, dynamic> map = activity.toMap();
      final Activity fromMap = Activity.fromMap(map);

      expect(fromMap.description, longDescription);
    });
  });
}