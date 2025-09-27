import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/interaction.dart';

/// Repository interface for Interaction entities
abstract class InteractionRepository
    implements RepositoryInterface<Interaction, int> {
  /// Find interactions for a specific contact
  Future<List<Interaction>> findByContactId(int contactId);

  /// Find interactions by type
  Future<List<Interaction>> findByType(String type);

  /// Find interactions within a date range
  Future<List<Interaction>> findByDateRange(DateTime start, DateTime end);

  /// Find recent interactions (last N days)
  Future<List<Interaction>> findRecent(int days);

  /// Count interactions for a contact
  Future<int> countByContactId(int contactId);

  /// Get the last interaction with a contact
  Future<Interaction?> findLastByContactId(int contactId);
}
