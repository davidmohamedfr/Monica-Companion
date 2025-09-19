import 'package:monica_mobile_app/config/feature_flags.dart';
import 'package:monica_mobile_app/core/config/environment.dart';

/// Application configuration constants and settings
class AppConfig {
  AppConfig._();

  /// Application name based on environment
  static String get appName => EnvironmentConfig.appDisplayName;

  /// Application version
  static const String version = '1.0.0';

  /// Debug mode flag (uses kDebugMode from foundation.dart)
  static bool get isDebug => EnvironmentConfig.isDevelopment;

  /// API base URL based on environment
  static String get apiBaseUrl => EnvironmentConfig.apiBaseUrl;

  /// HTTP request timeout based on environment
  static Duration get defaultTimeout =>
      Duration(seconds: FeatureFlags.apiTimeoutSeconds);

  /// Maximum retry attempts for network requests
  static const int maxRetryAttempts = 3;

  /// Default sync interval in hours
  static const Duration defaultSyncInterval = Duration(hours: 4);

  /// Package name base
  static const String packageNameBase = 'com.monica.app';

  /// Full package name with environment suffix
  static String get packageName =>
      packageNameBase + EnvironmentConfig.packageSuffix;
}
