import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/core/utils/logger.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/debt_repository.dart';
import 'package:monica_companion/db/models/debt.dart';
import 'package:monica_companion/db/repositories/base_repository.dart';

/// SQLite implementation of DebtRepository
class SqliteDebtRepository extends BaseRepository<Debt, int>
    implements DebtRepository {
  SqliteDebtRepository(DatabaseInterface database)
      : super(database, 'debts');

  @override
  Debt fromMap(Map<String, dynamic> map) => Debt.fromMap(map);

  @override
  Future<List<Debt>> findByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT * FROM debts
        WHERE contact_id = ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding debts by contact ID');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find debts by contact ID', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Debt>> findByType(DebtType type) async {
    try {
      const String sql = '''
        SELECT * FROM debts
        WHERE type = ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[type.value],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding debts by type');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find debts by type', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Debt>> findUnpaid() async {
    try {
      const String sql = '''
        SELECT * FROM debts
        WHERE paid = 0
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding unpaid debts');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find unpaid debts', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Debt>> findPaid() async {
    try {
      const String sql = '''
        SELECT * FROM debts
        WHERE paid = 1
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding paid debts');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find paid debts', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Debt>> findByAmountRange(double minAmount, double maxAmount) async {
    try {
      const String sql = '''
        SELECT * FROM debts
        WHERE amount BETWEEN ? AND ?
        ORDER BY amount DESC, date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[minAmount, maxAmount],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding debts by amount range');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find debts by amount range', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Debt>> findByDateRange(DateTime start, DateTime end) async {
    try {
      const String sql = '''
        SELECT * FROM debts
        WHERE date BETWEEN ? AND ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[start.toIso8601String(), end.toIso8601String()],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding debts by date range');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find debts by date range', 'SEARCH_ERROR');
    }
  }

  @override
  Future<List<Debt>> findByCurrency(String currency) async {
    try {
      const String sql = '''
        SELECT * FROM debts
        WHERE currency = ?
        ORDER BY date DESC
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[currency],
      );
      return results.map(fromMap).toList();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'finding debts by currency');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to find debts by currency', 'SEARCH_ERROR');
    }
  }

  @override
  Future<int> countByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COUNT(*) as count FROM debts
        WHERE contact_id = ?
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return results.first['count'] as int;
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'counting debts by contact ID');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to count debts by contact ID', 'COUNT_ERROR');
    }
  }

  @override
  Future<double> getTotalOwedToMeByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COALESCE(SUM(amount), 0.0) as total FROM debts
        WHERE contact_id = ? AND type = ?
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId, DebtType.owedToMe.value],
      );
      return (results.first['total'] as num).toDouble();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'getting total owed to me by contact ID');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to get total owed to me by contact ID', 'CALCULATION_ERROR');
    }
  }

  @override
  Future<double> getTotalIOweByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COALESCE(SUM(amount), 0.0) as total FROM debts
        WHERE contact_id = ? AND type = ?
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId, DebtType.iOwe.value],
      );
      return (results.first['total'] as num).toDouble();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'getting total I owe by contact ID');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to get total I owe by contact ID', 'CALCULATION_ERROR');
    }
  }

  @override
  Future<double> getTotalUnpaidByContactId(int contactId) async {
    try {
      const String sql = '''
        SELECT COALESCE(SUM(amount), 0.0) as total FROM debts
        WHERE contact_id = ? AND paid = 0
      ''';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[contactId],
      );
      return (results.first['total'] as num).toDouble();
    } catch (e) {
      final failure = ErrorTransformer.transformException(e, 'getting total unpaid by contact ID');
      throw failure is DatabaseFailure
          ? DatabaseException(failure.message, failure.code)
          : DatabaseException('Failed to get total unpaid by contact ID', 'CALCULATION_ERROR');
    }
  }
}