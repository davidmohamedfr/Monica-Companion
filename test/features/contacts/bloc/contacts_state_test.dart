import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_state.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/models/contact_sort_order.dart';
import 'package:monica_companion/features/contacts/models/contact_view_mode.dart';

void main() {
  group('ContactsState Sorting Tests', () {
    group('Test 4.2: State includes currentSortOrder', () {
      test('shouldIncludeCurrentSortOrderInState', () {
        const ContactsState state = ContactsState(
          currentSortOrder: ContactSortOrder.nameDescending,
        );

        expect(state.currentSortOrder, equals(ContactSortOrder.nameDescending));
      });

      test('shouldDefaultToNameAscending', () {
        const ContactsState state = ContactsState();

        expect(state.currentSortOrder, equals(ContactSortOrder.nameAscending));
      });
    });

    group('Test 4.3: State copyWith handles sortOrder', () {
      test('shouldCopyWithSortOrder', () {
        const ContactsState initialState = ContactsState(
          currentSortOrder: ContactSortOrder.nameAscending,
        );

        final ContactsState newState = initialState.copyWith(
          currentSortOrder: ContactSortOrder.lastInteractionRecent,
        );

        expect(
          newState.currentSortOrder,
          equals(ContactSortOrder.lastInteractionRecent),
        );
        expect(
          initialState.currentSortOrder,
          equals(ContactSortOrder.nameAscending),
        );
      });
    });

    group('Test 4.4: State props includes sortOrder', () {
      test('shouldIncludeSortOrderInEquality', () {
        const ContactsState state1 = ContactsState(
          currentSortOrder: ContactSortOrder.nameAscending,
        );
        const ContactsState state2 = ContactsState(
          currentSortOrder: ContactSortOrder.nameAscending,
        );
        const ContactsState state3 = ContactsState(
          currentSortOrder: ContactSortOrder.nameDescending,
        );

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });
  });
}
