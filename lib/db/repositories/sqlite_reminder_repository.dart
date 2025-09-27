import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/core/utils/logger.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/reminder_repository.dart';
import 'package:monica_companion/db/models/reminder.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of ReminderRepository
class SqliteReminderRepository extends BaseRepository<Reminder, int>
    implements ReminderRepository {
  SqliteReminderRepository(DatabaseInterface database)
      : super(database, 'reminders');

  @override
  Reminder fromMap(Map<String, dynamic> map) => Reminder.fromMap(map);

  @override
  Future<List<Reminder>> findByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM reminders
        WHERE contact_id = ?
        ORDER BY due_date ASC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding reminders by contact ID');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find reminders by contact ID', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Reminder>> findActive() async {
    try {
      const String sql = '''
        SELECT * FROM reminders
        WHERE active = 1
        ORDER BY due_date ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding active reminders');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find active reminders', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Reminder>> findInactive() async {
    try {
      const String sql = '''
        SELECT * FROM reminders
        WHERE active = 0
        ORDER BY due_date ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding inactive reminders');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find inactive reminders', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Reminder>> findByFrequency(ReminderFrequency frequency) async {
    try {
      const String sql = '''
        SELECT * FROM reminders
        WHERE frequency = ?
        ORDER BY due_date ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[frequency.value],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding reminders by frequency');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find reminders by frequency', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Reminder>> findOverdue() async {
    try {
      final DateTime now = DateTime.now();
      const String sql = '''
        SELECT * FROM reminders
        WHERE active = 1 AND due_date < ?
        ORDER BY due_date ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[now.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding overdue reminders');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find overdue reminders', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Reminder>> findUpcoming(int daysAhead) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime futureDate = now.add(Duration(days: daysAhead));

      const String sql = '''
        SELECT * FROM reminders
        WHERE active = 1 AND due_date BETWEEN ? AND ?
        ORDER BY due_date ASC
      ''';

      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[now.toIso8601String(), futureDate.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding upcoming reminders');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find upcoming reminders', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Reminder>> findByDateRange(DateTime start, DateTime end) async {
    try {
      const String sql = '''
        SELECT * FROM reminders
        WHERE due_date BETWEEN ? AND ?
        ORDER BY due_date ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[start.toIso8601String(), end.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding reminders by date range');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find reminders by date range', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Reminder>> findByTitle(String title) async {
    try {
      const String sql = '''
        SELECT * FROM reminders
        WHERE title LIKE ?
        ORDER BY due_date ASC
      ''';
      final String searchPattern = '%$title%';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[searchPattern],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding reminders by title');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find reminders by title', 'SEARCH_ERROR');
    }
  }

  @override
  Future<int> countByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM reminders
        WHERE contact_id = ?
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.first['count'] as int;
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'counting reminders by contact ID');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to count reminders by contact ID', 'COUNT_ERROR');
    }
  }

  @override
  Future<int> countActiveByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM reminders
        WHERE contact_id = ? AND active = 1
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.first['count'] as int;
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'counting active reminders by contact ID');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to count active reminders by contact ID', 'COUNT_ERROR');
    }
  }

  @override
  Future<Reminder?> findNextDueByContactId(int contactId) async {
    try {
      final DateTime now = DateTime.now();
      const String sql = '''
        SELECT * FROM reminders
        WHERE contact_id = ? AND active = 1 AND due_date >= ?
        ORDER BY due_date ASC
        LIMIT 1
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId, now.toIso8601String()],
      );

      if (results.isEmpty) {
        return null;
      }
      return fromMap(results.first);
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding next due reminder by contact ID');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find next due reminder by contact ID', 'SEARCH_ERROR');
    }
  }
}