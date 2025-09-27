import 'package:monica_companion/core/di/database_module.dart';
import 'package:monica_companion/core/utils/logger.dart';

/// Service responsible for initializing the application
class AppInitializationService {
  AppInitializationService._();

  static final AppInitializationService _instance =
      AppInitializationService._();
  static AppInitializationService get instance => _instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize all application services
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.debug('App already initialized');
      return;
    }

    try {
      Logger.info('Starting app initialization...');

      // Initialize database and dependencies
      await DatabaseModule.initialize();

      _isInitialized = true;
      Logger.info('App initialization completed successfully');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to initialize app',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Dispose all application services
  Future<void> dispose() async {
    try {
      Logger.info('Starting app disposal...');

      // Dispose database services
      DatabaseModule.dispose();

      _isInitialized = false;
      Logger.info('App disposal completed successfully');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to dispose app',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
