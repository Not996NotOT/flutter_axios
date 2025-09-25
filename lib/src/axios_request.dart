import 'models/request_options.dart';
import 'types/types.dart';

/// Represents an HTTP request in the Axios style
class AxiosRequest {
  /// Request URL (can be relative or absolute)
  final String url;

  /// HTTP method
  final HttpMethod method;

  /// Request headers
  final Headers headers;

  /// Query parameters
  final QueryParameters? params;

  /// Request body data
  final RequestData? data;

  /// Request timeout
  final Duration? timeout;

  /// Base URL for resolving relative URLs
  final String? baseURL;

  /// Upload progress callback
  final ProgressCallback? onUploadProgress;

  /// Download progress callback
  final ProgressCallback? onDownloadProgress;

  /// Custom status validator
  final ValidateStatus? validateStatus;

  /// Whether to follow redirects
  final bool followRedirects;

  /// Maximum redirects to follow
  final int maxRedirects;

  /// Expected response type
  final String? responseType;

  const AxiosRequest({
    required this.url,
    required this.method,
    this.headers = const {},
    this.params,
    this.data,
    this.timeout,
    this.baseURL,
    this.onUploadProgress,
    this.onDownloadProgress,
    this.validateStatus,
    this.followRedirects = true,
    this.maxRedirects = 5,
    this.responseType,
  });

  /// Create request from RequestOptions
  factory AxiosRequest.fromOptions(RequestOptions options, {String? baseURL}) {
    return AxiosRequest(
      url: options.url,
      method: options.method,
      headers: options.headers ?? {},
      params: options.params,
      data: options.data,
      timeout: options.timeout,
      baseURL: baseURL,
      onUploadProgress: options.onUploadProgress,
      onDownloadProgress: options.onDownloadProgress,
      validateStatus: options.validateStatus,
      followRedirects: options.followRedirects ?? true,
      maxRedirects: options.maxRedirects ?? 5,
      responseType: options.responseType,
    );
  }

  /// Get the full URL by combining baseURL and url
  String get fullUrl {
    if (baseURL == null || url.startsWith('http')) {
      return url;
    }

    final base = baseURL!.endsWith('/')
        ? baseURL!.substring(0, baseURL!.length - 1)
        : baseURL!;
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
  }

  /// Create a copy with some values replaced
  AxiosRequest copyWith({
    String? url,
    HttpMethod? method,
    Headers? headers,
    QueryParameters? params,
    RequestData? data,
    Duration? timeout,
    String? baseURL,
    ProgressCallback? onUploadProgress,
    ProgressCallback? onDownloadProgress,
    ValidateStatus? validateStatus,
    bool? followRedirects,
    int? maxRedirects,
    String? responseType,
  }) {
    return AxiosRequest(
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      params: params ?? this.params,
      data: data ?? this.data,
      timeout: timeout ?? this.timeout,
      baseURL: baseURL ?? this.baseURL,
      onUploadProgress: onUploadProgress ?? this.onUploadProgress,
      onDownloadProgress: onDownloadProgress ?? this.onDownloadProgress,
      validateStatus: validateStatus ?? this.validateStatus,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      responseType: responseType ?? this.responseType,
    );
  }

  @override
  String toString() {
    return 'AxiosRequest{method: $method, url: $fullUrl, headers: $headers}';
  }
}
