import 'package:fast_contacts/fast_contacts.dart' as fast_contacts;
import 'package:monica_companion/core/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsSeeder {
  static Future<void> seedContacts() async {
    // Check and request permission
    final PermissionStatus status = await Permission.contacts.request();
    if (!status.isGranted) {
      Logger.warning('Contacts permission denied');
      return;
    }

    try {
      // Check if contacts already exist to avoid duplicates
      final List<fast_contacts.Contact> existingContacts =
          await fast_contacts.FastContacts.getAllContacts();

      if (existingContacts.length >= 10) {
        Logger.info(
          'Contacts already seeded (${existingContacts.length} contacts found)',
        );
        return;
      }

      Logger.info('Seeding sample contacts...');

      // Sample contacts from the VCF file
      final List<Map<String, String>> sampleContacts = [
        {
          'name': 'Thomas Dupuis',
          'phone': '+3360120000',
          'email': 'thomas.dupuis0@example.com',
        },
        {
          'name': 'Maya Dupuis',
          'phone': '+3360120001',
          'email': 'maya.dupuis1@example.com',
        },
        {
          'name': 'Manon Weber',
          'phone': '+3360120002',
          'email': 'manon.weber2@example.com',
        },
        {
          'name': 'Sabrina Dufour',
          'phone': '+3360120003',
          'email': 'sabrina.dufour3@example.com',
        },
        {
          'name': 'Julien Poirier',
          'phone': '+3360120004',
          'email': 'julien.poirier4@example.com',
        },
        {
          'name': 'John Doe',
          'phone': '+1234567890',
          'email': 'john.doe@example.com',
        },
        {
          'name': 'Jane Smith',
          'phone': '+0987654321',
          'email': 'jane.smith@example.com',
        },
      ];

      // Add each contact
      for (final Map<String, String> contactData in sampleContacts) {
        try {
          final fast_contacts.Contact newContact = fast_contacts.Contact(
            displayName: contactData['name']!,
            phones: [
              fast_contacts.Phone(
                number: contactData['phone']!,
                label: fast_contacts.PhoneLabel.mobile,
              ),
            ],
            emails: [
              fast_contacts.Email(
                address: contactData['email']!,
                label: fast_contacts.EmailLabel.home,
              ),
            ],
          );

          await fast_contacts.FastContacts.insertContact(newContact);
          Logger.info('✅ Added contact: ${contactData['name']}');
        } catch (e) {
          Logger.error('❌ Failed to add contact ${contactData['name']}: $e');
        }
      }

      Logger.info('🎉 Contact seeding completed!');
    } catch (e) {
      Logger.error('❌ Failed to seed contacts: $e');
    }
  }
}
