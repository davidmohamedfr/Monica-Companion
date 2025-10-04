import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('Contact Model Tests', () {
    late Contact testContact;
    late DateTime testDateTime;

    setUpAll(TestHelpers.setupMockFallbacks);

    setUp(() {
      testDateTime = TestHelpers.createMockDateTime(
        month: 6,
        day: 15,
        hour: 10,
        minute: 30,
      );

      testContact = Contact(
        id: 'test-id-123',
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john.doe@example.com',
        photoUrl: 'https://example.com/photo.jpg',
        isFavorite: true,
        lastContactedAt: testDateTime,
      );
    });

    group('Constructor Tests', () {
      test('should create Contact with notes field', () {
        // Arrange & Act
        const Contact contact = Contact(
          id: 'test-id',
          name: 'Test User',
          notes: 'Important client, prefers email contact',
        );

        // Assert
        expect(
          contact.notes,
          equals('Important client, prefers email contact'),
        );
      });

      test('should create Contact with all parameters', () {
        // Act & Assert
        expect(testContact.id, equals('test-id-123'));
        expect(testContact.name, equals('John Doe'));
        expect(testContact.phone, equals('+1234567890'));
        expect(testContact.email, equals('john.doe@example.com'));
        expect(testContact.photoUrl, equals('https://example.com/photo.jpg'));
        expect(testContact.isFavorite, isTrue);
        expect(testContact.lastContactedAt, equals(testDateTime));
        expect(testContact.needsInteractionSoon, isFalse);
      });

      test('should create Contact without notes field (null)', () {
        // Arrange & Act
        const Contact contact = Contact(
          id: 'no-notes-id',
          name: 'User Without Notes',
        );

        // Assert
        expect(contact.notes, isNull);
      });

      test('should create Contact with required parameters only', () {
        // Arrange & Act
        const Contact contact = Contact(id: 'minimal-id', name: 'Jane Smith');

        // Assert
        expect(contact.id, equals('minimal-id'));
        expect(contact.name, equals('Jane Smith'));
        expect(contact.phone, isNull);
        expect(contact.email, isNull);
        expect(contact.photoUrl, isNull);
        expect(contact.notes, isNull);
        expect(contact.isFavorite, isFalse);
        expect(contact.lastContactedAt, isNull);
        expect(contact.needsInteractionSoon, isFalse);
      });

      test('should create Contact with default values', () {
        // Arrange & Act
        const Contact contact = Contact(
          id: 'default-test',
          name: 'Default User',
        );

        // Assert
        expect(contact.isFavorite, isFalse);
        expect(contact.needsInteractionSoon, isFalse);
      });
    });

    group('copyWith Tests', () {
      test('should create copy with updated name', () {
        // Act
        final Contact updatedContact = testContact.copyWith(name: 'Jane Doe');

        // Assert
        expect(updatedContact.id, equals(testContact.id));
        expect(updatedContact.name, equals('Jane Doe'));
        expect(updatedContact.phone, equals(testContact.phone));
        expect(updatedContact.email, equals(testContact.email));
        expect(updatedContact.photoUrl, equals(testContact.photoUrl));
        expect(updatedContact.isFavorite, equals(testContact.isFavorite));
        expect(
          updatedContact.lastContactedAt,
          equals(testContact.lastContactedAt),
        );
        expect(
          updatedContact.needsInteractionSoon,
          equals(testContact.needsInteractionSoon),
        );
      });

      test('should create copy with updated favorite status', () {
        // Act
        final Contact updatedContact = testContact.copyWith(isFavorite: false);

        // Assert
        expect(updatedContact.isFavorite, isFalse);
        expect(updatedContact.name, equals(testContact.name));
      });

      test('should create copy with updated interaction status', () {
        // Act
        final Contact updatedContact = testContact.copyWith(
          needsInteractionSoon: true,
        );

        // Assert
        expect(updatedContact.needsInteractionSoon, isTrue);
        expect(updatedContact.name, equals(testContact.name));
      });

      test('should create copy with updated notes', () {
        // Act
        final Contact updatedContact = testContact.copyWith(
          notes: 'Updated notes for this contact',
        );

        // Assert
        expect(updatedContact.notes, equals('Updated notes for this contact'));
        expect(updatedContact.name, equals(testContact.name));
      });

      test('should create copy with updated contact information', () {
        // Arrange
        final DateTime newDateTime = TestHelpers.createMockDateTime(year: 2024);

        // Act
        final Contact updatedContact = testContact.copyWith(
          phone: '+0987654321',
          email: 'jane.doe@example.com',
          lastContactedAt: newDateTime,
        );

        // Assert
        expect(updatedContact.phone, equals('+0987654321'));
        expect(updatedContact.email, equals('jane.doe@example.com'));
        expect(updatedContact.lastContactedAt, equals(newDateTime));
        expect(updatedContact.name, equals(testContact.name));
      });

      test('should create identical copy when no parameters provided', () {
        // Act
        final Contact copiedContact = testContact.copyWith();

        // Assert
        expect(copiedContact.id, equals(testContact.id));
        expect(copiedContact.name, equals(testContact.name));
        expect(copiedContact.phone, equals(testContact.phone));
        expect(copiedContact.email, equals(testContact.email));
        expect(copiedContact.photoUrl, equals(testContact.photoUrl));
        expect(copiedContact.isFavorite, equals(testContact.isFavorite));
        expect(
          copiedContact.lastContactedAt,
          equals(testContact.lastContactedAt),
        );
        expect(
          copiedContact.needsInteractionSoon,
          equals(testContact.needsInteractionSoon),
        );
      });
    });

    group('Equatable Tests', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final Contact contact1 = Contact(
          id: 'same-id',
          name: 'Same Name',
          phone: '+1234567890',
          email: 'same@example.com',
          photoUrl: 'https://example.com/same.jpg',
          isFavorite: true,
          lastContactedAt: testDateTime,
        );

        final Contact contact2 = Contact(
          id: 'same-id',
          name: 'Same Name',
          phone: '+1234567890',
          email: 'same@example.com',
          photoUrl: 'https://example.com/same.jpg',
          isFavorite: true,
          lastContactedAt: testDateTime,
        );

        // Act & Assert
        expect(contact1, equals(contact2));
        expect(contact1.hashCode, equals(contact2.hashCode));
      });

      test('should not be equal when id is different', () {
        // Arrange
        const Contact contact1 = Contact(id: 'id-1', name: 'Same Name');

        const Contact contact2 = Contact(id: 'id-2', name: 'Same Name');

        // Act & Assert
        expect(contact1, isNot(equals(contact2)));
      });

      test('should not be equal when name is different', () {
        // Arrange
        const Contact contact1 = Contact(id: 'same-id', name: 'Name One');

        const Contact contact2 = Contact(id: 'same-id', name: 'Name Two');

        // Act & Assert
        expect(contact1, isNot(equals(contact2)));
      });

      test('should not be equal when notes differ', () {
        // Arrange
        const Contact contact1 = Contact(
          id: 'same-id',
          name: 'Same Name',
          notes: 'Some notes',
        );

        const Contact contact2 = Contact(
          id: 'same-id',
          name: 'Same Name',
          notes: 'Different notes',
        );

        // Act & Assert
        expect(contact1, isNot(equals(contact2)));
      });

      test('should not be equal when optional properties differ', () {
        // Arrange
        const Contact contact1 = Contact(
          id: 'same-id',
          name: 'Same Name',
          isFavorite: true,
        );

        const Contact contact2 = Contact(id: 'same-id', name: 'Same Name');

        // Act & Assert
        expect(contact1, isNot(equals(contact2)));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle empty strings correctly', () {
        // Arrange & Act
        const Contact contact = Contact(
          id: '',
          name: '',
          phone: '',
          email: '',
          photoUrl: '',
        );

        // Assert
        expect(contact.id, equals(''));
        expect(contact.name, equals(''));
        expect(contact.phone, equals(''));
        expect(contact.email, equals(''));
        expect(contact.photoUrl, equals(''));
      });

      test('should handle null parameters in copyWith correctly', () {
        // Note: copyWith with null parameters should preserve original values
        // This is the standard Flutter copyWith behavior

        // Act
        final Contact updatedContact = testContact.copyWith();

        // Assert - null parameters should preserve original values
        expect(updatedContact.phone, equals(testContact.phone));
        expect(updatedContact.email, equals(testContact.email));
        expect(updatedContact.photoUrl, equals(testContact.photoUrl));
        expect(
          updatedContact.lastContactedAt,
          equals(testContact.lastContactedAt),
        );
        expect(updatedContact.name, equals(testContact.name));
      });

      test('should handle special characters in contact information', () {
        // Arrange & Act
        const Contact contact = Contact(
          id: 'special-chars-123',
          name: 'José María García-López',
          phone: '+33 1 23 45 67 89',
          email: 'josé.maría@example.com',
          photoUrl: 'https://example.com/photos/josé_maría.jpg?v=1&format=jpeg',
        );

        // Assert
        expect(contact.name, equals('José María García-López'));
        expect(contact.phone, equals('+33 1 23 45 67 89'));
        expect(contact.email, equals('josé.maría@example.com'));
        expect(
          contact.photoUrl,
          equals('https://example.com/photos/josé_maría.jpg?v=1&format=jpeg'),
        );
      });
    });

    group('toString Tests', () {
      test('should include all properties in props list', () {
        // Arrange
        final Contact contact = Contact(
          id: 'test-id',
          name: 'Test Name',
          phone: '+1234567890',
          email: 'test@example.com',
          photoUrl: 'https://example.com/test.jpg',
          isFavorite: true,
          lastContactedAt: testDateTime,
          needsInteractionSoon: true,
        );

        // Act
        final List<Object?> props = contact.props;

        // Assert
        expect(props, hasLength(9));
        expect(props, contains('test-id'));
        expect(props, contains('Test Name'));
        expect(props, contains('+1234567890'));
        expect(props, contains('test@example.com'));
        expect(props, contains('https://example.com/test.jpg'));
        expect(props, contains(true));
        expect(props, contains(testDateTime));
        expect(props, contains(true));
      });
    });
  });
}
