import 'package:flutter_test/flutter_test.dart';
import 'package:monica_mobile_app/core/utils/logger.dart';

void main() {
  group('Logger', () {
    test('should log debug messages when in debug mode', () {
      // This test verifies the Logger utility works correctly
      // In a real app, you might want to capture log output for testing
      expect(() => Logger.debug('Test debug message'), returnsNormally);
    });

    test('should log info messages', () {
      expect(() => Logger.info('Test info message'), returnsNormally);
    });

    test('should log warning messages', () {
      expect(() => Logger.warning('Test warning message'), returnsNormally);
    });

    test('should log error messages', () {
      expect(() => Logger.error('Test error message'), returnsNormally);
    });

    test('should handle error with exception', () {
      final Exception testException = Exception('Test exception');
      expect(
        () => Logger.error('Test error with exception', error: testException),
        returnsNormally,
      );
    });
  });
}
