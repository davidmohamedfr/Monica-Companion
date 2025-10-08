import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/services/app_initialization_service.dart';
import 'package:monica_companion/core/services/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPermissionService extends Mock implements PermissionService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('AppInitializationService Permission Flow Tests', () {
    late MockPermissionService mockPermissionService;
    late MockSharedPreferences mockPrefs;
    late AppInitializationService appInitService;

    setUp(() {
      mockPermissionService = MockPermissionService();
      mockPrefs = MockSharedPreferences();
    });

    group('First Launch Permission Request', () {
      test(
          'should request WRITE_CONTACTS permission when first launch and READ_CONTACTS granted',
          () async {
        // Arrange
        when(() => mockPrefs.getBool('is_first_launch')).thenReturn(true);
        when(() => mockPrefs.setBool('is_first_launch', false))
            .thenAnswer((_) async => true);
        when(() => mockPermissionService.hasWriteContactsPermission())
            .thenAnswer((_) async => false);
        when(() => mockPermissionService.requestWriteContactsPermission())
            .thenAnswer((_) async => true);

        appInitService = AppInitializationService.withDependencies(
          prefs: mockPrefs,
          permissionService: mockPermissionService,
        );

        // Act
        await appInitService.requestPermissionsOnFirstLaunch();

        // Assert
        verify(() => mockPermissionService.requestWriteContactsPermission())
            .called(1);
        verify(() => mockPrefs.setBool('is_first_launch', false)).called(1);
      });

      test('should not request permissions on subsequent launches', () async {
        // Arrange
        when(() => mockPrefs.getBool('is_first_launch')).thenReturn(false);

        appInitService = AppInitializationService.withDependencies(
          prefs: mockPrefs,
          permissionService: mockPermissionService,
        );

        // Act
        await appInitService.requestPermissionsOnFirstLaunch();

        // Assert
        verifyNever(
          () => mockPermissionService.requestWriteContactsPermission(),
        );
      });

      test('should handle permission denial gracefully', () async {
        // Arrange
        when(() => mockPrefs.getBool('is_first_launch')).thenReturn(true);
        when(() => mockPrefs.setBool('is_first_launch', false))
            .thenAnswer((_) async => true);
        when(() => mockPermissionService.hasWriteContactsPermission())
            .thenAnswer((_) async => false);
        when(() => mockPermissionService.requestWriteContactsPermission())
            .thenAnswer((_) async => false);

        appInitService = AppInitializationService.withDependencies(
          prefs: mockPrefs,
          permissionService: mockPermissionService,
        );

        // Act
        await appInitService.requestPermissionsOnFirstLaunch();

        // Assert - should complete without throwing
        verify(() => mockPermissionService.requestWriteContactsPermission())
            .called(1);
        verify(() => mockPrefs.setBool('is_first_launch', false)).called(1);
      });

      test('should skip if permission already granted', () async {
        // Arrange
        when(() => mockPrefs.getBool('is_first_launch')).thenReturn(true);
        when(() => mockPrefs.setBool('is_first_launch', false))
            .thenAnswer((_) async => true);
        when(() => mockPermissionService.hasWriteContactsPermission())
            .thenAnswer((_) async => true);

        appInitService = AppInitializationService.withDependencies(
          prefs: mockPrefs,
          permissionService: mockPermissionService,
        );

        // Act
        await appInitService.requestPermissionsOnFirstLaunch();

        // Assert - should not request if already granted
        verifyNever(
          () => mockPermissionService.requestWriteContactsPermission(),
        );
        verify(() => mockPrefs.setBool('is_first_launch', false)).called(1);
      });
    });
  });
}
