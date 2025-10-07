import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/services/contacts_service.dart';

abstract class ContactsRepository {
  Future<List<Contact>> getContacts();
  Future<List<Contact>> searchContacts(String query);
  Future<List<Contact>> filterContacts(ContactFilter filter);
  Future<List<Contact>> searchAndFilterContacts(
    String query,
    ContactFilter filter,
  );
  Future<void> updateDeviceContact(Contact contact);
  Future<void> createDeviceContact(Contact contact);
  Future<bool> isContactReadOnly(String contactId);
}

class ContactsRepositoryImpl implements ContactsRepository {
  const ContactsRepositoryImpl(this._contactsService);

  final ContactsService _contactsService;

  @override
  Future<List<Contact>> getContacts() async =>
      _contactsService.getDeviceContacts();

  @override
  Future<List<Contact>> searchContacts(String query) async {
    final List<Contact> contacts = await getContacts();

    if (query.isEmpty) {
      return contacts;
    }

    final String lowercaseQuery = query.toLowerCase();

    return contacts.where((Contact contact) {
      final bool nameMatch = contact.name.toLowerCase().contains(
        lowercaseQuery,
      );
      final bool phoneMatch =
          contact.phone?.toLowerCase().contains(lowercaseQuery) ?? false;
      final bool emailMatch =
          contact.email?.toLowerCase().contains(lowercaseQuery) ?? false;

      return nameMatch || phoneMatch || emailMatch;
    }).toList();
  }

  @override
  Future<List<Contact>> filterContacts(ContactFilter filter) async {
    final List<Contact> contacts = await getContacts();

    return _applyFilter(contacts, filter);
  }

  @override
  Future<List<Contact>> searchAndFilterContacts(
    String query,
    ContactFilter filter,
  ) async {
    final List<Contact> contacts = await searchContacts(query);

    return _applyFilter(contacts, filter);
  }

  @override
  Future<void> updateDeviceContact(Contact contact) async =>
      _contactsService.updateDeviceContact(contact);

  @override
  Future<void> createDeviceContact(Contact contact) async =>
      _contactsService.createDeviceContact(contact);

  @override
  Future<bool> isContactReadOnly(String contactId) async =>
      _contactsService.isContactReadOnly(contactId);

  List<Contact> _applyFilter(List<Contact> contacts, ContactFilter filter) {
    switch (filter) {
      case ContactFilter.all:
        return contacts;
      case ContactFilter.favorites:
        return contacts.where((Contact contact) => contact.isFavorite).toList();
      case ContactFilter.recentlyContacted:
        final DateTime now = DateTime.now();
        const Duration recentThreshold = Duration(days: 30);
        return contacts.where((Contact contact) {
          final DateTime? lastContacted = contact.lastContactedAt;
          return lastContacted != null &&
              now.difference(lastContacted) <= recentThreshold;
        }).toList();
      case ContactFilter.needsInteraction:
        return contacts
            .where((Contact contact) => contact.needsInteractionSoon)
            .toList();
    }
  }
}
