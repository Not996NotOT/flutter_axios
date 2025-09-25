import '../types/types.dart';

/// Response data wrapper
class ResponseData {
  /// Response body data
  final dynamic data;
  
  /// HTTP status code
  final int status;
  
  /// Status text
  final String statusText;
  
  /// Response headers
  final Headers headers;
  
  /// Request configuration that produced this response
  final Map<String, dynamic>? config;

  const ResponseData({
    required this.data,
    required this.status,
    required this.statusText,
    required this.headers,
    this.config,
  });

  @override
  String toString() {
    return 'ResponseData{status: $status, statusText: $statusText, data: $data}';
  }
}
