import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/migrations/v1_initial_schema.dart';
import 'package:sqflite/sqflite.dart';

/// Database migration runner for managing schema versions
class MigrationRunner {
  MigrationRunner(this._database);
  final DatabaseInterface _database;

  /// List of all migrations in order
  final List<Migration> _migrations = <Migration>[V1InitialSchema()];

  /// Run all pending migrations
  Future<void> runMigrations() async {
    final int currentVersion = await _getCurrentVersion();

    for (final Migration migration in _migrations) {
      if (migration.version > currentVersion) {
        await _runMigration(migration);
        await _updateVersion(migration.version);
      }
    }
  }

  /// Get current database version
  Future<int> _getCurrentVersion() async {
    try {
      final List<Map<String, dynamic>> result = await _database.rawQuery(
        'SELECT version FROM schema_version ORDER BY version DESC LIMIT 1',
      );

      if (result.isNotEmpty) {
        return result.first['version'] as int;
      }
    } on Object catch (e) {
      // Schema version table doesn't exist yet
    }

    return 0;
  }

  /// Run a single migration
  Future<void> _runMigration(Migration migration) async {
    await _database.transaction((Transaction txn) async {
      // Run up migration
      for (final String sql in migration.upStatements) {
        await txn.rawUpdate(sql);
      }

      // Run any post-migration operations
      await migration.onUp(_database);
    });
  }

  /// Update the schema version
  Future<void> _updateVersion(int version) async {
    await _database.rawExecute(
      'INSERT OR REPLACE INTO schema_version '
      '(version, migrated_at) VALUES (?, ?)',
      <dynamic>[version, DateTime.now().toIso8601String()],
    );
  }

  /// Rollback to a specific version (for development/testing)
  Future<void> rollbackToVersion(int targetVersion) async {
    final int currentVersion = await _getCurrentVersion();

    if (targetVersion >= currentVersion) {
      return; // Nothing to rollback
    }

    // Find migrations to rollback (in reverse order)
    final List<Migration> migrationsToRollback =
        _migrations.where((Migration m) => m.version > targetVersion).toList()
          ..sort(
            (Migration a, Migration b) => b.version.compareTo(a.version),
          ); // Reverse order

    for (final Migration migration in migrationsToRollback) {
      await _database.transaction((Transaction txn) async {
        // Run down migration
        for (final String sql in migration.downStatements) {
          await txn.rawUpdate(sql);
        }

        // Run any post-rollback operations
        await migration.onDown(_database);
      });
    }

    // Remove version record
    await _database.rawExecute(
      'DELETE FROM schema_version WHERE version > ?',
      <dynamic>[targetVersion],
    );
  }
}

/// Base migration class
abstract class Migration {
  /// Migration version number
  int get version;

  /// SQL statements to run when upgrading
  List<String> get upStatements;

  /// SQL statements to run when downgrading
  List<String> get downStatements;

  /// Optional post-migration operations
  Future<void> onUp(DatabaseInterface database) async {}

  /// Optional post-rollback operations
  Future<void> onDown(DatabaseInterface database) async {}
}
