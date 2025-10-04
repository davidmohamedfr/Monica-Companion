import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_bloc.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_event.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_state.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/test_helpers.dart';

// Mock classes
class MockContactsRepository extends Mock implements ContactsRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('ContactsBloc Search Debouncing Tests', () {
    late ContactsBloc contactsBloc;
    late MockContactsRepository mockContactsRepository;
    late MockSharedPreferences mockSharedPreferences;
    late List<Contact> testContacts;

    setUpAll(() {
      TestHelpers.setupMockFallbacks();
      registerFallbackValue(ContactFilter.all);
    });

    setUp(() {
      mockContactsRepository = MockContactsRepository();
      mockSharedPreferences = MockSharedPreferences();

      testContacts = <Contact>[
        Contact(
          id: '1',
          name: 'John Doe',
          phone: '+1234567890',
          email: 'john@example.com',
        ),
        Contact(
          id: '2',
          name: 'Jane Smith',
          phone: '+0987654321',
          email: 'jane@example.com',
        ),
      ];

      when(
        () => mockContactsRepository.getContacts(),
      ).thenAnswer((_) async => testContacts);
      when(
        () => mockContactsRepository.searchAndFilterContacts(any(), any()),
      ).thenAnswer((_) async => testContacts);
      when(() => mockSharedPreferences.getInt(any())).thenReturn(null);
      when(
        () => mockSharedPreferences.setInt(any(), any()),
      ).thenAnswer((_) async => true);

      contactsBloc = ContactsBloc(
        contactsRepository: mockContactsRepository,
        sharedPreferences: mockSharedPreferences,
      );
    });

    tearDown(() async {
      await contactsBloc.close();
    });

    group('Test 1.1: Search query immediate update', () {
      blocTest<ContactsBloc, ContactsState>(
        'shouldUpdateSearchQueryImmediatelyWhenSearchEventAdded',
        build: () => contactsBloc,
        act: (ContactsBloc bloc) => bloc.add(const SearchContactsEvent('John')),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) => state.searchQuery == 'John',
            'Search query should be updated immediately to "John"',
          ),
        ],
        verify: (_) {
          // Verify state was updated immediately without waiting for debounce
        },
      );
    });

    group('Test 1.2: Empty search returns all contacts', () {
      blocTest<ContactsBloc, ContactsState>(
        'shouldReturnAllContactsWhenSearchQueryIsEmpty',
        build: () => contactsBloc,
        seed: () => ContactsState(
          contacts: testContacts,
          filteredContacts: <Contact>[testContacts[0]], // Previously filtered
          searchQuery: 'John',
        ),
        act: (ContactsBloc bloc) => bloc.add(const SearchContactsEvent('')),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) =>
                state.searchQuery.isEmpty && state.filteredContacts.length == 1,
            'First emission: search query cleared but filteredContacts still has previous value',
          ),
          predicate<ContactsState>(
            (ContactsState state) =>
                state.searchQuery.isEmpty && state.filteredContacts.length == 2,
            'Second emission: empty search returns all contacts (2)',
          ),
        ],
        verify: (_) {
          // Should not call repository for empty search
          verifyNever(
            () => mockContactsRepository.searchAndFilterContacts(any(), any()),
          );
        },
      );
    });
  });
}
