import 'dart:async';

import 'package:flutter_axios/flutter_axios.dart';
import 'package:flutter_test/flutter_test.dart';

/// 集成测试 - 测试所有功能的实际可用性
void main() {
  group('Flutter Axios Integration Tests', () {
    late AxiosInstance axios;

    setUp(() {
      axios = AxiosInstance(
        config: const AxiosConfig(
          baseURL: 'https://httpbin.org',
          timeout: Duration(seconds: 30),
          headers: {'User-Agent': 'Flutter-Axios-Test'},
        ),
      );
    });

    group('REST API Tests', () {
      test('GET request with query parameters', () async {
        final response = await axios.get('/get', params: {
          'test': 'value',
          'number': 123,
          'bool': true,
        });

        expect(response.status, 200);
        expect(response.data, isA<Map<String, dynamic>>());

        final args = response.data['args'] as Map<String, dynamic>;
        expect(args['test'], 'value');
        expect(args['number'], '123');
        expect(args['bool'], 'true');
      });

      test('POST request with JSON data', () async {
        final testData = {
          'name': 'Flutter Axios',
          'version': '1.2.0',
          'features': ['REST', 'SSE', 'WebSocket', 'Streaming'],
          'timestamp': DateTime.now().toIso8601String(),
        };

        final response = await axios.post('/post', data: testData);

        expect(response.status, 200);
        expect(response.data, isA<Map<String, dynamic>>());

        final json = response.data['json'] as Map<String, dynamic>;
        expect(json['name'], testData['name']);
        expect(json['version'], testData['version']);
        expect(json['features'], testData['features']);
      });

      test('PUT request with data update', () async {
        final updateData = {
          'id': 'test-123',
          'status': 'updated',
          'lastModified': DateTime.now().toIso8601String(),
        };

        final response = await axios.put('/put', data: updateData);

        expect(response.status, 200);
        expect(response.data['json']['status'], 'updated');
      });

      test('DELETE request', () async {
        final response = await axios.delete('/delete');
        expect(response.status, 200);
      });

      test('Error handling for 404', () async {
        expect(
          () async => await axios.get('/status/404'),
          throwsA(isA<AxiosError>()),
        );
      });

      test('Timeout handling', () async {
        final shortTimeoutAxios = AxiosInstance(
          config: const AxiosConfig(
            baseURL: 'https://httpbin.org',
            timeout: Duration(milliseconds: 1), // 极短超时
          ),
        );

        expect(
          () async => await shortTimeoutAxios.get('/delay/5'),
          throwsA(isA<AxiosError>()),
        );
      });
    });

    group('Streaming Tests', () {
      test('Stream response line by line', () async {
        final response = await axios.getStream('/stream/5');

        expect(response.status, 200);
        expect(response.dataStream, isA<Stream<String>>());

        final lines = <String>[];
        await for (final line in response.dataStream.take(3)) {
          lines.add(line);
          expect(line, isNotEmpty);
          expect(line, contains('httpbin.org'));
        }

        expect(lines.length, 3);
      });

      test('Progressive download with progress tracking', () async {
        final progressUpdates = <DownloadProgress>[];

        await for (final progress in axios.downloadStream('/bytes/8192')) {
          progressUpdates.add(progress);

          expect(progress.downloaded, greaterThan(0));
          expect(progress.total, 8192);
          expect(progress.progress, isNotNull);
          expect(progress.progressPercent, isNotNull);

          // 测试进度是否递增
          if (progressUpdates.length > 1) {
            expect(
                progress.downloaded,
                greaterThanOrEqualTo(
                    progressUpdates[progressUpdates.length - 2].downloaded));
          }
        }

        expect(progressUpdates.isNotEmpty, true);
        expect(progressUpdates.last.downloaded, 8192);
        expect(progressUpdates.last.progressPercent, 100.0);
      });

      test('Stream POST request', () async {
        final testData = {'message': 'streaming test'};
        final response = await axios.postStream('/post', data: testData);

        expect(response.status, 200);

        bool foundData = false;
        await for (final line in response.dataStream.take(10)) {
          if (line.contains('streaming test')) {
            foundData = true;
            break;
          }
        }

        expect(foundData, true);
      });

      test('Large file streaming performance', () async {
        final stopwatch = Stopwatch()..start();
        int totalBytes = 0;

        await for (final progress in axios.downloadStream('/bytes/32768')) {
          totalBytes = progress.downloaded;

          // 验证速度计算
          if (progress.speed != null) {
            expect(progress.speed, greaterThan(0));
          }
        }

        stopwatch.stop();
        expect(totalBytes, 32768);
        expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 应该在10秒内完成
      });
    });

    group('SSE Simulation Tests', () {
      test('SSE event parsing and handling', () async {
        // 模拟 SSE 数据流
        final sseData = '''
data: {"type": "message", "content": "Hello World"}

event: notification
data: {"alert": "System update available"}

id: 123
event: heartbeat
data: {"timestamp": "${DateTime.now().toIso8601String()}"}

data: {"type": "multiline",
data: "content": "This is a
data: multiline message"}

retry: 5000
data: {"reconnect": true}

''';

        final events = <Map<String, String>>[];
        final lines = sseData.split('\n');

        String? currentId;
        String? currentEvent;
        String currentData = '';
        int? currentRetry;

        for (final line in lines) {
          if (line.isEmpty) {
            if (currentData.isNotEmpty) {
              events.add({
                'id': currentId ?? '',
                'event': currentEvent ?? 'message',
                'data': currentData.trim(),
                'retry': currentRetry?.toString() ?? '',
              });
              currentData = '';
              currentId = null;
              currentEvent = null;
              currentRetry = null;
            }
          } else if (line.startsWith('data:')) {
            currentData += line.substring(5) + '\n';
          } else if (line.startsWith('id:')) {
            currentId = line.substring(3).trim();
          } else if (line.startsWith('event:')) {
            currentEvent = line.substring(6).trim();
          } else if (line.startsWith('retry:')) {
            currentRetry = int.tryParse(line.substring(6).trim());
          }
        }

        expect(events.length, 5);
        expect(events[0]['event'], 'message');
        expect(events[1]['event'], 'notification');
        expect(events[2]['id'], '123');
        expect(events[2]['event'], 'heartbeat');
        expect(events[3]['data'], contains('multiline'));
        expect(events[4]['retry'], '5000');
      });

      test('SSE event creation and JSON conversion', () async {
        final event = SSEEvent.now(
          id: 'test-event-123',
          event: 'user-action',
          data: '{"action": "click", "element": "button"}',
          retry: 3000,
        );

        expect(event.id, 'test-event-123');
        expect(event.event, 'user-action');
        expect(event.data, contains('click'));
        expect(event.retry, 3000);
        expect(event.timestamp, isA<DateTime>());

        final json = event.toJson();
        expect(json, isNotNull);
        expect(json!['id'], 'test-event-123');
        expect(json['event'], 'user-action');
      });

      test('SSE options configuration', () async {
        const options = SSEOptions(
          reconnectInterval: Duration(seconds: 5),
          maxReconnectAttempts: 3,
          autoReconnect: false,
          headers: {'Authorization': 'Bearer test-token'},
        );

        expect(options.reconnectInterval.inSeconds, 5);
        expect(options.maxReconnectAttempts, 3);
        expect(options.autoReconnect, false);
        expect(options.headers!['Authorization'], 'Bearer test-token');
      });
    });

    group('WebSocket Simulation Tests', () {
      test('WebSocket message types and handling', () async {
        final messages = [
          WebSocketMessage.text('{"type": "auth", "token": "abc123"}'),
          WebSocketMessage.binary([1, 2, 3, 4, 5]),
          WebSocketMessage.error('Connection failed'),
          WebSocketMessage.now(type: WebSocketMessageType.ping, data: 'ping'),
          WebSocketMessage.now(type: WebSocketMessageType.pong, data: 'pong'),
        ];

        expect(messages[0].type, WebSocketMessageType.text);
        expect(messages[0].data, contains('auth'));

        expect(messages[1].type, WebSocketMessageType.binary);
        expect(messages[1].data, [1, 2, 3, 4, 5]);

        expect(messages[2].type, WebSocketMessageType.error);
        expect(messages[2].error, 'Connection failed');

        expect(messages[3].type, WebSocketMessageType.ping);
        expect(messages[4].type, WebSocketMessageType.pong);

        for (final message in messages) {
          expect(message.timestamp, isA<DateTime>());
        }
      });

      test('WebSocket options configuration', () async {
        const options = WebSocketOptions(
          protocols: ['chat', 'superchat'],
          headers: {'Origin': 'https://example.com'},
          connectTimeout: Duration(seconds: 10),
          pingInterval: Duration(seconds: 30),
          autoReconnect: true,
          reconnectInterval: Duration(seconds: 5),
          maxReconnectAttempts: 3,
        );

        expect(options.protocols, ['chat', 'superchat']);
        expect(options.headers!['Origin'], 'https://example.com');
        expect(options.connectTimeout!.inSeconds, 10);
        expect(options.pingInterval!.inSeconds, 30);
        expect(options.autoReconnect, true);
        expect(options.reconnectInterval.inSeconds, 5);
        expect(options.maxReconnectAttempts, 3);
      });

      test('WebSocket message serialization', () async {
        final textMessage = WebSocketMessage.text('Hello WebSocket');
        final binaryMessage = WebSocketMessage.binary([72, 101, 108, 108, 111]);

        expect(textMessage.data, 'Hello WebSocket');
        expect(binaryMessage.data, [72, 101, 108, 108, 111]);

        // 测试消息字符串表示
        expect(textMessage.toString(), contains('WebSocketMessage'));
        expect(textMessage.toString(), contains('text'));
      });
    });

    group('Cross-Feature Integration Tests', () {
      test('REST API with interceptors and streaming', () async {
        // 添加日志拦截器
        axios.interceptors.add(LoggingRequestInterceptor(logger: print));
        axios.interceptors.add(LoggingResponseInterceptor(logger: print));

        // 测试普通 REST API
        final restResponse =
            await axios.get('/get', params: {'test': 'interceptor'});
        expect(restResponse.status, 200);

        // 测试流式响应
        final streamResponse = await axios.getStream('/stream/2');
        expect(streamResponse.status, 200);

        int lineCount = 0;
        await for (final line in streamResponse.dataStream) {
          lineCount++;
          expect(line, isNotEmpty);
        }
        expect(lineCount, 2);
      });

      test('Error handling across all features', () async {
        // REST API 错误
        expect(
          () async => await axios.get('/status/500'),
          throwsA(predicate(
              (e) => e is AxiosError && e.type == AxiosErrorType.response)),
        );

        // 流式下载错误
        expect(
          () async {
            await for (final _ in axios.downloadStream('/status/404')) {
              // 不应该到达这里
            }
          },
          throwsA(isA<AxiosError>()),
        );
      });

      test('Performance comparison: REST vs Streaming', () async {
        final stopwatch1 = Stopwatch()..start();

        // 普通 REST 请求大数据
        final restResponse = await axios.get('/bytes/16384');
        stopwatch1.stop();

        final stopwatch2 = Stopwatch()..start();

        // 流式下载同样大小的数据
        await for (final _ in axios.downloadStream('/bytes/16384')) {
          // 处理进度
        }
        stopwatch2.stop();

        expect(restResponse.status, 200);

        // 两种方式都应该能成功获取数据
        print('REST API time: ${stopwatch1.elapsedMilliseconds}ms');
        print('Streaming time: ${stopwatch2.elapsedMilliseconds}ms');
      });

      test('Concurrent requests handling', () async {
        final futures = <Future>[];

        // 并发 REST 请求
        for (int i = 0; i < 5; i++) {
          futures.add(axios.get('/get', params: {'request': i}));
        }

        // 并发流式请求
        for (int i = 0; i < 3; i++) {
          futures.add(() async {
            await for (final _ in axios.downloadStream('/bytes/1024')) {
              // 处理下载
            }
          }());
        }

        final results = await Future.wait(futures);
        expect(results.length, 8);
      });
    });

    group('Edge Cases and Robustness Tests', () {
      test('Empty response handling', () async {
        final response = await axios.get('/bytes/0');
        expect(response.status, 200);
      });

      test('Large JSON payload', () async {
        final largeData = {
          'items': List.generate(
              1000,
              (i) => {
                    'id': i,
                    'name': 'Item $i',
                    'data': List.generate(10, (j) => 'data_${i}_$j'),
                    'timestamp': DateTime.now().toIso8601String(),
                  }),
        };

        final response = await axios.post('/post', data: largeData);
        expect(response.status, 200);

        final receivedData = response.data['json']['items'] as List;
        expect(receivedData.length, 1000);
      });

      test('Special characters in URLs and data', () async {
        final specialData = {
          'chinese': '你好世界',
          'emoji': '🚀📡🔌',
          'special': 'Special chars: !@#\$%^&*()',
          'unicode': '\u{1F600}\u{1F601}\u{1F602}',
        };

        final response = await axios.post('/post', data: specialData);
        expect(response.status, 200);

        final json = response.data['json'] as Map<String, dynamic>;
        expect(json['chinese'], '你好世界');
        expect(json['emoji'], '🚀📡🔌');
      });

      test('Download progress accuracy', () async {
        final progressList = <DownloadProgress>[];

        await for (final progress in axios.downloadStream('/bytes/10240')) {
          progressList.add(progress);
        }

        // 验证进度单调递增
        for (int i = 1; i < progressList.length; i++) {
          expect(
            progressList[i].downloaded,
            greaterThanOrEqualTo(progressList[i - 1].downloaded),
          );
        }

        // 验证最终进度
        final finalProgress = progressList.last;
        expect(finalProgress.downloaded, 10240);
        expect(finalProgress.progress, 1.0);
        expect(finalProgress.progressPercent, 100.0);
      });
    });
  });
}
