import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/errors/failures.dart';
import 'package:monica_companion/core/utils/logger.dart';

/// Utility class for transforming low-level exceptions into domain failures
class ErrorTransformer {
  ErrorTransformer._();

  /// Transform any exception into an appropriate domain failure
  static Failure transformException(Object exception, String context) {
    Logger.error('Error in $context', error: exception);

    if (exception is DatabaseException) {
      return _transformDatabaseException(exception, context);
    }

    if (exception is ValidationException) {
      return ValidationFailure(exception.message, exception.code);
    }

    if (exception is AuthenticationException) {
      return AuthenticationFailure(exception.message, exception.code);
    }

    if (exception is NetworkException) {
      return NetworkFailure(exception.message, exception.code);
    }

    if (exception is PermissionException) {
      return PermissionFailure(exception.message, exception.code);
    }

    // Handle SQLite-specific errors
    if (exception.toString().contains('SQLITE_CONSTRAINT')) {
      return _handleSQLiteConstraintError(exception, context);
    }

    if (exception.toString().contains('SQLITE_BUSY') ||
        exception.toString().contains('database is locked')) {
      return const DatabaseFailure(
        'Database is currently busy. Please try again.',
        'DATABASE_BUSY',
      );
    }

    if (exception.toString().contains('FOREIGN KEY constraint failed') ||
        exception.toString().contains('SQLITE_CONSTRAINT_FOREIGNKEY')) {
      return const ValidationFailure(
        'Cannot perform operation due to data relationships.',
        'FOREIGN_KEY_CONSTRAINT',
      );
    }

    if (exception.toString().contains('no such table') ||
        exception.toString().contains('no such column')) {
      return const DatabaseFailure(
        'Database structure error. Please restart the app.',
        'SCHEMA_ERROR',
      );
    }

    if (exception.toString().contains('disk I/O error') ||
        exception.toString().contains('database disk image is malformed')) {
      return const DatabaseFailure(
        'Database file is corrupted. Please contact support.',
        'CORRUPTION_ERROR',
      );
    }

    // Fallback for unknown exceptions
    return const DatabaseFailure(
      'An unexpected error occurred. Please try again.',
      'UNKNOWN_ERROR',
    );
  }

  static DatabaseFailure _transformDatabaseException(
    DatabaseException exception,
    String context,
  ) {
    final String message = exception.message.toLowerCase();

    if (message.contains('constraint') || message.contains('unique')) {
      return const DatabaseFailure(
        'Data already exists or violates requirements.',
        'CONSTRAINT_VIOLATION',
      );
    }

    if (message.contains('not found') || message.contains('no rows')) {
      return const DatabaseFailure(
        'Requested data was not found.',
        'DATA_NOT_FOUND',
      );
    }

    if (message.contains('timeout') || message.contains('busy')) {
      return const DatabaseFailure(
        'Database operation timed out. Please try again.',
        'TIMEOUT_ERROR',
      );
    }

    return DatabaseFailure(exception.message, exception.code);
  }

  static ValidationFailure _handleSQLiteConstraintError(
    Object exception,
    String context,
  ) {
    final String errorString = exception.toString().toLowerCase();

    if (errorString.contains('unique')) {
      return const ValidationFailure(
        'This data already exists and must be unique.',
        'UNIQUE_CONSTRAINT',
      );
    }

    if (errorString.contains('not null')) {
      return const ValidationFailure(
        'Required information is missing.',
        'NOT_NULL_CONSTRAINT',
      );
    }

    if (errorString.contains('check')) {
      return const ValidationFailure(
        'The provided data does not meet requirements.',
        'CHECK_CONSTRAINT',
      );
    }

    return const ValidationFailure(
      'Data validation failed.',
      'CONSTRAINT_VIOLATION',
    );
  }

  /// Get user-friendly error message from failure
  static String getUserFriendlyMessage(Failure failure) => switch (failure) {
    DatabaseFailure() => _getDatabaseErrorMessage(failure),
    NetworkFailure() => 'Please check your internet connection and try again.',
    ValidationFailure() => _getValidationErrorMessage(failure),
    AuthenticationFailure() => 'Authentication failed. Please sign in again.',
    PermissionFailure() => 'Permission denied. Please check app permissions.',
    _ => failure.message,
  };

  static String _getDatabaseErrorMessage(DatabaseFailure failure) {
    switch (failure.code) {
      case 'DATABASE_BUSY':
        return 'The app is currently busy. Please wait a moment and try again.';
      case 'CONSTRAINT_VIOLATION':
        return 'This information conflicts with existing data.';
      case 'DATA_NOT_FOUND':
        return 'The requested information could not be found.';
      case 'TIMEOUT_ERROR':
        return 'The operation took too long. Please try again.';
      case 'SCHEMA_ERROR':
        return "There's an issue with the app data. Please restart the app.";
      case 'CORRUPTION_ERROR':
        return 'The app data is corrupted. Please contact support.';
      default:
        return 'A database error occurred. Please try again.';
    }
  }

  static String _getValidationErrorMessage(ValidationFailure failure) {
    switch (failure.code) {
      case 'UNIQUE_CONSTRAINT':
        return 'This information already exists.';
      case 'NOT_NULL_CONSTRAINT':
        return 'Please fill in all required fields.';
      case 'CHECK_CONSTRAINT':
        return 'Please check that all information is correct.';
      case 'FOREIGN_KEY_CONSTRAINT':
        return "Cannot delete this item as it's being used elsewhere.";
      default:
        return 'Please check your input and try again.';
    }
  }
}
