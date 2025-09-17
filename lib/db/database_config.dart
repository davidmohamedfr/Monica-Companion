import 'package:monica_mobile_app/core/constants/app_constants.dart';

/// Database configuration and schema management
class DatabaseConfig {
  DatabaseConfig._();

  /// Database name
  static const String databaseName = AppConstants.dbName;

  /// Database version
  static const int databaseVersion = AppConstants.dbVersion;

  /// Common column names
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnSyncStatus = 'sync_status';
  static const String columnLocalId = 'local_id';
  static const String columnRemoteId = 'remote_id';

  /// SQL data types
  static const String typeInteger = 'INTEGER';
  static const String typeText = 'TEXT';
  static const String typeReal = 'REAL';
  static const String typeBlob = 'BLOB';
  static const String typeDatetime = 'DATETIME';

  /// SQL constraints
  static const String primaryKey = 'PRIMARY KEY';
  static const String autoIncrement = 'AUTOINCREMENT';
  static const String notNull = 'NOT NULL';
  static const String unique = 'UNIQUE';
  static const String defaultCurrentTimestamp = 'DEFAULT CURRENT_TIMESTAMP';

  /// Common SQL fragments
  static String get commonColumns =>
      '''
    $columnId $typeInteger $primaryKey $autoIncrement,
    $columnCreatedAt $typeDatetime $defaultCurrentTimestamp,
    $columnUpdatedAt $typeDatetime $defaultCurrentTimestamp
  ''';

  /// Get standard index creation SQL
  static String createIndex(
    String tableName,
    String columnName, {
    bool unique = false,
  }) {
    final String uniqueKeyword = unique ? 'UNIQUE ' : '';
    return 'CREATE ${uniqueKeyword}INDEX IF NOT EXISTS '
        'idx_${tableName}_$columnName ON $tableName($columnName)';
  }

  /// Get trigger SQL for updating updated_at column
  static String createUpdateTrigger(String tableName) =>
      '''
      CREATE TRIGGER IF NOT EXISTS update_${tableName}_updated_at
      AFTER UPDATE ON $tableName
      FOR EACH ROW
      BEGIN
        UPDATE $tableName SET $columnUpdatedAt = CURRENT_TIMESTAMP WHERE $columnId = NEW.$columnId;
      END
    ''';
}
