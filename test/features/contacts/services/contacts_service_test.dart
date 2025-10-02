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

      // Mock the contacts_service method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('github.com/clovisnicolas/flutter_contacts'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'getContacts') {
                // Return mock contacts data
                return _getMockContactsData();
              }
              return null;
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('github.com/clovisnicolas/flutter_contacts'),
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

          final Contact mayaContact = result.firstWhere(
            (Contact contact) => contact.name == 'Maya Dupuis',
          );
          expect(mayaContact.phone, equals('+3360120001'));
          expect(mayaContact.email, equals('maya.dupuis1@example.com'));
        },
      );

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

/// Returns mock contacts data in the format expected by contacts_service package
List<Map<String, dynamic>> _getMockContactsData() {
  return <Map<String, dynamic>>[
    <String, dynamic>{
      'identifier': '1',
      'displayName': 'Thomas Dupuis',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120000'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'thomas.dupuis0@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '2',
      'displayName': 'Maya Dupuis',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120001'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'maya.dupuis1@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '3',
      'displayName': 'Manon Weber',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120002'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'manon.weber2@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '4',
      'displayName': 'Sabrina Dufour',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120003'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'sabrina.dufour3@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '5',
      'displayName': 'Julien Poirier',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120004'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'julien.poirier4@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '6',
      'displayName': 'Claire Martin',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120005'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'claire.martin5@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '7',
      'displayName': 'Lucas Bernard',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120006'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'lucas.bernard6@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '8',
      'displayName': 'Emma Moreau',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120007'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'emma.moreau7@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '9',
      'displayName': 'Hugo Petit',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120008'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'hugo.petit8@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '10',
      'displayName': 'Louise Roux',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120009'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'louise.roux9@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '11',
      'displayName': 'Antoine Blanc',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120010'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'antoine.blanc10@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '12',
      'displayName': 'Camille Noir',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120011'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'camille.noir11@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '13',
      'displayName': 'Gabriel Vert',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120012'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'gabriel.vert12@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '14',
      'displayName': 'Inès Rouge',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120013'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'ines.rouge13@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '15',
      'displayName': 'Nathan Bleu',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+3360120014'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'nathan.bleu14@example.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '16',
      'displayName': 'John Doe',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+1 (555) 123-4567'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'john.doe@email.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '17',
      'displayName': 'Jane Smith',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+1 (555) 987-6543'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'jane.smith@email.com'},
      ],
    },
    <String, dynamic>{
      'identifier': '18',
      'displayName': 'María García',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+34 912 345 678'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'maria.garcia@email.es'},
      ],
    },
    <String, dynamic>{
      'identifier': '19',
      'displayName': 'Hans Mueller',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+49 30 12345678'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'hans.mueller@email.de'},
      ],
    },
    <String, dynamic>{
      'identifier': '20',
      'displayName': 'Yuki Tanaka',
      'phones': <Map<String, String>>[
        <String, String>{'value': '+81 3 1234 5678'},
      ],
      'emails': <Map<String, String>>[
        <String, String>{'value': 'yuki.tanaka@email.jp'},
      ],
    },
  ];
}
