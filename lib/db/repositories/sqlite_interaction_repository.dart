import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/interaction_repository.dart';
import 'package:monica_companion/db/models/interaction.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of InteractionRepository
class SqliteInteractionRepository extends BaseRepository<Interaction, int>
    implements InteractionRepository {
  SqliteInteractionRepository(DatabaseInterface database)
    : super(database, 'interactions');

  @override
  Interaction fromMap(Map<String, dynamic> map) => Interaction.fromMap(map);

  @override
  Future<List<Interaction>> findByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM interactions
        WHERE contact_id = ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding interactions by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find interactions by contact ID',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Interaction>> findByType(String type) async {
    try {
      const String sql = '''
        SELECT * FROM interactions
        WHERE type = ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[type],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding interactions by type',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find interactions by type',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Interaction>> findByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      const String sql = '''
        SELECT * FROM interactions
        WHERE date BETWEEN ? AND ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[start.toIso8601String(), end.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding interactions by date range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find interactions by date range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Interaction>> findRecent(int days) async {
    try {
      final DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
      const String sql = '''
        SELECT * FROM interactions
        WHERE date >= ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[cutoffDate.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding recent interactions',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find recent interactions',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<int> countByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM interactions
        WHERE contact_id = ?
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.first['count'] as int;
    } catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'counting interactions by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to count interactions by contact ID',
              'COUNT_ERROR',
            );
    }
  }

  @override
  Future<Interaction?> findLastByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM interactions
        WHERE contact_id = ?
        ORDER BY date DESC
        LIMIT 1
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );

      if (results.isEmpty) {
        return null;
      }
      return fromMap(results.first);
    } catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding last interaction by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find last interaction by contact ID',
              'SEARCH_ERROR',
            );
    }
  }
}
