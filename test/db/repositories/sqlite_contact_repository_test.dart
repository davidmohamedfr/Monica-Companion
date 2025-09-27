import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/models/contact.dart';
import 'package:monica_companion/db/repositories/sqlite_contact_repository.dart';

// Mock classes
class MockDatabaseInterface extends Mock implements DatabaseInterface {}

void main() {
  late SqliteContactRepository repository;
  late MockDatabaseInterface mockDatabase;

  final DateTime testDate = DateTime(2024, 1, 15, 10, 30);

  final List<Map<String, dynamic>> mockContactsResponse =
      <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'name': 'John Smith',
          'email': 'john.smith@email.com',
          'phone': '+1-555-0101',
          'avatar': '/avatars/john.jpg',
          'birthday': '1990-03-15',
          'address': '123 Main St, City, State',
          'notes': 'Close friend from college',
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
        },
        <String, dynamic>{
          'id': 2,
          'name': 'Jane Doe',
          'email': 'jane.doe@email.com',
          'phone': '+1-555-0102',
          'avatar': null,
          'birthday': '1985-07-22',
          'address': null,
          'notes': null,
          'created_at': testDate.toIso8601String(),
          'updated_at': null,
        },
        <String, dynamic>{
          'id': 3,
          'name': 'Bob Johnson',
          'email': null,
          'phone': '+1-555-0103',
          'avatar': null,
          'birthday': null,
          'address': '456 Oak Ave',
          'notes': 'Work colleague',
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
        },
      ];

  // Test data for expected contacts - currently not used in tests
  // final List<Contact> expectedContacts = <Contact>[
  //   Contact(
  //     id: 1,
  //     name: 'John Smith',
  //     email: 'john.smith@email.com',
  //     phone: '+1-555-0101',
  //     avatar: '/avatars/john.jpg',
  //     birthday: '1990-03-15',
  //     address: '123 Main St, City, State',
  //     notes: 'Close friend from college',
  //     createdAt: testDate,
  //     updatedAt: testDate,
  //   ),
  //   Contact(
  //     id: 2,
  //     name: 'Jane Doe',
  //     email: 'jane.doe@email.com',
  //     phone: '+1-555-0102',
  //     birthday: '1985-07-22',
  //     createdAt: testDate,
  //   ),
  //   Contact(
  //     id: 3,
  //     name: 'Bob Johnson',
  //     phone: '+1-555-0103',
  //     address: '456 Oak Ave',
  //     notes: 'Work colleague',
  //     createdAt: testDate,
  //     updatedAt: testDate,
  //   ),
  // ];

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(MockDatabaseInterface());
  });

  setUp(() {
    mockDatabase = MockDatabaseInterface();
    repository = SqliteContactRepository(mockDatabase);

    // Setup default mock behaviors
    when(
      () => mockDatabase.rawQuery(any(), any()),
    ).thenAnswer((_) async => <Map<String, dynamic>>[]);
  });

  group('SqliteContactRepository - findByName', () {
    testWidgets(
      'should find contacts by name with partial matching using LIKE',
      (WidgetTester tester) async {
        const String searchName = 'John';
        final List<Map<String, dynamic>> johnContacts = mockContactsResponse
            .where(
              (Map<String, dynamic> contact) =>
                  (contact['name'] as String).contains(searchName),
            )
            .toList();

        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => johnContacts);

        final List<Contact> result = await repository.findByName(searchName);

        expect(
          result,
          hasLength(2),
        ); // Both "John Smith" and "Bob Johnson" match
        expect(
          result.any((Contact contact) => contact.name == 'John Smith'),
          isTrue,
        );
        expect(
          result.any((Contact contact) => contact.name == 'Bob Johnson'),
          isTrue,
        );
        verify(
          () => mockDatabase.rawQuery(
            '''
        SELECT * FROM contacts
        WHERE name LIKE ?
        ORDER BY name ASC
      ''',
            <dynamic>['%$searchName%'],
          ),
        ).called(1);
      },
    );

    testWidgets('should return contacts ordered by name ascending', (
      WidgetTester tester,
    ) async {
      const String searchPattern = 'o'; // Should match John and Bob
      final List<Map<String, dynamic>> matchingContacts =
          <Map<String, dynamic>>[
            mockContactsResponse[2], // Bob Johnson
            mockContactsResponse[0], // John Smith
          ];

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => matchingContacts);

      final List<Contact> result = await repository.findByName(searchPattern);

      expect(result, hasLength(2));
      // Results should be ordered by the query (ASC)
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>['%$searchPattern%']),
      ).called(1);
    });

    testWidgets(
      'should return empty list when no contacts match name pattern',
      (WidgetTester tester) async {
        const String searchName = 'NonExistentName';
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final List<Contact> result = await repository.findByName(searchName);

        expect(result, isEmpty);
        verify(
          () => mockDatabase.rawQuery(any(), <dynamic>['%$searchName%']),
        ).called(1);
      },
    );

    testWidgets('should handle special characters in search pattern', (
      WidgetTester tester,
    ) async {
      const String searchName = "O'Connor";
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findByName(searchName);

      expect(result, isEmpty);
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>['%$searchName%']),
      ).called(1);
    });

    testWidgets('should handle empty search string', (
      WidgetTester tester,
    ) async {
      const String searchName = '';
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => mockContactsResponse);

      final List<Contact> result = await repository.findByName(searchName);

      expect(result, hasLength(3));
      verify(() => mockDatabase.rawQuery(any(), <dynamic>['%%'])).called(1);
    });

    testWidgets('should throw DatabaseException on query error', (
      WidgetTester tester,
    ) async {
      const String searchName = 'John';
      final Exception queryError = Exception('Database connection failed');
      when(() => mockDatabase.rawQuery(any(), any())).thenThrow(queryError);

      expect(
        () => repository.findByName(searchName),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );

      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });
  });

  group('SqliteContactRepository - findByEmail', () {
    testWidgets('should find contacts by exact email match', (
      WidgetTester tester,
    ) async {
      const String searchEmail = 'john.smith@email.com';
      final List<Map<String, dynamic>> emailContacts = mockContactsResponse
          .where(
            (Map<String, dynamic> contact) => contact['email'] == searchEmail,
          )
          .toList();

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => emailContacts);

      final List<Contact> result = await repository.findByEmail(searchEmail);

      expect(result, hasLength(1));
      expect(result.first.email, equals(searchEmail));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT * FROM contacts
        WHERE email = ?
        ORDER BY name ASC
      ''',
          <dynamic>[searchEmail],
        ),
      ).called(1);
    });

    testWidgets('should return empty list when no contacts match email', (
      WidgetTester tester,
    ) async {
      const String searchEmail = 'nonexistent@email.com';
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findByEmail(searchEmail);

      expect(result, isEmpty);
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>[searchEmail]),
      ).called(1);
    });

    testWidgets('should handle case sensitivity in email search', (
      WidgetTester tester,
    ) async {
      const String searchEmail = 'JOHN.SMITH@EMAIL.COM';
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findByEmail(searchEmail);

      expect(result, isEmpty);
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>[searchEmail]),
      ).called(1);
    });

    testWidgets(
      'should return contacts ordered by name when multiple matches',
      (WidgetTester tester) async {
        const String sharedEmail = 'shared@email.com';
        final List<Map<String, dynamic>> multipleContacts =
            <Map<String, dynamic>>[
              <String, dynamic>{
                ...mockContactsResponse[0],
                'email': sharedEmail,
                'name': 'Zoe Smith',
              },
              <String, dynamic>{
                ...mockContactsResponse[1],
                'email': sharedEmail,
                'name': 'Alice Johnson',
              },
            ];

        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => multipleContacts);

        final List<Contact> result = await repository.findByEmail(sharedEmail);

        expect(result, hasLength(2));
        verify(
          () => mockDatabase.rawQuery(any(), <dynamic>[sharedEmail]),
        ).called(1);
      },
    );

    testWidgets('should handle empty email search', (
      WidgetTester tester,
    ) async {
      const String searchEmail = '';
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findByEmail(searchEmail);

      expect(result, isEmpty);
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>[searchEmail]),
      ).called(1);
    });

    testWidgets('should throw DatabaseException on query error', (
      WidgetTester tester,
    ) async {
      const String searchEmail = 'test@email.com';
      final Exception queryError = Exception('SQL syntax error');
      when(() => mockDatabase.rawQuery(any(), any())).thenThrow(queryError);

      expect(
        () => repository.findByEmail(searchEmail),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );

      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });
  });

  group('SqliteContactRepository - findByBirthdayMonth', () {
    testWidgets('should find contacts by birthday month using strftime', (
      WidgetTester tester,
    ) async {
      const int searchMonth = 3; // March
      final List<Map<String, dynamic>> marchBirthdays = mockContactsResponse
          .where(
            (Map<String, dynamic> contact) =>
                contact['birthday'] != null &&
                (contact['birthday'] as String).substring(5, 7) == '03',
          )
          .toList();

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => marchBirthdays);

      final List<Contact> result = await repository.findByBirthdayMonth(
        searchMonth,
      );

      expect(result, hasLength(1));
      expect(result.first.birthday, equals('1990-03-15'));
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT * FROM contacts
        WHERE strftime('%m', birthday) = ?
        ORDER BY strftime('%d', birthday) ASC, name ASC
      ''',
          <dynamic>['03'], // Month should be zero-padded
        ),
      ).called(1);
    });

    testWidgets('should pad single-digit months with zero', (
      WidgetTester tester,
    ) async {
      const int searchMonth = 7; // July
      final List<Map<String, dynamic>> julyBirthdays = mockContactsResponse
          .where(
            (Map<String, dynamic> contact) =>
                contact['birthday'] != null &&
                (contact['birthday'] as String).substring(5, 7) == '07',
          )
          .toList();

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => julyBirthdays);

      final List<Contact> result = await repository.findByBirthdayMonth(
        searchMonth,
      );

      expect(result, hasLength(1));
      expect(result.first.birthday, equals('1985-07-22'));
      verify(() => mockDatabase.rawQuery(any(), <dynamic>['07'])).called(1);
    });

    testWidgets(
      'should return empty list when no birthdays in specified month',
      (WidgetTester tester) async {
        const int searchMonth = 12; // December
        when(
          () => mockDatabase.rawQuery(any(), any()),
        ).thenAnswer((_) async => <Map<String, dynamic>>[]);

        final List<Contact> result = await repository.findByBirthdayMonth(
          searchMonth,
        );

        expect(result, isEmpty);
        verify(() => mockDatabase.rawQuery(any(), <dynamic>['12'])).called(1);
      },
    );

    testWidgets('should handle invalid month numbers gracefully', (
      WidgetTester tester,
    ) async {
      const int invalidMonth = 13;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findByBirthdayMonth(
        invalidMonth,
      );

      expect(result, isEmpty);
      verify(() => mockDatabase.rawQuery(any(), <dynamic>['13'])).called(1);
    });

    testWidgets('should order results by day then name', (
      WidgetTester tester,
    ) async {
      const int searchMonth = 3;
      final List<Map<String, dynamic>> orderedResults = <Map<String, dynamic>>[
        <String, dynamic>{
          ...mockContactsResponse[0],
          'birthday': '1990-03-05',
          'name': 'Alice March',
        },
        <String, dynamic>{
          ...mockContactsResponse[1],
          'birthday': '1985-03-15',
          'name': 'Bob March',
        },
      ];

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => orderedResults);

      final List<Contact> result = await repository.findByBirthdayMonth(
        searchMonth,
      );

      expect(result, hasLength(2));
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    testWidgets('should throw DatabaseException on query error', (
      WidgetTester tester,
    ) async {
      const int searchMonth = 6;
      final Exception queryError = Exception('strftime function error');
      when(() => mockDatabase.rawQuery(any(), any())).thenThrow(queryError);

      expect(
        () => repository.findByBirthdayMonth(searchMonth),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );

      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });
  });

  group('SqliteContactRepository - findUpcomingBirthdays', () {
    testWidgets('should find upcoming birthdays within specified days', (
      WidgetTester tester,
    ) async {
      const int daysAhead = 30;
      final List<Map<String, dynamic>> upcomingBirthdays =
          <Map<String, dynamic>>[
            <String, dynamic>{
              ...mockContactsResponse[0],
              'birthday': DateTime.now()
                  .add(const Duration(days: 10))
                  .toIso8601String()
                  .substring(0, 10),
            },
          ];

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => upcomingBirthdays);

      final List<Contact> result = await repository.findUpcomingBirthdays(
        daysAhead,
      );

      expect(result, hasLength(1));
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    testWidgets('should use complex date logic for year boundary handling', (
      WidgetTester tester,
    ) async {
      const int daysAhead = 60;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findUpcomingBirthdays(
        daysAhead,
      );

      // Verify the complex SQL with multiple date conditions
      final List<dynamic> captured = verify(
        () => mockDatabase.rawQuery(captureAny(), captureAny()),
      ).captured;
      final String sql = captured[0] as String;
      final List<dynamic> params = captured[1] as List<dynamic>;

      expect(sql, contains("strftime('%m-%d', birthday) BETWEEN"));
      expect(sql, contains('OR ('));
      expect(params, hasLength(5)); // Five date parameters for complex logic
      expect(result, isEmpty);
    });

    testWidgets('should exclude contacts without birthdays', (
      WidgetTester tester,
    ) async {
      const int daysAhead = 30;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      await repository.findUpcomingBirthdays(daysAhead);

      final List<dynamic> captured = verify(
        () => mockDatabase.rawQuery(captureAny(), any()),
      ).captured;
      final String sql = captured[0] as String;
      expect(sql, contains('WHERE birthday IS NOT NULL'));
    });

    testWidgets('should order results by month, day, then name', (
      WidgetTester tester,
    ) async {
      const int daysAhead = 90;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      await repository.findUpcomingBirthdays(daysAhead);

      final List<dynamic> captured = verify(
        () => mockDatabase.rawQuery(captureAny(), any()),
      ).captured;
      final String sql = captured[0] as String;
      expect(
        sql,
        contains(
          "ORDER BY strftime('%m', birthday) ASC, strftime('%d', birthday) ASC, name ASC",
        ),
      );
    });

    testWidgets('should handle zero days ahead', (WidgetTester tester) async {
      const int daysAhead = 0;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findUpcomingBirthdays(
        daysAhead,
      );

      expect(result, isEmpty);
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    testWidgets('should handle negative days ahead', (
      WidgetTester tester,
    ) async {
      const int daysAhead = -10;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findUpcomingBirthdays(
        daysAhead,
      );

      expect(result, isEmpty);
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    testWidgets('should throw DatabaseException on query error', (
      WidgetTester tester,
    ) async {
      const int daysAhead = 30;
      final Exception queryError = Exception('Complex date query failed');
      when(() => mockDatabase.rawQuery(any(), any())).thenThrow(queryError);

      expect(
        () => repository.findUpcomingBirthdays(daysAhead),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );

      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });
  });

  group('SqliteContactRepository - search (Cross-field)', () {
    testWidgets('should search across name, email, and phone fields', (
      WidgetTester tester,
    ) async {
      const String searchQuery = '555';
      final List<Map<String, dynamic>> matchingContacts = mockContactsResponse
          .where(
            (Map<String, dynamic> contact) =>
                (contact['name'] as String).contains(searchQuery) ||
                ((contact['email'] as String?)?.contains(searchQuery) ??
                    false) ||
                ((contact['phone'] as String?)?.contains(searchQuery) ?? false),
          )
          .toList();

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => matchingContacts);

      final List<Contact> result = await repository.search(searchQuery);

      expect(result, hasLength(3)); // All contacts have phone numbers with 555
      verify(
        () => mockDatabase.rawQuery(
          '''
        SELECT * FROM contacts
        WHERE name LIKE ? OR email LIKE ? OR phone LIKE ?
        ORDER BY name ASC
      ''',
          <dynamic>['%$searchQuery%', '%$searchQuery%', '%$searchQuery%'],
        ),
      ).called(1);
    });

    testWidgets('should find contacts by partial name match in search', (
      WidgetTester tester,
    ) async {
      const String searchQuery = 'John';
      final List<Map<String, dynamic>> nameMatches = mockContactsResponse
          .where(
            (Map<String, dynamic> contact) =>
                (contact['name'] as String).contains(searchQuery),
          )
          .toList();

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => nameMatches);

      final List<Contact> result = await repository.search(searchQuery);

      expect(result, hasLength(2)); // Both "John Smith" and "Bob Johnson" match
      expect(
        result.every((Contact contact) => contact.name.contains(searchQuery)),
        isTrue,
      );
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    testWidgets('should find contacts by email domain in search', (
      WidgetTester tester,
    ) async {
      const String searchQuery = 'email.com';
      final List<Map<String, dynamic>> emailMatches = mockContactsResponse
          .where(
            (Map<String, dynamic> contact) =>
                (contact['email'] as String?)?.contains(searchQuery) ?? false,
          )
          .toList();

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => emailMatches);

      final List<Contact> result = await repository.search(searchQuery);

      expect(result, hasLength(2)); // John and Jane have email.com addresses
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    testWidgets('should find contacts by phone area code in search', (
      WidgetTester tester,
    ) async {
      const String searchQuery = '0101';
      final List<Map<String, dynamic>> phoneMatches = mockContactsResponse
          .where(
            (Map<String, dynamic> contact) =>
                (contact['phone'] as String?)?.contains(searchQuery) ?? false,
          )
          .toList();

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => phoneMatches);

      final List<Contact> result = await repository.search(searchQuery);

      expect(result, hasLength(1));
      expect(result.first.phone, contains(searchQuery));
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    testWidgets('should return results ordered by name ascending', (
      WidgetTester tester,
    ) async {
      const String searchQuery = 'o'; // Should match multiple contacts
      final List<Map<String, dynamic>> orderedResults = <Map<String, dynamic>>[
        mockContactsResponse[2], // Bob Johnson
        mockContactsResponse[0], // John Smith
      ];

      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => orderedResults);

      final List<Contact> result = await repository.search(searchQuery);

      expect(result, hasLength(2));
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    testWidgets('should handle empty search query', (
      WidgetTester tester,
    ) async {
      const String searchQuery = '';
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => mockContactsResponse);

      final List<Contact> result = await repository.search(searchQuery);

      expect(result, hasLength(3));
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>['%%', '%%', '%%']),
      ).called(1);
    });

    testWidgets('should handle special characters in search query', (
      WidgetTester tester,
    ) async {
      const String searchQuery = r'@#$%';
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.search(searchQuery);

      expect(result, isEmpty);
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>[
          '%$searchQuery%',
          '%$searchQuery%',
          '%$searchQuery%',
        ]),
      ).called(1);
    });

    testWidgets('should return empty list when no matches found', (
      WidgetTester tester,
    ) async {
      const String searchQuery = 'NoMatchesFound';
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.search(searchQuery);

      expect(result, isEmpty);
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    testWidgets('should throw DatabaseException on query error', (
      WidgetTester tester,
    ) async {
      const String searchQuery = 'test';
      final Exception queryError = Exception('Cross-field search failed');
      when(() => mockDatabase.rawQuery(any(), any())).thenThrow(queryError);

      expect(
        () => repository.search(searchQuery),
        throwsA(
          isA<DatabaseException>().having(
            (DatabaseException e) => e.message,
            'message',
            contains('An unexpected error occurred'),
          ),
        ),
      );

      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });
  });

  group('SqliteContactRepository - fromMap', () {
    testWidgets(
      'should correctly convert database map to Contact model with all fields',
      (WidgetTester tester) async {
        final Map<String, dynamic> contactMap = mockContactsResponse[0];

        final Contact result = repository.fromMap(contactMap);

        expect(result.id, equals(1));
        expect(result.name, equals('John Smith'));
        expect(result.email, equals('john.smith@email.com'));
        expect(result.phone, equals('+1-555-0101'));
        expect(result.avatar, equals('/avatars/john.jpg'));
        expect(result.birthday, equals('1990-03-15'));
        expect(result.address, equals('123 Main St, City, State'));
        expect(result.notes, equals('Close friend from college'));
        expect(result.createdAt, equals(testDate));
        expect(result.updatedAt, equals(testDate));
      },
    );

    testWidgets(
      'should handle null values correctly when converting from map',
      (WidgetTester tester) async {
        final Map<String, dynamic> contactMap = <String, dynamic>{
          'id': null,
          'name': 'Minimal Contact',
          'email': null,
          'phone': null,
          'avatar': null,
          'birthday': null,
          'address': null,
          'notes': null,
          'created_at': null,
          'updated_at': null,
        };

        final Contact result = repository.fromMap(contactMap);

        expect(result.id, isNull);
        expect(result.name, equals('Minimal Contact'));
        expect(result.email, isNull);
        expect(result.phone, isNull);
        expect(result.avatar, isNull);
        expect(result.birthday, isNull);
        expect(result.address, isNull);
        expect(result.notes, isNull);
        expect(result.createdAt, isNull);
        expect(result.updatedAt, isNull);
      },
    );

    testWidgets('should handle date parsing correctly', (
      WidgetTester tester,
    ) async {
      final Map<String, dynamic> contactMap = <String, dynamic>{
        'id': 1,
        'name': 'Date Test Contact',
        'created_at': '2024-01-15T10:30:00.000Z',
        'updated_at': '2024-01-15T15:45:30.123Z',
      };

      final Contact result = repository.fromMap(contactMap);

      expect(result.createdAt, isA<DateTime>());
      expect(result.updatedAt, isA<DateTime>());
      expect(
        result.createdAt?.toIso8601String(),
        equals('2024-01-15T10:30:00.000Z'),
      );
      expect(
        result.updatedAt?.toIso8601String(),
        equals('2024-01-15T15:45:30.123Z'),
      );
    });
  });

  group('SqliteContactRepository - Edge Cases', () {
    testWidgets('should handle very long search strings', (
      WidgetTester tester,
    ) async {
      final String longSearchString = 'A' * 1000;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findByName(
        longSearchString,
      );

      expect(result, isEmpty);
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>['%$longSearchString%']),
      ).called(1);
    });

    testWidgets('should handle unicode characters in search', (
      WidgetTester tester,
    ) async {
      const String unicodeName = '张三'; // Chinese characters
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findByName(unicodeName);

      expect(result, isEmpty);
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>['%$unicodeName%']),
      ).called(1);
    });

    testWidgets('should handle SQL injection attempts safely', (
      WidgetTester tester,
    ) async {
      const String maliciousInput = "'; DROP TABLE contacts; --";
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findByName(maliciousInput);

      expect(result, isEmpty);
      // Parameters should be safely escaped
      verify(
        () => mockDatabase.rawQuery(any(), <dynamic>['%$maliciousInput%']),
      ).called(1);
    });

    testWidgets('should handle extreme birthday month values', (
      WidgetTester tester,
    ) async {
      const int extremeMonth = 99999;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findByBirthdayMonth(
        extremeMonth,
      );

      expect(result, isEmpty);
      verify(() => mockDatabase.rawQuery(any(), <dynamic>['99999'])).called(1);
    });

    testWidgets('should handle very large daysAhead values', (
      WidgetTester tester,
    ) async {
      const int largeDaysAhead = 999999;
      when(
        () => mockDatabase.rawQuery(any(), any()),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      final List<Contact> result = await repository.findUpcomingBirthdays(
        largeDaysAhead,
      );

      expect(result, isEmpty);
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });
  });
}
