import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/life_event.dart';

/// Repository interface for LifeEvent entities
abstract class LifeEventRepository
    implements RepositoryInterface<LifeEvent, int> {
  /// Find life events for a specific contact
  Future<List<LifeEvent>> findByContactId(int contactId);

  /// Find life events by event type
  Future<List<LifeEvent>> findByEventType(String eventType);

  /// Find life events within a date range
  Future<List<LifeEvent>> findByDateRange(DateTime start, DateTime end);

  /// Find life events by importance level
  Future<List<LifeEvent>> findByImportance(int importance);

  /// Find upcoming life events (within next N days)
  Future<List<LifeEvent>> findUpcomingEvents(int daysAhead);

  /// Find life events by importance level range
  Future<List<LifeEvent>> findByImportanceRange(
    int minImportance,
    int maxImportance,
  );

  /// Count life events for a contact
  Future<int> countByContactId(int contactId);
}
