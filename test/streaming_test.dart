import 'package:flutter_axios/flutter_axios.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

import 'streaming_test.mocks.dart';

// Generate mocks for http.Client
@GenerateMocks([http.Client])
void main() {
  group('Flutter Axios Streaming Features', () {
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

    group('Stream Types', () {
      test('should create SSEEvent correctly', () {
        final event = SSEEvent.now(
          id: 'test-id',
          event: 'message',
          data: 'test data',
          retry: 5000,
        );

        expect(event.id, 'test-id');
        expect(event.event, 'message');
        expect(event.data, 'test data');
        expect(event.retry, 5000);
        expect(event.timestamp, isA<DateTime>());
      });

      test('should create WebSocketMessage correctly', () {
        final message = WebSocketMessage.text('Hello WebSocket');

        expect(message.type, WebSocketMessageType.text);
        expect(message.data, 'Hello WebSocket');
        expect(message.timestamp, isA<DateTime>());
        expect(message.error, isNull);
      });

      test('should create DownloadProgress correctly', () {
        const progress = DownloadProgress(
          downloaded: 500,
          total: 1000,
          speed: 1024.0,
          remainingTime: 0.5,
        );

        expect(progress.downloaded, 500);
        expect(progress.total, 1000);
        expect(progress.progress, 0.5);
        expect(progress.progressPercent, 50.0);
        expect(progress.speed, 1024.0);
        expect(progress.remainingTime, 0.5);
      });

      test('should handle DownloadProgress without total', () {
        const progress = DownloadProgress(downloaded: 500);

        expect(progress.downloaded, 500);
        expect(progress.total, isNull);
        expect(progress.progress, isNull);
        expect(progress.progressPercent, isNull);
      });
    });

    group('SSE Client', () {
      test('should parse SSE events correctly', () {
        // 这个测试验证 SSE 事件解析逻辑
        final sseData = '''
data: {"message": "Hello World"}

event: custom
data: {"type": "custom", "payload": "test"}

id: 123
data: Simple message

''';

        // 模拟解析逻辑
        final lines = sseData.split('\n');
        final events = <Map<String, String>>[];

        String? currentId;
        String? currentEvent;
        String currentData = '';

        for (final line in lines) {
          if (line.isEmpty) {
            if (currentData.isNotEmpty) {
              events.add({
                'id': currentId ?? '',
                'event': currentEvent ?? 'message',
                'data': currentData.trim(),
              });
              currentData = '';
              currentId = null;
              currentEvent = null;
            }
          } else if (line.startsWith('data:')) {
            currentData += line.substring(5) + '\n';
          } else if (line.startsWith('id:')) {
            currentId = line.substring(3).trim();
          } else if (line.startsWith('event:')) {
            currentEvent = line.substring(6).trim();
          }
        }

        expect(events.length, 3);
        expect(events[0]['event'], 'message');
        expect(events[0]['data'], '{"message": "Hello World"}');
        expect(events[1]['event'], 'custom');
        expect(events[1]['data'], '{"type": "custom", "payload": "test"}');
        expect(events[2]['id'], '123');
        expect(events[2]['data'], 'Simple message');
      });

      test('should create SSEOptions with default values', () {
        const options = SSEOptions();

        expect(options.reconnectInterval, const Duration(seconds: 3));
        expect(options.maxReconnectAttempts, 5);
        expect(options.autoReconnect, true);
        expect(options.headers, isNull);
      });

      test('should create SSEOptions with custom values', () {
        const options = SSEOptions(
          reconnectInterval: Duration(seconds: 5),
          maxReconnectAttempts: 3,
          autoReconnect: false,
          headers: {'Authorization': 'Bearer token'},
        );

        expect(options.reconnectInterval, const Duration(seconds: 5));
        expect(options.maxReconnectAttempts, 3);
        expect(options.autoReconnect, false);
        expect(options.headers, {'Authorization': 'Bearer token'});
      });
    });

    group('WebSocket Options', () {
      test('should create WebSocketOptions with default values', () {
        const options = WebSocketOptions();

        expect(options.protocols, isNull);
        expect(options.headers, isNull);
        expect(options.connectTimeout, isNull);
        expect(options.pingInterval, isNull);
        expect(options.autoReconnect, true);
        expect(options.reconnectInterval, const Duration(seconds: 3));
        expect(options.maxReconnectAttempts, 5);
      });

      test('should create WebSocketOptions with custom values', () {
        const options = WebSocketOptions(
          protocols: ['chat', 'superchat'],
          headers: {'Authorization': 'Bearer token'},
          connectTimeout: Duration(seconds: 10),
          pingInterval: Duration(seconds: 30),
          autoReconnect: false,
          reconnectInterval: Duration(seconds: 5),
          maxReconnectAttempts: 3,
        );

        expect(options.protocols, ['chat', 'superchat']);
        expect(options.headers, {'Authorization': 'Bearer token'});
        expect(options.connectTimeout, const Duration(seconds: 10));
        expect(options.pingInterval, const Duration(seconds: 30));
        expect(options.autoReconnect, false);
        expect(options.reconnectInterval, const Duration(seconds: 5));
        expect(options.maxReconnectAttempts, 3);
      });
    });

    group('Stream Download Options', () {
      test('should create StreamDownloadOptions with default values', () {
        const options = StreamDownloadOptions();

        expect(options.bufferSize, 8192);
        expect(options.calculateSpeed, true);
        expect(options.speedCalculationInterval, const Duration(seconds: 1));
      });

      test('should create StreamDownloadOptions with custom values', () {
        const options = StreamDownloadOptions(
          bufferSize: 4096,
          calculateSpeed: false,
          speedCalculationInterval: Duration(milliseconds: 500),
        );

        expect(options.bufferSize, 4096);
        expect(options.calculateSpeed, false);
        expect(options.speedCalculationInterval,
            const Duration(milliseconds: 500));
      });
    });

    group('WebSocket Message Types', () {
      test('should create text message', () {
        final message = WebSocketMessage.text('Hello');

        expect(message.type, WebSocketMessageType.text);
        expect(message.data, 'Hello');
        expect(message.error, isNull);
      });

      test('should create binary message', () {
        final data = [1, 2, 3, 4, 5];
        final message = WebSocketMessage.binary(data);

        expect(message.type, WebSocketMessageType.binary);
        expect(message.data, data);
        expect(message.error, isNull);
      });

      test('should create error message', () {
        final message = WebSocketMessage.error('Connection failed');

        expect(message.type, WebSocketMessageType.error);
        expect(message.error, 'Connection failed');
      });
    });

    group('SSE Event JSON Conversion', () {
      test('should convert SSE event to JSON', () {
        final event = SSEEvent.now(
          id: 'test-id',
          event: 'message',
          data: 'test data',
          retry: 5000,
        );

        final json = event.toJson();

        expect(json, isNotNull);
        expect(json!['id'], 'test-id');
        expect(json['event'], 'message');
        expect(json['data'], 'test data');
        expect(json['retry'], 5000);
        expect(json['timestamp'], isA<String>());
      });
    });

    group('Progress Calculation', () {
      test('should calculate progress correctly', () {
        const progress1 = DownloadProgress(downloaded: 250, total: 1000);
        expect(progress1.progress, 0.25);
        expect(progress1.progressPercent, 25.0);

        const progress2 = DownloadProgress(downloaded: 1000, total: 1000);
        expect(progress2.progress, 1.0);
        expect(progress2.progressPercent, 100.0);

        const progress3 = DownloadProgress(downloaded: 500);
        expect(progress3.progress, isNull);
        expect(progress3.progressPercent, isNull);
      });

      test('should handle zero total correctly', () {
        const progress = DownloadProgress(downloaded: 100, total: 0);
        expect(progress.progress, isNull);
        expect(progress.progressPercent, isNull);
      });
    });
  });
}
