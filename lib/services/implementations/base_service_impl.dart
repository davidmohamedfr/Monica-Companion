import 'package:monica_mobile_app/core/utils/logger.dart';
import 'package:monica_mobile_app/services/interfaces/base_service.dart';

/// Base service implementation with common functionality
abstract class BaseServiceImpl implements BaseService {
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.warning(
        'Service ${runtimeType.toString()} is already initialized',
      );
      return;
    }

    try {
      await onInitialize();
      _isInitialized = true;
      Logger.info('Service ${runtimeType.toString()} initialized successfully');
    } catch (e) {
      Logger.error(
        'Failed to initialize service ${runtimeType.toString()}',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) {
      Logger.warning('Service ${runtimeType.toString()} is not initialized');
      return;
    }

    try {
      await onDispose();
      _isInitialized = false;
      Logger.info('Service ${runtimeType.toString()} disposed successfully');
    } catch (e) {
      Logger.error(
        'Failed to dispose service ${runtimeType.toString()}',
        error: e,
      );
      rethrow;
    }
  }

  /// Override this method to implement service-specific initialization
  Future<void> onInitialize();

  /// Override this method to implement service-specific disposal
  Future<void> onDispose();

  /// Ensure service is initialized before performing operations
  void ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('Service ${runtimeType.toString()} is not initialized');
    }
  }
}
