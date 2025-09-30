import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ContactsService {
  Future<List<Contact>> getDeviceContacts();
  Future<bool> requestContactsPermission();
  Future<bool> hasContactsPermission();
}

class ContactsServiceImpl implements ContactsService {
  @override
  Future<List<Contact>> getDeviceContacts() async {
    try {
      final bool hasPermission = await hasContactsPermission();
      if (!hasPermission) {
        final bool granted = await requestContactsPermission();
        if (!granted) {
          throw const ContactsPermissionException('Contacts permission denied');
        }
      }

      // Comprehensive mock contacts based on the VCF file data
      await Future<void>.delayed(
          const Duration(seconds: 1)); // Simulate API delay

      return <Contact>[
        // French contacts from VCF file
        Contact(
          id: '1',
          name: 'Thomas Dupuis',
          phone: '+3360120000',
          email: 'thomas.dupuis0@example.com',
          photoUrl: null, // Removed 404 placeholder
          isFavorite: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Contact(
          id: '2',
          name: 'Maya Dupuis',
          phone: '+3360120001',
          email: 'maya.dupuis1@example.com',
          photoUrl: null, // Removed 404 placeholder
          isFavorite: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        Contact(
          id: '3',
          name: 'Manon Weber',
          phone: '+3360120002',
          email: 'manon.weber2@example.com',
          photoUrl: null, // Removed 404 placeholder
          lastContactedAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
        Contact(
          id: '4',
          name: 'Sabrina Dufour',
          phone: '+3360120003',
          email: 'sabrina.dufour3@example.com',
          photoUrl: null, // Removed 404 placeholder
          isFavorite: false,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        Contact(
          id: '5',
          name: 'Julien Poirier',
          phone: '+3360120004',
          email: 'julien.poirier4@example.com',
          photoUrl: null, // Removed 404 placeholder
          needsInteractionSoon: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
        Contact(
          id: '6',
          name: 'Claire Martin',
          phone: '+3360120005',
          email: 'claire.martin5@example.com',
          photoUrl: null, // Removed 404 placeholder
          lastContactedAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
        Contact(
          id: '7',
          name: 'Lucas Bernard',
          phone: '+3360120006',
          email: 'lucas.bernard6@example.com',
          photoUrl: null, // Removed 404 placeholder
          isFavorite: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Contact(
          id: '8',
          name: 'Emma Moreau',
          phone: '+3360120007',
          email: 'emma.moreau7@example.com',
          photoUrl: null, // Removed 404 placeholder
          needsInteractionSoon: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        Contact(
          id: '9',
          name: 'Hugo Petit',
          phone: '+3360120008',
          email: 'hugo.petit8@example.com',
          photoUrl: null, // Removed 404 placeholder
          lastContactedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Contact(
          id: '10',
          name: 'Louise Roux',
          phone: '+3360120009',
          email: 'louise.roux9@example.com',
          photoUrl: null, // Removed 404 placeholder
          isFavorite: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        // Additional contacts to test pagination and scrolling
        Contact(
          id: '11',
          name: 'Antoine Blanc',
          phone: '+3360120010',
          email: 'antoine.blanc10@example.com',
          needsInteractionSoon: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 50)),
        ),
        Contact(
          id: '12',
          name: 'Camille Noir',
          phone: '+3360120011',
          email: 'camille.noir11@example.com',
          isFavorite: false,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 18)),
        ),
        Contact(
          id: '13',
          name: 'Gabriel Vert',
          phone: '+3360120012',
          email: 'gabriel.vert12@example.com',
          lastContactedAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
        Contact(
          id: '14',
          name: 'Inès Rouge',
          phone: '+3360120013',
          email: 'ines.rouge13@example.com',
          isFavorite: true,
          needsInteractionSoon: false,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
        Contact(
          id: '15',
          name: 'Nathan Bleu',
          phone: '+3360120014',
          email: 'nathan.bleu14@example.com',
          lastContactedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        // International contacts for diversity
        Contact(
          id: '16',
          name: 'John Doe',
          phone: '+1 (555) 123-4567',
          email: 'john.doe@email.com',
          isFavorite: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Contact(
          id: '17',
          name: 'Jane Smith',
          phone: '+1 (555) 987-6543',
          email: 'jane.smith@email.com',
          isFavorite: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
        Contact(
          id: '18',
          name: 'María García',
          phone: '+34 912 345 678',
          email: 'maria.garcia@email.es',
          lastContactedAt: DateTime.now().subtract(const Duration(days: 22)),
        ),
        Contact(
          id: '19',
          name: 'Hans Mueller',
          phone: '+49 30 12345678',
          email: 'hans.mueller@email.de',
          needsInteractionSoon: true,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 70)),
        ),
        Contact(
          id: '20',
          name: 'Yuki Tanaka',
          phone: '+81 3 1234 5678',
          email: 'yuki.tanaka@email.jp',
          isFavorite: false,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ];
    } catch (e) {
      if (e is ContactsPermissionException) {
        rethrow;
      }
      throw ContactsException(
          'Failed to fetch device contacts: ${e.toString()}');
    }
  }

  @override
  Future<bool> requestContactsPermission() async {
    try {
      final PermissionStatus status = await Permission.contacts.request();
      return status.isGranted;
    } catch (e) {
      throw ContactsPermissionException(
          'Failed to request contacts permission: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasContactsPermission() async {
    try {
      final PermissionStatus status = await Permission.contacts.status;
      return status.isGranted;
    } catch (e) {
      throw ContactsPermissionException(
          'Failed to check contacts permission: ${e.toString()}');
    }
  }
}
