import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/contacts/models/contact_sort_order.dart';

void main() {
  group('ContactSortOrder Tests', () {
    group('Test 4.1: Enum display names', () {
      test('shouldReturnCorrectDisplayNamesForSortOrders', () {
        expect(
          ContactSortOrder.nameAscending.displayName,
          equals('Name (A-Z)'),
        );
        expect(
          ContactSortOrder.nameDescending.displayName,
          equals('Name (Z-A)'),
        );
        expect(
          ContactSortOrder.lastInteractionRecent.displayName,
          equals('Last interaction (Recent)'),
        );
        expect(
          ContactSortOrder.lastInteractionOldest.displayName,
          equals('Last interaction (Oldest)'),
        );
      });
    });
  });
}
