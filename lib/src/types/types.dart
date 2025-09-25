import 'dart:async';

import '../axios_request.dart';
import '../axios_response.dart';

/// HTTP methods supported by Axios
enum HttpMethod {
  /// GET method for retrieving data
  get,
  /// POST method for creating data
  post,
  /// PUT method for updating data
  put,
  /// PATCH method for partial updates
  patch,
  /// DELETE method for removing data
  delete,
  /// HEAD method for retrieving headers only
  head,
  /// OPTIONS method for retrieving allowed methods
  options,
}

/// Request interceptor function type
typedef RequestInterceptorFunction = FutureOr<AxiosRequest> Function(AxiosRequest request);

/// Response interceptor function type
typedef ResponseInterceptorFunction = FutureOr<AxiosResponse<dynamic>> Function(AxiosResponse<dynamic> response);

/// Error interceptor function type
typedef ErrorInterceptorFunction = FutureOr<void> Function(dynamic error);

/// Request data type - can be String, Map, List, or any JSON-serializable object
typedef RequestData = dynamic;

/// Response data type - typically parsed JSON
typedef ResponseData = dynamic;

/// Headers type
typedef Headers = Map<String, String>;

/// Query parameters type
typedef QueryParameters = Map<String, dynamic>;

/// Transform request function type
typedef TransformRequest = RequestData Function(RequestData data, Headers headers);

/// Transform response function type  
typedef TransformResponse = ResponseData Function(ResponseData data, Headers headers);

/// Progress callback for uploads/downloads
typedef ProgressCallback = void Function(int count, int total);

/// Validator function for response status codes
typedef ValidateStatus = bool Function(int? status);
