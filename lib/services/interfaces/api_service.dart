import 'package:monica_mobile_app/services/interfaces/base_service.dart';

/// HTTP client response wrapper
class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    required this.statusCode,
    this.message,
  });

  final T? data;
  final int statusCode;
  final String? message;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Base API service interface for HTTP operations
abstract class ApiService extends BaseService {
  /// Set base URL for API requests
  void setBaseUrl(String baseUrl);

  /// Set authentication token
  void setAuthToken(String token);

  /// Clear authentication token
  void clearAuthToken();

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  });

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  });

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
  });

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  });
}
