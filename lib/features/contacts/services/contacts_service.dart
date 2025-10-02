import 'package:contacts_service/contacts_service.dart' as cs;
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

      // Fetch real device contacts
      final Iterable<cs.Contact> deviceContacts =
          await cs.ContactsService.getContacts();

      // Convert to our Contact model
      return deviceContacts.map((cs.Contact deviceContact) {
        final String name = deviceContact.displayName ?? 'Unknown';
        final String? phone = (deviceContact.phones?.isNotEmpty ?? false)
            ? deviceContact.phones!.first.value
            : null;
        final String? email = (deviceContact.emails?.isNotEmpty ?? false)
            ? deviceContact.emails!.first.value
            : null;

        return Contact(
          id: deviceContact.identifier ?? '',
          name: name,
          phone: phone,
          email: email,
          photoUrl: (deviceContact.avatar?.isNotEmpty ?? false)
              ? 'data:image/png;base64,${deviceContact.avatar}'
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
}
