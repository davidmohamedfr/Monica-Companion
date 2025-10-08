import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/core/services/app_initialization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('AppInitializationService First Launch Tests', () {
    late MockSharedPreferences mockPrefs;
    late AppInitializationService appInitService;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      // We'll need to modify AppInitializationService to accept SharedPreferences
      // For now, this will guide our refactoring
    });

    group('First Launch Detection', () {
      test('isFirstLaunch should return true when flag not set', () async {
        // Arrange
        when(() => mockPrefs.getBool('is_first_launch')).thenReturn(null);
        appInitService = AppInitializationService.withPreferences(mockPrefs);

        // Act
        final bool result = await appInitService.isFirstLaunch();

        // Assert
        expect(result, isTrue);
      });

      test('isFirstLaunch should return false when flag is false', () async {
        // Arrange
        when(() => mockPrefs.getBool('is_first_launch')).thenReturn(false);
        appInitService = AppInitializationService.withPreferences(mockPrefs);

        // Act
        final bool result = await appInitService.isFirstLaunch();

        // Assert
        expect(result, isFalse);
      });

      test('setFirstLaunchComplete should set flag to false', () async {
        // Arrange
        when(
          () => mockPrefs.setBool('is_first_launch', false),
        ).thenAnswer((_) async => true);
        appInitService = AppInitializationService.withPreferences(mockPrefs);

        // Act
        await appInitService.setFirstLaunchComplete();

        // Assert
        verify(() => mockPrefs.setBool('is_first_launch', false)).called(1);
      });

      test('should correctly identify subsequent launches', () async {
        // Arrange
        when(() => mockPrefs.getBool('is_first_launch')).thenReturn(false);
        appInitService = AppInitializationService.withPreferences(mockPrefs);

        // Act
        final bool isFirst = await appInitService.isFirstLaunch();

        // Assert
        expect(isFirst, isFalse);
      });
    });
  });
}
