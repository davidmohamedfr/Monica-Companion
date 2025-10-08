import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/config/permission_config.dart';

void main() {
  group('PermissionConfig Tests', () {
    group('Constants Tests', () {
      test('should have maxDenialAttempts constant set to 2', () {
        // Arrange & Act
        const int maxAttempts = PermissionConfig.maxDenialAttempts;

        // Assert
        expect(maxAttempts, equals(2));
      });

      test('should have writeContactsDenialCountKey constant', () {
        // Arrange & Act
        const String key = PermissionConfig.writeContactsDenialCountKey;

        // Assert
        expect(key, equals('write_contacts_denial_count'));
      });

      test('should have readOnlyModeKey constant', () {
        // Arrange & Act
        const String key = PermissionConfig.readOnlyModeKey;

        // Assert
        expect(key, equals('read_only_mode'));
      });
    });
  });
}
