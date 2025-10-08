import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/services/permission_service.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:monica_companion/features/contacts/services/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration test to verify the complete contacts edit flow
void main() {
  group('Contacts Edit Flow Integration', () {
    test(
      'Contact should NOT be read-only when WRITE_CONTACTS granted and no denials',
      () async {
        // Arrange - simulate granted permission
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        final PermissionService permissionService = PermissionServiceImpl(
          prefs,
          checkPermission: () async => PermissionStatus.granted,
          requestPermission: () async => PermissionStatus.granted,
        );

        final ContactsService contactsService = ContactsServiceImpl(
          permissionService,
        );

        final ContactsRepository repository = ContactsRepositoryImpl(
          contactsService,
        );

        // Act - check if contact is read-only
        final bool isReadOnly = await repository.isContactReadOnly('test-id');

        // Assert - should be writable (false) because:
        // 1. Permission is granted
        // 2. No denial count exists
        // 3. PermissionService is injected
        expect(
          isReadOnly,
          isFalse,
          reason:
              'Contact should be editable when permission granted and no denials',
        );

        // Verify the chain
        final bool appReadOnlyMode = await permissionService.isReadOnlyMode();
        expect(
          appReadOnlyMode,
          isFalse,
          reason: 'App should not be in read-only mode',
        );

        final int denialCount = await permissionService.getDenialCount();
        expect(denialCount, 0, reason: 'Should have zero denials');
      },
    );

    test('Contact should be read-only when denial count is 2', () async {
      // Arrange
      SharedPreferences.setMockInitialValues(<String, Object>{
        'flutter.write_contacts_denial_count': 2,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final PermissionService permissionService = PermissionServiceImpl(
        prefs,
        checkPermission: () async => PermissionStatus.denied,
        requestPermission: () async => PermissionStatus.denied,
      );

      final ContactsService contactsService = ContactsServiceImpl(
        permissionService,
      );

      final ContactsRepository repository = ContactsRepositoryImpl(
        contactsService,
      );

      // Act
      final bool isReadOnly = await repository.isContactReadOnly('test-id');

      // Assert
      expect(
        isReadOnly,
        isTrue,
        reason: 'Contact should be read-only when denied twice',
      );

      final bool appReadOnlyMode = await permissionService.isReadOnlyMode();
      expect(
        appReadOnlyMode,
        isTrue,
        reason: 'App should be in read-only mode after 2 denials',
      );
    });
  });
}
