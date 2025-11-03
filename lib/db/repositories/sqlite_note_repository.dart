import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/note_repository.dart';
import 'package:monica_companion/db/models/note.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of NoteRepository
class SqliteNoteRepository extends BaseRepository<Note, int>
    implements NoteRepository {
  SqliteNoteRepository(DatabaseInterface database) : super(database, 'notes');

  @override
  Note fromMap(Map<String, dynamic> map) => Note.fromMap(map);

  @override
  Future<List<Note>> findByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM notes
        WHERE contact_id = ?
        ORDER BY updated_at DESC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding notes by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find notes by contact ID',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Note>> findByCategory(String category) async {
    try {
      const String sql = '''
        SELECT * FROM notes
        WHERE category = ?
        ORDER BY updated_at DESC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[category],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding notes by category',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find notes by category',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Note>> findPrivate() async {
    try {
      const String sql = '''
        SELECT * FROM notes
        WHERE is_private = 1
        ORDER BY updated_at DESC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding private notes',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find private notes',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Note>> findPublic() async {
    try {
      const String sql = '''
        SELECT * FROM notes
        WHERE is_private = 0
        ORDER BY updated_at DESC, created_at DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding public notes',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find public notes',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Note>> findByContent(String searchQuery) async {
    try {
      const String sql = '''
        SELECT * FROM notes
        WHERE content LIKE ? ESCAPE '\\'
        ORDER BY updated_at DESC, created_at DESC
      ''';
      final String sanitizedQuery = sanitizeSearchQuery(searchQuery);
      final String searchPattern = '%$sanitizedQuery%';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[searchPattern],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'searching notes by content',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to search notes by content',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Note>> findRecent(int days) async {
    try {
      final DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
      const String sql = '''
        SELECT * FROM notes
        WHERE updated_at >= ? OR (updated_at IS NULL AND created_at >= ?)
        ORDER BY updated_at DESC, created_at DESC
      ''';
      final String cutoffString = cutoffDate.toIso8601String();
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[cutoffString, cutoffString],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding recent notes',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find recent notes',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Note>> findByDateRange(DateTime start, DateTime end) async {
    try {
      const String sql = '''
        SELECT * FROM notes
        WHERE (updated_at BETWEEN ? AND ?) OR (updated_at IS NULL AND created_at BETWEEN ? AND ?)
        ORDER BY updated_at DESC, created_at DESC
      ''';
      final String startString = start.toIso8601String();
      final String endString = end.toIso8601String();
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[startString, endString, startString, endString],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding notes by date range',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find notes by date range',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<int> countByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM notes
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
        'counting notes by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to count notes by contact ID',
              'COUNT_ERROR',
            );
    }
  }

  @override
  Future<Note?> findMostRecentByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM notes
        WHERE contact_id = ?
        ORDER BY updated_at DESC, created_at DESC
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
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding most recent note by contact ID',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find most recent note by contact ID',
              'SEARCH_ERROR',
            );
    }
  }
}
