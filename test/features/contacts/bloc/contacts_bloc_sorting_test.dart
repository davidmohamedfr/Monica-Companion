import 'package:bloc_test/bloc_test.dart';
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
  group('ContactsBloc Sorting Tests', () {
    late ContactsRepository mockRepository;
    late SharedPreferences sharedPreferences;

    setUp(() async {
      mockRepository = MockContactsRepository();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    group('Test 5.1-5.2: Sort by name', () {
      test('shouldSortContactsByNameAscending', () async {
        final List<Contact> contacts = <Contact>[
          const Contact(id: '1', name: 'Zara Johnson'),
          const Contact(id: '2', name: 'alice Smith'),
          const Contact(id: '3', name: 'Bob Williams'),
        ];

        when(
          () => mockRepository.getContacts(),
        ).thenAnswer((_) async => contacts);
        when(
          () => mockRepository.filterContacts(ContactFilter.all),
        ).thenAnswer((_) async => contacts);

        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        bloc.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['alice Smith', 'Bob Williams', 'Zara Johnson']),
        );

        bloc.close();
      });

      test('shouldSortContactsByNameDescending', () async {
        final List<Contact> contacts = <Contact>[
          const Contact(id: '1', name: 'Zara Johnson'),
          const Contact(id: '2', name: 'alice Smith'),
          const Contact(id: '3', name: 'Bob Williams'),
        ];

        when(
          () => mockRepository.getContacts(),
        ).thenAnswer((_) async => contacts);
        when(
          () => mockRepository.filterContacts(ContactFilter.all),
        ).thenAnswer((_) async => contacts);

        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        bloc.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc.add(const ChangeSortOrderEvent(ContactSortOrder.nameDescending));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Zara Johnson', 'Bob Williams', 'alice Smith']),
        );

        bloc.close();
      });
    });

    group('Test 5.3-5.4: Sort by last interaction', () {
      test('shouldSortContactsByLastInteractionRecent', () async {
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

        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        bloc.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc.add(
          const ChangeSortOrderEvent(ContactSortOrder.lastInteractionRecent),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Bob', 'Alice', 'Charlie']),
        );

        bloc.close();
      });

      test('shouldSortContactsByLastInteractionOldest', () async {
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

        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        bloc.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc.add(
          const ChangeSortOrderEvent(ContactSortOrder.lastInteractionOldest),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Charlie', 'Alice', 'Bob']),
        );

        bloc.close();
      });
    });

    group('Test 5.5: Null dates at end', () {
      test('shouldPlaceNullDatesAtEnd', () async {
        final DateTime now = DateTime.now();
        final List<Contact> contacts = <Contact>[
          Contact(
            id: '1',
            name: 'Alice',
            lastContactedAt: now.subtract(const Duration(days: 10)),
          ),
          const Contact(id: '2', name: 'Bob'),
          Contact(
            id: '3',
            name: 'Charlie',
            lastContactedAt: now.subtract(const Duration(days: 2)),
          ),
          const Contact(id: '4', name: 'Diana'),
        ];

        when(
          () => mockRepository.getContacts(),
        ).thenAnswer((_) async => contacts);
        when(
          () => mockRepository.filterContacts(ContactFilter.all),
        ).thenAnswer((_) async => contacts);

        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        bloc.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc.add(
          const ChangeSortOrderEvent(ContactSortOrder.lastInteractionRecent),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Charlie', 'Alice', 'Bob', 'Diana']),
        );

        bloc.close();
      });
    });

    group('Test 5.6: Sort event triggers sorting', () {
      test('shouldTriggerSortingOnChangeSortOrderEvent', () async {
        final List<Contact> contacts = <Contact>[
          const Contact(id: '1', name: 'Zara'),
          const Contact(id: '2', name: 'Alice'),
          const Contact(id: '3', name: 'Bob'),
        ];

        when(
          () => mockRepository.getContacts(),
        ).thenAnswer((_) async => contacts);
        when(
          () => mockRepository.filterContacts(ContactFilter.all),
        ).thenAnswer((_) async => contacts);

        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        bloc.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Default is nameAscending
        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Alice', 'Bob', 'Zara']),
        );

        bloc.add(const ChangeSortOrderEvent(ContactSortOrder.nameDescending));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Zara', 'Bob', 'Alice']),
        );

        bloc.close();
      });
    });

    group('Test 5.7: Persist sort preference', () {
      test('shouldPersistSortPreference', () async {
        final List<Contact> contacts = <Contact>[
          const Contact(id: '1', name: 'Alice'),
        ];

        when(
          () => mockRepository.getContacts(),
        ).thenAnswer((_) async => contacts);
        when(
          () => mockRepository.filterContacts(ContactFilter.all),
        ).thenAnswer((_) async => contacts);

        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        bloc.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        bloc.add(const ChangeSortOrderEvent(ContactSortOrder.nameDescending));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final int? savedSortOrder = sharedPreferences.getInt(
          'contacts_sort_order',
        );

        expect(savedSortOrder, equals(ContactSortOrder.nameDescending.index));

        bloc.close();
      });
    });

    group('Test 5.8: Load saved sort preference', () {
      test('shouldLoadSavedSortPreference', () async {
        await sharedPreferences.setInt(
          'contacts_sort_order',
          ContactSortOrder.lastInteractionRecent.index,
        );

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
        ];

        when(
          () => mockRepository.getContacts(),
        ).thenAnswer((_) async => contacts);
        when(
          () => mockRepository.filterContacts(ContactFilter.all),
        ).thenAnswer((_) async => contacts);

        final ContactsBloc bloc = ContactsBloc(
          contactsRepository: mockRepository,
          sharedPreferences: sharedPreferences,
        );

        // Wait for saved preferences to load
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.currentSortOrder,
          equals(ContactSortOrder.lastInteractionRecent),
        );

        bloc.add(const LoadContactsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.filteredContacts.map((Contact c) => c.name).toList(),
          equals(<String>['Bob', 'Alice']),
        );

        bloc.close();
      });
    });
  });
}
