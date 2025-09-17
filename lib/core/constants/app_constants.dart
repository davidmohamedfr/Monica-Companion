/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// Database constants
  static const String dbName = 'monica_mobile.db';
  static const int dbVersion = 1;

  /// Shared preferences keys
  static const String keyApiToken = 'api_token';
  static const String keyServerUrl = 'server_url';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyUserId = 'user_id';
  static const String keySyncInterval = 'sync_interval';

  /// Default values
  static const String defaultServerUrl = 'https://app.monicahq.com';
  static const int defaultSyncIntervalHours = 4;

  /// API endpoints
  static const String apiBasePath = '/api';
  static const String apiVersion = 'v1';

  /// Permission request codes
  static const int permissionContacts = 100;
  static const int permissionPhone = 101;
  static const int permissionCallLog = 102;

  /// Notification channels
  static const String notificationChannelSync = 'sync_channel';
  static const String notificationChannelGeneral = 'general_channel';
}
