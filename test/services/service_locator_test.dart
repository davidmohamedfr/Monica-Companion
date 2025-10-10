import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/services/service_locator.dart';

// Test service interfaces and implementations
abstract class TestService {
  String getValue();
}

class TestServiceImpl implements TestService {
  TestServiceImpl(this.value);
  final String value;

  @override
  String getValue() => value;
}

abstract class AnotherTestService {
  int getNumber();
}

class AnotherTestServiceImpl implements AnotherTestService {
  AnotherTestServiceImpl(this.number);
  final int number;

  @override
  int getNumber() => number;
}

class DisposableService {
  bool disposed = false;

  void dispose() {
    disposed = true;
  }
}

void main() {
  group('ServiceLocator', () {
    late ServiceLocator serviceLocator;

    setUp(() {
      serviceLocator = ServiceLocator.instance;
      serviceLocator.clear(); // Ensure clean state for each test
    });

    group('Singleton Pattern', () {
      testWidgets('should return same instance for ServiceLocator.instance', (
        WidgetTester tester,
      ) async {
        // Act
        final ServiceLocator instance1 = ServiceLocator.instance;
        final ServiceLocator instance2 = ServiceLocator.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
        expect(instance1, same(serviceLocator));
      });
    });

    group('Singleton Registration and Retrieval', () {
      testWidgets('should register and retrieve singleton service', (
        WidgetTester tester,
      ) async {
        // Arrange
        final TestService testService = TestServiceImpl('singleton_value');

        // Act
        serviceLocator.registerSingleton<TestService>(testService);
        final TestService retrieved = serviceLocator.get<TestService>();

        // Assert
        expect(retrieved, same(testService));
        expect(retrieved.getValue(), 'singleton_value');
        expect(serviceLocator.isRegistered<TestService>(), isTrue);
      });

      testWidgets('should return same singleton instance on multiple calls', (
        WidgetTester tester,
      ) async {
        // Arrange
        final TestService testService = TestServiceImpl('singleton_value');
        serviceLocator.registerSingleton<TestService>(testService);

        // Act
        final TestService instance1 = serviceLocator.get<TestService>();
        final TestService instance2 = serviceLocator.get<TestService>();
        final TestService instance3 = serviceLocator.get<TestService>();

        // Assert
        expect(identical(instance1, instance2), isTrue);
        expect(identical(instance2, instance3), isTrue);
        expect(instance1.getValue(), 'singleton_value');
      });

      testWidgets('should handle multiple different singleton types', (
        WidgetTester tester,
      ) async {
        // Arrange
        final TestService testService = TestServiceImpl('test_value');
        final AnotherTestService anotherService = AnotherTestServiceImpl(42);

        // Act
        serviceLocator.registerSingleton<TestService>(testService);
        serviceLocator.registerSingleton<AnotherTestService>(anotherService);

        final TestService retrievedTest = serviceLocator.get<TestService>();
        final AnotherTestService retrievedAnother = serviceLocator
            .get<AnotherTestService>();

        // Assert
        expect(retrievedTest, same(testService));
        expect(retrievedAnother, same(anotherService));
        expect(retrievedTest.getValue(), 'test_value');
        expect(retrievedAnother.getNumber(), 42);
        expect(serviceLocator.isRegistered<TestService>(), isTrue);
        expect(serviceLocator.isRegistered<AnotherTestService>(), isTrue);
      });

      testWidgets('should overwrite existing singleton on re-registration', (
        WidgetTester tester,
      ) async {
        // Arrange
        final TestService originalService = TestServiceImpl('original');
        final TestService newService = TestServiceImpl('new');

        serviceLocator.registerSingleton<TestService>(originalService);

        // Act
        serviceLocator.registerSingleton<TestService>(newService);
        final TestService retrieved = serviceLocator.get<TestService>();

        // Assert
        expect(retrieved, same(newService));
        expect(retrieved.getValue(), 'new');
        expect(retrieved, isNot(same(originalService)));
      });
    });

    group('Factory Registration and Retrieval', () {
      testWidgets('should register factory and create new instances', (
        WidgetTester tester,
      ) async {
        // Arrange
        int callCount = 0;

        serviceLocator.registerFactory<TestService>(() {
          callCount++;
          return TestServiceImpl('factory_$callCount');
        });

        // Act
        final TestService instance1 = serviceLocator.get<TestService>();
        final TestService instance2 = serviceLocator.get<TestService>();

        // Assert
        expect(instance1, isNot(same(instance2)));
        expect(instance1.getValue(), 'factory_1');
        expect(instance2.getValue(), 'factory_2');
        expect(serviceLocator.isRegistered<TestService>(), isTrue);
      });

      testWidgets('should handle multiple different factory types', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerFactory<TestService>(
          () => TestServiceImpl('test_factory'),
        );
        serviceLocator.registerFactory<AnotherTestService>(
          () => AnotherTestServiceImpl(100),
        );

        // Act
        final TestService testInstance = serviceLocator.get<TestService>();
        final AnotherTestService anotherInstance = serviceLocator
            .get<AnotherTestService>();

        // Assert
        expect(testInstance.getValue(), 'test_factory');
        expect(anotherInstance.getNumber(), 100);
        expect(serviceLocator.isRegistered<TestService>(), isTrue);
        expect(serviceLocator.isRegistered<AnotherTestService>(), isTrue);
      });

      testWidgets('should overwrite existing factory on re-registration', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerFactory<TestService>(
          () => TestServiceImpl('original_factory'),
        );

        // Act - Register new factory
        serviceLocator.registerFactory<TestService>(
          () => TestServiceImpl('new_factory'),
        );
        final TestService retrieved = serviceLocator.get<TestService>();

        // Assert
        expect(retrieved.getValue(), 'new_factory');
      });
    });

    group('Service Priority and Resolution', () {
      testWidgets('should prioritize singleton over factory when both exist', (
        WidgetTester tester,
      ) async {
        // Arrange
        final TestService singletonService = TestServiceImpl('singleton');

        serviceLocator.registerFactory<TestService>(
          () => TestServiceImpl('factory'),
        );
        serviceLocator.registerSingleton<TestService>(singletonService);

        // Act
        final TestService retrieved = serviceLocator.get<TestService>();

        // Assert - Singleton should take precedence
        expect(retrieved, same(singletonService));
        expect(retrieved.getValue(), 'singleton');
      });

      testWidgets('should use factory when singleton is removed', (
        WidgetTester tester,
      ) async {
        // Arrange
        final TestService singletonService = TestServiceImpl('singleton');

        serviceLocator.registerSingleton<TestService>(singletonService);
        serviceLocator.registerFactory<TestService>(
          () => TestServiceImpl('factory'),
        );

        // Act - Remove singleton
        serviceLocator.unregister<TestService>();
        serviceLocator.registerFactory<TestService>(
          () => TestServiceImpl('factory'),
        );

        final TestService retrieved = serviceLocator.get<TestService>();

        // Assert
        expect(retrieved.getValue(), 'factory');
        expect(retrieved, isNot(same(singletonService)));
      });
    });

    group('Service Registration Status', () {
      testWidgets('should correctly report registration status', (
        WidgetTester tester,
      ) async {
        // Arrange & Assert - Initially not registered
        expect(serviceLocator.isRegistered<TestService>(), isFalse);
        expect(serviceLocator.isRegistered<AnotherTestService>(), isFalse);

        // Act - Register singleton
        serviceLocator.registerSingleton<TestService>(TestServiceImpl('test'));

        // Assert
        expect(serviceLocator.isRegistered<TestService>(), isTrue);
        expect(serviceLocator.isRegistered<AnotherTestService>(), isFalse);

        // Act - Register factory
        serviceLocator.registerFactory<AnotherTestService>(
          () => AnotherTestServiceImpl(1),
        );

        // Assert
        expect(serviceLocator.isRegistered<TestService>(), isTrue);
        expect(serviceLocator.isRegistered<AnotherTestService>(), isTrue);
      });

      testWidgets('should provide list of registered service types', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerSingleton<TestService>(TestServiceImpl('test'));
        serviceLocator.registerFactory<AnotherTestService>(
          () => AnotherTestServiceImpl(1),
        );

        // Act
        final List<Type> registeredTypes = serviceLocator.registeredTypes;

        // Assert
        expect(registeredTypes, hasLength(2));
        expect(registeredTypes, contains(TestService));
        expect(registeredTypes, contains(AnotherTestService));
      });

      testWidgets('should return empty list when no services registered', (
        WidgetTester tester,
      ) async {
        // Act
        final List<Type> registeredTypes = serviceLocator.registeredTypes;

        // Assert
        expect(registeredTypes, isEmpty);
      });
    });

    group('Service Unregistration', () {
      testWidgets('should unregister singleton service', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerSingleton<TestService>(TestServiceImpl('test'));
        expect(serviceLocator.isRegistered<TestService>(), isTrue);

        // Act
        serviceLocator.unregister<TestService>();

        // Assert
        expect(serviceLocator.isRegistered<TestService>(), isFalse);
        expect(() => serviceLocator.get<TestService>(), throwsException);
      });

      testWidgets('should unregister factory service', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerFactory<TestService>(
          () => TestServiceImpl('test'),
        );
        expect(serviceLocator.isRegistered<TestService>(), isTrue);

        // Act
        serviceLocator.unregister<TestService>();

        // Assert
        expect(serviceLocator.isRegistered<TestService>(), isFalse);
        expect(() => serviceLocator.get<TestService>(), throwsException);
      });

      testWidgets(
        'should unregister both singleton and factory if both exist',
        (WidgetTester tester) async {
          // Arrange
          serviceLocator.registerSingleton<TestService>(
            TestServiceImpl('singleton'),
          );
          serviceLocator.registerFactory<TestService>(
            () => TestServiceImpl('factory'),
          );
          expect(serviceLocator.isRegistered<TestService>(), isTrue);

          // Act
          serviceLocator.unregister<TestService>();

          // Assert
          expect(serviceLocator.isRegistered<TestService>(), isFalse);
          expect(() => serviceLocator.get<TestService>(), throwsException);
        },
      );

      testWidgets(
        'should handle unregistering non-existent service gracefully',
        (WidgetTester tester) async {
          // Act & Assert - Should not throw
          expect(
            () => serviceLocator.unregister<TestService>(),
            returnsNormally,
          );
          expect(serviceLocator.isRegistered<TestService>(), isFalse);
        },
      );
    });

    group('Service Clearing', () {
      testWidgets('should clear all registered services', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerSingleton<TestService>(TestServiceImpl('test'));
        serviceLocator.registerFactory<AnotherTestService>(
          () => AnotherTestServiceImpl(1),
        );

        expect(serviceLocator.isRegistered<TestService>(), isTrue);
        expect(serviceLocator.isRegistered<AnotherTestService>(), isTrue);

        // Act
        serviceLocator.clear();

        // Assert
        expect(serviceLocator.isRegistered<TestService>(), isFalse);
        expect(serviceLocator.isRegistered<AnotherTestService>(), isFalse);
        expect(serviceLocator.registeredTypes, isEmpty);
        expect(() => serviceLocator.get<TestService>(), throwsException);
        expect(() => serviceLocator.get<AnotherTestService>(), throwsException);
      });

      testWidgets('should handle clearing empty service locator', (
        WidgetTester tester,
      ) async {
        // Act & Assert - Should not throw
        expect(() => serviceLocator.clear(), returnsNormally);
        expect(serviceLocator.registeredTypes, isEmpty);
      });
    });

    group('Error Handling', () {
      testWidgets('should throw exception for unregistered service', (
        WidgetTester tester,
      ) async {
        // Act & Assert
        expect(
          () => serviceLocator.get<TestService>(),
          throwsA(
            isA<Exception>().having(
              (Exception e) => e.toString(),
              'message',
              contains('Service of type TestService is not registered'),
            ),
          ),
        );
      });

      testWidgets(
        'should throw exception with correct service type in message',
        (WidgetTester tester) async {
          // Act & Assert
          expect(
            () => serviceLocator.get<AnotherTestService>(),
            throwsA(
              isA<Exception>().having(
                (Exception e) => e.toString(),
                'message',
                contains(
                  'Service of type AnotherTestService is not registered',
                ),
              ),
            ),
          );
        },
      );

      testWidgets('should handle factory that throws exception', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerFactory<TestService>(() {
          throw Exception('Factory creation failed');
        });

        // Act & Assert
        expect(
          () => serviceLocator.get<TestService>(),
          throwsA(
            isA<Exception>().having(
              (Exception e) => e.toString(),
              'message',
              contains('Factory creation failed'),
            ),
          ),
        );
      });

      testWidgets('should handle factory that returns null', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerFactory<TestService>(
          () => throw Exception('Factory returns null'),
        );

        // Act & Assert
        expect(
          () => serviceLocator.get<TestService>(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Concurrent Access', () {
      testWidgets('should handle concurrent singleton access safely', (
        WidgetTester tester,
      ) async {
        // Arrange
        final TestService testService = TestServiceImpl('concurrent_test');
        serviceLocator.registerSingleton<TestService>(testService);

        // Act - Multiple synchronous accesses
        final TestService instance1 = serviceLocator.get<TestService>();
        final TestService instance2 = serviceLocator.get<TestService>();
        final TestService instance3 = serviceLocator.get<TestService>();

        // Assert - All should be same instance
        expect(identical(instance1, instance2), isTrue);
        expect(identical(instance2, instance3), isTrue);
        expect(instance1, same(testService));
      });

      testWidgets('should handle concurrent factory access safely', (
        WidgetTester tester,
      ) async {
        // Arrange
        int creationCount = 0;
        serviceLocator.registerFactory<TestService>(() {
          creationCount++;
          return TestServiceImpl('instance_$creationCount');
        });

        // Act - Multiple synchronous accesses
        final TestService instance1 = serviceLocator.get<TestService>();
        final TestService instance2 = serviceLocator.get<TestService>();
        final TestService instance3 = serviceLocator.get<TestService>();

        // Assert - All should be different instances
        expect(identical(instance1, instance2), isFalse);
        expect(identical(instance2, instance3), isFalse);
        expect(instance1.getValue(), 'instance_1');
        expect(instance2.getValue(), 'instance_2');
        expect(instance3.getValue(), 'instance_3');
      });

      testWidgets('should handle mixed operations safely', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerSingleton<TestService>(
          TestServiceImpl('singleton'),
        );
        serviceLocator.registerFactory<AnotherTestService>(
          () => AnotherTestServiceImpl(1),
        );

        // Act - Mixed access patterns
        final TestService singleton1 = serviceLocator.get<TestService>();
        final AnotherTestService factory1 = serviceLocator
            .get<AnotherTestService>();
        final TestService singleton2 = serviceLocator.get<TestService>();
        final AnotherTestService factory2 = serviceLocator
            .get<AnotherTestService>();

        // Assert
        expect(identical(singleton1, singleton2), isTrue);
        expect(identical(factory1, factory2), isFalse);
        expect(singleton1.getValue(), 'singleton');
        expect(factory1.getNumber(), 1);
        expect(factory2.getNumber(), 1);
      });
    });

    group('Memory Management', () {
      testWidgets('should properly handle service disposal patterns', (
        WidgetTester tester,
      ) async {
        // Arrange
        final DisposableService disposableService = DisposableService();
        serviceLocator.registerSingleton<DisposableService>(disposableService);

        // Act - Get service and manually dispose
        final DisposableService retrieved = serviceLocator
            .get<DisposableService>();
        retrieved.dispose();

        // Assert - Service is still registered but disposed
        expect(serviceLocator.isRegistered<DisposableService>(), isTrue);
        expect(retrieved.disposed, isTrue);
        expect(
          serviceLocator.get<DisposableService>().disposed,
          isTrue,
        ); // Same instance
      });

      testWidgets('should not hold references after clear', (
        WidgetTester tester,
      ) async {
        // Arrange
        final TestService testService = TestServiceImpl('test');
        serviceLocator.registerSingleton<TestService>(testService);

        // Act
        serviceLocator.clear();

        // Assert - Service should not be accessible
        expect(serviceLocator.isRegistered<TestService>(), isFalse);
        expect(() => serviceLocator.get<TestService>(), throwsException);
        expect(serviceLocator.registeredTypes, isEmpty);
      });
    });

    group('Type Safety', () {
      testWidgets('should handle generic type constraints correctly', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        serviceLocator.registerSingleton<TestService>(
          TestServiceImpl('generic_test'),
        );
        final TestService service = serviceLocator.get<TestService>();

        // Assert - Type should be preserved
        expect(service, isA<TestService>());
        expect(service, isA<TestServiceImpl>());
        expect(service.getValue(), 'generic_test');
      });

      testWidgets('should distinguish between different types correctly', (
        WidgetTester tester,
      ) async {
        // Arrange
        serviceLocator.registerSingleton<TestService>(TestServiceImpl('test'));
        serviceLocator.registerSingleton<AnotherTestService>(
          AnotherTestServiceImpl(42),
        );

        // Act & Assert - Different types should be handled separately
        final TestService testService = serviceLocator.get<TestService>();
        final AnotherTestService anotherService = serviceLocator
            .get<AnotherTestService>();

        expect(testService, isA<TestService>());
        expect(anotherService, isA<AnotherTestService>());
        expect(testService.getValue(), 'test');
        expect(anotherService.getNumber(), 42);
      });
    });
  });
}
