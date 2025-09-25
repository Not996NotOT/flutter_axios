import 'axios_config.dart';
import 'axios_instance.dart';
import 'axios_response.dart';
import 'interceptors/interceptor.dart';
import 'models/request_options.dart';
import 'types/types.dart';

/// Global Axios instance and convenience methods
class Axios {
  static final AxiosInstance _defaultInstance = AxiosInstance();

  /// Get the default instance
  static AxiosInstance get instance => _defaultInstance;

  /// Get interceptors manager for the default instance
  static InterceptorManager get interceptors => _defaultInstance.interceptors;

  /// Create a new Axios instance with custom configuration
  static AxiosInstance create([AxiosConfig? config]) {
    return AxiosInstance(config: config);
  }

  /// Make a GET request using the default instance
  static Future<AxiosResponse<T>> get<T>(
    String url, {
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ProgressCallback? onDownloadProgress,
    ValidateStatus? validateStatus,
  }) {
    return _defaultInstance.get<T>(
      url,
      params: params,
      headers: headers,
      timeout: timeout,
      onDownloadProgress: onDownloadProgress,
      validateStatus: validateStatus,
    );
  }

  /// Make a POST request using the default instance
  static Future<AxiosResponse<T>> post<T>(
    String url, {
    RequestData? data,
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ProgressCallback? onUploadProgress,
    ProgressCallback? onDownloadProgress,
    ValidateStatus? validateStatus,
  }) {
    return _defaultInstance.post<T>(
      url,
      data: data,
      params: params,
      headers: headers,
      timeout: timeout,
      onUploadProgress: onUploadProgress,
      onDownloadProgress: onDownloadProgress,
      validateStatus: validateStatus,
    );
  }

  /// Make a PUT request using the default instance
  static Future<AxiosResponse<T>> put<T>(
    String url, {
    RequestData? data,
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ProgressCallback? onUploadProgress,
    ProgressCallback? onDownloadProgress,
    ValidateStatus? validateStatus,
  }) {
    return _defaultInstance.put<T>(
      url,
      data: data,
      params: params,
      headers: headers,
      timeout: timeout,
      onUploadProgress: onUploadProgress,
      onDownloadProgress: onDownloadProgress,
      validateStatus: validateStatus,
    );
  }

  /// Make a PATCH request using the default instance
  static Future<AxiosResponse<T>> patch<T>(
    String url, {
    RequestData? data,
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ProgressCallback? onUploadProgress,
    ProgressCallback? onDownloadProgress,
    ValidateStatus? validateStatus,
  }) {
    return _defaultInstance.patch<T>(
      url,
      data: data,
      params: params,
      headers: headers,
      timeout: timeout,
      onUploadProgress: onUploadProgress,
      onDownloadProgress: onDownloadProgress,
      validateStatus: validateStatus,
    );
  }

  /// Make a DELETE request using the default instance
  static Future<AxiosResponse<T>> delete<T>(
    String url, {
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ValidateStatus? validateStatus,
  }) {
    return _defaultInstance.delete<T>(
      url,
      params: params,
      headers: headers,
      timeout: timeout,
      validateStatus: validateStatus,
    );
  }

  /// Make a HEAD request using the default instance
  static Future<AxiosResponse<T>> head<T>(
    String url, {
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    ValidateStatus? validateStatus,
  }) {
    return _defaultInstance.head<T>(
      url,
      params: params,
      headers: headers,
      timeout: timeout,
      validateStatus: validateStatus,
    );
  }

  /// Make a request using the default instance
  static Future<AxiosResponse<T>> request<T>(RequestOptions options) {
    return _defaultInstance.request<T>(options);
  }
}
