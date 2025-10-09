import 'package:monica_companion/db/database_service.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/repositories/repository_registry.dart';
import 'package:monica_companion/services/service_locator.dart';

/// Database dependency injection module
class DatabaseModule {
  /// Initialize database services and repositories
  static Future<void> initialize() async {
    final ServiceLocator locator = ServiceLocator.instance;

    // Register database service as singleton
    final DatabaseInterface databaseService = DatabaseService();
    await databaseService.initialize();
    locator.registerSingleton<DatabaseInterface>(databaseService);

    // Register repository registry as singleton
    final RepositoryRegistry repositoryRegistry = RepositoryRegistry(
      databaseService,
    );
    await repositoryRegistry.initialize();
    locator.registerSingleton<RepositoryRegistry>(repositoryRegistry);
  }

  /// Dispose database services
  static void dispose() {
    final ServiceLocator locator = ServiceLocator.instance;

    // Dispose repository registry if registered
    if (locator.isRegistered<RepositoryRegistry>()) {
      locator.get<RepositoryRegistry>().dispose();
    }

    // Unregister services
    locator
      ..unregister<RepositoryRegistry>()
      ..unregister<DatabaseInterface>();
  }
}
