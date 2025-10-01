import 'dart:convert';

import 'package:flutter_axios/flutter_axios.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'flutter_axios_test.mocks.dart';

// Generate mocks for http.Client
@GenerateMocks([http.Client])
void main() {
  group('AxiosInstance', () {
    late MockClient mockClient;
    late AxiosInstance axios;

    setUp(() {
      mockClient = MockClient();
      axios = AxiosInstance(
        config: const AxiosConfig(
          baseURL: 'https://api.example.com',
          timeout: Duration(seconds: 5),
        ),
        client: mockClient,
      );
    });

    group('GET requests', () {
      test('should make successful GET request', () async {
        // Arrange
        final responseBody = '{"message": "success"}';
        when(mockClient.get(
          Uri.parse('https://api.example.com/users'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final response = await axios.get('/users');

        // Assert
        expect(response.status, 200);
        expect(response.data, contains('success'));
        verify(mockClient.get(
          Uri.parse('https://api.example.com/users'),
          headers: anyNamed('headers'),
        )).called(1);
      });

      test('should handle GET request with query parameters', () async {
        // Arrange
        final responseBody = '{"users": []}';
        when(mockClient.get(
          Uri.parse('https://api.example.com/users?page=1&limit=10'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final response = await axios.get('/users', params: {
          'page': 1,
          'limit': 10,
        });

        // Assert
        expect(response.status, 200);
        expect(response.data, contains('users'));
      });

      test('should throw AxiosError on HTTP error status', () async {
        // Arrange
        when(mockClient.get(
          Uri.parse('https://api.example.com/users/999'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        // Act & Assert
        expect(
          () async => await axios.get('/users/999'),
          throwsA(isA<AxiosError>()),
        );
      });
    });

    group('POST requests', () {
      test('should make successful POST request with JSON data', () async {
        // Arrange
        final requestData = {'name': 'John', 'email': 'john@example.com'};
        final responseBody =
            '{"id": 1, "name": "John", "email": "john@example.com"}';

        when(mockClient.post(
          Uri.parse('https://api.example.com/users'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(responseBody, 201));

        // Act
        final response = await axios.post('/users', data: requestData);

        // Assert
        expect(response.status, 201);
        expect(response.data, contains('John'));

        // Verify the request was made with correct JSON body
        verify(mockClient.post(
          Uri.parse('https://api.example.com/users'),
          headers: argThat(
            contains('content-type'),
            named: 'headers',
          ),
          body: jsonEncode(requestData),
        )).called(1);
      });
    });

    group('PUT requests', () {
      test('should make successful PUT request', () async {
        // Arrange
        final requestData = {'name': 'John Updated'};
        final responseBody = '{"id": 1, "name": "John Updated"}';

        when(mockClient.put(
          Uri.parse('https://api.example.com/users/1'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final response = await axios.put('/users/1', data: requestData);

        // Assert
        expect(response.status, 200);
        expect(response.data, contains('John Updated'));
      });
    });

    group('DELETE requests', () {
      test('should make successful DELETE request', () async {
        // Arrange
        when(mockClient.delete(
          Uri.parse('https://api.example.com/users/1'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 204));

        // Act
        final response = await axios.delete('/users/1');

        // Assert
        expect(response.status, 204);
      });
    });

    group('Error handling', () {
      test('should handle network errors', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () async => await axios.get('/users'),
          throwsA(isA<AxiosError>()),
        );
      });

      test('should handle timeout errors', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('TimeoutException'));

        // Act & Assert
        expect(
          () async => await axios.get('/users'),
          throwsA(isA<AxiosError>()),
        );
      });
    });

    group('Configuration', () {
      test('should merge config with request options', () async {
        // Arrange
        final axios = AxiosInstance(
          config: const AxiosConfig(
            baseURL: 'https://api.example.com',
            headers: {'Authorization': 'Bearer token'},
            params: {'version': 'v1'},
          ),
          client: mockClient,
        );

        when(mockClient.get(
          Uri.parse('https://api.example.com/users?version=v1&page=1'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await axios.get('/users', params: {'page': 1});

        // Assert
        verify(mockClient.get(
          Uri.parse('https://api.example.com/users?version=v1&page=1'),
          headers: anyNamed('headers'),
        )).called(1);
      });
    });
  });

  group('AxiosConfig', () {
    test('should create config with default values', () {
      const config = AxiosConfig();
      expect(config.baseURL, isNull);
      expect(config.timeout, isNull);
      expect(config.headers, isNull);
    });

    test('should create config with custom values', () {
      const config = AxiosConfig(
        baseURL: 'https://api.example.com',
        timeout: Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      );

      expect(config.baseURL, 'https://api.example.com');
      expect(config.timeout, const Duration(seconds: 10));
      expect(config.headers, {'Content-Type': 'application/json'});
    });

    test('should merge configs correctly', () {
      const config1 = AxiosConfig(
        baseURL: 'https://api.example.com',
        headers: {'Authorization': 'Bearer token'},
      );

      const config2 = AxiosConfig(
        timeout: Duration(seconds: 5),
        headers: {'Content-Type': 'application/json'},
      );

      final merged = config1.merge(config2);

      expect(merged.baseURL, 'https://api.example.com');
      expect(merged.timeout, const Duration(seconds: 5));
      expect(merged.headers, {
        'Authorization': 'Bearer token',
        'Content-Type': 'application/json',
      });
    });
  });

  group('AxiosError', () {
    test('should create timeout error', () {
      final request = AxiosRequest(
        method: HttpMethod.get,
        url: 'https://api.example.com/users',
      );

      final error = AxiosError.timeout(
        message: 'Request timeout',
        request: request,
      );

      expect(error.type, AxiosErrorType.timeout);
      expect(error.message, 'Request timeout');
      expect(error.request, request);
    });

    test('should create network error', () {
      final request = AxiosRequest(
        method: HttpMethod.get,
        url: 'https://api.example.com/users',
      );

      final error = AxiosError.network(
        message: 'Network error',
        request: request,
      );

      expect(error.type, AxiosErrorType.network);
      expect(error.message, 'Network error');
      expect(error.request, request);
    });

    test('should create response error', () {
      final request = AxiosRequest(
        method: HttpMethod.get,
        url: 'https://api.example.com/users',
      );

      final response = AxiosResponse<dynamic>(
        data: 'Not Found',
        status: 404,
        statusText: 'Not Found',
        headers: {},
        request: request,
        rawData: 'Not Found',
      );

      final error = AxiosError.response(
        message: 'Request failed',
        response: response,
        request: request,
      );

      expect(error.type, AxiosErrorType.response);
      expect(error.message, 'Request failed');
      expect(error.response, response);
    });
  });
}
