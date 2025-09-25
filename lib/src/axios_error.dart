import 'axios_request.dart';
import 'axios_response.dart';

/// Error types that can occur during HTTP requests
enum AxiosErrorType {
  /// Network error (no internet, DNS failure, etc.)
  network,
  
  /// Request timeout
  timeout,
  
  /// Request was cancelled
  cancelled,
  
  /// HTTP error response (4xx, 5xx)
  response,
  
  /// Unknown error
  unknown,
}

/// Axios-style error class
class AxiosError implements Exception {
  /// Error message
  final String message;
  
  /// Error type
  final AxiosErrorType type;
  
  /// The request that caused the error
  final AxiosRequest? request;
  
  /// The response (if any) that caused the error
  final AxiosResponse<dynamic>? response;
  
  /// The underlying error (if any)
  final dynamic cause;
  
  /// Error code (optional)
  final String? code;

  const AxiosError({
    required this.message,
    required this.type,
    this.request,
    this.response,
    this.cause,
    this.code,
  });

  /// Create a network error
  factory AxiosError.network({
    required String message,
    AxiosRequest? request,
    dynamic cause,
    String? code,
  }) {
    return AxiosError(
      message: message,
      type: AxiosErrorType.network,
      request: request,
      cause: cause,
      code: code,
    );
  }

  /// Create a timeout error
  factory AxiosError.timeout({
    required String message,
    AxiosRequest? request,
    dynamic cause,
    String? code,
  }) {
    return AxiosError(
      message: message,
      type: AxiosErrorType.timeout,
      request: request,
      cause: cause,
      code: code,
    );
  }

  /// Create a cancellation error
  factory AxiosError.cancelled({
    required String message,
    AxiosRequest? request,
    dynamic cause,
    String? code,
  }) {
    return AxiosError(
      message: message,
      type: AxiosErrorType.cancelled,
      request: request,
      cause: cause,
      code: code,
    );
  }

  /// Create a response error (4xx, 5xx)
  factory AxiosError.response({
    required String message,
    required AxiosResponse<dynamic> response,
    AxiosRequest? request,
    dynamic cause,
    String? code,
  }) {
    return AxiosError(
      message: message,
      type: AxiosErrorType.response,
      request: request ?? response.request,
      response: response,
      cause: cause,
      code: code,
    );
  }

  /// Create an unknown error
  factory AxiosError.unknown({
    required String message,
    AxiosRequest? request,
    dynamic cause,
    String? code,
  }) {
    return AxiosError(
      message: message,
      type: AxiosErrorType.unknown,
      request: request,
      cause: cause,
      code: code,
    );
  }

  /// Whether this is a network error
  bool get isNetworkError => type == AxiosErrorType.network;

  /// Whether this is a timeout error
  bool get isTimeoutError => type == AxiosErrorType.timeout;

  /// Whether this is a cancellation error
  bool get isCancelledError => type == AxiosErrorType.cancelled;

  /// Whether this is a response error
  bool get isResponseError => type == AxiosErrorType.response;

  /// Whether this is an unknown error
  bool get isUnknownError => type == AxiosErrorType.unknown;

  @override
  String toString() {
    return 'AxiosError{type: $type, message: $message, code: $code}';
  }
}
