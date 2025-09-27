import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/gift.dart';

/// Repository interface for Gift entities
abstract class GiftRepository implements RepositoryInterface<Gift, int> {
  /// Find gifts for a specific contact
  Future<List<Gift>> findByContactId(int contactId);

  /// Find gifts by occasion
  Future<List<Gift>> findByOccasion(String occasion);

  /// Find gifts within a date range
  Future<List<Gift>> findByDateRange(DateTime start, DateTime end);

  /// Find gifts within a value range
  Future<List<Gift>> findByValueRange(double minValue, double maxValue);

  /// Find gifts by name (partial match)
  Future<List<Gift>> findByName(String name);

  /// Find recent gifts (last N days)
  Future<List<Gift>> findRecent(int days);

  /// Find gifts with value greater than specified amount
  Future<List<Gift>> findByMinValue(double minValue);

  /// Count gifts for a contact
  Future<int> countByContactId(int contactId);

  /// Get total value of gifts for a contact
  Future<double> getTotalValueByContactId(int contactId);
}
