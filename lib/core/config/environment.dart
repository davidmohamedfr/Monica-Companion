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
    const String flavor = String.fromEnvironment(
      'FLAVOR',
      defaultValue: 'development',
    );
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
  static bool get isDevelopment =>
      currentEnvironment == Environment.development;

  /// Check if running in staging mode
  static bool get isStaging => currentEnvironment == Environment.staging;

  /// Check if running in production mode
  static bool get isProduction => currentEnvironment == Environment.production;

  /// Get API base URL for current environment
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://dev-api.monica.com',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://staging-api.monica.com',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.monica.com',
        );
    }
  }

  /// Get app display name for current environment
  static String get appDisplayName {
    switch (currentEnvironment) {
      case Environment.development:
        return 'Monica Dev';
      case Environment.staging:
        return 'Monica Staging';
      case Environment.production:
        return 'Monica';
    }
  }

  /// Get app package suffix for current environment
  static String get packageSuffix {
    switch (currentEnvironment) {
      case Environment.development:
        return '.dev';
      case Environment.staging:
        return '.staging';
      case Environment.production:
        return '';
    }
  }
}
