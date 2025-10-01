import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/life_event_repository.dart';
import 'package:monica_companion/db/models/life_event.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of LifeEventRepository
class SqliteLifeEventRepository extends BaseRepository<LifeEvent, int>
    implements LifeEventRepository {
  SqliteLifeEventRepository(DatabaseInterface database)
    : super(database, 'life_events');

  @override
  LifeEvent fromMap(Map<String, dynamic> map) => LifeEvent.fromMap(map);

  @override
  Future<List<LifeEvent>> findByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM life_events
        WHERE contact_id = ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding life events by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find life events by contact ID',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<LifeEvent>> findByEventType(String eventType) async {
    try {
      const String sql = '''
        SELECT * FROM life_events
        WHERE event_type = ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[eventType],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding life events by event type',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find life events by event type',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<LifeEvent>> findByDateRange(DateTime start, DateTime end) async {
    try {
      const String sql = '''
        SELECT * FROM life_events
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
        'finding life events by date range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find life events by date range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<LifeEvent>> findByImportance(int importance) async {
    try {
      const String sql = '''
        SELECT * FROM life_events
        WHERE importance = ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[importance],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding life events by importance',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find life events by importance',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<LifeEvent>> findUpcomingEvents(int daysAhead) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime futureDate = now.add(Duration(days: daysAhead));

      const String sql = '''
        SELECT * FROM life_events
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
        'finding upcoming life events',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find upcoming life events',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<LifeEvent>> findByImportanceRange(
    int minImportance,
    int maxImportance,
  ) async {
    try {
      const String sql = '''
        SELECT * FROM life_events
        WHERE importance BETWEEN ? AND ?
        ORDER BY importance DESC, date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[minImportance, maxImportance],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding life events by importance range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find life events by importance range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<int> countByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM life_events
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
        'counting life events by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to count life events by contact ID',
              'COUNT_ERROR',
            );
    }
  }
}
