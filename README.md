# Flutter Axios

A promise-based HTTP client for Flutter inspired by [Axios](https://axios-http.com/). Provides interceptors, request/response transformation, error handling, and more.

[![pub package](https://img.shields.io/pub/v/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)

## Features

- ✅ Promise-based API similar to Axios
- ✅ Request and response interceptors  
- ✅ Request and response transformation
- ✅ Automatic request body serialization (JSON, form data)
- ✅ Automatic response data parsing
- ✅ Error handling with detailed error types
- ✅ Request/response timeout support
- ✅ Query parameters serialization
- ✅ Custom instance creation with base configuration
- ✅ Progress callbacks for uploads/downloads
- ✅ Request cancellation support

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_axios: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

Performing a `GET` request (similar to [Axios example](https://axios-http.com/docs/example)):

```dart
import 'package:flutter_axios/flutter_axios.dart';

// Make a request for a user with a given ID
try {
  final response = await Axios.get<Map<String, dynamic>>(
    'https://jsonplaceholder.typicode.com/users/1'
  );
  // handle success
  print(response.data);
} catch (error) {
  // handle error
  print(error);
}

// Optionally the request above could also be done as
try {
  final response = await Axios.get<List<dynamic>>(
    'https://jsonplaceholder.typicode.com/users',
    params: {
      'id': 1,
      '_limit': 1,
    },
  );
  print(response.data);
} catch (error) {
  print(error);
} finally {
  // always executed
  print('Request completed');
}

// Want to use async/await? Here's how:
Future<void> getUser() async {
  try {
    final response = await Axios.get<Map<String, dynamic>>(
      'https://jsonplaceholder.typicode.com/users/1'
    );
    print(response.data);
  } catch (error) {
    print(error);
  }
}
```

### Creating an Instance

```dart
final api = Axios.create(const AxiosConfig(
  baseURL: 'https://api.example.com',
  timeout: Duration(seconds: 30),
  headers: {
    'Authorization': 'Bearer your-token',
    'Content-Type': 'application/json',
  },
));

// Use the instance
final response = await api.get<List<dynamic>>('/users');
```

## API Reference

### Axios Class

The main class providing static methods for common HTTP operations:

```dart
// GET request
Future<AxiosResponse<T>> Axios.get<T>(String url, {
  QueryParameters? params,
  Headers? headers,
  Duration? timeout,
  ProgressCallback? onDownloadProgress,
  ValidateStatus? validateStatus,
});

// POST request  
Future<AxiosResponse<T>> Axios.post<T>(String url, {
  RequestData? data,
  QueryParameters? params,
  Headers? headers,
  Duration? timeout,
  ProgressCallback? onUploadProgress,
  ProgressCallback? onDownloadProgress,
  ValidateStatus? validateStatus,
});

// PUT, PATCH, DELETE, HEAD methods also available
```

### AxiosInstance

Create custom instances with their own configuration:

```dart
final instance = Axios.create(AxiosConfig(
  baseURL: 'https://api.example.com',
  timeout: Duration(seconds: 10),
  headers: {'Authorization': 'Bearer token'},
));
```

### Request Options

Configure individual requests:

```dart
final response = await Axios.request<Map<String, dynamic>>(
  RequestOptions(
    url: '/users',
    method: HttpMethod.get,
    params: {'page': 1, 'limit': 10},
    headers: {'X-Custom-Header': 'value'},
    timeout: Duration(seconds: 5),
  ),
);
```

### Response Object

```dart
class AxiosResponse<T> {
  final T data;              // Parsed response data
  final int status;          // HTTP status code
  final String statusText;   // HTTP status message
  final Headers headers;     // Response headers
  final AxiosRequest request; // Original request
  final String? rawData;     // Raw response body
}
```

## Interceptors

### Request Interceptors

Modify requests before they are sent:

```dart
// Add authentication header
Axios.interceptors.add(AuthInterceptor(token: 'your-token'));

// Custom request interceptor
Axios.interceptors.add(RequestInterceptor((request) {
  print('Sending request to ${request.url}');
  return request.copyWith(
    headers: {...request.headers, 'X-Timestamp': DateTime.now().toString()},
  );
}));
```

### Response Interceptors

Process responses or handle errors:

```dart
// Logging interceptor
Axios.interceptors.add(LoggingResponseInterceptor(
  logger: (message) => print(message),
));

// Custom response interceptor
Axios.interceptors.add(ResponseInterceptor((response) {
  print('Received ${response.status} from ${response.request.url}');
  return response;
}));
```

### Built-in Interceptors

- `AuthInterceptor` - Adds authentication headers
- `HeadersInterceptor` - Adds custom headers
- `LoggingRequestInterceptor` - Logs requests
- `LoggingResponseInterceptor` - Logs responses
- `RetryInterceptor` - Retry failed requests

## Error Handling

Flutter Axios provides detailed error information:

```dart
try {
  final response = await Axios.get('/api/data');
  print(response.data);
} catch (error) {
  if (error is AxiosError) {
    switch (error.type) {
      case AxiosErrorType.network:
        print('Network error: ${error.message}');
        break;
      case AxiosErrorType.timeout:
        print('Request timeout');
        break;
      case AxiosErrorType.response:
        print('HTTP error: ${error.response?.status}');
        break;
      case AxiosErrorType.cancelled:
        print('Request cancelled');
        break;
      default:
        print('Unknown error: ${error.message}');
    }
  }
}
```

## Configuration

### Global Configuration

Configure the default instance:

```dart
// Access the default instance
final defaultInstance = Axios.instance;

// Add global interceptors
Axios.interceptors.add(LoggingRequestInterceptor(
  logger: (message) => debugPrint(message),
));
```

### Instance Configuration

```dart
final api = Axios.create(const AxiosConfig(
  baseURL: 'https://api.example.com',
  timeout: Duration(seconds: 30),
  headers: {
    'User-Agent': 'MyApp/1.0',
    'Accept': 'application/json',
  },
  validateStatus: (status) => status != null && status < 400,
));
```

## Examples

### File Upload with Progress

```dart
final response = await Axios.post<Map<String, dynamic>>(
  '/upload',
  data: formData,
  onUploadProgress: (count, total) {
    final progress = count / total;
    print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
  },
);
```

### Query Parameters

```dart
final response = await Axios.get<List<dynamic>>(
  '/users',
  params: {
    'page': 1,
    'limit': 20,
    'sort': 'name',
    'active': true,
  },
);
```

### Custom Headers

```dart
final response = await Axios.post<Map<String, dynamic>>(
  '/api/data',
  data: {'key': 'value'},
  headers: {
    'Authorization': 'Bearer token',
    'X-API-Key': 'api-key',
    'Content-Type': 'application/json',
  },
);
```

## Testing

Mock HTTP client for testing:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_axios/flutter_axios.dart';

void main() {
  test('should handle GET request', () async {
    final mockClient = MockClient();
    final axios = AxiosInstance(client: mockClient);
    
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('{"result": "success"}', 200));
    
    final response = await axios.get<Map<String, dynamic>>('/test');
    
    expect(response.data['result'], 'success');
  });
}
```

## Migration from http package

### Before (http package)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

final response = await http.get(
  Uri.parse('https://api.example.com/users'),
  headers: {'Authorization': 'Bearer token'},
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  print(data);
} else {
  throw Exception('Failed to load data');
}
```

### After (flutter_axios)

```dart
import 'package:flutter_axios/flutter_axios.dart';

final api = Axios.create(const AxiosConfig(
  baseURL: 'https://api.example.com',
  headers: {'Authorization': 'Bearer token'},
));

try {
  final response = await api.get<List<dynamic>>('/users');
  print(response.data);
} catch (error) {
  print('Error: $error');
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.
