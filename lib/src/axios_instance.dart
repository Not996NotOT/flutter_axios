import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'axios_config.dart';
import 'axios_error.dart';
import 'axios_request.dart';
import 'axios_response.dart';
import 'interceptors/interceptor.dart';
import 'models/request_options.dart';
import 'types/types.dart';

/// Axios instance for making HTTP requests
class AxiosInstance {
  /// Instance configuration
  final AxiosConfig config;
  
  /// HTTP client for making requests
  final http.Client _client;
  
  /// Interceptor manager
  final InterceptorManager _interceptors = InterceptorManager();

  AxiosInstance({
    AxiosConfig? config,
    http.Client? client,
  }) : config = config ?? const AxiosConfig(),
        _client = client ?? http.Client();

  /// Get interceptors manager
  InterceptorManager get interceptors => _interceptors;

  /// Make a GET request
  Future<AxiosResponse<T>> get<T>(
    String url, {
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ProgressCallback? onDownloadProgress,
    ValidateStatus? validateStatus,
    List<TransformResponse>? transformResponse,
  }) {
    return request<T>(RequestOptions(
      url: url,
      method: HttpMethod.get,
      params: params,
      headers: headers,
      timeout: timeout,
      onDownloadProgress: onDownloadProgress,
      validateStatus: validateStatus,
    ));
  }

  /// Make a POST request
  Future<AxiosResponse<T>> post<T>(
    String url, {
    RequestData? data,
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ProgressCallback? onUploadProgress,
    ProgressCallback? onDownloadProgress,
    ValidateStatus? validateStatus,
    List<TransformResponse>? transformResponse,
  }) {
    return request<T>(RequestOptions(
      url: url,
      method: HttpMethod.post,
      data: data,
      params: params,
      headers: headers,
      timeout: timeout,
      onUploadProgress: onUploadProgress,
      onDownloadProgress: onDownloadProgress,
      validateStatus: validateStatus,
    ));
  }

  /// Make a PUT request
  Future<AxiosResponse<T>> put<T>(
    String url, {
    RequestData? data,
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ProgressCallback? onUploadProgress,
    ProgressCallback? onDownloadProgress,
    ValidateStatus? validateStatus,
    List<TransformResponse>? transformResponse,
  }) {
    return request<T>(RequestOptions(
      url: url,
      method: HttpMethod.put,
      data: data,
      params: params,
      headers: headers,
      timeout: timeout,
      onUploadProgress: onUploadProgress,
      onDownloadProgress: onDownloadProgress,
      validateStatus: validateStatus,
    ));
  }

  /// Make a PATCH request
  Future<AxiosResponse<T>> patch<T>(
    String url, {
    RequestData? data,
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ProgressCallback? onUploadProgress,
    ProgressCallback? onDownloadProgress,
    ValidateStatus? validateStatus,
    List<TransformResponse>? transformResponse,
  }) {
    return request<T>(RequestOptions(
      url: url,
      method: HttpMethod.patch,
      data: data,
      params: params,
      headers: headers,
      timeout: timeout,
      onUploadProgress: onUploadProgress,
      onDownloadProgress: onDownloadProgress,
      validateStatus: validateStatus,
    ));
  }

  /// Make a DELETE request
  Future<AxiosResponse<T>> delete<T>(
    String url, {
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ValidateStatus? validateStatus,
    List<TransformResponse>? transformResponse,
  }) {
    return request<T>(RequestOptions(
      url: url,
      method: HttpMethod.delete,
      params: params,
      headers: headers,
      timeout: timeout,
      validateStatus: validateStatus,
    ));
  }

  /// Make a HEAD request
  Future<AxiosResponse<T>> head<T>(
    String url, {
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ValidateStatus? validateStatus,
  }) {
    return request<T>(RequestOptions(
      url: url,
      method: HttpMethod.head,
      params: params,
      headers: headers,
      timeout: timeout,
      validateStatus: validateStatus,
    ));
  }

  /// Make a request with the given options
  Future<AxiosResponse<T>> request<T>(RequestOptions options) async {
    try {
      // Create the request
      var request = AxiosRequest.fromOptions(options, baseURL: config.baseURL);
      
      // Apply config defaults
      request = _applyConfigDefaults(request);
      
      // Process through request interceptors
      request = await _interceptors.processRequest(request);
      
      // Execute the request
      final response = await _executeRequest<T>(request);
      
      // Process through response interceptors
      final processedResponse = await _interceptors.processResponse(response);
      
      return processedResponse as AxiosResponse<T>;
    } catch (error) {
      AxiosError axiosError;
      
      if (error is AxiosError) {
        axiosError = error;
      } else if (error is TimeoutException) {
        axiosError = AxiosError.timeout(
          message: 'Request timeout',
          request: AxiosRequest.fromOptions(options, baseURL: config.baseURL),
          cause: error,
        );
      } else if (error is SocketException) {
        axiosError = AxiosError.network(
          message: 'Network error: ${error.message}',
          request: AxiosRequest.fromOptions(options, baseURL: config.baseURL),
          cause: error,
        );
      } else {
        axiosError = AxiosError.unknown(
          message: 'Unknown error: $error',
          request: AxiosRequest.fromOptions(options, baseURL: config.baseURL),
          cause: error,
        );
      }
      
      // Process through error interceptors
      await _interceptors.processError(axiosError);
      
      throw axiosError;
    }
  }

  /// Apply config defaults to the request
  AxiosRequest _applyConfigDefaults(AxiosRequest request) {
    final mergedHeaders = <String, String>{};
    
    // Add config headers
    if (config.headers != null) {
      mergedHeaders.addAll(config.headers!);
    }
    
    // Add request headers (they override config headers)
    mergedHeaders.addAll(request.headers);
    
    // Merge params
    final mergedParams = <String, dynamic>{};
    if (config.params != null) {
      mergedParams.addAll(config.params!);
    }
    if (request.params != null) {
      mergedParams.addAll(request.params!);
    }
    
    return request.copyWith(
      headers: mergedHeaders,
      params: mergedParams.isNotEmpty ? mergedParams : null,
      timeout: request.timeout ?? config.timeout,
      validateStatus: request.validateStatus ?? config.validateStatus,
    );
  }

  /// Execute the HTTP request
  Future<AxiosResponse<T>> _executeRequest<T>(AxiosRequest request) async {
    final uri = _buildUri(request);
    final headers = Map<String, String>.from(request.headers);
    
    // Set default content type for requests with body
    if (_hasBody(request.method) && request.data != null) {
      headers.putIfAbsent('content-type', () => 'application/json');
    }

    http.Response httpResponse;
    final timeout = request.timeout ?? config.timeout;

    try {
      Future<http.Response> requestFuture;
      
      switch (request.method) {
        case HttpMethod.get:
          requestFuture = _client.get(uri, headers: headers);
          break;
        case HttpMethod.post:
          requestFuture = _client.post(
            uri,
            headers: headers,
            body: _encodeBody(request.data, headers),
          );
          break;
        case HttpMethod.put:
          requestFuture = _client.put(
            uri,
            headers: headers,
            body: _encodeBody(request.data, headers),
          );
          break;
        case HttpMethod.patch:
          requestFuture = _client.patch(
            uri,
            headers: headers,
            body: _encodeBody(request.data, headers),
          );
          break;
        case HttpMethod.delete:
          requestFuture = _client.delete(uri, headers: headers);
          break;
        case HttpMethod.head:
          requestFuture = _client.head(uri, headers: headers);
          break;
        case HttpMethod.options:
          // HTTP client doesn't have options method, use send
          final req = http.Request('OPTIONS', uri);
          req.headers.addAll(headers);
          final streamedResponse = await _client.send(req);
          requestFuture = http.Response.fromStream(streamedResponse);
          break;
      }

      if (timeout != null) {
        httpResponse = await requestFuture.timeout(timeout);
      } else {
        httpResponse = await requestFuture;
      }
    } on TimeoutException {
      throw AxiosError.timeout(
        message: 'Request timeout after ${timeout?.inMilliseconds}ms',
        request: request,
      );
    } on SocketException catch (e) {
      throw AxiosError.network(
        message: 'Network error: ${e.message}',
        request: request,
        cause: e,
      );
    }

    // Create the response
    final responseHeaders = <String, String>{};
    httpResponse.headers.forEach((key, value) {
      responseHeaders[key.toLowerCase()] = value;
    });

    final data = _parseResponseData<T>(httpResponse.body, responseHeaders);
    
    final response = AxiosResponse<T>(
      data: data,
      status: httpResponse.statusCode,
      statusText: httpResponse.reasonPhrase ?? '',
      headers: responseHeaders,
      request: request,
      rawData: httpResponse.body,
    );

    // Validate status
    final validateStatus = request.validateStatus ?? config.validateStatus ?? AxiosConfig.defaultValidateStatus;
    if (!validateStatus(response.status)) {
      throw AxiosError.response(
        message: 'Request failed with status ${response.status}',
        response: response,
        request: request,
      );
    }

    return response;
  }

  /// Build URI from request
  Uri _buildUri(AxiosRequest request) {
    final url = request.fullUrl;
    final uri = Uri.parse(url);
    
    if (request.params == null || request.params!.isEmpty) {
      return uri;
    }
    
    final queryParams = <String, String>{};
    request.params!.forEach((key, value) {
      queryParams[key] = value.toString();
    });
    
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });
  }

  /// Encode request body
  String? _encodeBody(RequestData? data, Headers headers) {
    if (data == null) return null;
    
    final contentType = headers['content-type']?.toLowerCase() ?? 'application/json';
    
    if (data is String) {
      return data;
    }
    
    if (contentType.contains('application/json')) {
      return jsonEncode(data);
    }
    
    if (contentType.contains('application/x-www-form-urlencoded')) {
      if (data is Map<String, dynamic>) {
        return data.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
      }
    }
    
    return data.toString();
  }

  /// Parse response data
  T _parseResponseData<T>(String body, Headers headers) {
    if (body.isEmpty) {
      return null as T;
    }
    
    final contentType = headers['content-type']?.toLowerCase() ?? '';
    
    if (contentType.contains('application/json')) {
      try {
        final decoded = jsonDecode(body);
        // If T is dynamic, return decoded as is
        if (T == dynamic) {
          return decoded as T;
        }
        // Try to cast to T, fallback to body if cast fails
        try {
          return decoded as T;
        } catch (e) {
          return body as T;
        }
      } catch (e) {
        return body as T;
      }
    }
    
    return body as T;
  }

  /// Check if method can have a body
  bool _hasBody(HttpMethod method) {
    return method == HttpMethod.post ||
           method == HttpMethod.put ||
           method == HttpMethod.patch;
  }

  /// Create a new instance with merged configuration
  AxiosInstance copyWith({AxiosConfig? config}) {
    return AxiosInstance(
      config: this.config.merge(config),
      client: _client,
    );
  }

  /// Close the HTTP client
  void close() {
    _client.close();
  }
}
