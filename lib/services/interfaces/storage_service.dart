import 'package:monica_mobile_app/services/interfaces/base_service.dart';

/// Local storage service interface for key-value storage
abstract class StorageService extends BaseService {
  /// Store a string value
  Future<bool> setString(String key, String value);

  /// Retrieve a string value
  Future<String?> getString(String key);

  /// Store an integer value
  Future<bool> setInt(String key, int value);

  /// Retrieve an integer value
  Future<int?> getInt(String key);

  /// Store a boolean value
  Future<bool> setBool(String key, {required bool value});

  /// Retrieve a boolean value
  Future<bool?> getBool(String key);

  /// Store a double value
  Future<bool> setDouble(String key, double value);

  /// Retrieve a double value
  Future<double?> getDouble(String key);

  /// Store a list of strings
  Future<bool> setStringList(String key, List<String> value);

  /// Retrieve a list of strings
  Future<List<String>?> getStringList(String key);

  /// Remove a key
  Future<bool> remove(String key);

  /// Check if key exists
  Future<bool> containsKey(String key);

  /// Clear all stored data
  Future<bool> clear();

  /// Get all keys
  Future<Set<String>> getKeys();
}
