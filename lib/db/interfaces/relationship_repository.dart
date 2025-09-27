import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/relationship.dart';

/// Repository interface for Relationship entities
abstract class RelationshipRepository
    implements RepositoryInterface<Relationship, int> {
  /// Find relationships for a specific contact
  Future<List<Relationship>> findByContactId(int contactId);

  /// Find relationships by type
  Future<List<Relationship>> findByType(String relationshipType);

  /// Find relationships within a date range (by start date)
  Future<List<Relationship>> findByDateRange(DateTime start, DateTime end);

  /// Find relationships that started before a specific date
  Future<List<Relationship>> findStartedBefore(DateTime date);

  /// Find relationships that started after a specific date
  Future<List<Relationship>> findStartedAfter(DateTime date);

  /// Find recent relationships (started within last N days)
  Future<List<Relationship>> findRecent(int days);

  /// Count relationships for a contact
  Future<int> countByContactId(int contactId);

  /// Get all unique relationship types
  Future<List<String>> getUniqueTypes();

  /// Find longest relationships (by start date)
  Future<List<Relationship>> findLongestRelationships(int limit);
}
