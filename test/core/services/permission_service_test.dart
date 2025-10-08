import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/config/permission_config.dart';
import 'package:monica_companion/core/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('PermissionService Tests', () {
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
    });

    group('Basic Permission Checks', () {
      test(
        'hasWriteContactsPermission should return false when permission not granted',
        () async {
          // Arrange
          final PermissionService permissionService = PermissionServiceImpl(
            mockPrefs,
            checkPermission: () async => PermissionStatus.denied,
          );

          // Act
          final bool result = await permissionService
              .hasWriteContactsPermission();

          // Assert
          expect(result, isFalse);
        },
      );

      test(
        'hasWriteContactsPermission should return true when permission granted',
        () async {
          // Arrange
          final PermissionService permissionService = PermissionServiceImpl(
            mockPrefs,
            checkPermission: () async => PermissionStatus.granted,
          );

          // Act
          final bool result = await permissionService
              .hasWriteContactsPermission();

          // Assert
          expect(result, isTrue);
        },
      );

      test(
        'requestWriteContactsPermission should return true when user grants permission',
        () async {
          // Arrange
          final PermissionService permissionService = PermissionServiceImpl(
            mockPrefs,
            requestPermission: () async => PermissionStatus.granted,
          );

          // Act
          final bool result = await permissionService
              .requestWriteContactsPermission();

          // Assert
          expect(result, isTrue);
        },
      );

      test(
        'requestWriteContactsPermission should return false when user denies permission',
        () async {
          // Arrange
          when(() => mockPrefs.getInt(any())).thenReturn(0);
          when(
            () => mockPrefs.setInt(any(), any()),
          ).thenAnswer((_) async => true);

          final PermissionService permissionService = PermissionServiceImpl(
            mockPrefs,
            requestPermission: () async => PermissionStatus.denied,
          );

          // Act
          final bool result = await permissionService
              .requestWriteContactsPermission();

          // Assert
          expect(result, isFalse);
        },
      );
    });

    group('Denial Counter Logic', () {
      test('should start with denial count of 0', () async {
        // Arrange
        when(() => mockPrefs.getInt(any())).thenReturn(null);
        final PermissionService permissionService = PermissionServiceImpl(
          mockPrefs,
        );

        // Act
        final int count = await permissionService.getDenialCount();

        // Assert
        expect(count, equals(0));
      });

      test('should increment denial count when permission denied', () async {
        // Arrange
        when(() => mockPrefs.getInt(any())).thenReturn(0);
        when(
          () => mockPrefs.setInt(any(), any()),
        ).thenAnswer((_) async => true);

        final PermissionService permissionService = PermissionServiceImpl(
          mockPrefs,
          requestPermission: () async => PermissionStatus.denied,
        );

        // Act
        await permissionService.requestWriteContactsPermission();

        // Assert
        verify(
          () =>
              mockPrefs.setInt(PermissionConfig.writeContactsDenialCountKey, 1),
        ).called(1);
      });

      test(
        'should not increment denial count when permission granted',
        () async {
          // Arrange
          when(() => mockPrefs.getInt(any())).thenReturn(0);
          when(
            () => mockPrefs.setInt(any(), any()),
          ).thenAnswer((_) async => true);

          final PermissionService permissionService = PermissionServiceImpl(
            mockPrefs,
            requestPermission: () async => PermissionStatus.granted,
          );

          // Act
          await permissionService.requestWriteContactsPermission();

          // Assert
          verifyNever(() => mockPrefs.setInt(any(), any()));
        },
      );
    });

    group('Read-Only Mode', () {
      test(
        'isReadOnlyMode should return false when denial count is 0',
        () async {
          // Arrange
          when(
            () =>
                mockPrefs.getInt(PermissionConfig.writeContactsDenialCountKey),
          ).thenReturn(0);
          when(
            () => mockPrefs.getBool(PermissionConfig.readOnlyModeKey),
          ).thenReturn(null);

          final PermissionService permissionService = PermissionServiceImpl(
            mockPrefs,
          );

          // Act
          final bool result = await permissionService.isReadOnlyMode();

          // Assert
          expect(result, isFalse);
        },
      );

      test(
        'isReadOnlyMode should return false when denial count is 1',
        () async {
          // Arrange
          when(
            () =>
                mockPrefs.getInt(PermissionConfig.writeContactsDenialCountKey),
          ).thenReturn(1);
          when(
            () => mockPrefs.getBool(PermissionConfig.readOnlyModeKey),
          ).thenReturn(null);

          final PermissionService permissionService = PermissionServiceImpl(
            mockPrefs,
          );

          // Act
          final bool result = await permissionService.isReadOnlyMode();

          // Assert
          expect(result, isFalse);
        },
      );

      test(
        'isReadOnlyMode should return true when denial count is 2 or more',
        () async {
          // Arrange
          when(
            () =>
                mockPrefs.getInt(PermissionConfig.writeContactsDenialCountKey),
          ).thenReturn(2);
          when(
            () => mockPrefs.getBool(PermissionConfig.readOnlyModeKey),
          ).thenReturn(null);

          final PermissionService permissionService = PermissionServiceImpl(
            mockPrefs,
          );

          // Act
          final bool result = await permissionService.isReadOnlyMode();

          // Assert
          expect(result, isTrue);
        },
      );
    });
  });
}
