import 'dart:async';

import '../axios_error.dart';
import '../axios_response.dart';
import '../types/types.dart';
import 'interceptor.dart';

/// Simple response interceptor that takes a function
class ResponseInterceptor extends Interceptor {
  final ResponseInterceptorFunction _onResponse;

  ResponseInterceptor(this._onResponse);

  @override
  FutureOr<AxiosResponse<dynamic>> onResponse(AxiosResponse<dynamic> response) {
    return _onResponse(response);
  }
}

/// Response interceptor for handling errors
class ErrorResponseInterceptor extends Interceptor {
  final ErrorInterceptorFunction _onError;

  ErrorResponseInterceptor(this._onError);

  @override
  FutureOr<void> onError(AxiosError error) {
    return _onError(error);
  }
}

/// Response interceptor for logging responses
class LoggingResponseInterceptor extends Interceptor {
  final void Function(String message) logger;

  LoggingResponseInterceptor({
    required this.logger,
  });

  @override
  FutureOr<AxiosResponse<dynamic>> onResponse(AxiosResponse<dynamic> response) {
    logger('✅ Response: ${response.status} ${response.statusText}');
    logger('📋 Headers: ${response.headers}');
    if (response.data != null) {
      logger('📦 Data: ${response.data}');
    }
    
    return response;
  }

  @override
  FutureOr<void> onError(AxiosError error) {
    logger('❌ Error: ${error.type.name} - ${error.message}');
    if (error.response != null) {
      logger('📋 Response Status: ${error.response!.status}');
    }
  }
}

/// Response interceptor for retry logic
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final bool Function(AxiosError error)? shouldRetry;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.shouldRetry,
  });

  @override
  FutureOr<void> onError(AxiosError error) async {
    if (_shouldRetryError(error)) {
      // Note: Actual retry logic would need to be implemented at the axios instance level
      // This is just a placeholder for the retry interceptor concept
    }
  }

  bool _shouldRetryError(AxiosError error) {
    if (shouldRetry != null) {
      return shouldRetry!(error);
    }
    
    // Default retry logic: retry on network errors and 5xx responses
    return error.isNetworkError || 
           error.isTimeoutError ||
           (error.response != null && error.response!.status >= 500);
  }
}
