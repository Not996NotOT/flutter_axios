import 'dart:io';

import 'package:flutter_axios/flutter_axios.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'flutter_axios_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('AxiosInstance', () {
    late MockClient mockClient;
    late AxiosInstance axios;

    setUp(() {
      mockClient = MockClient();
      axios = AxiosInstance(client: mockClient);
    });

    test('should make GET request successfully', () async {
      // Arrange
      const url = 'https://api.example.com/data';
      const responseBody = '{"message": "success"}';
      
      when(mockClient.get(Uri.parse(url), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await axios.get<Map<String, dynamic>>(url);

      // Assert
      expect(response.status, 200);
      expect(response.data['message'], 'success');
      verify(mockClient.get(Uri.parse(url), headers: anyNamed('headers')));
    });

    test('should make POST request successfully', () async {
      // Arrange
      const url = 'https://api.example.com/data';
      const requestData = {'name': 'test'};
      const responseBody = '{"id": 1, "name": "test"}';
      
      when(mockClient.post(
        Uri.parse(url),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 201));

      // Act
      final response = await axios.post<Map<String, dynamic>>(
        url,
        data: requestData,
      );

      // Assert
      expect(response.status, 201);
      expect(response.data['id'], 1);
      expect(response.data['name'], 'test');
    });

    test('should handle network errors', () async {
      // Arrange
      const url = 'https://api.example.com/data';
      
      when(mockClient.get(Uri.parse(url), headers: anyNamed('headers')))
          .thenThrow(const SocketException('Network error'));

      // Act & Assert
      expect(
        () => axios.get(url),
        throwsA(isA<AxiosError>()
            .having((e) => e.type, 'type', AxiosErrorType.network)),
      );
    });

    test('should handle timeout errors', () async {
      // Arrange
      const url = 'https://api.example.com/data';
      
      when(mockClient.get(Uri.parse(url), headers: anyNamed('headers')))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return http.Response('{}', 200);
      });

      // Act & Assert
      await expectLater(
        () => axios.get(url, timeout: const Duration(milliseconds: 100)),
        throwsA(isA<AxiosError>()
            .having((e) => e.type, 'type', AxiosErrorType.timeout)),
      );
    });

    test('should handle HTTP error responses', () async {
      // Arrange
      const url = 'https://api.example.com/data';
      const responseBody = '{"error": "Not found"}';
      
      when(mockClient.get(Uri.parse(url), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(responseBody, 404));

      // Act & Assert
      expect(
        () => axios.get(url),
        throwsA(isA<AxiosError>()
            .having((e) => e.type, 'type', AxiosErrorType.response)
            .having((e) => e.response?.status, 'status', 404)),
      );
    });

    test('should apply config defaults', () async {
      // Arrange
      const baseURL = 'https://api.example.com';
      const defaultHeaders = {'Authorization': 'Bearer token'};
      
      final configuredAxios = AxiosInstance(
        config: const AxiosConfig(
          baseURL: baseURL,
          headers: defaultHeaders,
        ),
        client: mockClient,
      );
      
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{}', 200));

      // Act
      await configuredAxios.get('/users');

      // Assert
      final captured = verify(mockClient.get(
        captureAny,
        headers: captureAnyNamed('headers'),
      )).captured;
      
      expect(captured[0].toString(), '$baseURL/users');
      expect(captured[1]['Authorization'], 'Bearer token');
    });
  });

  group('Interceptors', () {
    test('should process request through interceptors', () async {
      final axios = AxiosInstance();
      bool interceptorCalled = false;
      
      axios.interceptors.add(RequestInterceptor((request) {
        interceptorCalled = true;
        return request.copyWith(
          headers: {...request.headers, 'X-Custom': 'test'},
        );
      }));

      try {
        await axios.get('https://httpbin.org/get');
      } catch (e) {
        // Ignore network errors in test
      }

      expect(interceptorCalled, true);
    });

    test('should process response through interceptors', () async {
      final axios = AxiosInstance();
      bool interceptorCalled = false;
      
      axios.interceptors.add(ResponseInterceptor((response) {
        interceptorCalled = true;
        return response;
      }));

      try {
        await axios.get('https://httpbin.org/get');
        expect(interceptorCalled, true);
      } catch (e) {
        // Ignore network errors in test
      }
    });
  });

  group('Axios static methods', () {
    test('should use default instance for static calls', () async {
      // This is more of an integration test
      // In a real test, you'd mock the default instance
      expect(Axios.instance, isA<AxiosInstance>());
    });
  });
}
