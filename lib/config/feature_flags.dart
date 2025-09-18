/// Feature flags configuration for the application
class FeatureFlags {
  FeatureFlags._();

  /// Enable debug mode features
  static const bool enableDebugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: true);

  /// API timeout in seconds
  static const int apiTimeoutSeconds = int.fromEnvironment('API_TIMEOUT_SECONDS', defaultValue: 30);

  /// Enable offline mode
  static const bool enableOfflineMode = bool.fromEnvironment('ENABLE_OFFLINE_MODE', defaultValue: true);

  /// Enable analytics tracking
  static const bool enableAnalytics = bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: false);

  /// Enable push notifications
  static const bool enablePushNotifications = bool.fromEnvironment('ENABLE_PUSH_NOTIFICATIONS', defaultValue: true);

  /// Enable biometric authentication
  static const bool enableBiometricAuth = bool.fromEnvironment('ENABLE_BIOMETRIC_AUTH', defaultValue: false);

  /// All feature flags for display purposes
  static Map<String, dynamic> get allFlags => {
    'Debug Mode': enableDebugMode,
    'Offline Mode': enableOfflineMode,
    'Analytics': enableAnalytics,
    'Push Notifications': enablePushNotifications,
    'Biometric Auth': enableBiometricAuth,
  };
}