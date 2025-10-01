import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/db/interfaces/contact_repository.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/models/contact.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of ContactRepository
class SqliteContactRepository extends BaseRepository<Contact, int>
    implements ContactRepository {
  SqliteContactRepository(DatabaseInterface database)
    : super(database, 'contacts');

  @override
  Contact fromMap(Map<String, dynamic> map) => Contact.fromMap(map);

  @override
  Future<List<Contact>> findByName(String name) async {
    try {
      const String sql = '''
        SELECT * FROM contacts
        WHERE name LIKE ?
        ORDER BY name ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>['%$name%'],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding contacts by name',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find contacts by name',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Contact>> findByEmail(String email) async {
    try {
      const String sql = '''
        SELECT * FROM contacts
        WHERE email = ?
        ORDER BY name ASC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[email],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding contacts by email',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find contacts by email',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Contact>> findByBirthdayMonth(int month) async {
    try {
      const String sql = '''
        SELECT * FROM contacts
        WHERE strftime('%m', birthday) = ?
        ORDER BY strftime('%d', birthday) ASC, name ASC
      ''';
      final String monthStr = month.toString().padLeft(2, '0');
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[monthStr],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding contacts by birthday month',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find contacts by birthday month',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Contact>> findUpcomingBirthdays(int daysAhead) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime futureDate = now.add(Duration(days: daysAhead));

      const String sql = '''
        SELECT * FROM contacts
        WHERE birthday IS NOT NULL
        AND (
          strftime('%m-%d', birthday) BETWEEN strftime('%m-%d', ?) AND strftime('%m-%d', ?)
          OR (
            strftime('%m', birthday) > strftime('%m', ?)
            OR (
              strftime('%m', birthday) = strftime('%m', ?)
              AND strftime('%d', birthday) >= strftime('%d', ?)
            )
          )
        )
        ORDER BY strftime('%m', birthday) ASC, strftime('%d', birthday) ASC, name ASC
      ''';

      final List<Map<String, dynamic>> results = await database
          .rawQuery(sql, <dynamic>[
            now.toIso8601String(),
            futureDate.toIso8601String(),
            now.toIso8601String(),
            now.toIso8601String(),
            now.toIso8601String(),
          ]);
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'finding upcoming birthdays',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to find upcoming birthdays',
              'SEARCH_ERROR',
            );
    }
  }

  @override
  Future<List<Contact>> search(String query) async {
    try {
      const String sql = '''
        SELECT * FROM contacts
        WHERE name LIKE ? OR email LIKE ? OR phone LIKE ?
        ORDER BY name ASC
      ''';
      final String searchPattern = '%$query%';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[searchPattern, searchPattern, searchPattern],
      );
      return results.map(fromMap).toList();
    } on Object catch (e) {
      final Failure failure = ErrorTransformer.transformException(
        e,
        'searching contacts',
      );
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : const DatabaseException(
              'Failed to search contacts',
              'SEARCH_ERROR',
            );
    }
  }
}
