import 'package:monica_companion/core/di/database_module.dart';
import 'package:monica_companion/core/services/permission_service.dart';
import 'package:monica_companion/core/utils/logger.dart';
import 'package:monica_companion/features/contacts/di/contacts_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for initializing the application
class AppInitializationService {
  AppInitializationService._() : _prefs = null, _permissionService = null;

  AppInitializationService.withPreferences(this._prefs)
    : _permissionService = null;

  AppInitializationService.withDependencies({
    required SharedPreferences prefs,
    required PermissionService permissionService,
  }) : _prefs = prefs,
       _permissionService = permissionService;

  static final AppInitializationService _instance =
      AppInitializationService._();
  static AppInitializationService get instance => _instance;

  final SharedPreferences? _prefs;
  final PermissionService? _permissionService;
  static const String _firstLaunchKey = 'is_first_launch';

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

      // Initialize feature dependencies
      await ContactsDependencies.registerDependencies();

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
      Logger.error('Failed to dispose app', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Check if this is the first launch of the app
  Future<bool> isFirstLaunch() async {
    if (_prefs == null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_firstLaunchKey) ?? true;
    }
    return _prefs!.getBool(_firstLaunchKey) ?? true;
  }

  /// Mark first launch as complete
  Future<void> setFirstLaunchComplete() async {
    if (_prefs == null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, false);
    } else {
      await _prefs!.setBool(_firstLaunchKey, false);
    }
  }

  /// Request permissions on first launch
  Future<void> requestPermissionsOnFirstLaunch() async {
    final bool isFirst = await isFirstLaunch();

    if (!isFirst) {
      return;
    }

    if (_permissionService != null) {
      // Check if permission already granted
      final bool hasPermission = await _permissionService!
          .hasWriteContactsPermission();

      if (!hasPermission) {
        // Request permission
        await _permissionService!.requestWriteContactsPermission();
      }
    }

    // Mark first launch complete
    await setFirstLaunchComplete();
  }
}
