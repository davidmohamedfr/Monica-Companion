/// Application configuration constants and settings
class AppConfig {
  AppConfig._();

  /// Application name
  static const String appName = 'Monica Mobile App';

  /// Application version
  static const String version = '1.0.0';

  /// Debug mode flag
  static const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;

  /// Default timeout for HTTP requests in seconds
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Maximum retry attempts for network requests
  static const int maxRetryAttempts = 3;

  /// Default sync interval in hours
  static const Duration defaultSyncInterval = Duration(hours: 4);
}