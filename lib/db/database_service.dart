import 'dart:async';

import 'package:monica_companion/core/constants/app_constants.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// SQLite implementation of the database interface
class DatabaseService implements DatabaseInterface {
  Database? _database;
  final String _databaseName = AppConstants.dbName;
  final int _databaseVersion = AppConstants.dbVersion;

  /// Get the database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  @override
  Future<void> initialize() async {
    _database = await _initDatabase();
  }

  /// Initialize database with proper path and configuration
  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String dbPath = path.join(databasesPath, _databaseName);

    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database settings
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create schema version table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schema_version (
        version INTEGER PRIMARY KEY,
        migrated_at TEXT NOT NULL
      )
    ''');

    // Create contacts table
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        avatar TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert version record
    await db.insert('schema_version', <String, Object?>{
      'version': 1,
      'migrated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Simple upgrade - for now just recreate
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS contacts');
      await _onCreate(db, newVersion);
    }
  }

  /// Close the database connection
  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Check if database is open
  @override
  bool get isOpen => _database?.isOpen ?? false;

  /// Get database version
  @override
  int get version => _databaseVersion;

  /// Execute a raw SQL query
  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final Database db = await database;
    return db.rawQuery(sql, arguments);
  }

  /// Execute a raw SQL insert/update/delete
  @override
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final Database db = await database;
    return db.rawUpdate(sql, arguments ?? <Object?>[]);
  }

  /// Execute operations within a transaction
  /// Properly passes the Transaction object to the action function
  /// for database operations within the transaction
  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final Database db = await database;
    return db.transaction((Transaction txn) async => action(txn));
  }
}
