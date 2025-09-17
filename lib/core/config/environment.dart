/// Environment configuration for different build flavors
enum Environment {
  development,
  staging,
  production,
}

/// Environment configuration manager
class EnvironmentConfig {
  EnvironmentConfig._();

  /// Current environment
  static Environment get currentEnvironment {
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'development');
    switch (flavor) {
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      default:
        return Environment.development;
    }
  }

  /// Check if running in development mode
  static bool get isDevelopment => currentEnvironment == Environment.development;

  /// Check if running in staging mode
  static bool get isStaging => currentEnvironment == Environment.staging;

  /// Check if running in production mode
  static bool get isProduction => currentEnvironment == Environment.production;
}