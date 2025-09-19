import 'package:monica_mobile_app/core/utils/logger.dart';

/// Simple service locator for dependency injection
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator _instance = ServiceLocator._();
  static ServiceLocator get instance => _instance;

  final Map<Type, dynamic> _services = <Type, dynamic>{};
  final Map<Type, dynamic Function()> _factories = <Type, dynamic Function()>{};

  /// Register a singleton service instance
  void registerSingleton<T extends Object>(T service) {
    _services[T] = service;
    Logger.debug('Registered singleton service: ${T.toString()}');
  }

  /// Register a factory function for creating service instances
  void registerFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
    Logger.debug('Registered factory for service: ${T.toString()}');
  }

  /// Get a service instance
  T get<T extends Object>() {
    // Check for singleton first
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }

    // Check for factory
    if (_factories.containsKey(T)) {
      final T instance = _factories[T]!() as T;
      Logger.debug('Created instance from factory: ${T.toString()}');
      return instance;
    }

    throw Exception('Service of type ${T.toString()} is not registered');
  }

  /// Check if service is registered
  bool isRegistered<T extends Object>() =>
      _services.containsKey(T) || _factories.containsKey(T);

  /// Unregister a service
  void unregister<T extends Object>() {
    _services.remove(T);
    _factories.remove(T);
    Logger.debug('Unregistered service: ${T.toString()}');
  }

  /// Clear all services (useful for testing)
  void clear() {
    _services.clear();
    _factories.clear();
    Logger.debug('Cleared all services from locator');
  }

  /// Get list of registered service types
  List<Type> get registeredTypes => <Type>[
    ..._services.keys,
    ..._factories.keys,
  ];
}
