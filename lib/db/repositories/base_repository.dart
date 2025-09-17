import 'package:monica_mobile_app/core/errors/exceptions.dart';
import 'package:monica_mobile_app/core/utils/logger.dart';
import 'package:monica_mobile_app/db/interfaces/database_interface.dart';
import 'package:monica_mobile_app/db/interfaces/repository_interface.dart';
import 'package:monica_mobile_app/db/models/base_model.dart';

/// Base repository implementation with common CRUD operations
abstract class BaseRepository<T extends BaseModel, ID>
    implements RepositoryInterface<T, ID> {
  BaseRepository(this.database, this.tableName);

  final DatabaseInterface database;
  final String tableName;

  /// Convert Map to entity instance
  T fromMap(Map<String, dynamic> map);

  @override
  Future<ID> insert(T entity) async {
    try {
      final Map<String, dynamic> map = entity.toMap()
        ..remove('id'); // Remove ID for insert

      final String columns = map.keys.join(', ');
      final String placeholders = map.keys.map((_) => '?').join(', ');
      final String sql =
          'INSERT INTO $tableName ($columns) VALUES ($placeholders)';

      final int id = await database.rawExecute(sql, map.values.toList());
      return id as ID;
    } catch (e) {
      Logger.error('Failed to insert entity in $tableName', error: e);
      throw DatabaseException('Failed to insert entity: $e');
    }
  }

  @override
  Future<List<ID>> insertAll(List<T> entities) async {
    final List<ID> ids = <ID>[];

    await database.transaction(() async {
      for (final T entity in entities) {
        final ID id = await insert(entity);
        ids.add(id);
      }
    });

    return ids;
  }

  @override
  Future<bool> update(T entity) async {
    try {
      final Map<String, dynamic> map = entity.toMap();
      final ID? id = map.remove('id') as ID?;

      if (id == null) {
        throw const DatabaseException('Cannot update entity without ID');
      }

      final String setClause = map.keys
          .map((String key) => '$key = ?')
          .join(', ');
      final String sql = 'UPDATE $tableName SET $setClause WHERE id = ?';
      final List<dynamic> values = <dynamic>[...map.values, id];

      final int rowsAffected = await database.rawExecute(sql, values);
      return rowsAffected > 0;
    } catch (e) {
      Logger.error('Failed to update entity in $tableName', error: e);
      throw DatabaseException('Failed to update entity: $e');
    }
  }

  @override
  Future<bool> delete(ID id) async {
    try {
      final String sql = 'DELETE FROM $tableName WHERE id = ?';
      final int rowsAffected = await database.rawExecute(sql, <dynamic>[id]);
      return rowsAffected > 0;
    } catch (e) {
      Logger.error('Failed to delete entity from $tableName', error: e);
      throw DatabaseException('Failed to delete entity: $e');
    }
  }

  @override
  Future<int> deleteAll(List<ID> ids) async {
    if (ids.isEmpty) {
      return 0;
    }

    try {
      final String placeholders = ids.map((_) => '?').join(', ');
      final String sql = 'DELETE FROM $tableName WHERE id IN ($placeholders)';
      return await database.rawExecute(sql, ids);
    } catch (e) {
      Logger.error('Failed to delete entities from $tableName', error: e);
      throw DatabaseException('Failed to delete entities: $e');
    }
  }

  @override
  Future<T?> findById(ID id) async {
    try {
      final String sql = 'SELECT * FROM $tableName WHERE id = ? LIMIT 1';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[id],
      );

      if (results.isEmpty) {
        return null;
      }
      return fromMap(results.first);
    } catch (e) {
      Logger.error('Failed to find entity by ID in $tableName', error: e);
      throw DatabaseException('Failed to find entity: $e');
    }
  }

  @override
  Future<List<T>> findAll() async {
    try {
      final String sql = 'SELECT * FROM $tableName ORDER BY id DESC';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);

      return results.map(fromMap).toList();
    } catch (e) {
      Logger.error('Failed to find all entities in $tableName', error: e);
      throw DatabaseException('Failed to find entities: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final String sql = 'SELECT COUNT(*) as count FROM $tableName';
      final List<Map<String, dynamic>> results = await database.rawQuery(sql);
      return results.first['count'] as int;
    } catch (e) {
      Logger.error('Failed to count entities in $tableName', error: e);
      throw DatabaseException('Failed to count entities: $e');
    }
  }

  @override
  Future<bool> exists(ID id) async {
    try {
      final String sql = 'SELECT 1 FROM $tableName WHERE id = ? LIMIT 1';
      final List<Map<String, dynamic>> results = await database.rawQuery(
        sql,
        <dynamic>[id],
      );
      return results.isNotEmpty;
    } catch (e) {
      Logger.error('Failed to check entity existence in $tableName', error: e);
      throw DatabaseException('Failed to check entity existence: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      final String sql = 'DELETE FROM $tableName';
      await database.rawExecute(sql);
    } catch (e) {
      Logger.error('Failed to clear entities from $tableName', error: e);
      throw DatabaseException('Failed to clear entities: $e');
    }
  }
}
