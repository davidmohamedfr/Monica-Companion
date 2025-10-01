import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/relationship_repository.dart';
import 'package:monica_companion/db/models/relationship.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of RelationshipRepository
class SqliteRelationshipRepository extends BaseRepository<Relationship, int>
    implements RelationshipRepository {
  SqliteRelationshipRepository(DatabaseInterface database)
    : super(database, 'relationships');

  @override
  Relationship fromMap(Map<String, dynamic> map) => Relationship.fromMap(map);

  @override
  Future<List<Relationship>> findByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM relationships
        WHERE contact_id = ?
        ORDER BY start_date DESC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding relationships by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find relationships by contact ID',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Relationship>> findByType(String relationshipType) async {
    try {
      const String sql = '''
        SELECT * FROM relationships
        WHERE relationship_type = ?
        ORDER BY start_date DESC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[relationshipType],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding relationships by type',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find relationships by type',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Relationship>> findByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      const String sql = '''
        SELECT * FROM relationships
        WHERE start_date BETWEEN ? AND ?
        ORDER BY start_date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[start.toIso8601String(), end.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding relationships by date range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find relationships by date range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Relationship>> findStartedBefore(DateTime date) async {
    try {
      const String sql = '''
        SELECT * FROM relationships
        WHERE start_date IS NOT NULL AND start_date < ?
        ORDER BY start_date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[date.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding relationships started before date',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find relationships started before date',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Relationship>> findStartedAfter(DateTime date) async {
    try {
      const String sql = '''
        SELECT * FROM relationships
        WHERE start_date IS NOT NULL AND start_date > ?
        ORDER BY start_date ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[date.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding relationships started after date',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find relationships started after date',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Relationship>> findRecent(int days) async {
    try {
      final DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
      const String sql = '''
        SELECT * FROM relationships
        WHERE start_date >= ?
        ORDER BY start_date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[cutoffDate.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding recent relationships',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find recent relationships',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<int> countByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM relationships
        WHERE contact_id = ?
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.first['count'] as int;
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'counting relationships by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to count relationships by contact ID',
              'COUNT_ERROR',
            );
    }
  }

  @override
  Future<List<String>> getUniqueTypes() async {
    try {
      const String sql = '''
        SELECT DISTINCT relationship_type FROM relationships
        WHERE relationship_type IS NOT NULL AND relationship_type != ''
        ORDER BY relationship_type ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results
          .map((Map<String, dynamic> row) => row['relationship_type'] as String)
          .toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'getting unique relationship types',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to get unique relationship types',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Relationship>> findLongestRelationships(int limit) async {
    try {
      const String sql = '''
        SELECT * FROM relationships
        WHERE start_date IS NOT NULL
        ORDER BY start_date ASC
        LIMIT ?
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[limit],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding longest relationships',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find longest relationships',
              'SEARCH_ERROR',
            );
    }
  }
}
