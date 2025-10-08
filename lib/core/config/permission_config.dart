/// Configuration for permission-related constants
class PermissionConfig {
  const PermissionConfig._();

  /// Maximum number of times user can deny WRITE_CONTACTS before read-only mode
  static const int maxDenialAttempts = 2;

  /// SharedPreferences key for WRITE_CONTACTS denial count
  static const String writeContactsDenialCountKey =
      'write_contacts_denial_count';

  /// SharedPreferences key for read-only mode flag
  static const String readOnlyModeKey = 'read_only_mode';
}
