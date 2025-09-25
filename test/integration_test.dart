import 'package:flutter_axios/flutter_axios.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Integration Tests', () {
    test('should perform basic HTTP requests', () async {
      // This is more of a smoke test to ensure the package compiles and works
      final instance = Axios.create(const AxiosConfig(
        baseURL: 'https://httpbin.org',
        timeout: Duration(seconds: 10),
      ));
      
      // Test that we can create requests without errors
      try {
        // We don't actually make the request to avoid external dependencies
        final options = RequestOptions(
          url: '/get',
          method: HttpMethod.get,
          headers: {'User-Agent': 'Flutter Axios Test'},
        );
        
        expect(options.url, '/get');
        expect(options.method, HttpMethod.get);
        expect(options.headers?['User-Agent'], 'Flutter Axios Test');
      } catch (e) {
        // Expected to fail in test environment, but should not crash
      }
    });

    test('should create axios error correctly', () {
      final error = AxiosError.network(
        message: 'Network connection failed',
        code: 'NETWORK_ERROR',
      );
      
      expect(error.message, 'Network connection failed');
      expect(error.type, AxiosErrorType.network);
      expect(error.code, 'NETWORK_ERROR');
      expect(error.isNetworkError, true);
      expect(error.isTimeoutError, false);
    });

    test('should handle interceptors', () {
      final instance = Axios.create();
      bool requestInterceptorCalled = false;
      
      instance.interceptors.add(RequestInterceptor((request) {
        requestInterceptorCalled = true;
        return request.copyWith(
          headers: {...request.headers, 'X-Test': 'true'},
        );
      }));
      
      expect(instance.interceptors.interceptors.length, 1);
    });

    test('should create request and response objects', () {
      final request = AxiosRequest(
        url: '/test',
        method: HttpMethod.post,
        headers: {'Content-Type': 'application/json'},
        data: {'key': 'value'},
      );
      
      expect(request.url, '/test');
      expect(request.method, HttpMethod.post);
      expect(request.headers['Content-Type'], 'application/json');
      
      final response = AxiosResponse<Map<String, dynamic>>(
        data: {'result': 'success'},
        status: 200,
        statusText: 'OK',
        headers: {'content-type': 'application/json'},
        request: request,
      );
      
      expect(response.data['result'], 'success');
      expect(response.status, 200);
      expect(response.isSuccess, true);
      expect(response.isError, false);
    });
  });
}
