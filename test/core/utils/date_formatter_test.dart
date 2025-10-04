import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    late DateTime now;

    setUp(() {
      // Use a fixed "now" for consistent testing
      now = DateTime(2025, 10, 4, 12, 0, 0);
    });

    group('Test 2.1: Null date', () {
      test('shouldReturnEmptyStringForNullDate', () {
        // Act
        final String result = DateFormatter.formatDualDate(null);

        // Assert
        expect(result, equals(''));
      });
    });

    group('Test 2.2: Today', () {
      test('shouldReturnTodayForCurrentDate', () {
        // Arrange
        final DateTime today = now;

        // Act
        final String result = DateFormatter.formatDualDate(today, now: now);

        // Assert
        expect(result, contains('Today'));
      });
    });

    group('Test 2.3: Yesterday', () {
      test('shouldReturnYesterdayForOneDayAgo', () {
        // Arrange
        final DateTime yesterday = now.subtract(const Duration(days: 1));

        // Act
        final String result = DateFormatter.formatDualDate(yesterday, now: now);

        // Assert
        expect(result, contains('Yesterday'));
      });
    });

    group('Test 2.4: Days ago', () {
      test('shouldReturnDaysAgoForDatesWithinWeek', () {
        // Arrange
        final DateTime threeDaysAgo = now.subtract(const Duration(days: 3));

        // Act
        final String result = DateFormatter.formatDualDate(
          threeDaysAgo,
          now: now,
        );

        // Assert
        expect(result, contains('3 days ago'));
      });
    });

    group('Test 2.5: Weeks ago', () {
      test('shouldReturnWeeksAgoForDatesWithinMonth', () {
        // Arrange
        final DateTime twoWeeksAgo = now.subtract(const Duration(days: 14));

        // Act
        final String result = DateFormatter.formatDualDate(
          twoWeeksAgo,
          now: now,
        );

        // Assert
        expect(result, contains('2 weeks ago'));
      });

      test('shouldUseSingularWeekForOneWeek', () {
        // Arrange
        final DateTime oneWeekAgo = now.subtract(const Duration(days: 7));

        // Act
        final String result = DateFormatter.formatDualDate(
          oneWeekAgo,
          now: now,
        );

        // Assert
        expect(result, contains('1 week ago'));
      });
    });

    group('Test 2.6: Months ago', () {
      test('shouldReturnMonthsAgoForDatesWithinYear', () {
        // Arrange
        // Use 61 days to ensure we get 2 months (61 / 30.44 = 2.00)
        final DateTime twoMonthsAgo = now.subtract(const Duration(days: 61));

        // Act
        final String result = DateFormatter.formatDualDate(
          twoMonthsAgo,
          now: now,
        );

        // Assert
        expect(result, contains('2 months ago'));
      });

      test('shouldUseSingularMonthForOneMonth', () {
        // Arrange
        // Use 31 days to ensure we get 1 month (31 / 30.44 = 1.01)
        final DateTime oneMonthAgo = now.subtract(const Duration(days: 31));

        // Act
        final String result = DateFormatter.formatDualDate(
          oneMonthAgo,
          now: now,
        );

        // Assert
        expect(result, contains('1 month ago'));
      });
    });

    group('Test 2.7: Years ago', () {
      test('shouldReturnYearsAgoForDatesOverYear', () {
        // Arrange
        // Use 731 days to ensure we get 2 years (731 / 365.25 = 2.00)
        final DateTime twoYearsAgo = now.subtract(const Duration(days: 731));

        // Act
        final String result = DateFormatter.formatDualDate(
          twoYearsAgo,
          now: now,
        );

        // Assert
        expect(result, contains('2 years ago'));
      });

      test('shouldUseSingularYearForOneYear', () {
        // Arrange
        // Use 366 days to ensure we get 1 year (366 / 365.25 = 1.00)
        final DateTime oneYearAgo = now.subtract(const Duration(days: 366));

        // Act
        final String result = DateFormatter.formatDualDate(
          oneYearAgo,
          now: now,
        );

        // Assert
        expect(result, contains('1 year ago'));
      });
    });

    group('Test 2.8: Absolute date', () {
      test('shouldIncludeAbsoluteDateInDualFormat', () {
        // Arrange
        final DateTime date = DateTime(2024, 10, 2);

        // Act
        final String result = DateFormatter.formatDualDate(date, now: now);

        // Assert
        expect(result, contains('Oct 2, 2024'));
      });
    });

    group('Test 2.9: Dual format combination', () {
      test('shouldCombineRelativeAndAbsoluteWithBulletSeparator', () {
        // Arrange
        final DateTime yesterday = now.subtract(const Duration(days: 1));

        // Act
        final String result = DateFormatter.formatDualDate(yesterday, now: now);

        // Assert
        expect(result, contains('•'));
        expect(result, contains('Yesterday'));
        expect(result, contains('Oct 3, 2025'));
      });
    });
  });
}
