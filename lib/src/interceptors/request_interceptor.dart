import 'dart:async';

import '../axios_request.dart';
import '../types/types.dart';
import 'interceptor.dart';

/// Simple request interceptor that takes a function
class RequestInterceptor extends Interceptor {
  final RequestInterceptorFunction _onRequest;

  RequestInterceptor(this._onRequest);

  @override
  FutureOr<AxiosRequest> onRequest(AxiosRequest request) {
    return _onRequest(request);
  }
}

/// Request interceptor for adding authentication headers
class AuthInterceptor extends Interceptor {
  final String token;
  final String headerName;

  AuthInterceptor({
    required this.token,
    this.headerName = 'Authorization',
  });

  @override
  FutureOr<AxiosRequest> onRequest(AxiosRequest request) {
    final newHeaders = Map<String, String>.from(request.headers);
    newHeaders[headerName] = 'Bearer $token';
    
    return request.copyWith(headers: newHeaders);
  }
}

/// Request interceptor for adding common headers
class HeadersInterceptor extends Interceptor {
  final Headers headers;

  HeadersInterceptor(this.headers);

  @override
  FutureOr<AxiosRequest> onRequest(AxiosRequest request) {
    final newHeaders = Map<String, String>.from(request.headers);
    newHeaders.addAll(headers);
    
    return request.copyWith(headers: newHeaders);
  }
}

/// Request interceptor for logging requests
class LoggingRequestInterceptor extends Interceptor {
  final void Function(String message) logger;

  LoggingRequestInterceptor({
    required this.logger,
  });

  @override
  FutureOr<AxiosRequest> onRequest(AxiosRequest request) {
    logger('🚀 Request: ${request.method.name.toUpperCase()} ${request.fullUrl}');
    if (request.headers.isNotEmpty) {
      logger('📋 Headers: ${request.headers}');
    }
    if (request.params != null) {
      logger('🔍 Params: ${request.params}');
    }
    if (request.data != null) {
      logger('📦 Data: ${request.data}');
    }
    
    return request;
  }
}
