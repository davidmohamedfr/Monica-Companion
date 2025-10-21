import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/utils/communication_utils.dart';

void main() {
  group('CommunicationUtils Tests', () {
    group('makePhoneCall', () {
      testWidgets('should return false for empty phone number', (
        WidgetTester tester,
      ) async {
        // Act
        final bool result = await CommunicationUtils.makePhoneCall('');

        // Assert
        expect(result, isFalse);
      });

      testWidgets('should return false for whitespace-only phone number', (
        WidgetTester tester,
      ) async {
        // Act
        final bool result = await CommunicationUtils.makePhoneCall('   ');

        // Assert
        expect(result, isFalse);
      });

      // Note: url_launcher cannot actually launch URLs in test environment
      // Tests that attempt to launch will hang, so we only test validation
    });

    group('sendSMS', () {
      testWidgets('should return false for empty phone number', (
        WidgetTester tester,
      ) async {
        // Act
        final bool result = await CommunicationUtils.sendSMS('');

        // Assert
        expect(result, isFalse);
      });

      testWidgets('should return false for whitespace-only phone number', (
        WidgetTester tester,
      ) async {
        // Act
        final bool result = await CommunicationUtils.sendSMS('   ');

        // Assert
        expect(result, isFalse);
      });

      // Note: Actual URL launching tests skipped (would hang in test env)
    });

    group('sendEmail', () {
      testWidgets('should return false for empty email', (
        WidgetTester tester,
      ) async {
        // Act
        final bool result = await CommunicationUtils.sendEmail('');

        // Assert
        expect(result, isFalse);
      });

      testWidgets('should return false for whitespace-only email', (
        WidgetTester tester,
      ) async {
        // Act
        final bool result = await CommunicationUtils.sendEmail('   ');

        // Assert
        expect(result, isFalse);
      });

      // Note: Actual URL launching tests skipped (would hang in test env)
    });

    group('Input Validation', () {
      testWidgets('should handle null-like empty strings', (
        WidgetTester tester,
      ) async {
        // Act & Assert - All should return false for empty input
        expect(await CommunicationUtils.makePhoneCall(''), isFalse);
        expect(await CommunicationUtils.sendSMS(''), isFalse);
        expect(await CommunicationUtils.sendEmail(''), isFalse);
      });

      // Note: Whitespace trimming tests skipped (would hang on URL launch)
    });

    // Note: Error handling tests with actual URL launching skipped
    // These would require integration tests on real device/emulator
  });
}
