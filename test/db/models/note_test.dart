import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/note.dart';

void main() {
  group('Note Model', () {
    const int testContactId = 1;
    const String testContent = 'This is a test note about John';
    const String testCategory = 'personal';
    const bool testIsPrivate = true;

    test('should create Note with required fields', () {
      const Note note = Note(
        contactId: testContactId,
        content: testContent,
      );

      expect(note.contactId, testContactId);
      expect(note.content, testContent);
      expect(note.isPrivate, false); // Default value
      expect(note.id, isNull);
      expect(note.category, isNull);
      expect(note.createdAt, isNull);
      expect(note.updatedAt, isNull);
    });

    test('should create Note with all fields', () {
      final DateTime now = DateTime.now();
      final DateTime updated = now.add(const Duration(hours: 1));
      final Note note = Note(
        id: 1,
        contactId: testContactId,
        content: testContent,
        category: testCategory,
        isPrivate: testIsPrivate,
        createdAt: now,
        updatedAt: updated,
      );

      expect(note.id, 1);
      expect(note.contactId, testContactId);
      expect(note.content, testContent);
      expect(note.category, testCategory);
      expect(note.isPrivate, testIsPrivate);
      expect(note.createdAt, now);
      expect(note.updatedAt, updated);
    });

    test('should convert Note to Map correctly', () {
      final DateTime now = DateTime.now();
      final DateTime updated = now.add(const Duration(hours: 1));
      final Note note = Note(
        id: 1,
        contactId: testContactId,
        content: testContent,
        category: testCategory,
        isPrivate: testIsPrivate,
        createdAt: now,
        updatedAt: updated,
      );

      final Map<String, dynamic> map = note.toMap();

      expect(map['id'], 1);
      expect(map['contact_id'], testContactId);
      expect(map['content'], testContent);
      expect(map['category'], testCategory);
      expect(map['is_private'], 1); // Boolean stored as int
      expect(map['created_at'], now.toIso8601String());
      expect(map['updated_at'], updated.toIso8601String());
    });

    test('should create Note from Map correctly', () {
      final DateTime now = DateTime.now();
      final DateTime updated = now.add(const Duration(hours: 1));
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'content': testContent,
        'category': testCategory,
        'is_private': 1,
        'created_at': now.toIso8601String(),
        'updated_at': updated.toIso8601String(),
      };

      final Note note = Note.fromMap(map);

      expect(note.id, 1);
      expect(note.contactId, testContactId);
      expect(note.content, testContent);
      expect(note.category, testCategory);
      expect(note.isPrivate, true);
      expect(note.createdAt, now);
      expect(note.updatedAt, updated);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'content': testContent,
        'category': null,
        'is_private': null,
        'created_at': null,
        'updated_at': null,
      };

      final Note note = Note.fromMap(map);

      expect(note.id, 1);
      expect(note.contactId, testContactId);
      expect(note.content, testContent);
      expect(note.category, isNull);
      expect(note.isPrivate, false); // null treated as false
      expect(note.createdAt, isNull);
      expect(note.updatedAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      final DateTime now = DateTime.now();
      const Note original = Note(
        id: 1,
        contactId: testContactId,
        content: testContent,
        isPrivate: false,
      );

      final Note updated = original.copyWith(
        content: 'Updated note content',
        category: testCategory,
        isPrivate: testIsPrivate,
        updatedAt: now,
      );

      expect(updated.id, 1);
      expect(updated.contactId, testContactId);
      expect(updated.content, 'Updated note content');
      expect(updated.category, testCategory);
      expect(updated.isPrivate, testIsPrivate);
      expect(updated.updatedAt, now);
      expect(original.content, testContent); // Original should be unchanged
      expect(original.isPrivate, false); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const Note note1 = Note(
        id: 1,
        contactId: testContactId,
        content: testContent,
        category: testCategory,
        isPrivate: testIsPrivate,
      );

      const Note note2 = Note(
        id: 1,
        contactId: testContactId,
        content: testContent,
        category: testCategory,
        isPrivate: testIsPrivate,
      );

      const Note note3 = Note(
        id: 2,
        contactId: testContactId,
        content: testContent,
        category: testCategory,
        isPrivate: testIsPrivate,
      );

      expect(note1, equals(note2));
      expect(note1, isNot(equals(note3)));
      expect(note1.hashCode, equals(note2.hashCode));
    });

    test('should handle boolean isPrivate field correctly', () {
      // Test true value
      const Note privateNote = Note(
        contactId: testContactId,
        content: testContent,
        isPrivate: true,
      );

      final Map<String, dynamic> privateMap = privateNote.toMap();
      expect(privateMap['is_private'], 1);

      final Note privateFromMap = Note.fromMap(privateMap);
      expect(privateFromMap.isPrivate, true);

      // Test false value
      const Note publicNote = Note(
        contactId: testContactId,
        content: testContent,
        isPrivate: false,
      );

      final Map<String, dynamic> publicMap = publicNote.toMap();
      expect(publicMap['is_private'], 0);

      final Note publicFromMap = Note.fromMap(publicMap);
      expect(publicFromMap.isPrivate, false);
    });

    test('should handle different categories', () {
      const List<String> categories = ['personal', 'work', 'family', 'health', 'hobbies'];

      for (final String category in categories) {
        final Note note = Note(
          contactId: testContactId,
          content: testContent,
          category: category,
        );

        expect(note.category, category);

        final Map<String, dynamic> map = note.toMap();
        expect(map['category'], category);

        final Note fromMap = Note.fromMap(map);
        expect(fromMap.category, category);
      }
    });

    test('should handle isPrivate conversion from different int values', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'content': testContent,
        'category': testCategory,
        'is_private': 0,
        'created_at': null,
        'updated_at': null,
      };

      // Test with 0 (should be false)
      final Note note0 = Note.fromMap(map);
      expect(note0.isPrivate, false);

      // Test with 1 (should be true)
      map['is_private'] = 1;
      final Note note1 = Note.fromMap(map);
      expect(note1.isPrivate, true);

      // Test with other positive int (should be false, only 1 is true)
      map['is_private'] = 5;
      final Note note5 = Note.fromMap(map);
      expect(note5.isPrivate, false);
    });

    test('should use default isPrivate when not specified', () {
      const Note note = Note(
        contactId: testContactId,
        content: testContent,
      );

      expect(note.isPrivate, false);

      final Map<String, dynamic> map = note.toMap();
      expect(map['is_private'], 0);
    });
  });
}