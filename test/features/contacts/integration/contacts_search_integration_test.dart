import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_bloc.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_event.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_state.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/models/contact_sort_order.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockContactsRepository extends Mock implements ContactsRepository {}

void main() {
  group('Contacts Search Integration Tests', () {
    late ContactsRepository mockRepository;
    late SharedPreferences sharedPreferences;

    setUp(() async {
      mockRepository = MockContactsRepository();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    group('Test 8.1: End-to-end search workflow', () {
      test('shouldCompleteSearchWorkflow', () async {
        final DateTime now = DateTime.now();
        final List<Contact> allContacts = <Contact>[
          Contact(
            id: '1',
            name: 'Alice Johnson',
            email: 'alice@example.com',
            lastContactedAt: now.subtract(const Duration(days: 5)),
          ),
          Contact(
            id: '2',
            name: 'Bob Smith',
            phone: '+1234567890',
            lastContactedAt: now.subtract(const Duration(days: 10)),
          ),
          Contact(
            id: '3',
            name: 'Charlie Brown',
            email: 'charlie@example.com',
            phone: '+0987654321',
            isFavorite: true,
            lastContactedAt: now.subtract(const Duration(days: 2)),
          ),
        ];

        final List<Contact> searchResults = <Contact>[
          allContacts[0], // Alice Johnson
        ];

        final List<Contact> favoriteContacts = <Contact>[
          allContacts[2], // Charlie Brown
        ];

        when(
          () => mockRepository.getContacts(),
        ).thenAnswer((_) async => allContacts);
        when(
          () => mockRepository.filterContacts(ContactFilter.all),
        ).thenAnswer((_) async => allContacts);
        when(
          () => mockRepository.filterContacts(ContactFilter.favorites),
        ).thenAnswer((_) async => favoriteContacts);
        when(
          () => mockRepository.searchAndFilterContacts(
            'alice',
            ContactFilter.all,
          ),
        ).thenAnswer((_) async => searchResults);

        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        // Step 1: Load all contacts
        bloc.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(bloc.state.filteredContacts.length, equals(3));
        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Alice Johnson', 'Bob Smith', 'Charlie Brown']),
        );

        // Step 2: Search for "alice"
        bloc.add(const SearchContactsEvent('alice'));
        await Future<void>.delayed(const Duration(milliseconds: 400));

        expect(bloc.state.searchQuery, equals('alice'));
        expect(bloc.state.filteredContacts.length, equals(1));
        expect(bloc.state.filteredContacts.first.name, equals('Alice Johnson'));

        // Step 3: Clear search
        bloc.add(const SearchContactsEvent(''));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(bloc.state.searchQuery, equals(''));
        expect(bloc.state.filteredContacts.length, equals(3));

        // Step 4: Apply filter (favorites)
        bloc.add(const FilterContactsEvent(ContactFilter.favorites));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(bloc.state.currentFilter, equals(ContactFilter.favorites));
        expect(bloc.state.filteredContacts.length, equals(1));
        expect(bloc.state.filteredContacts.first.name, equals('Charlie Brown'));

        // Step 5: Change sort order
        bloc.add(
          const ChangeSortOrderEvent(ContactSortOrder.lastInteractionRecent),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.currentSortOrder,
          equals(ContactSortOrder.lastInteractionRecent),
        );
        expect(bloc.state.filteredContacts.first.name, equals('Charlie Brown'));

        // Step 6: Reset filter
        bloc.add(const FilterContactsEvent(ContactFilter.all));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(bloc.state.filteredContacts.length, equals(3));
        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Charlie Brown', 'Alice Johnson', 'Bob Smith']),
        );

        bloc.close();
      });
    });

    group('Test 8.2: Sort preference persistence across app restarts', () {
      test('shouldPersistSortPreferenceAcrossRestarts', () async {
        final DateTime now = DateTime.now();
        final List<Contact> contacts = <Contact>[
          Contact(
            id: '1',
            name: 'Alice',
            lastContactedAt: now.subtract(const Duration(days: 10)),
          ),
          Contact(
            id: '2',
            name: 'Bob',
            lastContactedAt: now.subtract(const Duration(days: 2)),
          ),
          Contact(
            id: '3',
            name: 'Charlie',
            lastContactedAt: now.subtract(const Duration(days: 30)),
          ),
        ];

        when(
          () => mockRepository.getContacts(),
        ).thenAnswer((_) async => contacts);
        when(
          () => mockRepository.filterContacts(ContactFilter.all),
        ).thenAnswer((_) async => contacts);

        // First app session: Set sort preference
        final ContactsBloc bloc1 = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        bloc1.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc1.add(
          const ChangeSortOrderEvent(ContactSortOrder.lastInteractionRecent),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc1.state.currentSortOrder,
          equals(ContactSortOrder.lastInteractionRecent),
        );
        expect(
          bloc1.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Bob', 'Alice', 'Charlie']),
        );

        bloc1.close();

        // Simulate app restart: Create new BLoC with same SharedPreferences
        final ContactsBloc bloc2 = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        // Wait for saved preference to load
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc2.state.currentSortOrder,
          equals(ContactSortOrder.lastInteractionRecent),
        );

        bloc2.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Verify sort order persisted
        expect(
          bloc2.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Bob', 'Alice', 'Charlie']),
        );

        bloc2.close();
      });
    });
  });
}
