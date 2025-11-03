import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/db/interfaces/activity_repository.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/models/activity.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of ActivityRepository
class SqliteActivityRepository extends BaseRepository<Activity, int>
    implements ActivityRepository {
  SqliteActivityRepository(DatabaseInterface database)
    : super(database, 'activities');

  @override
  Activity fromMap(Map<String, dynamic> map) => Activity.fromMap(map);

  @override
  Future<List<Activity>> findByParticipant(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM activities
        WHERE participants LIKE ? OR participants LIKE ? OR participants LIKE ? OR participants = ?
        ORDER BY date DESC
      ''';
      final String contactIdStr = contactId.toString();
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[
          '%,$contactIdStr,%', // Middle of list
          '$contactIdStr,%', // Start of list
          '%,$contactIdStr', // End of list
          contactIdStr, // Only participant
        ],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding activities by participant',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find activities by participant',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Activity>> findByDateRange(DateTime start, DateTime end) async {
    try {
      const String sql = '''
        SELECT * FROM activities
        WHERE date BETWEEN ? AND ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[start.toIso8601String(), end.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding activities by date range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find activities by date range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Activity>> findByLocation(String location) async {
    try {
      const String sql = '''
        SELECT * FROM activities
        WHERE location LIKE ? ESCAPE '\\'
        ORDER BY date DESC
      ''';
      final String sanitizedLocation = sanitizeSearchQuery(location);
      final String searchPattern = '%$sanitizedLocation%';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[searchPattern],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding activities by location',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find activities by location',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Activity>> findRecent(int days) async {
    try {
      final DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
      const String sql = '''
        SELECT * FROM activities
        WHERE date >= ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[cutoffDate.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding recent activities',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find recent activities',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Activity>> findByTitle(String title) async {
    try {
      const String sql = '''
        SELECT * FROM activities
        WHERE title LIKE ? ESCAPE '\\'
        ORDER BY date DESC
      ''';
      final String sanitizedTitle = sanitizeSearchQuery(title);
      final String searchPattern = '%$sanitizedTitle%';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[searchPattern],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding activities by title',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find activities by title',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Activity>> findUpcoming(int daysAhead) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime futureDate = now.add(Duration(days: daysAhead));

      const String sql = '''
        SELECT * FROM activities
        WHERE date BETWEEN ? AND ?
        ORDER BY date ASC
      ''';

      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[now.toIso8601String(), futureDate.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding upcoming activities',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find upcoming activities',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Activity>> findWithMultipleParticipants() async {
    try {
      const String sql = '''
        SELECT * FROM activities
        WHERE participants LIKE '%,%'
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding activities with multiple participants',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find activities with multiple participants',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<int> countByParticipant(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM activities
        WHERE participants LIKE ? OR participants LIKE ? OR participants LIKE ? OR participants = ?
      ''';
      final String contactIdStr = contactId.toString();
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[
          '%,$contactIdStr,%', // Middle of list
          '$contactIdStr,%', // Start of list
          '%,$contactIdStr', // End of list
          contactIdStr, // Only participant
        ],
      );
      return results.first['count'] as int;
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'counting activities by participant',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to count activities by participant',
              'COUNT_ERROR',
            );
    }
  }

  @override
  Future<List<String>> getUniqueLocations() async {
    try {
      const String sql = '''
        SELECT DISTINCT location FROM activities
        WHERE location IS NOT NULL AND location != ''
        ORDER BY location ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results
          .map((Map<String, dynamic> row) => row['location'] as String)
          .toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'getting unique activity locations',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to get unique activity locations',
              'SEARCH_ERROR',
            );
    }
  }
}
