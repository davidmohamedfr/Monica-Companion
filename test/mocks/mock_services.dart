import 'package:mocktail/mocktail.dart';
import 'package:monica_companion/db/interfaces/contact_repository.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/repositories/repository_registry.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_bloc.dart';
import 'package:monica_companion/services/interfaces/api_service.dart';
import 'package:monica_companion/services/interfaces/storage_service.dart';

/// Mock database interface for testing
class MockDatabaseInterface extends Mock implements DatabaseInterface {}

/// Mock repository registry for testing
class MockRepositoryRegistry extends Mock implements RepositoryRegistry {}

/// Mock contact repository for testing
class MockContactRepository extends Mock implements ContactRepository {}

/// Mock API service for testing
class MockApiService extends Mock implements ApiService {}

/// Mock storage service for testing
class MockStorageService extends Mock implements StorageService {}

/// Mock contacts bloc for testing
class MockContactsBloc extends Mock implements ContactsBloc {}

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
