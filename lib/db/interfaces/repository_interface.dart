/// Base repository interface for CRUD operations
abstract class RepositoryInterface<T, ID> {
  /// Insert a new entity
  Future<ID> insert(T entity);

  /// Insert multiple entities
  Future<List<ID>> insertAll(List<T> entities);

  /// Update an existing entity
  Future<bool> update(T entity);

  /// Delete an entity by ID
  Future<bool> delete(ID id);

  /// Delete multiple entities by IDs
  Future<int> deleteAll(List<ID> ids);

  /// Find entity by ID
  Future<T?> findById(ID id);

  /// Find all entities
  Future<List<T>> findAll();

  /// Count total entities
  Future<int> count();

  /// Check if entity exists by ID
  Future<bool> exists(ID id);

  /// Clear all entities
  Future<void> clear();
}
