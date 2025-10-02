import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/relationship.dart';

void main() {
  group('Relationship Model', () {
    const int testContactId = 1;
    const String testRelationshipType = 'friend';
    const String testStartDate = '2020-03-15T00:00:00.000Z';
    const String testDescription =
        'Met at university during computer science program';

    test('should create Relationship with required fields', () {
      const Relationship relationship = Relationship(
        contactId: testContactId,
        relationshipType: testRelationshipType,
      );

      expect(relationship.contactId, testContactId);
      expect(relationship.relationshipType, testRelationshipType);
      expect(relationship.id, isNull);
      expect(relationship.startDate, isNull);
      expect(relationship.description, isNull);
      expect(relationship.createdAt, isNull);
    });

    test('should create Relationship with all fields', () {
      final DateTime now = DateTime.now();
      final Relationship relationship = Relationship(
        id: 1,
        contactId: testContactId,
        relationshipType: testRelationshipType,
        startDate: testStartDate,
        description: testDescription,
        createdAt: now,
      );

      expect(relationship.id, 1);
      expect(relationship.contactId, testContactId);
      expect(relationship.relationshipType, testRelationshipType);
      expect(relationship.startDate, testStartDate);
      expect(relationship.description, testDescription);
      expect(relationship.createdAt, now);
    });

    test('should convert Relationship to Map correctly', () {
      final DateTime now = DateTime.now();
      final Relationship relationship = Relationship(
        id: 1,
        contactId: testContactId,
        relationshipType: testRelationshipType,
        startDate: testStartDate,
        description: testDescription,
        createdAt: now,
      );

      final Map<String, dynamic> map = relationship.toMap();

      expect(map['id'], 1);
      expect(map['contact_id'], testContactId);
      expect(map['relationship_type'], testRelationshipType);
      expect(map['start_date'], testStartDate);
      expect(map['description'], testDescription);
      expect(map['created_at'], now.toIso8601String());
    });

    test('should create Relationship from Map correctly', () {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'relationship_type': testRelationshipType,
        'start_date': testStartDate,
        'description': testDescription,
        'created_at': now.toIso8601String(),
      };

      final Relationship relationship = Relationship.fromMap(map);

      expect(relationship.id, 1);
      expect(relationship.contactId, testContactId);
      expect(relationship.relationshipType, testRelationshipType);
      expect(relationship.startDate, testStartDate);
      expect(relationship.description, testDescription);
      expect(relationship.createdAt, now);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'relationship_type': testRelationshipType,
        'start_date': null,
        'description': null,
        'created_at': null,
      };

      final Relationship relationship = Relationship.fromMap(map);

      expect(relationship.id, 1);
      expect(relationship.contactId, testContactId);
      expect(relationship.relationshipType, testRelationshipType);
      expect(relationship.startDate, isNull);
      expect(relationship.description, isNull);
      expect(relationship.createdAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      const Relationship original = Relationship(
        id: 1,
        contactId: testContactId,
        relationshipType: testRelationshipType,
        startDate: testStartDate,
      );

      final Relationship updated = original.copyWith(
        relationshipType: 'colleague',
        description: testDescription,
      );

      expect(updated.id, 1);
      expect(updated.contactId, testContactId);
      expect(updated.relationshipType, 'colleague');
      expect(updated.startDate, testStartDate);
      expect(updated.description, testDescription);
      expect(
        original.relationshipType,
        testRelationshipType,
      ); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const Relationship relationship1 = Relationship(
        id: 1,
        contactId: testContactId,
        relationshipType: testRelationshipType,
        startDate: testStartDate,
      );

      const Relationship relationship2 = Relationship(
        id: 1,
        contactId: testContactId,
        relationshipType: testRelationshipType,
        startDate: testStartDate,
      );

      const Relationship relationship3 = Relationship(
        id: 2,
        contactId: testContactId,
        relationshipType: testRelationshipType,
        startDate: testStartDate,
      );

      expect(relationship1, equals(relationship2));
      expect(relationship1, isNot(equals(relationship3)));
      expect(relationship1.hashCode, equals(relationship2.hashCode));
    });

    test('should handle different relationship types', () {
      const List<String> relationshipTypes = <String>[
        'friend',
        'family',
        'colleague',
        'spouse',
        'partner',
        'sibling',
        'parent',
        'child',
        'neighbor',
        'acquaintance',
      ];

      for (final String relationshipType in relationshipTypes) {
        final Relationship relationship = Relationship(
          contactId: testContactId,
          relationshipType: relationshipType,
        );

        expect(relationship.relationshipType, relationshipType);

        final Map<String, dynamic> map = relationship.toMap();
        expect(map['relationship_type'], relationshipType);

        final Relationship fromMap = Relationship.fromMap(map);
        expect(fromMap.relationshipType, relationshipType);
      }
    });

    test('should handle different start date formats', () {
      const List<String> startDates = <String>[
        '2020-01-01T00:00:00.000Z',
        '2019-06-15T12:30:00.000Z',
        '2021-12-25T18:00:00.000Z',
        '2022-02-29T00:00:00.000Z', // Leap year
      ];

      for (final String startDate in startDates) {
        final Relationship relationship = Relationship(
          contactId: testContactId,
          relationshipType: testRelationshipType,
          startDate: startDate,
        );

        expect(relationship.startDate, startDate);

        final Map<String, dynamic> map = relationship.toMap();
        expect(map['start_date'], startDate);

        final Relationship fromMap = Relationship.fromMap(map);
        expect(fromMap.startDate, startDate);
      }
    });

    test('should handle various relationship descriptions', () {
      const List<String> descriptions = <String>[
        'College roommate',
        'Work colleague from marketing department',
        'Childhood friend from neighborhood',
        'Met through mutual friends at party',
        'Business partner in startup venture',
      ];

      for (final String description in descriptions) {
        final Relationship relationship = Relationship(
          contactId: testContactId,
          relationshipType: testRelationshipType,
          description: description,
        );

        expect(relationship.description, description);

        final Map<String, dynamic> map = relationship.toMap();
        final Relationship fromMap = Relationship.fromMap(map);

        expect(fromMap.description, description);
      }
    });

    test('should handle long relationship descriptions', () {
      const String longDescription =
          'This is a very detailed description of how we met and '
          'developed our relationship. '
          'We first encountered each other during our freshman year '
          'at university in the computer science program. '
          'Initially we were just classmates, but over time we became '
          'study partners and eventually close friends. '
          'Our friendship has continued to grow stronger over the years '
          'through shared experiences and mutual support.';

      const Relationship relationship = Relationship(
        contactId: testContactId,
        relationshipType: testRelationshipType,
        description: longDescription,
      );

      final Map<String, dynamic> map = relationship.toMap();
      final Relationship fromMap = Relationship.fromMap(map);

      expect(fromMap.description, longDescription);
    });

    test('should handle special characters in relationship type', () {
      const List<String> specialTypes = <String>[
        'ex-colleague',
        'step-parent',
        'in-law',
        'co-worker',
        'best friend',
      ];

      for (final String relationshipType in specialTypes) {
        final Relationship relationship = Relationship(
          contactId: testContactId,
          relationshipType: relationshipType,
        );

        final Map<String, dynamic> map = relationship.toMap();
        final Relationship fromMap = Relationship.fromMap(map);

        expect(fromMap.relationshipType, relationshipType);
      }
    });

    test('should handle edge case with empty strings', () {
      const Relationship relationship = Relationship(
        contactId: testContactId,
        relationshipType: '', // Empty but not null
        startDate: '',
        description: '',
      );

      final Map<String, dynamic> map = relationship.toMap();
      expect(map['relationship_type'], '');
      expect(map['start_date'], '');
      expect(map['description'], '');

      final Relationship fromMap = Relationship.fromMap(map);
      expect(fromMap.relationshipType, '');
      expect(fromMap.startDate, '');
      expect(fromMap.description, '');
    });

    test('should preserve relationship hierarchy information', () {
      const Map<String, String> familyRelationships = <String, String>{
        'parent': 'Mother figure in my life',
        'child': 'My daughter from previous marriage',
        'sibling': 'Younger brother, very close relationship',
        'grandparent': 'Maternal grandmother, very influential',
        'cousin': "First cousin on father's side",
      };

      for (final MapEntry<String, String> entry
          in familyRelationships.entries) {
        final Relationship relationship = Relationship(
          contactId: testContactId,
          relationshipType: entry.key,
          description: entry.value,
        );

        final Map<String, dynamic> map = relationship.toMap();
        final Relationship fromMap = Relationship.fromMap(map);

        expect(fromMap.relationshipType, entry.key);
        expect(fromMap.description, entry.value);
      }
    });

    test('should handle professional relationship types', () {
      const Map<String, String> professionalRelationships = <String, String>{
        'manager': 'Direct supervisor at current company',
        'employee': 'Junior developer on my team',
        'client': 'Long-term business client',
        'vendor': 'Preferred supplier for office supplies',
        'mentor': 'Career guidance and professional development',
      };

      for (final MapEntry<String, String> entry
          in professionalRelationships.entries) {
        final Relationship relationship = Relationship(
          contactId: testContactId,
          relationshipType: entry.key,
          description: entry.value,
        );

        final Map<String, dynamic> map = relationship.toMap();
        final Relationship fromMap = Relationship.fromMap(map);

        expect(fromMap.relationshipType, entry.key);
        expect(fromMap.description, entry.value);
      }
    });

    test('should handle relationship evolution over time', () {
      // Test that we can update relationship type to show evolution
      const Relationship original = Relationship(
        id: 1,
        contactId: testContactId,
        relationshipType: 'acquaintance',
        startDate: '2020-01-01T00:00:00.000Z',
        description: 'Met at networking event',
      );

      final Relationship evolved = original.copyWith(
        relationshipType: 'friend',
        description: 'Developed into close friendship over shared interests',
      );

      expect(evolved.relationshipType, 'friend');
      expect(
        evolved.description,
        'Developed into close friendship over shared interests',
      );
      expect(
        evolved.startDate,
        '2020-01-01T00:00:00.000Z',
      ); // Keep original start date
      expect(original.relationshipType, 'acquaintance'); // Original unchanged
    });
  });
}
