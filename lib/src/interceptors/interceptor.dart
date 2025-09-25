import 'dart:async';

import '../axios_error.dart';
import '../axios_request.dart';
import '../axios_response.dart';

/// Base class for all interceptors
abstract class Interceptor {
  /// Called before the request is sent
  FutureOr<AxiosRequest> onRequest(AxiosRequest request) => request;

  /// Called when the response is received
  FutureOr<AxiosResponse<dynamic>> onResponse(
          AxiosResponse<dynamic> response) =>
      response;

  /// Called when an error occurs
  FutureOr<void> onError(AxiosError error) {}
}

/// Manager for handling interceptors
class InterceptorManager {
  final List<Interceptor> _interceptors = [];

  /// Add an interceptor
  void add(Interceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// Remove an interceptor
  void remove(Interceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  /// Clear all interceptors
  void clear() {
    _interceptors.clear();
  }

  /// Get all interceptors
  List<Interceptor> get interceptors => List.unmodifiable(_interceptors);

  /// Process a request through all interceptors
  Future<AxiosRequest> processRequest(AxiosRequest request) async {
    var processedRequest = request;

    for (final interceptor in _interceptors) {
      processedRequest = await interceptor.onRequest(processedRequest);
    }

    return processedRequest;
  }

  /// Process a response through all interceptors
  Future<AxiosResponse<dynamic>> processResponse(
      AxiosResponse<dynamic> response) async {
    var processedResponse = response;

    for (final interceptor in _interceptors) {
      processedResponse = await interceptor.onResponse(processedResponse);
    }

    return processedResponse;
  }

  /// Process an error through all interceptors
  Future<void> processError(AxiosError error) async {
    for (final interceptor in _interceptors) {
      await interceptor.onError(error);
    }
  }
}
