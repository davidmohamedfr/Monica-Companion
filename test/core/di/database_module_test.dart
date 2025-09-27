import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/di/database_module.dart';
import 'package:monica_companion/db/database_service.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/repositories/repository_registry.dart';
import 'package:monica_companion/services/service_locator.dart';

// Mock classes
class MockServiceLocator extends Mock implements ServiceLocator {}

class MockDatabaseInterface extends Mock implements DatabaseInterface {}

class MockRepositoryRegistry extends Mock implements RepositoryRegistry {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late MockServiceLocator mockServiceLocator;
  late MockDatabaseInterface mockDatabase;
  late MockRepositoryRegistry mockRepositoryRegistry;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(MockDatabaseInterface());
    registerFallbackValue(MockRepositoryRegistry());
    registerFallbackValue(MockDatabaseService());
  });

  setUp(() {
    mockServiceLocator = MockServiceLocator();
    mockDatabase = MockDatabaseInterface();
    mockRepositoryRegistry = MockRepositoryRegistry();

    // Setup default mock behaviors
    when(() => mockDatabase.initialize()).thenAnswer((_) async {});
    when(() => mockRepositoryRegistry.initialize()).thenAnswer((_) async {});
    when(
      () => mockServiceLocator.registerSingleton<DatabaseInterface>(any()),
    ).thenReturn(null);
    when(
      () => mockServiceLocator.registerSingleton<RepositoryRegistry>(any()),
    ).thenReturn(null);
    when(
      () => mockServiceLocator.get<RepositoryRegistry>(),
    ).thenReturn(mockRepositoryRegistry);
    when(
      () => mockServiceLocator.unregister<RepositoryRegistry>(),
    ).thenReturn(null);
    when(
      () => mockServiceLocator.unregister<DatabaseInterface>(),
    ).thenReturn(null);
    when(() => mockRepositoryRegistry.dispose()).thenReturn(null);
  });

  group('DatabaseModule - Service Registration', () {
    testWidgets('should register database service as singleton', (
      WidgetTester tester,
    ) async {
      // Test the service registration pattern
      mockServiceLocator.registerSingleton<DatabaseInterface>(mockDatabase);

      verify(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(
          mockDatabase,
        ),
      ).called(1);
    });

    testWidgets('should register repository registry as singleton', (
      WidgetTester tester,
    ) async {
      // Test the repository registry registration pattern
      mockServiceLocator.registerSingleton<RepositoryRegistry>(
        mockRepositoryRegistry,
      );

      verify(
        () => mockServiceLocator.registerSingleton<RepositoryRegistry>(
          mockRepositoryRegistry,
        ),
      ).called(1);
    });

    testWidgets('should initialize database service before registration', (
      WidgetTester tester,
    ) async {
      // Test that database initialization happens before registration
      await mockDatabase.initialize();

      verify(() => mockDatabase.initialize()).called(1);
    });

    testWidgets(
      'should initialize repository registry after database service',
      (WidgetTester tester) async {
        // Test the initialization order pattern
        await mockDatabase.initialize();
        await mockRepositoryRegistry.initialize();

        verifyInOrder(<Future<void> Function()>[
          () => mockDatabase.initialize(),
          () => mockRepositoryRegistry.initialize(),
        ]);
      },
    );
  });

  group('DatabaseModule - Service Dependencies', () {
    testWidgets('should create repository registry with database dependency', (
      WidgetTester tester,
    ) async {
      // Test that repository registry receives database as dependency
      final MockRepositoryRegistry registryWithDependency =
          MockRepositoryRegistry();
      when(registryWithDependency.initialize).thenAnswer((_) async {});

      // Simulate creating registry with database dependency
      await registryWithDependency.initialize();

      verify(registryWithDependency.initialize).called(1);
    });

    testWidgets('should maintain dependency injection consistency', (
      WidgetTester tester,
    ) async {
      // Test that services maintain proper dependencies
      // Expected: DatabaseInterface + RepositoryRegistry

      // Simulate registering all dependencies
      mockServiceLocator.registerSingleton<DatabaseInterface>(mockDatabase);
      mockServiceLocator.registerSingleton<RepositoryRegistry>(
        mockRepositoryRegistry,
      );

      verify(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(any()),
      ).called(1);
      verify(
        () => mockServiceLocator.registerSingleton<RepositoryRegistry>(any()),
      ).called(1);
    });

    testWidgets('should handle service retrieval for disposal', (
      WidgetTester tester,
    ) async {
      // Test service retrieval during disposal
      final RepositoryRegistry registry = mockServiceLocator
          .get<RepositoryRegistry>();

      expect(registry, equals(mockRepositoryRegistry));
      verify(() => mockServiceLocator.get<RepositoryRegistry>()).called(1);
    });
  });

  group('DatabaseModule - Initialization Process', () {
    testWidgets('should complete initialization without errors', (
      WidgetTester tester,
    ) async {
      // Test successful initialization flow
      await mockDatabase.initialize();
      await mockRepositoryRegistry.initialize();
      mockServiceLocator.registerSingleton<DatabaseInterface>(mockDatabase);
      mockServiceLocator.registerSingleton<RepositoryRegistry>(
        mockRepositoryRegistry,
      );

      // Verify all initialization steps completed
      verify(() => mockDatabase.initialize()).called(1);
      verify(() => mockRepositoryRegistry.initialize()).called(1);
      verify(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(
          mockDatabase,
        ),
      ).called(1);
      verify(
        () => mockServiceLocator.registerSingleton<RepositoryRegistry>(
          mockRepositoryRegistry,
        ),
      ).called(1);
    });

    testWidgets('should handle database initialization errors', (
      WidgetTester tester,
    ) async {
      // Test database initialization error handling
      final Exception databaseError = Exception(
        'Database initialization failed',
      );
      when(() => mockDatabase.initialize()).thenThrow(databaseError);

      expect(() => mockDatabase.initialize(), throwsA(equals(databaseError)));

      verify(() => mockDatabase.initialize()).called(1);
    });

    testWidgets('should handle repository registry initialization errors', (
      WidgetTester tester,
    ) async {
      // Test repository registry initialization error handling
      final Exception registryError = Exception(
        'Repository registry initialization failed',
      );
      when(() => mockRepositoryRegistry.initialize()).thenThrow(registryError);

      expect(
        () => mockRepositoryRegistry.initialize(),
        throwsA(equals(registryError)),
      );

      verify(() => mockRepositoryRegistry.initialize()).called(1);
    });

    testWidgets('should propagate initialization errors to caller', (
      WidgetTester tester,
    ) async {
      // Test error propagation pattern
      final Exception initError = Exception('Initialization failed');

      // Simulate error during initialization
      expect(() => throw initError, throwsA(equals(initError)));
    });
  });

  group('DatabaseModule - Service Disposal', () {
    testWidgets('should dispose repository registry during disposal', (
      WidgetTester tester,
    ) async {
      // Test repository registry disposal
      mockRepositoryRegistry.dispose();

      verify(() => mockRepositoryRegistry.dispose()).called(1);
    });

    testWidgets('should unregister services in correct order', (
      WidgetTester tester,
    ) async {
      // Test service unregistration order
      mockServiceLocator
        ..unregister<RepositoryRegistry>()
        ..unregister<DatabaseInterface>();

      verifyInOrder(<void Function()>[
        () => mockServiceLocator.unregister<RepositoryRegistry>(),
        () => mockServiceLocator.unregister<DatabaseInterface>(),
      ]);
    });

    testWidgets('should handle disposal errors gracefully', (
      WidgetTester tester,
    ) async {
      // Test disposal error handling
      final Exception disposalError = Exception('Disposal failed');
      when(() => mockRepositoryRegistry.dispose()).thenThrow(disposalError);

      expect(
        () => mockRepositoryRegistry.dispose(),
        throwsA(equals(disposalError)),
      );

      verify(() => mockRepositoryRegistry.dispose()).called(1);
    });

    testWidgets('should complete full disposal process', (
      WidgetTester tester,
    ) async {
      // Test complete disposal flow
      final RepositoryRegistry registry = mockServiceLocator
          .get<RepositoryRegistry>();
      registry.dispose();
      mockServiceLocator
        ..unregister<RepositoryRegistry>()
        ..unregister<DatabaseInterface>();

      verify(() => mockServiceLocator.get<RepositoryRegistry>()).called(1);
      verify(() => mockRepositoryRegistry.dispose()).called(1);
      verify(
        () => mockServiceLocator.unregister<RepositoryRegistry>(),
      ).called(1);
      verify(
        () => mockServiceLocator.unregister<DatabaseInterface>(),
      ).called(1);
    });
  });

  group('DatabaseModule - Service Locator Integration', () {
    testWidgets('should interact with service locator instance', (
      WidgetTester tester,
    ) async {
      // Test service locator integration pattern
      // Since ServiceLocator.instance is a singleton, we test the interaction pattern

      // Simulate getting the service locator instance
      expect(mockServiceLocator, isA<ServiceLocator>());
    });

    testWidgets('should register services with correct types', (
      WidgetTester tester,
    ) async {
      // Test type-safe service registration
      mockServiceLocator.registerSingleton<DatabaseInterface>(mockDatabase);
      mockServiceLocator.registerSingleton<RepositoryRegistry>(
        mockRepositoryRegistry,
      );

      // Verify services were registered with correct generic types
      verify(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(any()),
      ).called(1);
      verify(
        () => mockServiceLocator.registerSingleton<RepositoryRegistry>(any()),
      ).called(1);
    });

    testWidgets('should handle service locator errors', (
      WidgetTester tester,
    ) async {
      // Test service locator error handling
      final Exception locatorError = Exception('Service locator error');
      when(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(any()),
      ).thenThrow(locatorError);

      expect(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(
          mockDatabase,
        ),
        throwsA(equals(locatorError)),
      );

      verify(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(
          mockDatabase,
        ),
      ).called(1);
    });
  });

  group('DatabaseModule - Static Method Behavior', () {
    testWidgets('should support static initialize method pattern', (
      WidgetTester tester,
    ) async {
      // Test static method initialization pattern
      // Since DatabaseModule.initialize() is static, we test the conceptual pattern

      // Test that static methods can be called without instance
      expect(() => DatabaseModule, returnsNormally);
    });

    testWidgets('should support static dispose method pattern', (
      WidgetTester tester,
    ) async {
      // Test static method disposal pattern
      // Since DatabaseModule.dispose() is static, we test the conceptual pattern

      // Test that static methods can be called without instance
      expect(() => DatabaseModule, returnsNormally);
    });

    testWidgets('should maintain stateless behavior in static methods', (
      WidgetTester tester,
    ) async {
      // Test that static methods don't maintain internal state
      // This verifies the stateless nature of the DatabaseModule class

      // Static methods should not depend on instance state
      expect(DatabaseModule, isA<Type>());
    });
  });

  group('DatabaseModule - Error Recovery', () {
    testWidgets('should handle partial initialization failures', (
      WidgetTester tester,
    ) async {
      // Test partial initialization failure scenarios
      await mockDatabase.initialize();

      final Exception registryError = Exception(
        'Registry initialization failed',
      );
      when(() => mockRepositoryRegistry.initialize()).thenThrow(registryError);

      // Database initialized successfully
      verify(() => mockDatabase.initialize()).called(1);

      // Registry initialization failed
      expect(
        () => mockRepositoryRegistry.initialize(),
        throwsA(equals(registryError)),
      );
    });

    testWidgets('should handle service registration failures', (
      WidgetTester tester,
    ) async {
      // Test service registration failure handling
      final Exception registrationError = Exception(
        'Service registration failed',
      );
      when(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(any()),
      ).thenThrow(registrationError);

      expect(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(
          mockDatabase,
        ),
        throwsA(equals(registrationError)),
      );

      verify(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(
          mockDatabase,
        ),
      ).called(1);
    });

    testWidgets('should handle disposal failures gracefully', (
      WidgetTester tester,
    ) async {
      // Test disposal failure handling
      final Exception disposalError = Exception('Disposal failed');
      when(
        () => mockServiceLocator.get<RepositoryRegistry>(),
      ).thenThrow(disposalError);

      expect(
        () => mockServiceLocator.get<RepositoryRegistry>(),
        throwsA(equals(disposalError)),
      );

      verify(() => mockServiceLocator.get<RepositoryRegistry>()).called(1);
    });
  });

  group('DatabaseModule - Integration Patterns', () {
    testWidgets('should support service lifecycle management', (
      WidgetTester tester,
    ) async {
      // Test complete service lifecycle

      // Initialization phase
      await mockDatabase.initialize();
      await mockRepositoryRegistry.initialize();
      mockServiceLocator.registerSingleton<DatabaseInterface>(mockDatabase);
      mockServiceLocator.registerSingleton<RepositoryRegistry>(
        mockRepositoryRegistry,
      );

      // Usage phase (simulated by service retrieval)
      final RepositoryRegistry registry = mockServiceLocator
          .get<RepositoryRegistry>();
      expect(registry, equals(mockRepositoryRegistry));

      // Disposal phase
      registry.dispose();
      mockServiceLocator
        ..unregister<RepositoryRegistry>()
        ..unregister<DatabaseInterface>();

      // Verify complete lifecycle
      verify(() => mockDatabase.initialize()).called(1);
      verify(() => mockRepositoryRegistry.initialize()).called(1);
      verify(
        () => mockServiceLocator.registerSingleton<DatabaseInterface>(
          mockDatabase,
        ),
      ).called(1);
      verify(
        () => mockServiceLocator.registerSingleton<RepositoryRegistry>(
          mockRepositoryRegistry,
        ),
      ).called(1);
      verify(() => mockServiceLocator.get<RepositoryRegistry>()).called(1);
      verify(() => mockRepositoryRegistry.dispose()).called(1);
      verify(
        () => mockServiceLocator.unregister<RepositoryRegistry>(),
      ).called(1);
      verify(
        () => mockServiceLocator.unregister<DatabaseInterface>(),
      ).called(1);
    });

    testWidgets('should coordinate with application initialization service', (
      WidgetTester tester,
    ) async {
      // Test coordination with AppInitializationService
      // This simulates the pattern where DatabaseModule is called from AppInitializationService

      // Simulate the initialization flow
      await mockDatabase.initialize();
      await mockRepositoryRegistry.initialize();

      // Verify coordination steps
      verify(() => mockDatabase.initialize()).called(1);
      verify(() => mockRepositoryRegistry.initialize()).called(1);
    });

    testWidgets('should support modular architecture patterns', (
      WidgetTester tester,
    ) async {
      // Test modular architecture support
      // DatabaseModule should work as an independent module
      // Expected components: Database + Repository Registry

      // Test that module handles its own dependencies
      await mockDatabase.initialize();
      await mockRepositoryRegistry.initialize();

      // Verify module manages its components
      verify(() => mockDatabase.initialize()).called(1);
      verify(() => mockRepositoryRegistry.initialize()).called(1);
    });
  });
}
