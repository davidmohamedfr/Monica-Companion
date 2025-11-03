import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/gift_repository.dart';
import 'package:monica_companion/db/models/gift.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of GiftRepository
class SqliteGiftRepository extends BaseRepository<Gift, int>
    implements GiftRepository {
  SqliteGiftRepository(DatabaseInterface database) : super(database, 'gifts');

  @override
  Gift fromMap(Map<String, dynamic> map) => Gift.fromMap(map);

  @override
  Future<List<Gift>> findByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM gifts
        WHERE contact_id = ?
        ORDER BY date_given DESC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding gifts by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find gifts by contact ID',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Gift>> findByOccasion(String occasion) async {
    try {
      const String sql = '''
        SELECT * FROM gifts
        WHERE occasion = ?
        ORDER BY date_given DESC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[occasion],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding gifts by occasion',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find gifts by occasion',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Gift>> findByDateRange(DateTime start, DateTime end) async {
    try {
      const String sql = '''
        SELECT * FROM gifts
        WHERE date_given BETWEEN ? AND ?
        ORDER BY date_given DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[start.toIso8601String(), end.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding gifts by date range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find gifts by date range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Gift>> findByValueRange(double minValue, double maxValue) async {
    try {
      const String sql = '''
        SELECT * FROM gifts
        WHERE value BETWEEN ? AND ?
        ORDER BY value DESC, date_given DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[minValue, maxValue],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding gifts by value range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find gifts by value range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Gift>> findByName(String name) async {
    try {
      const String sql = '''
        SELECT * FROM gifts
        WHERE name LIKE ? ESCAPE '\\'
        ORDER BY date_given DESC, created_at DESC
      ''';
      final String sanitizedName = sanitizeSearchQuery(name);
      final String searchPattern = '%$sanitizedName%';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[searchPattern],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding gifts by name',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find gifts by name',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Gift>> findRecent(int days) async {
    try {
      final DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
      const String sql = '''
        SELECT * FROM gifts
        WHERE date_given >= ?
        ORDER BY date_given DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[cutoffDate.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding recent gifts',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find recent gifts',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Gift>> findByMinValue(double minValue) async {
    try {
      const String sql = '''
        SELECT * FROM gifts
        WHERE value >= ?
        ORDER BY value DESC, date_given DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[minValue],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding gifts by minimum value',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find gifts by minimum value',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<int> countByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM gifts
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
        'counting gifts by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to count gifts by contact ID',
              'COUNT_ERROR',
            );
    }
  }

  @override
  Future<double> getTotalValueByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COALESCE(SUM(value), 0.0) as total FROM gifts
        WHERE contact_id = ? AND value IS NOT NULL
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return (results.first['total'] as num).toDouble();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'getting total gift value by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to get total gift value by contact ID',
              'CALCULATION_ERROR',
            );
    }
  }
}
