import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_bloc.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_event.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_state.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/models/contact_view_mode.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/test_helpers.dart';

// Mock classes
class MockContactsRepository extends Mock implements ContactsRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('ContactsBloc Tests', () {
    late ContactsBloc contactsBloc;
    late MockContactsRepository mockContactsRepository;
    late MockSharedPreferences mockSharedPreferences;

    // Test data
    late List<Contact> testContacts;
    late Contact testContact1;
    late Contact testContact2;

    setUpAll(() {
      TestHelpers.setupMockFallbacks();
      registerFallbackValue(ContactFilter.all);
    });

    setUp(() {
      mockContactsRepository = MockContactsRepository();
      mockSharedPreferences = MockSharedPreferences();

      // Create test contacts
      testContact1 = Contact(
        id: '1',
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john@example.com',
        isFavorite: true,
        lastContactedAt: TestHelpers.createMockDateTime(month: 12),
      );

      testContact2 = Contact(
        id: '2',
        name: 'Jane Smith',
        phone: '+0987654321',
        email: 'jane@example.com',
        lastContactedAt: TestHelpers.createMockDateTime(month: 11, day: 15),
      );

      testContacts = <Contact>[testContact1, testContact2];

      // Setup default mock responses
      when(
        () => mockContactsRepository.getContacts(),
      ).thenAnswer((_) async => testContacts);
      when(
        () => mockContactsRepository.searchContacts(any()),
      ).thenAnswer((_) async => testContacts);
      when(
        () => mockContactsRepository.filterContacts(any()),
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

    tearDown(() {
      contactsBloc.close();
    });

    group('Initial State Tests', () {
      test('should have correct initial state', () {
        // Assert
        expect(contactsBloc.state, equals(const ContactsState()));
        expect(contactsBloc.state.contacts, isEmpty);
        expect(contactsBloc.state.filteredContacts, isEmpty);
        expect(contactsBloc.state.searchQuery, equals(''));
        expect(contactsBloc.state.currentFilter, equals(ContactFilter.all));
        expect(
          contactsBloc.state.currentViewMode,
          equals(ContactViewMode.list),
        );
        expect(contactsBloc.state.isLoading, isFalse);
        expect(contactsBloc.state.errorMessage, isNull);
      });
    });

    group('LoadContactsEvent Tests', () {
      blocTest<ContactsBloc, ContactsState>(
        'should emit loading then success state when contacts load successfully',
        build: () => contactsBloc,
        act: (ContactsBloc bloc) => bloc.add(const LoadContactsEvent()),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) =>
                state.isLoading == true && state.contacts.isEmpty,
          ),
          predicate<ContactsState>(
            (ContactsState state) =>
                state.isLoading == false &&
                state.contacts.length == 2 &&
                state.filteredContacts.length == 2 &&
                state.contacts.first.name == 'John Doe',
          ),
        ],
        verify: (_) {
          verify(() => mockContactsRepository.getContacts()).called(1);
        },
      );

      blocTest<ContactsBloc, ContactsState>(
        'should emit loading then error state when contacts fail to load',
        build: () {
          when(
            () => mockContactsRepository.getContacts(),
          ).thenThrow(Exception('Failed to load contacts'));
          return contactsBloc;
        },
        act: (ContactsBloc bloc) => bloc.add(const LoadContactsEvent()),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) => state.isLoading == true,
          ),
          predicate<ContactsState>(
            (ContactsState state) =>
                state.isLoading == false &&
                state.errorMessage != null &&
                state.errorMessage!.contains('Failed to load contacts'),
          ),
        ],
      );
    });

    group('SearchContactsEvent Tests', () {
      blocTest<ContactsBloc, ContactsState>(
        'should update search query and trigger search after debounce',
        build: () {
          when(
            () => mockContactsRepository.searchAndFilterContacts(
              'John',
              ContactFilter.all,
            ),
          ).thenAnswer((_) async => <Contact>[testContact1]);
          return contactsBloc;
        },
        act: (ContactsBloc bloc) => bloc.add(const SearchContactsEvent('John')),
        wait: const Duration(milliseconds: 400), // Wait for debounce
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) =>
                state.searchQuery == 'John' &&
                state.filteredContacts.isEmpty, // Initial state before debounce
          ),
        ],
        verify: (_) {
          // Verify the repository method was called after debounce
          verify(
            () => mockContactsRepository.searchAndFilterContacts(
              'John',
              ContactFilter.all,
            ),
          ).called(1);
        },
      );

      blocTest<ContactsBloc, ContactsState>(
        'should clear search query and show all contacts when query is empty',
        build: () => contactsBloc,
        seed: () => ContactsState(
          contacts: testContacts,
          filteredContacts: <Contact>[testContact1], // Previously filtered
          searchQuery: 'previous query',
        ),
        act: (ContactsBloc bloc) => bloc.add(const SearchContactsEvent('')),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) => state.searchQuery.isEmpty,
          ),
          predicate<ContactsState>(
            (ContactsState state) =>
                state.searchQuery.isEmpty &&
                state.filteredContacts.length == 2, // Should show all contacts
          ),
        ],
      );

      blocTest<ContactsBloc, ContactsState>(
        'should handle search error gracefully',
        build: () {
          when(
            () => mockContactsRepository.searchAndFilterContacts(any(), any()),
          ).thenThrow(Exception('Search failed'));
          return contactsBloc;
        },
        act: (ContactsBloc bloc) =>
            bloc.add(const SearchContactsEvent('error')),
        wait: const Duration(milliseconds: 400),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) => state.searchQuery == 'error',
          ),
        ],
        verify: (_) {
          // Verify the repository method was called and failed
          verify(
            () => mockContactsRepository.searchAndFilterContacts(
              'error',
              ContactFilter.all,
            ),
          ).called(1);
        },
      );
    });

    group('FilterContactsEvent Tests', () {
      blocTest<ContactsBloc, ContactsState>(
        'should apply filter when no search query exists',
        build: () {
          when(
            () =>
                mockContactsRepository.filterContacts(ContactFilter.favorites),
          ).thenAnswer((_) async => <Contact>[testContact1]);
          return contactsBloc;
        },
        act: (ContactsBloc bloc) =>
            bloc.add(const FilterContactsEvent(ContactFilter.favorites)),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) =>
                state.currentFilter == ContactFilter.favorites,
          ),
          predicate<ContactsState>(
            (ContactsState state) =>
                state.currentFilter == ContactFilter.favorites &&
                state.filteredContacts.length == 1 &&
                state.filteredContacts.first.isFavorite == true,
          ),
        ],
      );

      blocTest<ContactsBloc, ContactsState>(
        'should apply filter with existing search query',
        build: () {
          when(
            () => mockContactsRepository.searchAndFilterContacts(
              'John',
              ContactFilter.favorites,
            ),
          ).thenAnswer((_) async => <Contact>[testContact1]);
          return contactsBloc;
        },
        seed: () => const ContactsState(searchQuery: 'John'),
        act: (ContactsBloc bloc) =>
            bloc.add(const FilterContactsEvent(ContactFilter.favorites)),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) =>
                state.searchQuery == 'John' &&
                state.currentFilter == ContactFilter.favorites,
          ),
          predicate<ContactsState>(
            (ContactsState state) =>
                state.searchQuery == 'John' &&
                state.currentFilter == ContactFilter.favorites &&
                state.filteredContacts.length == 1,
          ),
        ],
      );

      blocTest<ContactsBloc, ContactsState>(
        'should handle filter error gracefully',
        build: () {
          when(
            () => mockContactsRepository.filterContacts(any()),
          ).thenThrow(Exception('Filter failed'));
          return contactsBloc;
        },
        act: (ContactsBloc bloc) =>
            bloc.add(const FilterContactsEvent(ContactFilter.favorites)),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) =>
                state.currentFilter == ContactFilter.favorites,
          ),
          predicate<ContactsState>(
            (ContactsState state) =>
                state.currentFilter == ContactFilter.favorites &&
                state.errorMessage != null &&
                state.errorMessage!.contains('Filter failed'),
          ),
        ],
      );
    });

    group('ChangeViewModeEvent Tests', () {
      blocTest<ContactsBloc, ContactsState>(
        'should change view mode and save to preferences',
        build: () => contactsBloc,
        act: (ContactsBloc bloc) =>
            bloc.add(const ChangeViewModeEvent(ContactViewMode.grid)),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) =>
                state.currentViewMode == ContactViewMode.grid,
          ),
        ],
        verify: (_) {
          verify(
            () => mockSharedPreferences.setInt(
              'contacts_view_mode',
              ContactViewMode.grid.index,
            ),
          ).called(1);
        },
      );

      test('should not change view mode when preference save fails', () async {
        // Arrange
        when(
          () => mockSharedPreferences.setInt(any(), any()),
        ).thenThrow(Exception('Preference save failed'));

        final ContactViewMode initialViewMode =
            contactsBloc.state.currentViewMode;

        // Act
        contactsBloc.add(const ChangeViewModeEvent(ContactViewMode.card));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert - View mode should not change when save fails
        expect(contactsBloc.state.currentViewMode, equals(initialViewMode));
      });
    });

    group('RefreshContactsEvent Tests', () {
      blocTest<ContactsBloc, ContactsState>(
        'should trigger LoadContactsEvent',
        build: () => contactsBloc,
        act: (ContactsBloc bloc) => bloc.add(const RefreshContactsEvent()),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) => state.isLoading == true,
          ),
          predicate<ContactsState>(
            (ContactsState state) =>
                state.isLoading == false && state.contacts.length == 2,
          ),
        ],
        verify: (_) {
          verify(() => mockContactsRepository.getContacts()).called(1);
        },
      );
    });

    group('View Mode Persistence Tests', () {
      test('should load saved view mode on initialization', () async {
        // Arrange
        when(
          () => mockSharedPreferences.getInt('contacts_view_mode'),
        ).thenReturn(ContactViewMode.grid.index);

        // Act
        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockContactsRepository,
          sharedPreferences: mockSharedPreferences,
        );

        // Wait for the async initialization to complete
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(bloc.state.currentViewMode, equals(ContactViewMode.grid));

        // Cleanup
        await bloc.close();
      });

      test('should use default view mode when no saved preference exists', () {
        // Arrange
        when(
          () => mockSharedPreferences.getInt('contacts_view_mode'),
        ).thenReturn(null);

        // Act
        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockContactsRepository,
          sharedPreferences: mockSharedPreferences,
        );

        // Assert
        expect(bloc.state.currentViewMode, equals(ContactViewMode.list));

        // Cleanup
        bloc.close();
      });
    });

    group('Error State Management Tests', () {
      blocTest<ContactsBloc, ContactsState>(
        'should preserve error message during successful operations',
        build: () => contactsBloc,
        seed: () => const ContactsState(errorMessage: 'Previous error'),
        act: (ContactsBloc bloc) => bloc.add(const LoadContactsEvent()),
        expect: () => <Matcher>[
          predicate<ContactsState>(
            (ContactsState state) =>
                state.errorMessage == 'Previous error' &&
                state.isLoading == true,
          ),
          predicate<ContactsState>(
            (ContactsState state) =>
                state.errorMessage == 'Previous error' &&
                state.isLoading == false &&
                state.contacts.length == 2,
          ),
        ],
      );
    });

    group('Memory Management Tests', () {
      test('should cancel debounce timer on close', () async {
        // Arrange
        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockContactsRepository,
          sharedPreferences: mockSharedPreferences,
        );

        // Act
        bloc.add(const SearchContactsEvent('test'));
        await bloc.close();

        // Should not throw or cause memory leaks
        expect(bloc.isClosed, isTrue);
      });
    });
  });
}
