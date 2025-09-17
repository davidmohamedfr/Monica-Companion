import 'package:monica_mobile_app/core/config/environment.dart';

/// Feature flags configuration for different environments
class FeatureFlags {
  FeatureFlags._();

  /// Enable debug tools and developer options
  static bool get enableDebugTools {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  /// Enable logging to console
  static bool get enableConsoleLogging {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  /// Enable crash reporting
  static bool get enableCrashReporting {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }

  /// Enable analytics tracking
  static bool get enableAnalytics {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return false;
      case Environment.production:
        return true;
    }
  }

  /// Enable performance monitoring
  static bool get enablePerformanceMonitoring {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }

  /// Enable mock data for testing
  static bool get enableMockData => false;

  /// Enable experimental features
  static bool get enableExperimentalFeatures {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return false;
      case Environment.production:
        return false;
    }
  }

  /// API request timeout in seconds
  static int get apiTimeoutSeconds {
    switch (EnvironmentConfig.currentEnvironment) {
      case Environment.development:
        return 60; // Longer timeout for debugging
      case Environment.staging:
        return 45;
      case Environment.production:
        return 30;
    }
  }

  /// Get all feature flags as a map for debugging
  static Map<String, dynamic> get allFlags => <String, dynamic>{
    'enableDebugTools': enableDebugTools,
    'enableConsoleLogging': enableConsoleLogging,
    'enableCrashReporting': enableCrashReporting,
    'enableAnalytics': enableAnalytics,
    'enablePerformanceMonitoring': enablePerformanceMonitoring,
    'enableMockData': enableMockData,
    'enableExperimentalFeatures': enableExperimentalFeatures,
    'apiTimeoutSeconds': apiTimeoutSeconds,
  };
}
