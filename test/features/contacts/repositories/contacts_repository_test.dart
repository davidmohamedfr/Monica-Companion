import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:monica_companion/features/contacts/services/contacts_service.dart';
import '../../../helpers/test_helpers.dart';

// Mock classes
class MockContactsService extends Mock implements ContactsService {}

void main() {
  group('ContactsRepository Tests', () {
    late ContactsRepositoryImpl repository;
    late MockContactsService mockContactsService;

    // Test data
    late List<Contact> testContacts;
    late Contact johnDoe;
    late Contact janeDoe;
    late Contact bobSmith;
    late Contact aliceJohnson;

    setUpAll(TestHelpers.setupMockFallbacks);

    setUp(() {
      mockContactsService = MockContactsService();
      repository = ContactsRepositoryImpl(mockContactsService);

      // Create comprehensive test data
      final DateTime now = DateTime.now();

      johnDoe = Contact(
        id: '1',
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john.doe@email.com',
        isFavorite: true,
        lastContactedAt: now.subtract(const Duration(days: 5)),
      );

      janeDoe = Contact(
        id: '2',
        name: 'Jane Doe',
        phone: '+0987654321',
        email: 'jane.doe@email.com',
        lastContactedAt: now.subtract(const Duration(days: 10)),
      );

      bobSmith = Contact(
        id: '3',
        name: 'Bob Smith',
        phone: '+1122334455',
        email: 'bob.smith@company.com',
        isFavorite: true,
        needsInteractionSoon: true,
        lastContactedAt: now.subtract(const Duration(days: 45)),
      );

      aliceJohnson = Contact(
        id: '4',
        name: 'Alice Johnson',
        phone: '+5566778899',
        email: 'alice.johnson@domain.org',
        lastContactedAt: now.subtract(const Duration(days: 100)),
      );

      testContacts = <Contact>[johnDoe, janeDoe, bobSmith, aliceJohnson];

      // Setup default mock response
      when(
        () => mockContactsService.getDeviceContacts(),
      ).thenAnswer((_) async => testContacts);
    });

    group('getContacts Tests', () {
      test('should return all contacts from service', () async {
        // Act
        final List<Contact> result = await repository.getContacts();

        // Assert
        expect(result, equals(testContacts));
        expect(result.length, equals(4));
        verify(() => mockContactsService.getDeviceContacts()).called(1);
      });

      test('should propagate service exceptions', () async {
        // Arrange
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenThrow(Exception('Service error'));

        // Act & Assert
        expect(() async => repository.getContacts(), throwsA(isA<Exception>()));
      });
    });

    group('searchContacts Tests', () {
      test('should return all contacts when query is empty', () async {
        // Act
        final List<Contact> result = await repository.searchContacts('');

        // Assert
        expect(result, equals(testContacts));
        expect(result.length, equals(4));
      });

      test(
        'should return empty results when query is whitespace only',
        () async {
          // Act (whitespace query is not treated as empty by implementation)
          final List<Contact> result = await repository.searchContacts('   ');

          // Assert
          expect(result, isEmpty); // No contacts match whitespace
        },
      );

      test('should search by name (case insensitive)', () async {
        // Act
        final List<Contact> result = await repository.searchContacts('john');

        // Assert
        expect(result.length, equals(2));
        expect(result, contains(johnDoe));
        expect(result, contains(aliceJohnson));
      });

      test('should search by name with exact case', () async {
        // Act
        final List<Contact> result = await repository.searchContacts('John');

        // Assert
        expect(result.length, equals(2));
        expect(result, contains(johnDoe));
        expect(result, contains(aliceJohnson));
      });

      test('should search by phone number', () async {
        // Act
        final List<Contact> result = await repository.searchContacts(
          '1234567890',
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first, equals(johnDoe));
      });

      test('should search by partial phone number', () async {
        // Act
        final List<Contact> result = await repository.searchContacts('123');

        // Assert
        expect(result.length, equals(1));
        expect(result, contains(johnDoe)); // +1234567890 contains '123'
        // bobSmith (+1122334455) does not contain '123'
      });

      test('should search by email address', () async {
        // Act
        final List<Contact> result = await repository.searchContacts(
          'jane.doe@email.com',
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first, equals(janeDoe));
      });

      test('should search by email domain', () async {
        // Act
        final List<Contact> result = await repository.searchContacts(
          'email.com',
        );

        // Assert
        expect(result.length, equals(2));
        expect(result, contains(johnDoe));
        expect(result, contains(janeDoe));
      });

      test('should handle special characters in search query', () async {
        // Act
        final List<Contact> result = await repository.searchContacts(
          '@company',
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first, equals(bobSmith));
      });

      test('should return empty list for non-matching query', () async {
        // Act
        final List<Contact> result = await repository.searchContacts(
          'nonexistent',
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should handle Unicode characters in search', () async {
        // Arrange
        const Contact unicodeContact = Contact(
          id: '5',
          name: 'José García',
          phone: '+34123456789',
          email: 'jose@example.com',
        );
        final List<Contact> contactsWithUnicode = <Contact>[
          ...testContacts,
          unicodeContact,
        ];
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenAnswer((_) async => contactsWithUnicode);

        // Act
        final List<Contact> result = await repository.searchContacts('José');

        // Assert
        expect(result.length, equals(1));
        expect(result.first.name, equals('José García'));
      });

      test('should search contacts with null phone number', () async {
        // Arrange
        const Contact contactWithoutPhone = Contact(
          id: '6',
          name: 'No Phone Contact',
          email: 'nophone@example.com',
        );
        final List<Contact> modifiedContacts = <Contact>[
          ...testContacts,
          contactWithoutPhone,
        ];
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenAnswer((_) async => modifiedContacts);

        // Act
        final List<Contact> result = await repository.searchContacts('nophone');

        // Assert
        expect(result.length, equals(1));
        expect(result.first.name, equals('No Phone Contact'));
      });

      test('should search contacts with null email', () async {
        // Arrange
        const Contact contactWithoutEmail = Contact(
          id: '7',
          name: 'No Email Contact',
          phone: '+9876543210',
        );
        final List<Contact> modifiedContacts = <Contact>[
          ...testContacts,
          contactWithoutEmail,
        ];
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenAnswer((_) async => modifiedContacts);

        // Act
        final List<Contact> result = await repository.searchContacts(
          '9876543210',
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.name, equals('No Email Contact'));
      });
    });

    group('filterContacts Tests', () {
      test('should return all contacts for ContactFilter.all', () async {
        // Act
        final List<Contact> result = await repository.filterContacts(
          ContactFilter.all,
        );

        // Assert
        expect(result, equals(testContacts));
        expect(result.length, equals(4));
      });

      test('should filter favorite contacts only', () async {
        // Act
        final List<Contact> result = await repository.filterContacts(
          ContactFilter.favorites,
        );

        // Assert
        expect(result.length, equals(2));
        expect(result, contains(johnDoe));
        expect(result, contains(bobSmith));
        expect(result.every((Contact contact) => contact.isFavorite), isTrue);
      });

      test(
        'should filter recently contacted contacts (within 30 days)',
        () async {
          // Act
          final List<Contact> result = await repository.filterContacts(
            ContactFilter.recentlyContacted,
          );

          // Assert
          expect(result.length, equals(2));
          expect(result, contains(johnDoe)); // 5 days ago
          expect(result, contains(janeDoe)); // 10 days ago
          // Should not contain bobSmith (45 days) or aliceJohnson (100 days)
        },
      );

      test('should filter contacts needing interaction soon', () async {
        // Act
        final List<Contact> result = await repository.filterContacts(
          ContactFilter.needsInteraction,
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first, equals(bobSmith));
        expect(result.first.needsInteractionSoon, isTrue);
      });

      test('should handle contacts with null lastContactedAt '
          'for recently contacted filter', () async {
        // Arrange
        const Contact contactWithoutLastContacted = Contact(
          id: '8',
          name: 'Never Contacted',
          phone: '+1111111111',
          email: 'never@example.com',
        );
        final List<Contact> modifiedContacts = <Contact>[
          ...testContacts,
          contactWithoutLastContacted,
        ];
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenAnswer((_) async => modifiedContacts);

        // Act
        final List<Contact> result = await repository.filterContacts(
          ContactFilter.recentlyContacted,
        );

        // Assert
        expect(result.length, equals(2)); // Only johnDoe and janeDoe
        expect(result, isNot(contains(contactWithoutLastContacted)));
      });

      test(
        'should handle edge case where lastContactedAt is close to 30 days',
        () async {
          // Arrange
          final DateTime now = DateTime.now();
          final Contact twentyNineDaysAgo = Contact(
            id: '9',
            name: 'Twenty Nine Days Contact',
            phone: '+2222222222',
            email: 'twentynine@example.com',
            lastContactedAt: now.subtract(const Duration(days: 29)),
          );
          final List<Contact> modifiedContacts = <Contact>[
            ...testContacts,
            twentyNineDaysAgo,
          ];
          when(
            () => mockContactsService.getDeviceContacts(),
          ).thenAnswer((_) async => modifiedContacts);

          // Act
          final List<Contact> result = await repository.filterContacts(
            ContactFilter.recentlyContacted,
          );

          // Assert
          expect(result, contains(twentyNineDaysAgo));
        },
      );

      test('should handle future lastContactedAt dates', () async {
        // Arrange
        final DateTime now = DateTime.now();
        final Contact futureContact = Contact(
          id: '10',
          name: 'Future Contact',
          phone: '+3333333333',
          email: 'future@example.com',
          lastContactedAt: now.add(const Duration(days: 5)),
        );
        final List<Contact> modifiedContacts = <Contact>[
          ...testContacts,
          futureContact,
        ];
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenAnswer((_) async => modifiedContacts);

        // Act
        final List<Contact> result = await repository.filterContacts(
          ContactFilter.recentlyContacted,
        );

        // Assert
        expect(
          result,
          contains(futureContact),
        ); // Future dates should be included
      });
    });

    group('searchAndFilterContacts Tests', () {
      test('should combine search and filter correctly', () async {
        // Act - Search for "doe" and filter favorites
        final List<Contact> result = await repository.searchAndFilterContacts(
          'doe',
          ContactFilter.favorites,
        );

        // Assert
        expect(result.length, equals(1));
        expect(
          result.first,
          equals(johnDoe),
        ); // Only favorite with "doe" in name
      });

      test(
        'should return empty when search and filter have no matches',
        () async {
          // Act - Search for "nonexistent" and filter favorites
          final List<Contact> result = await repository.searchAndFilterContacts(
            'nonexistent',
            ContactFilter.favorites,
          );

          // Assert
          expect(result, isEmpty);
        },
      );

      test('should handle empty search with filter', () async {
        // Act - Empty search with favorites filter
        final List<Contact> result = await repository.searchAndFilterContacts(
          '',
          ContactFilter.favorites,
        );

        // Assert
        expect(result.length, equals(2));
        expect(result, contains(johnDoe));
        expect(result, contains(bobSmith));
      });

      test(
        'should combine search by email with recently contacted filter',
        () async {
          // Act - Search by email domain and filter recently contacted
          final List<Contact> result = await repository.searchAndFilterContacts(
            'email.com',
            ContactFilter.recentlyContacted,
          );

          // Assert
          expect(result.length, equals(2));
          expect(result, contains(johnDoe));
          expect(result, contains(janeDoe));
        },
      );

      test(
        'should combine search by phone with needsInteraction filter',
        () async {
          // Act - Search by phone and filter needs interaction
          final List<Contact> result = await repository.searchAndFilterContacts(
            '112233',
            ContactFilter.needsInteraction,
          );

          // Assert
          expect(result.length, equals(1));
          expect(result.first, equals(bobSmith));
        },
      );

      test('should handle complex search with multiple filters', () async {
        // Act - Search for contacts with "smith" that are favorites
        final List<Contact> result = await repository.searchAndFilterContacts(
          'smith',
          ContactFilter.favorites,
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first, equals(bobSmith));
      });

      test(
        'should be case insensitive for search combined with filter',
        () async {
          // Act - Case insensitive search with filter
          final List<Contact> result = await repository.searchAndFilterContacts(
            'JOHN',
            ContactFilter.favorites,
          );

          // Assert
          expect(result.length, equals(1));
          expect(result.first, equals(johnDoe));
        },
      );
    });

    group('Edge Cases and Error Handling', () {
      test('should handle service returning empty list', () async {
        // Arrange
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenAnswer((_) async => <Contact>[]);

        // Act
        final List<Contact> result = await repository.getContacts();

        // Assert
        expect(result, isEmpty);
      });

      test('should propagate service exceptions in search', () async {
        // Arrange
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () async => repository.searchContacts('test'),
          throwsA(isA<Exception>()),
        );
      });

      test('should propagate service exceptions in filter', () async {
        // Arrange
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenThrow(Exception('Permission denied'));

        // Act & Assert
        expect(
          () async => repository.filterContacts(ContactFilter.favorites),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle very long search queries', () async {
        // Arrange
        final String longQuery = 'a' * 1000;

        // Act
        final List<Contact> result = await repository.searchContacts(longQuery);

        // Assert
        expect(result, isEmpty); // Should not crash
      });

      test('should handle search with only special characters', () async {
        // Act
        final List<Contact> result = await repository.searchContacts(
          r'!@#$%^&*()',
        );

        // Assert
        expect(result, isEmpty); // Should not crash
      });

      test('should handle contacts with empty names gracefully', () async {
        // Arrange
        const Contact contactWithEmptyName = Contact(
          id: '11',
          name: '',
          phone: '+4444444444',
          email: 'empty@example.com',
        );
        final List<Contact> modifiedContacts = <Contact>[
          ...testContacts,
          contactWithEmptyName,
        ];
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenAnswer((_) async => modifiedContacts);

        // Act
        final List<Contact> result = await repository.searchContacts(
          '4444444444',
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.name, equals(''));
      });
    });

    group('Performance and Large Dataset Tests', () {
      test('should handle large number of contacts efficiently', () async {
        // Arrange
        final List<Contact> largeContactList = List<Contact>.generate(
          1000,
          (int index) => Contact(
            id: 'large_$index',
            name: 'Contact $index',
            phone: '+${1000000000 + index}',
            email: 'contact$index@example.com',
            isFavorite: index % 10 == 0, // Every 10th contact is favorite
          ),
        );
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenAnswer((_) async => largeContactList);

        // Act
        final Stopwatch stopwatch = Stopwatch()..start();
        final List<Contact> result = await repository.searchContacts(
          'Contact 5',
        );
        stopwatch.stop();

        // Assert
        expect(result.length, greaterThan(0));
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
      });

      test('should handle large dataset filtering efficiently', () async {
        // Arrange
        final List<Contact> largeContactList = List<Contact>.generate(
          1000,
          (int index) => Contact(
            id: 'large_$index',
            name: 'Contact $index',
            phone: '+${1000000000 + index}',
            email: 'contact$index@example.com',
            isFavorite: index % 10 == 0, // Every 10th contact is favorite
          ),
        );
        when(
          () => mockContactsService.getDeviceContacts(),
        ).thenAnswer((_) async => largeContactList);

        // Act
        final List<Contact> result = await repository.filterContacts(
          ContactFilter.favorites,
        );

        // Assert
        expect(result.length, equals(100)); // Should find 100 favorites
        expect(result.every((Contact contact) => contact.isFavorite), isTrue);
      });
    });
  });
}
