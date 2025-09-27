import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/contact.dart';

/// Repository interface for Contact entities
abstract class ContactRepository implements RepositoryInterface<Contact, int> {
  /// Find contacts by name (partial match)
  Future<List<Contact>> findByName(String name);

  /// Find contacts by email
  Future<List<Contact>> findByEmail(String email);

  /// Find contacts with birthdays in a specific month
  Future<List<Contact>> findByBirthdayMonth(int month);

  /// Find contacts with upcoming birthdays (within next N days)
  Future<List<Contact>> findUpcomingBirthdays(int daysAhead);

  /// Search contacts by name, email, or phone
  Future<List<Contact>> search(String query);
}
