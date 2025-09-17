import 'package:mocktail/mocktail.dart';
import 'package:monica_mobile_app/db/interfaces/database_interface.dart';
import 'package:monica_mobile_app/services/interfaces/api_service.dart';
import 'package:monica_mobile_app/services/interfaces/storage_service.dart';

/// Mock database interface for testing
class MockDatabaseInterface extends Mock implements DatabaseInterface {}

/// Mock API service for testing
class MockApiService extends Mock implements ApiService {}

/// Mock storage service for testing
class MockStorageService extends Mock implements StorageService {}

/// Mock API response for testing
class MockApiResponse<T> implements ApiResponse<T> {
  const MockApiResponse({
    required this.data,
    required this.statusCode,
    this.message,
  });

  @override
  final T? data;

  @override
  final int statusCode;

  @override
  final String? message;

  @override
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
