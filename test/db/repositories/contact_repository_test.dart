import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/db/interfaces/contact_repository.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/models/contact.dart';
import 'package:monica_companion/db/repositories/sqlite_contact_repository.dart';

class MockDatabaseInterface extends Mock implements DatabaseInterface {}

void main() {
  late MockDatabaseInterface mockDatabase;
  late ContactRepository repository;

  setUp(() {
    mockDatabase = MockDatabaseInterface();
    repository = SqliteContactRepository(mockDatabase);
  });

  group('SqliteContactRepository', () {
    const String testName = 'John Doe';
    const String testEmail = 'john.doe@example.com';

    final Contact testContact = Contact(
      id: 1,
      name: testName,
      email: testEmail,
      createdAt: DateTime.now(),
    );

    final Map<String, dynamic> testContactMap = testContact.toMap();

    test('findByName should return contacts matching name pattern', () async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[testContactMap]);

      final List<Contact> result = await repository.findByName('John');

      expect(result, hasLength(1));
      expect(result.first.name, testName);
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT * FROM contacts
        WHERE name LIKE ?
        ORDER BY name ASC
      ''',
          <dynamic>['%John%'],
        ),
      ).called(1);
    });

    test('findByEmail should return contacts with matching email', () async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[testContactMap]);

      final List<Contact> result = await repository.findByEmail(testEmail);

      expect(result, hasLength(1));
      expect(result.first.email, testEmail);
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT * FROM contacts
        WHERE email = ?
        ORDER BY name ASC
      ''',
          <dynamic>[testEmail],
        ),
      ).called(1);
    });

    test(
      'findByBirthdayMonth should return contacts with birthdays in month',
      () async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[testContactMap]);

        final List<Contact> result = await repository.findByBirthdayMonth(1);

        expect(result, hasLength(1));
        verify(
          () => mockDatabase.rawQuery(
            '''
        SELECT * FROM contacts
        WHERE strftime('%m', birthday) = ?
        ORDER BY strftime('%d', birthday) ASC, name ASC
      ''',
            <dynamic>['01'],
          ),
        ).called(1);
      },
    );

    test(
      'findUpcomingBirthdays should return contacts with upcoming birthdays',
      () async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[testContactMap]);

        final List<Contact> result = await repository.findUpcomingBirthdays(30);

        expect(result, hasLength(1));
        verify(() => mockDatabase.rawQuery(any(), any())).called(1);
      },
    );

    test(
      'search should return contacts matching query in name, email, or phone',
      () async {
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[testContactMap]);

        final List<Contact> result = await repository.search('John');

        expect(result, hasLength(1));
        verify(
          () => mockDatabase.rawQuery(
            '''
        SELECT * FROM contacts
        WHERE name LIKE ? OR email LIKE ? OR phone LIKE ?
        ORDER BY name ASC
      ''',
            <dynamic>['%John%', '%John%', '%John%'],
          ),
        ).called(1);
      },
    );

    test('findAll should return all contacts ordered by id desc', () async {
      when(
        () => mockDatabase.rawQuery('SELECT * FROM contacts ORDER BY id DESC'),
      ).thenAnswer((_) async => <Map<String, dynamic>>[testContactMap]);

      final List<Contact> result = await repository.findAll();

      expect(result, hasLength(1));
      expect(result.first.name, testName);
      verify(
        () => mockDatabase.rawQuery('SELECT * FROM contacts ORDER BY id DESC'),
      ).called(1);
    });

    test('findById should return contact with matching id', () async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[testContactMap]);

      final Contact? result = await repository.findById(1);

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.name, testName);
      verify(
        () => mockDatabase.rawQuery(
          'SELECT * FROM contacts WHERE id = ? LIMIT 1',
          <dynamic>[1],
        ),
      ).called(1);
    });

    test('findById should return null when contact not found', () async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final Contact? result = await repository.findById(999);

      expect(result, isNull);
    });

    test('insert should insert contact and return id', () async {
      when(
        () => mockDatabase.rawExecute(any(), any()),
      ).thenAnswer((_) async => 1);

      final int result = await repository.insert(testContact);

      expect(result, 1);
      verify(
        () => mockDatabase.rawExecute(
          'INSERT INTO contacts (name, email, phone, avatar, birthday, address, notes, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          any(),
        ),
      ).called(1);
    });

    test('update should update contact and return success', () async {
      when(
        () => mockDatabase.rawExecute(any(), any()),
      ).thenAnswer((_) async => 1);

      final bool result = await repository.update(testContact);

      expect(result, true);
      verify(
        () => mockDatabase.rawExecute(
          'UPDATE contacts SET name = ?, email = ?, phone = ?, avatar = ?, birthday = ?, address = ?, notes = ?, created_at = ?, updated_at = ? WHERE id = ?',
          any(),
        ),
      ).called(1);
    });

    test('delete should delete contact and return success', () async {
      when(
        () => mockDatabase.rawExecute(any(), any()),
      ).thenAnswer((_) async => 1);

      final bool result = await repository.delete(1);

      expect(result, true);
      verify(
        () => mockDatabase.rawExecute(
          'DELETE FROM contacts WHERE id = ?',
          <dynamic>[1],
        ),
      ).called(1);
    });

    test('count should return total number of contacts', () async {
      when(
        () => mockDatabase.rawQuery('SELECT COUNT(*) as count FROM contacts'),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          <String, dynamic>{'count': 5},
        ],
      );

      final int result = await repository.count();

      expect(result, 5);
      verify(
        () => mockDatabase.rawQuery('SELECT COUNT(*) as count FROM contacts'),
      ).called(1);
    });

    test('exists should return true when contact exists', () async {
      when(() => mockDatabase.rawQuery(any(), any())).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          <String, dynamic>{'dummy': 1},
        ],
      );

      final bool result = await repository.exists(1);

      expect(result, true);
      verify(
        () => mockDatabase.rawQuery(
          'SELECT 1 FROM contacts WHERE id = ? LIMIT 1',
          <dynamic>[1],
        ),
      ).called(1);
    });

    test('exists should return false when contact does not exist', () async {
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final bool result = await repository.exists(999);

      expect(result, false);
    });
  });
}
