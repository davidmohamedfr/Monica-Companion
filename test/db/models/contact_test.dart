import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/contact.dart';

void main() {
  group('Contact Model', () {
    const String testName = 'John Doe';
    const String testEmail = 'john.doe@example.com';
    const String testPhone = '+1234567890';
    const String testAvatar = 'https://example.com/avatar.jpg';
    const String testBirthday = '1990-01-01';
    const String testAddress = '123 Main St, City, State';
    const String testNotes = 'Test notes';

    test('should create Contact with required fields', () {
      const Contact contact = Contact(name: testName);

      expect(contact.name, testName);
      expect(contact.id, isNull);
      expect(contact.email, isNull);
      expect(contact.phone, isNull);
      expect(contact.avatar, isNull);
      expect(contact.birthday, isNull);
      expect(contact.address, isNull);
      expect(contact.notes, isNull);
      expect(contact.createdAt, isNull);
      expect(contact.updatedAt, isNull);
    });

    test('should create Contact with all fields', () {
      final DateTime now = DateTime.now();
      final Contact contact = Contact(
        id: 1,
        name: testName,
        email: testEmail,
        phone: testPhone,
        avatar: testAvatar,
        birthday: testBirthday,
        address: testAddress,
        notes: testNotes,
        createdAt: now,
        updatedAt: now,
      );

      expect(contact.id, 1);
      expect(contact.name, testName);
      expect(contact.email, testEmail);
      expect(contact.phone, testPhone);
      expect(contact.avatar, testAvatar);
      expect(contact.birthday, testBirthday);
      expect(contact.address, testAddress);
      expect(contact.notes, testNotes);
      expect(contact.createdAt, now);
      expect(contact.updatedAt, now);
    });

    test('should convert Contact to Map correctly', () {
      final DateTime now = DateTime.now();
      final Contact contact = Contact(
        id: 1,
        name: testName,
        email: testEmail,
        phone: testPhone,
        avatar: testAvatar,
        birthday: testBirthday,
        address: testAddress,
        notes: testNotes,
        createdAt: now,
        updatedAt: now,
      );

      final Map<String, dynamic> map = contact.toMap();

      expect(map['id'], 1);
      expect(map['name'], testName);
      expect(map['email'], testEmail);
      expect(map['phone'], testPhone);
      expect(map['avatar'], testAvatar);
      expect(map['birthday'], testBirthday);
      expect(map['address'], testAddress);
      expect(map['notes'], testNotes);
      expect(map['created_at'], now.toIso8601String());
      expect(map['updated_at'], now.toIso8601String());
    });

    test('should create Contact from Map correctly', () {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'name': testName,
        'email': testEmail,
        'phone': testPhone,
        'avatar': testAvatar,
        'birthday': testBirthday,
        'address': testAddress,
        'notes': testNotes,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final Contact contact = Contact.fromMap(map);

      expect(contact.id, 1);
      expect(contact.name, testName);
      expect(contact.email, testEmail);
      expect(contact.phone, testPhone);
      expect(contact.avatar, testAvatar);
      expect(contact.birthday, testBirthday);
      expect(contact.address, testAddress);
      expect(contact.notes, testNotes);
      expect(contact.createdAt, now);
      expect(contact.updatedAt, now);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'name': testName,
        'email': null,
        'phone': null,
        'avatar': null,
        'birthday': null,
        'address': null,
        'notes': null,
        'created_at': null,
        'updated_at': null,
      };

      final Contact contact = Contact.fromMap(map);

      expect(contact.id, 1);
      expect(contact.name, testName);
      expect(contact.email, isNull);
      expect(contact.phone, isNull);
      expect(contact.avatar, isNull);
      expect(contact.birthday, isNull);
      expect(contact.address, isNull);
      expect(contact.notes, isNull);
      expect(contact.createdAt, isNull);
      expect(contact.updatedAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      const Contact original = Contact(
        id: 1,
        name: testName,
        email: testEmail,
      );

      final Contact updated = original.copyWith(
        name: 'Jane Doe',
        phone: testPhone,
      );

      expect(updated.id, 1);
      expect(updated.name, 'Jane Doe');
      expect(updated.email, testEmail);
      expect(updated.phone, testPhone);
      expect(original.name, testName); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const Contact contact1 = Contact(
        id: 1,
        name: testName,
        email: testEmail,
      );

      const Contact contact2 = Contact(
        id: 1,
        name: testName,
        email: testEmail,
      );

      const Contact contact3 = Contact(
        id: 2,
        name: testName,
        email: testEmail,
      );

      expect(contact1, equals(contact2));
      expect(contact1, isNot(equals(contact3)));
      expect(contact1.hashCode, equals(contact2.hashCode));
    });
  });
}