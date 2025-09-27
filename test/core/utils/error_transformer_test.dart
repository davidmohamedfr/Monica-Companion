import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';

void main() {
  group('ErrorTransformer', () {
    group('transformException', () {
      test('should transform DatabaseException to DatabaseFailure', () {
        // Arrange
        const DatabaseException exception = DatabaseException(
          'Test error',
          'TEST_CODE',
        );

        // Act
        final Failure result = ErrorTransformer.transformException(
          exception,
          'test context',
        );

        // Assert
        expect(result, isA<DatabaseFailure>());
        expect(result.message, 'Test error');
        expect(result.code, 'TEST_CODE');
      });

      test('should transform ValidationException to ValidationFailure', () {
        // Arrange
        const ValidationException exception = ValidationException(
          'Validation error',
          'VAL_CODE',
        );

        // Act
        final Failure result = ErrorTransformer.transformException(
          exception,
          'test context',
        );

        // Assert
        expect(result, isA<ValidationFailure>());
        expect(result.message, 'Validation error');
        expect(result.code, 'VAL_CODE');
      });

      test('should handle SQLite constraint errors', () {
        // Arrange
        final Exception exception = Exception(
          'SQLITE_CONSTRAINT_UNIQUE failed',
        );

        // Act
        final Failure result = ErrorTransformer.transformException(
          exception,
          'test context',
        );

        // Assert
        expect(result, isA<ValidationFailure>());
        expect(result.code, 'UNIQUE_CONSTRAINT');
      });

      test('should handle database busy errors', () {
        // Arrange
        final Exception exception = Exception('SQLITE_BUSY database is locked');

        // Act
        final Failure result = ErrorTransformer.transformException(
          exception,
          'test context',
        );

        // Assert
        expect(result, isA<DatabaseFailure>());
        expect(result.code, 'DATABASE_BUSY');
      });

      test('should handle foreign key constraint errors', () {
        // Arrange
        final Exception exception = Exception('FOREIGN KEY constraint failed');

        // Act
        final Failure result = ErrorTransformer.transformException(
          exception,
          'test context',
        );

        // Assert
        expect(result, isA<ValidationFailure>());
        expect(result.code, 'FOREIGN_KEY_CONSTRAINT');
      });

      test('should handle unknown exceptions as database failures', () {
        // Arrange
        final Exception exception = Exception('Unknown error');

        // Act
        final Failure result = ErrorTransformer.transformException(
          exception,
          'test context',
        );

        // Assert
        expect(result, isA<DatabaseFailure>());
        expect(result.code, 'UNKNOWN_ERROR');
      });
    });

    group('getUserFriendlyMessage', () {
      test('should return user-friendly message for DatabaseFailure', () {
        // Arrange
        const DatabaseFailure failure = DatabaseFailure(
          'Database error',
          'DATABASE_BUSY',
        );

        // Act
        final String result = ErrorTransformer.getUserFriendlyMessage(failure);

        // Assert
        expect(
          result,
          'The app is currently busy. Please wait a moment and try again.',
        );
      });

      test('should return user-friendly message for NetworkFailure', () {
        // Arrange
        const NetworkFailure failure = NetworkFailure('Network error');

        // Act
        final String result = ErrorTransformer.getUserFriendlyMessage(failure);

        // Assert
        expect(result, 'Please check your internet connection and try again.');
      });

      test('should return user-friendly message for ValidationFailure', () {
        // Arrange
        const ValidationFailure failure = ValidationFailure(
          'Validation error',
          'UNIQUE_CONSTRAINT',
        );

        // Act
        final String result = ErrorTransformer.getUserFriendlyMessage(failure);

        // Assert
        expect(result, 'This information already exists.');
      });

      test('should return default message for unknown failure types', () {
        // Arrange
        const AuthenticationFailure failure = AuthenticationFailure(
          'Auth error',
        );

        // Act
        final String result = ErrorTransformer.getUserFriendlyMessage(failure);

        // Assert
        expect(result, 'Authentication failed. Please sign in again.');
      });
    });
  });
}
