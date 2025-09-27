import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/debt.dart';

/// Repository interface for Debt entities
abstract class DebtRepository implements RepositoryInterface<Debt, int> {
  /// Find debts for a specific contact
  Future<List<Debt>> findByContactId(int contactId);

  /// Find debts by type
  Future<List<Debt>> findByType(DebtType type);

  /// Find unpaid debts
  Future<List<Debt>> findUnpaid();

  /// Find paid debts
  Future<List<Debt>> findPaid();

  /// Find debts within an amount range
  Future<List<Debt>> findByAmountRange(double minAmount, double maxAmount);

  /// Find debts within a date range
  Future<List<Debt>> findByDateRange(DateTime start, DateTime end);

  /// Find debts by currency
  Future<List<Debt>> findByCurrency(String currency);

  /// Count debts for a contact
  Future<int> countByContactId(int contactId);

  /// Get total amount owed to me for a contact
  Future<double> getTotalOwedToMeByContactId(int contactId);

  /// Get total amount I owe to a contact
  Future<double> getTotalIOweByContactId(int contactId);

  /// Get total unpaid amount for a contact
  Future<double> getTotalUnpaidByContactId(int contactId);
}
