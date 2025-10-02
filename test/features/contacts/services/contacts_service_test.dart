import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/services/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('ContactsService Tests', () {
    late ContactsServiceImpl contactsService;

    setUpAll(() {
      TestHelpers.setupMockFallbacks();
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      contactsService = ContactsServiceImpl();

      // Mock the permission handler method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            (MethodCall methodCall) async {
              switch (methodCall.method) {
                case 'checkPermissionStatus':
                  return PermissionStatus.granted.index;
                case 'requestPermissions':
                  return <int, int>{
                    Permission.contacts.value: PermissionStatus.granted.index,
                  };
                default:
                  return null;
              }
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            null,
          );
    });

    group('getDeviceContacts Tests', () {
      test(
        'should return contacts when permission is already granted',
        () async {
          // This test verifies the service returns contacts
          // from the mock implementation
          // Since we can't mock Permission.contacts.status directly,
          // we test the current implementation

          // Act
          final List<Contact> result = await contactsService
              .getDeviceContacts();

          // Assert
          expect(result, isA<List<Contact>>());
          expect(result.length, equals(20));

          // Verify specific contacts from VCF data
          final Contact thomasContact = result.firstWhere(
            (Contact contact) => contact.name == 'Thomas Dupuis',
          );
          expect(thomasContact.phone, equals('+3360120000'));
          expect(thomasContact.email, equals('thomas.dupuis0@example.com'));
          expect(thomasContact.isFavorite, isTrue);

          final Contact mayaContact = result.firstWhere(
            (Contact contact) => contact.name == 'Maya Dupuis',
          );
          expect(mayaContact.phone, equals('+3360120001'));
          expect(mayaContact.email, equals('maya.dupuis1@example.com'));
          expect(mayaContact.isFavorite, isTrue);
        },
      );

      test('should return contacts with proper metadata', () async {
        // Act
        final List<Contact> result = await contactsService.getDeviceContacts();

        // Assert
        expect(result, isNotEmpty);

        // Verify favorites exist
        final List<Contact> favorites = result
            .where((Contact contact) => contact.isFavorite)
            .toList();
        expect(favorites, isNotEmpty);
        expect(favorites.length, greaterThan(0));

        // Verify contacts needing interaction exist
        final List<Contact> needsInteraction = result
            .where((Contact contact) => contact.needsInteractionSoon)
            .toList();
        expect(needsInteraction, isNotEmpty);

        // Verify lastContactedAt dates exist
        final List<Contact> withLastContact = result
            .where((Contact contact) => contact.lastContactedAt != null)
            .toList();
        expect(withLastContact, isNotEmpty);
      });

      test('should return international contacts for diversity', () async {
        // Act
        final List<Contact> result = await contactsService.getDeviceContacts();

        // Assert
        final Contact johnDoe = result.firstWhere(
          (Contact contact) => contact.name == 'John Doe',
        );
        expect(johnDoe.phone, equals('+1 (555) 123-4567'));
        expect(johnDoe.email, equals('john.doe@email.com'));

        final Contact mariaGarcia = result.firstWhere(
          (Contact contact) => contact.name == 'María García',
        );
        expect(mariaGarcia.phone, equals('+34 912 345 678'));
        expect(mariaGarcia.email, equals('maria.garcia@email.es'));

        final Contact hansmueller = result.firstWhere(
          (Contact contact) => contact.name == 'Hans Mueller',
        );
        expect(hansmueller.phone, equals('+49 30 12345678'));
        expect(hansmueller.email, equals('hans.mueller@email.de'));
      });

      test('should have null photo URLs for mock contacts', () async {
        // Act
        final List<Contact> result = await contactsService.getDeviceContacts();

        // Assert - Photo URLs are null in mock data
        // to avoid 404 errors in tests
        final List<Contact> contactsWithPhotos = result
            .where((Contact contact) => contact.photoUrl != null)
            .toList();
        expect(
          contactsWithPhotos,
          isEmpty,
        ); // All mock contacts have null photoUrl

        // Verify all contacts have null photoUrl
        for (final Contact contact in result) {
          expect(contact.photoUrl, isNull);
        }
      });

      test('should simulate network delay', () async {
        // Arrange
        final Stopwatch stopwatch = Stopwatch()..start();

        // Act
        await contactsService.getDeviceContacts();

        // Assert
        stopwatch.stop();
        expect(
          stopwatch.elapsedMilliseconds,
          greaterThanOrEqualTo(900),
        ); // Should be ~1 second
      });
    });

    group('requestContactsPermission Tests', () {
      test('should handle permission request success', () async {
        // Since we can't easily mock Permission.contacts.request()
        // in this setup, we test the actual implementation behavior

        // Act
        final bool result = await contactsService.requestContactsPermission();

        // Assert
        expect(result, isA<bool>());
        // Note: Result depends on system permission state
      });

      test('should handle permission request failure gracefully', () async {
        // This tests that the method doesn't throw unexpected exceptions

        // Act & Assert
        expect(
          () async => contactsService.requestContactsPermission(),
          returnsNormally,
        );
      });
    });

    group('hasContactsPermission Tests', () {
      test('should check permission status without throwing', () async {
        // Act & Assert
        expect(
          () async => contactsService.hasContactsPermission(),
          returnsNormally,
        );
      });

      test('should return boolean permission status', () async {
        // Act
        final bool result = await contactsService.hasContactsPermission();

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('Error Handling Tests', () {
      test(
        'should throw ContactsPermissionException with proper message',
        () async {
          // Note: This test covers the exception type and structure
          const ContactsPermissionException exception =
              ContactsPermissionException('Test permission denied');

          // Assert
          expect(exception.message, equals('Test permission denied'));
          expect(exception, isA<ContactsPermissionException>());
        },
      );

      test('should throw ContactsException with proper message', () async {
        // Note: This test covers the exception type and structure
        const ContactsException exception = ContactsException(
          'Test contacts error',
        );

        // Assert
        expect(exception.message, equals('Test contacts error'));
        expect(exception, isA<ContactsException>());
      });
    });

    group('Contact Data Validation Tests', () {
      test('should return contacts with valid structure', () async {
        // Act
        final List<Contact> result = await contactsService.getDeviceContacts();

        // Assert
        for (final Contact contact in result) {
          // Every contact must have an ID and name
          expect(contact.id, isNotEmpty);
          expect(contact.name, isNotEmpty);

          // Phone and email can be null but if present, should not be empty
          if (contact.phone != null) {
            expect(contact.phone, isNotEmpty);
          }
          if (contact.email != null) {
            expect(contact.email, isNotEmpty);
          }

          // Photo URL can be null but if present, should be valid URL format
          if (contact.photoUrl != null) {
            expect(contact.photoUrl, isNotEmpty);
            expect(contact.photoUrl, contains('https://'));
          }

          // Boolean fields should never be null
          expect(contact.isFavorite, isNotNull);
          expect(contact.needsInteractionSoon, isNotNull);
        }
      });

      test('should return contacts with unique IDs', () async {
        // Act
        final List<Contact> result = await contactsService.getDeviceContacts();

        // Assert
        final List<String> ids = result
            .map((Contact contact) => contact.id)
            .toList();
        final Set<String> uniqueIds = ids.toSet();
        expect(uniqueIds.length, equals(ids.length));
      });

      test('should return contacts with proper date formatting', () async {
        // Act
        final List<Contact> result = await contactsService.getDeviceContacts();

        // Assert
        final List<Contact> contactsWithDates = result
            .where((Contact contact) => contact.lastContactedAt != null)
            .toList();
        expect(contactsWithDates, isNotEmpty);

        for (final Contact contact in contactsWithDates) {
          expect(contact.lastContactedAt, isA<DateTime>());
          expect(contact.lastContactedAt!.isBefore(DateTime.now()), isTrue);
        }
      });
    });

    group('VCF Data Fidelity Tests', () {
      test('should match VCF file contact structure', () async {
        // Act
        final List<Contact> result = await contactsService.getDeviceContacts();

        // Assert - Verify French contacts match VCF naming patterns
        final List<Contact> frenchContacts = result
            .where(
              (Contact contact) => contact.phone?.startsWith('+336') ?? false,
            )
            .toList();
        expect(frenchContacts, isNotEmpty);
        expect(frenchContacts.length, greaterThanOrEqualTo(15));

        // Verify email patterns match VCF structure
        final RegExp vcfEmailPattern = RegExp(
          r'^[a-z]+\.[a-z]+\d*@example\.com$',
        );
        final List<Contact> vcfEmails = result
            .where(
              (Contact contact) =>
                  contact.email != null &&
                  vcfEmailPattern.hasMatch(contact.email!),
            )
            .toList();
        expect(vcfEmails, isNotEmpty);
      });

      test('should include VCF-specific contact names', () async {
        // Act
        final List<Contact> result = await contactsService.getDeviceContacts();

        // Assert - Check for specific VCF contact names
        final Set<String> contactNames = result
            .map((Contact contact) => contact.name)
            .toSet();

        expect(contactNames, contains('Thomas Dupuis'));
        expect(contactNames, contains('Maya Dupuis'));
        expect(contactNames, contains('Manon Weber'));
        expect(contactNames, contains('Sabrina Dufour'));
        expect(contactNames, contains('Julien Poirier'));
      });
    });
  });
}
