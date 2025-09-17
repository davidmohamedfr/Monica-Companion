/// Base database interface for all database operations
abstract class DatabaseInterface {
  /// Initialize the database
  Future<void> initialize();

  /// Close the database connection
  Future<void> close();

  /// Check if database is open
  bool get isOpen;

  /// Get database version
  int get version;

  /// Execute a raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]);

  /// Execute a raw SQL insert/update/delete
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]);

  /// Begin a transaction
  Future<void> beginTransaction();

  /// Commit a transaction
  Future<void> commitTransaction();

  /// Rollback a transaction
  Future<void> rollbackTransaction();

  /// Execute operations within a transaction
  Future<T> transaction<T>(Future<T> Function() action);
}
