import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/activity.dart';

/// Repository interface for Activity entities
abstract class ActivityRepository implements RepositoryInterface<Activity, int> {
  /// Find activities for a specific participant (contact)
  Future<List<Activity>> findByParticipant(int contactId);

  /// Find activities within a date range
  Future<List<Activity>> findByDateRange(DateTime start, DateTime end);

  /// Find activities by location
  Future<List<Activity>> findByLocation(String location);

  /// Find recent activities (last N days)
  Future<List<Activity>> findRecent(int days);

  /// Find activities by title (partial match)
  Future<List<Activity>> findByTitle(String title);

  /// Find upcoming activities (within next N days)
  Future<List<Activity>> findUpcoming(int daysAhead);

  /// Find activities with multiple participants
  Future<List<Activity>> findWithMultipleParticipants();

  /// Count activities for a participant
  Future<int> countByParticipant(int contactId);

  /// Get all unique locations
  Future<List<String>> getUniqueLocations();
}