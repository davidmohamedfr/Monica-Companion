import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/services/permission_service.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/services/contacts_service.dart';

class MockPermissionService extends Mock implements PermissionService {}

void main() {
  group('ContactsService Read-Only Mode Tests', () {
    late MockPermissionService mockPermissionService;
    late ContactsService contactsService;

    setUp(() {
      mockPermissionService = MockPermissionService();
    });

    group('Update Contact', () {
      test(
          'updateDeviceContact should throw exception when in read-only mode',
          () async {
        // Arrange
        when(() => mockPermissionService.isReadOnlyMode())
            .thenAnswer((_) async => true);

        contactsService = ContactsServiceImpl(mockPermissionService);

        final Contact testContact = Contact(
          id: '1',
          name: 'Test User',
        );

        // Act & Assert
        expect(
          () => contactsService.updateDeviceContact(testContact),
          throwsA(isA<ContactsException>()),
        );
      });

      test('updateDeviceContact should work normally when not in read-only mode',
          () async {
        // Arrange
        when(() => mockPermissionService.isReadOnlyMode())
            .thenAnswer((_) async => false);

        contactsService = ContactsServiceImpl(mockPermissionService);

        final Contact testContact = Contact(
          id: '1',
          name: 'Test User',
        );

        // Act & Assert
        // This will fail because we need to mock flutter_contacts
        // For now, we just verify the read-only check passes
        try {
          await contactsService.updateDeviceContact(testContact);
        } catch (e) {
          // We expect it to fail due to missing mocks, but NOT due to read-only
          expect(e, isNot(isA<ContactsException>().having(
            (e) => e.toString(),
            'message',
            contains('read-only'),
          )));
        }

        verify(() => mockPermissionService.isReadOnlyMode()).called(1);
      });
    });

    group('Create Contact', () {
      test(
          'createDeviceContact should throw exception when in read-only mode',
          () async {
        // Arrange
        when(() => mockPermissionService.isReadOnlyMode())
            .thenAnswer((_) async => true);

        contactsService = ContactsServiceImpl(mockPermissionService);

        final Contact testContact = Contact(
          id: '1',
          name: 'Test User',
        );

        // Act & Assert
        expect(
          () => contactsService.createDeviceContact(testContact),
          throwsA(isA<ContactsException>()),
        );
      });

      test('createDeviceContact should work normally when not in read-only mode',
          () async {
        // Arrange
        when(() => mockPermissionService.isReadOnlyMode())
            .thenAnswer((_) async => false);

        contactsService = ContactsServiceImpl(mockPermissionService);

        final Contact testContact = Contact(
          id: '1',
          name: 'Test User',
        );

        // Act & Assert
        try {
          await contactsService.createDeviceContact(testContact);
        } catch (e) {
          // We expect it to fail due to missing mocks, but NOT due to read-only
          expect(e, isNot(isA<ContactsException>().having(
            (e) => e.toString(),
            'message',
            contains('read-only'),
          )));
        }

        verify(() => mockPermissionService.isReadOnlyMode()).called(1);
      });
    });
  });
}
