import 'package:monica_companion/core/config/permission_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing WRITE_CONTACTS permission and read-only mode
abstract class PermissionService {
  /// Check if WRITE_CONTACTS permission is granted
  Future<bool> hasWriteContactsPermission();

  /// Request WRITE_CONTACTS permission from user
  Future<bool> requestWriteContactsPermission();

  /// Check if app is in read-only mode
  Future<bool> isReadOnlyMode();

  /// Get current denial count
  Future<int> getDenialCount();
}

/// Implementation of PermissionService
class PermissionServiceImpl implements PermissionService {
  final SharedPreferences _prefs;
  final Future<PermissionStatus> Function() _checkPermission;
  final Future<PermissionStatus> Function() _requestPermission;

  PermissionServiceImpl(
    this._prefs, {
    Future<PermissionStatus> Function()? checkPermission,
    Future<PermissionStatus> Function()? requestPermission,
  }) : _checkPermission = checkPermission ?? (() => Permission.contacts.status),
       _requestPermission =
           requestPermission ?? (() => Permission.contacts.request());

  @override
  Future<bool> hasWriteContactsPermission() async {
    final PermissionStatus status = await _checkPermission();
    return status.isGranted;
  }

  @override
  Future<bool> requestWriteContactsPermission() async {
    final PermissionStatus status = await _requestPermission();

    // Track denials
    if (!status.isGranted) {
      final int currentCount = await getDenialCount();
      await _prefs.setInt(
        PermissionConfig.writeContactsDenialCountKey,
        currentCount + 1,
      );
    }

    return status.isGranted;
  }

  @override
  Future<bool> isReadOnlyMode() async {
    // Check if explicitly set in SharedPreferences
    final bool? explicitReadOnly = _prefs.getBool(
      PermissionConfig.readOnlyModeKey,
    );
    if (explicitReadOnly != null) {
      return explicitReadOnly;
    }

    // Otherwise check denial count
    final int denialCount = await getDenialCount();
    return denialCount >= PermissionConfig.maxDenialAttempts;
  }

  @override
  Future<int> getDenialCount() async {
    final int? count = _prefs.getInt(
      PermissionConfig.writeContactsDenialCountKey,
    );
    return count ?? 0;
  }
}
