import 'axios_request.dart';
import 'types/types.dart';

/// Represents an HTTP response in the Axios style
class AxiosResponse<T> {
  /// Response data (parsed)
  final T data;
  
  /// HTTP status code
  final int status;
  
  /// HTTP status message
  final String statusText;
  
  /// Response headers
  final Headers headers;
  
  /// The request configuration that produced this response
  final AxiosRequest request;
  
  /// Raw response data (before parsing)
  final String? rawData;

  const AxiosResponse({
    required this.data,
    required this.status,
    required this.statusText,
    required this.headers,
    required this.request,
    this.rawData,
  });

  /// Whether the response indicates success
  bool get isSuccess => status >= 200 && status < 300;

  /// Whether the response indicates a client error
  bool get isClientError => status >= 400 && status < 500;

  /// Whether the response indicates a server error  
  bool get isServerError => status >= 500;

  /// Whether the response indicates an error
  bool get isError => status >= 400;

  /// Create a copy with some values replaced
  AxiosResponse<T> copyWith({
    T? data,
    int? status,
    String? statusText,
    Headers? headers,
    AxiosRequest? request,
    String? rawData,
  }) {
    return AxiosResponse<T>(
      data: data ?? this.data,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      headers: headers ?? this.headers,
      request: request ?? this.request,
      rawData: rawData ?? this.rawData,
    );
  }

  @override
  String toString() {
    return 'AxiosResponse{status: $status, statusText: $statusText, data: $data}';
  }
}
