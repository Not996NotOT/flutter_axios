import '../types/types.dart';

/// Options for making HTTP requests
class RequestOptions {
  /// Request URL
  final String url;

  /// HTTP method
  final HttpMethod method;

  /// Request data/body
  final RequestData? data;

  /// Query parameters
  final QueryParameters? params;

  /// Request headers
  final Headers? headers;

  /// Request timeout
  final Duration? timeout;

  /// Progress callback for uploads
  final ProgressCallback? onUploadProgress;

  /// Progress callback for downloads
  final ProgressCallback? onDownloadProgress;

  /// Whether to follow redirects
  final bool? followRedirects;

  /// Maximum number of redirects
  final int? maxRedirects;

  /// Response type expected
  final String? responseType;

  /// Custom validator for status codes
  final ValidateStatus? validateStatus;

  const RequestOptions({
    required this.url,
    this.method = HttpMethod.get,
    this.data,
    this.params,
    this.headers,
    this.timeout,
    this.onUploadProgress,
    this.onDownloadProgress,
    this.followRedirects,
    this.maxRedirects,
    this.responseType,
    this.validateStatus,
  });

  /// Create a copy with some values replaced
  RequestOptions copyWith({
    String? url,
    HttpMethod? method,
    RequestData? data,
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ProgressCallback? onUploadProgress,
    ProgressCallback? onDownloadProgress,
    bool? followRedirects,
    int? maxRedirects,
    String? responseType,
    ValidateStatus? validateStatus,
  }) {
    return RequestOptions(
      url: url ?? this.url,
      method: method ?? this.method,
      data: data ?? this.data,
      params: params ?? this.params,
      headers: headers ?? this.headers,
      timeout: timeout ?? this.timeout,
      onUploadProgress: onUploadProgress ?? this.onUploadProgress,
      onDownloadProgress: onDownloadProgress ?? this.onDownloadProgress,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      responseType: responseType ?? this.responseType,
      validateStatus: validateStatus ?? this.validateStatus,
    );
  }

  @override
  String toString() {
    return 'RequestOptions{url: $url, method: $method, headers: $headers}';
  }
}
