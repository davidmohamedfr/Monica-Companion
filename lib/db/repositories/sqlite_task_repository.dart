import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/task_repository.dart';
import 'package:monica_companion/db/models/task.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of TaskRepository
class SqliteTaskRepository extends BaseRepository<Task, int>
    implements TaskRepository {
  SqliteTaskRepository(DatabaseInterface database) : super(database, 'tasks');

  @override
  Task fromMap(Map<String, dynamic> map) => Task.fromMap(map);

  @override
  Future<List<Task>> findByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM tasks
        WHERE contact_id = ?
        ORDER BY priority DESC, due_date ASC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding tasks by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find tasks by contact ID',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Task>> findCompleted() async {
    try {
      const String sql = '''
        SELECT * FROM tasks
        WHERE completed = 1
        ORDER BY created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding completed tasks',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find completed tasks',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Task>> findPending() async {
    try {
      const String sql = '''
        SELECT * FROM tasks
        WHERE completed = 0
        ORDER BY priority DESC, due_date ASC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding pending tasks',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find pending tasks',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Task>> findByPriority(int priority) async {
    try {
      const String sql = '''
        SELECT * FROM tasks
        WHERE priority = ?
        ORDER BY due_date ASC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[priority],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding tasks by priority',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find tasks by priority',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Task>> findOverdue() async {
    try {
      final DateTime now = DateTime.now();
      const String sql = '''
        SELECT * FROM tasks
        WHERE completed = 0 AND due_date IS NOT NULL AND due_date < ?
        ORDER BY due_date ASC, priority DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[now.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding overdue tasks',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find overdue tasks',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Task>> findByDateRange(DateTime start, DateTime end) async {
    try {
      const String sql = '''
        SELECT * FROM tasks
        WHERE due_date BETWEEN ? AND ?
        ORDER BY due_date ASC, priority DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[start.toIso8601String(), end.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding tasks by date range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find tasks by date range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Task>> findByPriorityRange(
    int minPriority,
    int maxPriority,
  ) async {
    try {
      const String sql = '''
        SELECT * FROM tasks
        WHERE priority BETWEEN ? AND ?
        ORDER BY priority DESC, due_date ASC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[minPriority, maxPriority],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding tasks by priority range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find tasks by priority range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Task>> findUpcoming(int daysAhead) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime futureDate = now.add(Duration(days: daysAhead));

      const String sql = '''
        SELECT * FROM tasks
        WHERE completed = 0 AND due_date BETWEEN ? AND ?
        ORDER BY due_date ASC, priority DESC
      ''';

      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[now.toIso8601String(), futureDate.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding upcoming tasks',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find upcoming tasks',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<int> countByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM tasks
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
        'counting tasks by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to count tasks by contact ID',
              'COUNT_ERROR',
            );
    }
  }

  @override
  Future<int> countCompletedByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM tasks
        WHERE contact_id = ? AND completed = 1
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.first['count'] as int;
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'counting completed tasks by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to count completed tasks by contact ID',
              'COUNT_ERROR',
            );
    }
  }

  @override
  Future<int> countPendingByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM tasks
        WHERE contact_id = ? AND completed = 0
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.first['count'] as int;
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'counting pending tasks by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to count pending tasks by contact ID',
              'COUNT_ERROR',
            );
    }
  }
}
