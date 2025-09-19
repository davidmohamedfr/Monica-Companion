import 'package:equatable/equatable.dart';

/// Base failure class for error handling in the clean architecture
abstract class Failure extends Equatable {
  const Failure(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  List<Object?> get props => <Object?>[message, code];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]) : statusCode = null;

  const ServerFailure.withStatusCode(
    String message,
    this.statusCode, [
    String? code,
  ]) : super(message, code);

  final int? statusCode;

  @override
  List<Object?> get props => <Object?>[message, code, statusCode];
}

/// Database-related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.code]);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Authentication-related failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.code]);
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.code]);
}
