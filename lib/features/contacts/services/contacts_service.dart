import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ContactsService {
  Future<List<Contact>> getDeviceContacts();
  Future<bool> requestContactsPermission();
  Future<bool> hasContactsPermission();
  Future<void> updateDeviceContact(Contact contact);
  Future<void> createDeviceContact(Contact contact);
  Future<bool> isContactReadOnly(String contactId);
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

      // Fetch real device contacts
      final List<fc.Contact> deviceContacts = await fc
          .FlutterContacts.getContacts(withProperties: true, withPhoto: true);

      // Convert to our Contact model
      return deviceContacts.map((fc.Contact deviceContact) {
        final String name = deviceContact.displayName.isNotEmpty
            ? deviceContact.displayName
            : 'Unknown';
        final String? phone = deviceContact.phones.isNotEmpty
            ? deviceContact.phones.first.number
            : null;
        final String? email = deviceContact.emails.isNotEmpty
            ? deviceContact.emails.first.address
            : null;

        return Contact(
          id: deviceContact.id,
          name: name,
          phone: phone,
          email: email,
          photoUrl: deviceContact.photo != null
              ? 'data:image/png;base64,${deviceContact.photo}'
              : null,
        );
      }).toList();
    } catch (e) {
      throw ContactsException('Failed to fetch contacts: $e');
    }
  }

  @override
  Future<bool> requestContactsPermission() async {
    try {
      final PermissionStatus status = await Permission.contacts.request();
      return status.isGranted;
    } catch (e) {
      throw ContactsPermissionException(
        'Failed to request contacts permission: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasContactsPermission() async {
    try {
      final PermissionStatus status = await Permission.contacts.status;
      return status.isGranted;
    } catch (e) {
      throw ContactsPermissionException(
        'Failed to check contacts permission: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateDeviceContact(Contact contact) async {
    try {
      final bool hasPermission = await hasContactsPermission();
      if (!hasPermission) {
        final bool granted = await requestContactsPermission();
        if (!granted) {
          throw const ContactsPermissionException('Contacts permission denied');
        }
      }

      final fc.Contact? deviceContact = await fc.FlutterContacts.getContact(
        contact.id,
        withProperties: true,
      );

      if (deviceContact == null) {
        throw ContactsException('Contact not found: ${contact.id}');
      }

      deviceContact.name.first = '';
      deviceContact.name.last = '';
      deviceContact.displayName = contact.name;

      deviceContact.phones.clear();
      if (contact.phone != null && contact.phone!.isNotEmpty) {
        deviceContact.phones.add(fc.Phone(contact.phone!));
      }

      deviceContact.emails.clear();
      if (contact.email != null && contact.email!.isNotEmpty) {
        deviceContact.emails.add(fc.Email(contact.email!));
      }

      deviceContact.notes.clear();
      if (contact.notes != null && contact.notes!.isNotEmpty) {
        deviceContact.notes.add(fc.Note(contact.notes!));
      }

      await deviceContact.update();
    } catch (e) {
      if (e is ContactsException || e is ContactsPermissionException) {
        rethrow;
      }
      throw ContactsException('Failed to update contact: $e');
    }
  }

  @override
  Future<void> createDeviceContact(Contact contact) async {
    try {
      final bool hasPermission = await hasContactsPermission();
      if (!hasPermission) {
        final bool granted = await requestContactsPermission();
        if (!granted) {
          throw const ContactsPermissionException('Contacts permission denied');
        }
      }

      final fc.Contact newContact = fc.Contact()
        ..name.first = ''
        ..name.last = ''
        ..displayName = contact.name;

      if (contact.phone != null && contact.phone!.isNotEmpty) {
        newContact.phones.add(fc.Phone(contact.phone!));
      }

      if (contact.email != null && contact.email!.isNotEmpty) {
        newContact.emails.add(fc.Email(contact.email!));
      }

      if (contact.notes != null && contact.notes!.isNotEmpty) {
        newContact.notes.add(fc.Note(contact.notes!));
      }

      await newContact.insert();
    } catch (e) {
      if (e is ContactsException || e is ContactsPermissionException) {
        rethrow;
      }
      throw ContactsException('Failed to create contact: $e');
    }
  }

  @override
  Future<bool> isContactReadOnly(String contactId) async {
    try {
      final fc.Contact? deviceContact = await fc.FlutterContacts.getContact(
        contactId,
        withProperties: true,
      );

      if (deviceContact == null) {
        return true;
      }

      // For now, assume all fetched contacts are writable
      // This can be refined based on account type if needed
      return false;
    } catch (e) {
      // If we can't fetch the contact, assume read-only
      return true;
    }
  }
}
