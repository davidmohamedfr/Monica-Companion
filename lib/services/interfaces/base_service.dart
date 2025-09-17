/// Base service interface for all services
abstract class BaseService {
  /// Initialize the service
  Future<void> initialize();

  /// Dispose resources and cleanup
  Future<void> dispose();

  /// Check if service is initialized
  bool get isInitialized;
}
