import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/reminder.dart';

/// Repository interface for Reminder entities
abstract class ReminderRepository
    implements RepositoryInterface<Reminder, int> {
  /// Find reminders for a specific contact
  Future<List<Reminder>> findByContactId(int contactId);

  /// Find active reminders
  Future<List<Reminder>> findActive();

  /// Find inactive reminders
  Future<List<Reminder>> findInactive();

  /// Find reminders by frequency
  Future<List<Reminder>> findByFrequency(ReminderFrequency frequency);

  /// Find overdue reminders (past due date and active)
  Future<List<Reminder>> findOverdue();

  /// Find upcoming reminders (due within next N days)
  Future<List<Reminder>> findUpcoming(int daysAhead);

  /// Find reminders due within a date range
  Future<List<Reminder>> findByDateRange(DateTime start, DateTime end);

  /// Find reminders by title (partial match)
  Future<List<Reminder>> findByTitle(String title);

  /// Count reminders for a contact
  Future<int> countByContactId(int contactId);

  /// Count active reminders for a contact
  Future<int> countActiveByContactId(int contactId);

  /// Get the next due reminder for a contact
  Future<Reminder?> findNextDueByContactId(int contactId);
}
