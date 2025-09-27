import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/gift.dart';

void main() {
  group('Gift Model', () {
    const int testContactId = 1;
    const String testName = 'Wireless Headphones';
    const String testDescription = 'Sony WH-1000XM4 noise-canceling headphones';
    const String testDateGiven = '2024-01-15T10:00:00.000Z';
    const String testOccasion = 'birthday';
    const double testValue = 299.99;

    test('should create Gift with required fields', () {
      const Gift gift = Gift(contactId: testContactId, name: testName);

      expect(gift.contactId, testContactId);
      expect(gift.name, testName);
      expect(gift.id, isNull);
      expect(gift.description, isNull);
      expect(gift.dateGiven, isNull);
      expect(gift.occasion, isNull);
      expect(gift.value, isNull);
      expect(gift.createdAt, isNull);
    });

    test('should create Gift with all fields', () {
      final DateTime now = DateTime.now();
      final Gift gift = Gift(
        id: 1,
        contactId: testContactId,
        name: testName,
        description: testDescription,
        dateGiven: testDateGiven,
        occasion: testOccasion,
        value: testValue,
        createdAt: now,
      );

      expect(gift.id, 1);
      expect(gift.contactId, testContactId);
      expect(gift.name, testName);
      expect(gift.description, testDescription);
      expect(gift.dateGiven, testDateGiven);
      expect(gift.occasion, testOccasion);
      expect(gift.value, testValue);
      expect(gift.createdAt, now);
    });

    test('should convert Gift to Map correctly', () {
      final DateTime now = DateTime.now();
      final Gift gift = Gift(
        id: 1,
        contactId: testContactId,
        name: testName,
        description: testDescription,
        dateGiven: testDateGiven,
        occasion: testOccasion,
        value: testValue,
        createdAt: now,
      );

      final Map<String, dynamic> map = gift.toMap();

      expect(map['id'], 1);
      expect(map['contact_id'], testContactId);
      expect(map['name'], testName);
      expect(map['description'], testDescription);
      expect(map['date_given'], testDateGiven);
      expect(map['occasion'], testOccasion);
      expect(map['value'], testValue);
      expect(map['created_at'], now.toIso8601String());
    });

    test('should create Gift from Map correctly', () {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'name': testName,
        'description': testDescription,
        'date_given': testDateGiven,
        'occasion': testOccasion,
        'value': testValue,
        'created_at': now.toIso8601String(),
      };

      final Gift gift = Gift.fromMap(map);

      expect(gift.id, 1);
      expect(gift.contactId, testContactId);
      expect(gift.name, testName);
      expect(gift.description, testDescription);
      expect(gift.dateGiven, testDateGiven);
      expect(gift.occasion, testOccasion);
      expect(gift.value, testValue);
      expect(gift.createdAt, now);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'name': testName,
        'description': null,
        'date_given': null,
        'occasion': null,
        'value': null,
        'created_at': null,
      };

      final Gift gift = Gift.fromMap(map);

      expect(gift.id, 1);
      expect(gift.contactId, testContactId);
      expect(gift.name, testName);
      expect(gift.description, isNull);
      expect(gift.dateGiven, isNull);
      expect(gift.occasion, isNull);
      expect(gift.value, isNull);
      expect(gift.createdAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      const Gift original = Gift(
        id: 1,
        contactId: testContactId,
        name: testName,
        value: 100,
      );

      final Gift updated = original.copyWith(
        name: 'Updated Gift Name',
        description: testDescription,
        occasion: testOccasion,
        value: testValue,
      );

      expect(updated.id, 1);
      expect(updated.contactId, testContactId);
      expect(updated.name, 'Updated Gift Name');
      expect(updated.description, testDescription);
      expect(updated.occasion, testOccasion);
      expect(updated.value, testValue);
      expect(original.name, testName); // Original should be unchanged
      expect(original.value, 100.0); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const Gift gift1 = Gift(
        id: 1,
        contactId: testContactId,
        name: testName,
        value: testValue,
      );

      const Gift gift2 = Gift(
        id: 1,
        contactId: testContactId,
        name: testName,
        value: testValue,
      );

      const Gift gift3 = Gift(
        id: 2,
        contactId: testContactId,
        name: testName,
        value: testValue,
      );

      expect(gift1, equals(gift2));
      expect(gift1, isNot(equals(gift3)));
      expect(gift1.hashCode, equals(gift2.hashCode));
    });

    test('should handle different occasions', () {
      const List<String> occasions = <String>[
        'birthday',
        'christmas',
        'anniversary',
        'graduation',
        'wedding',
      ];

      for (final String occasion in occasions) {
        final Gift gift = Gift(
          contactId: testContactId,
          name: testName,
          occasion: occasion,
        );

        expect(gift.occasion, occasion);

        final Map<String, dynamic> map = gift.toMap();
        expect(map['occasion'], occasion);

        final Gift fromMap = Gift.fromMap(map);
        expect(fromMap.occasion, occasion);
      }
    });

    test('should handle various gift values', () {
      const List<double> values = <double>[0, 1.50, 25.99, 100, 999.99, 1500];

      for (final double value in values) {
        final Gift gift = Gift(
          contactId: testContactId,
          name: testName,
          value: value,
        );

        expect(gift.value, value);

        final Map<String, dynamic> map = gift.toMap();
        final Gift fromMap = Gift.fromMap(map);

        expect(fromMap.value, value);
      }
    });

    test('should handle negative gift values', () {
      const double negativeValue = -50;

      const Gift gift = Gift(
        contactId: testContactId,
        name: testName,
        value: negativeValue,
      );

      expect(gift.value, negativeValue);

      final Map<String, dynamic> map = gift.toMap();
      final Gift fromMap = Gift.fromMap(map);

      expect(fromMap.value, negativeValue);
    });

    test('should handle precise decimal values', () {
      const List<double> preciseValues = <double>[
        19.99,
        123.456,
        0.01,
        9999.9999,
      ];

      for (final double value in preciseValues) {
        final Gift gift = Gift(
          contactId: testContactId,
          name: testName,
          value: value,
        );

        final Map<String, dynamic> map = gift.toMap();
        final Gift fromMap = Gift.fromMap(map);

        expect(fromMap.value, closeTo(value, 0.0001));
      }
    });

    test('should handle different date formats', () {
      const List<String> dateFormats = <String>[
        '2024-01-15T10:00:00.000Z',
        '2024-12-25T00:00:00.000Z',
        '2025-06-30T18:30:00.000Z',
      ];

      for (final String date in dateFormats) {
        final Gift gift = Gift(
          contactId: testContactId,
          name: testName,
          dateGiven: date,
        );

        expect(gift.dateGiven, date);

        final Map<String, dynamic> map = gift.toMap();
        expect(map['date_given'], date);

        final Gift fromMap = Gift.fromMap(map);
        expect(fromMap.dateGiven, date);
      }
    });

    test('should handle gift name variations', () {
      const List<String> giftNames = <String>[
        'Book',
        'iPhone 15 Pro',
        'Handmade Scarf',
        'Concert Tickets',
        'Gift Card - Amazon',
      ];

      for (final String name in giftNames) {
        final Gift gift = Gift(contactId: testContactId, name: name);

        expect(gift.name, name);

        final Map<String, dynamic> map = gift.toMap();
        final Gift fromMap = Gift.fromMap(map);

        expect(fromMap.name, name);
      }
    });

    test('should handle long descriptions', () {
      const String longDescription =
          'This is a very long description of a gift that someone gave to another person. '
          'It contains multiple sentences and explains in detail what the gift was, when it was given, '
          'why it was given, and how the recipient felt about receiving it. This tests that the model '
          'can handle longer text content without issues during serialization and deserialization.';

      const Gift gift = Gift(
        contactId: testContactId,
        name: testName,
        description: longDescription,
      );

      final Map<String, dynamic> map = gift.toMap();
      final Gift fromMap = Gift.fromMap(map);

      expect(fromMap.description, longDescription);
    });
  });
}
