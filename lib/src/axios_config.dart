import 'types/types.dart';

/// Configuration class for Axios instances
class AxiosConfig {
  /// Base URL for requests
  final String? baseURL;

  /// Timeout for requests in milliseconds
  final Duration? timeout;

  /// Default headers for all requests
  final Headers? headers;

  /// Default query parameters
  final QueryParameters? params;

  /// Request data transformation functions
  final List<TransformRequest>? transformRequest;

  /// Response data transformation functions
  final List<TransformResponse>? transformResponse;

  /// Function to validate response status codes
  final ValidateStatus? validateStatus;

  /// Maximum number of redirects to follow
  final int? maxRedirects;

  /// Whether to follow redirects
  final bool? followRedirects;

  /// Response type expected
  final String? responseType;

  /// Whether to include credentials
  final bool? withCredentials;

  /// Creates a new [AxiosConfig] with the specified options
  const AxiosConfig({
    this.baseURL,
    this.timeout,
    this.headers,
    this.params,
    this.transformRequest,
    this.transformResponse,
    this.validateStatus,
    this.maxRedirects,
    this.followRedirects,
    this.responseType,
    this.withCredentials,
  });

  /// Create a copy of this config with some values replaced
  AxiosConfig copyWith({
    String? baseURL,
    Duration? timeout,
    Headers? headers,
    QueryParameters? params,
    List<TransformRequest>? transformRequest,
    List<TransformResponse>? transformResponse,
    ValidateStatus? validateStatus,
    int? maxRedirects,
    bool? followRedirects,
    String? responseType,
    bool? withCredentials,
  }) {
    return AxiosConfig(
      baseURL: baseURL ?? this.baseURL,
      timeout: timeout ?? this.timeout,
      headers: headers ?? this.headers,
      params: params ?? this.params,
      transformRequest: transformRequest ?? this.transformRequest,
      transformResponse: transformResponse ?? this.transformResponse,
      validateStatus: validateStatus ?? this.validateStatus,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      followRedirects: followRedirects ?? this.followRedirects,
      responseType: responseType ?? this.responseType,
      withCredentials: withCredentials ?? this.withCredentials,
    );
  }

  /// Merge this config with another config
  AxiosConfig merge(AxiosConfig? other) {
    if (other == null) {
      return this;
    }

    return AxiosConfig(
      baseURL: other.baseURL ?? baseURL,
      timeout: other.timeout ?? timeout,
      headers: _mergeHeaders(headers, other.headers),
      params: _mergeParams(params, other.params),
      transformRequest: other.transformRequest ?? transformRequest,
      transformResponse: other.transformResponse ?? transformResponse,
      validateStatus: other.validateStatus ?? validateStatus,
      maxRedirects: other.maxRedirects ?? maxRedirects,
      followRedirects: other.followRedirects ?? followRedirects,
      responseType: other.responseType ?? responseType,
      withCredentials: other.withCredentials ?? withCredentials,
    );
  }

  static Headers? _mergeHeaders(Headers? base, Headers? override) {
    if (base == null && override == null) {
      return null;
    }
    if (base == null) {
      return Map.from(override!);
    }
    if (override == null) {
      return Map.from(base);
    }

    final merged = Map<String, String>.from(base);
    merged.addAll(override);
    return merged;
  }

  static QueryParameters? _mergeParams(
      QueryParameters? base, QueryParameters? override) {
    if (base == null && override == null) {
      return null;
    }
    if (base == null) {
      return Map.from(override!);
    }
    if (override == null) {
      return Map.from(base);
    }

    final merged = Map<String, dynamic>.from(base);
    merged.addAll(override);
    return merged;
  }

  /// Default validate status function
  static bool defaultValidateStatus(int? status) {
    return status != null && status >= 200 && status < 300;
  }
}
