/// Base exception class for the application
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Database-related exceptions
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.code]);
}

/// Authentication-related exceptions
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code]);
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, [super.code]);
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException(super.message, [super.code]) : statusCode = null;

  const ServerException.withStatusCode(
    String message,
    this.statusCode, [
    String? code,
  ]) : super(message, code);

  final int? statusCode;
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}
