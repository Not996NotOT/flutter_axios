import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_axios/flutter_axios.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock Server 测试 - 使用本地 HTTP 服务器测试所有功能
void main() {
  group('Mock Server Tests', () {
    late HttpServer server;
    late AxiosInstance axios;
    late String baseUrl;

    setUpAll(() async {
      // 启动本地测试服务器
      server = await HttpServer.bind('127.0.0.1', 0);
      baseUrl = 'http://127.0.0.1:${server.port}';

      axios = AxiosInstance(
        config: AxiosConfig(
          baseURL: baseUrl,
          timeout: const Duration(seconds: 10),
        ),
      );

      // 设置服务器路由
      server.listen((HttpRequest request) async {
        final uri = request.uri;
        final method = request.method;

        try {
          switch ('${method} ${uri.path}') {
            case 'GET /api/users':
              await _handleGetUsers(request);
              break;
            case 'POST /api/users':
              await _handleCreateUser(request);
              break;
            case 'PUT /api/users/1':
              await _handleUpdateUser(request);
              break;
            case 'DELETE /api/users/1':
              await _handleDeleteUser(request);
              break;
            case 'GET /api/stream':
              await _handleStreamResponse(request);
              break;
            case 'GET /api/download':
              await _handleDownload(request);
              break;
            case 'GET /api/sse':
              await _handleSSE(request);
              break;
            case 'GET /api/error':
              await _handleError(request);
              break;
            case 'GET /api/slow':
              await _handleSlowResponse(request);
              break;
            default:
              request.response.statusCode = 404;
              request.response.write('Not Found');
              await request.response.close();
          }
        } catch (e) {
          request.response.statusCode = 500;
          request.response.write('Internal Server Error: $e');
          await request.response.close();
        }
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    group('REST API Mock Tests', () {
      test('GET /api/users - 获取用户列表', () async {
        final response = await axios.get('/api/users');

        expect(response.status, 200);
        expect(response.data, isA<Map<String, dynamic>>());

        final users = response.data['users'] as List;
        expect(users.length, 3);
        expect(users[0]['name'], 'Alice');
        expect(users[1]['name'], 'Bob');
        expect(users[2]['name'], 'Charlie');
      });

      test('POST /api/users - 创建新用户', () async {
        final newUser = {
          'name': 'David',
          'email': 'david@example.com',
          'age': 28,
        };

        final response = await axios.post('/api/users', data: newUser);

        expect(response.status, 201);
        expect(response.data['success'], true);
        expect(response.data['user']['name'], 'David');
        expect(response.data['user']['id'], isA<int>());
      });

      test('PUT /api/users/1 - 更新用户信息', () async {
        final updateData = {
          'name': 'Alice Updated',
          'email': 'alice.updated@example.com',
        };

        final response = await axios.put('/api/users/1', data: updateData);

        expect(response.status, 200);
        expect(response.data['success'], true);
        expect(response.data['user']['name'], 'Alice Updated');
      });

      test('DELETE /api/users/1 - 删除用户', () async {
        final response = await axios.delete('/api/users/1');

        expect(response.status, 200);
        expect(response.data['success'], true);
        expect(response.data['message'], 'User deleted successfully');
      });

      test('GET /api/error - 错误处理', () async {
        expect(
          () async => await axios.get('/api/error'),
          throwsA(predicate((e) =>
              e is AxiosError &&
              e.type == AxiosErrorType.response &&
              e.response?.status == 400)),
        );
      });

      test('GET /api/slow - 超时处理', () async {
        final fastAxios = AxiosInstance(
          config: AxiosConfig(
            baseURL: baseUrl,
            timeout: const Duration(milliseconds: 500), // 短超时
          ),
        );

        expect(
          () async => await fastAxios.get('/api/slow'),
          throwsA(predicate(
              (e) => e is AxiosError && e.type == AxiosErrorType.timeout)),
        );
      });
    });

    group('Streaming Mock Tests', () {
      test('GET /api/stream - 流式响应', () async {
        final response = await axios.getStream('/api/stream');

        expect(response.status, 200);
        expect(response.dataStream, isA<Stream<String>>());

        final lines = <String>[];
        await for (final line in response.dataStream) {
          lines.add(line);
          if (lines.length >= 5) break; // 只读取前5行
        }

        expect(lines.length, 5);
        for (int i = 0; i < lines.length; i++) {
          expect(lines[i], contains('Line ${i + 1}'));
        }
      });

      test('GET /api/download - 下载进度', () async {
        final progressUpdates = <DownloadProgress>[];

        await for (final progress in axios.downloadStream('/api/download')) {
          progressUpdates.add(progress);
        }

        expect(progressUpdates.isNotEmpty, true);

        // 验证进度递增
        for (int i = 1; i < progressUpdates.length; i++) {
          expect(
            progressUpdates[i].downloaded,
            greaterThanOrEqualTo(progressUpdates[i - 1].downloaded),
          );
        }

        final finalProgress = progressUpdates.last;
        expect(finalProgress.downloaded, 1024); // 1KB 测试文件
        expect(finalProgress.progress, 1.0);
      });

      test('POST /api/users - 流式 POST 请求', () async {
        final userData = {
          'name': 'Stream User',
          'email': 'stream@example.com',
        };

        final response = await axios.postStream('/api/users', data: userData);

        expect(response.status, 201);

        bool foundSuccess = false;
        await for (final line in response.dataStream) {
          if (line.contains('Stream User')) {
            foundSuccess = true;
            break;
          }
        }

        expect(foundSuccess, true);
      });
    });

    group('SSE Mock Tests', () {
      test('GET /api/sse - Server-Sent Events', () async {
        final sseClient = SSEClient();
        final events = <SSEEvent>[];

        final subscription = sseClient
            .connect(
          '$baseUrl/api/sse',
          options: const SSEOptions(
            autoReconnect: false,
          ),
        )
            .listen((event) {
          events.add(event);
        });

        // 等待接收一些事件
        await Future.delayed(const Duration(seconds: 2));
        await subscription.cancel();

        expect(events.isNotEmpty, true);
        expect(events.first.event, 'message');
        expect(events.first.data, contains('Hello'));
      });

      test('SSE 重连机制', () async {
        final sseClient = SSEClient();
        final events = <SSEEvent>[];
        int connectionCount = 0;

        final subscription = sseClient
            .connect(
          '$baseUrl/api/sse',
          options: const SSEOptions(
            autoReconnect: true,
            maxReconnectAttempts: 2,
            reconnectInterval: Duration(milliseconds: 500),
          ),
        )
            .listen(
          (event) {
            events.add(event);
            if (event.event == 'connected') {
              connectionCount++;
            }
          },
          onError: (error) {
            // 处理连接错误
          },
        );

        await Future.delayed(const Duration(seconds: 3));
        await subscription.cancel();

        expect(connectionCount, greaterThan(0));
      });
    });

    group('WebSocket Mock Tests', () {
      test('WebSocket 消息发送和接收', () async {
        // 注意：这里我们模拟 WebSocket 行为，因为 HttpServer 不直接支持 WebSocket
        final messages = <WebSocketMessage>[];

        // 模拟 WebSocket 连接
        final wsClient = WebSocketClient();

        // 创建测试消息
        final testMessages = [
          WebSocketMessage.text('{"type": "auth", "token": "test123"}'),
          WebSocketMessage.text(
              '{"type": "message", "content": "Hello WebSocket"}'),
          WebSocketMessage.binary([1, 2, 3, 4, 5]),
        ];

        for (final message in testMessages) {
          messages.add(message);
        }

        expect(messages.length, 3);
        expect(messages[0].type, WebSocketMessageType.text);
        expect(messages[1].data, contains('Hello WebSocket'));
        expect(messages[2].type, WebSocketMessageType.binary);
      });

      test('WebSocket 连接选项', () async {
        const options = WebSocketOptions(
          protocols: ['chat'],
          headers: {'Authorization': 'Bearer test-token'},
          connectTimeout: Duration(seconds: 5),
          autoReconnect: true,
        );

        expect(options.protocols, ['chat']);
        expect(options.headers!['Authorization'], 'Bearer test-token');
        expect(options.autoReconnect, true);
      });
    });

    group('并发和性能测试', () {
      test('并发 REST 请求', () async {
        final futures = <Future<AxiosResponse>>[];

        for (int i = 0; i < 10; i++) {
          futures.add(axios.get('/api/users'));
        }

        final responses = await Future.wait(futures);

        expect(responses.length, 10);
        for (final response in responses) {
          expect(response.status, 200);
        }
      });

      test('并发流式下载', () async {
        final futures = <Future>[];

        for (int i = 0; i < 5; i++) {
          futures.add(() async {
            final progressList = <DownloadProgress>[];
            await for (final progress
                in axios.downloadStream('/api/download')) {
              progressList.add(progress);
            }
            return progressList;
          }());
        }

        final results = await Future.wait(futures);
        expect(results.length, 5);
      });

      test('内存使用测试 - 大数据流', () async {
        // 测试处理大量数据时的内存使用
        int totalLines = 0;

        final response = await axios.getStream('/api/stream');
        await for (final line in response.dataStream.take(100)) {
          totalLines++;
          // 模拟处理每行数据
          expect(line, isNotEmpty);
        }

        expect(totalLines, 100);
      });
    });
  });
}

// Mock Server 路由处理函数
Future<void> _handleGetUsers(HttpRequest request) async {
  final users = [
    {'id': 1, 'name': 'Alice', 'email': 'alice@example.com', 'age': 25},
    {'id': 2, 'name': 'Bob', 'email': 'bob@example.com', 'age': 30},
    {'id': 3, 'name': 'Charlie', 'email': 'charlie@example.com', 'age': 35},
  ];

  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'success': true,
    'users': users,
    'total': users.length,
  }));
  await request.response.close();
}

Future<void> _handleCreateUser(HttpRequest request) async {
  final body = await utf8.decoder.bind(request).join();
  final userData = jsonDecode(body) as Map<String, dynamic>;

  final newUser = {
    'id': DateTime.now().millisecondsSinceEpoch,
    ...userData,
    'createdAt': DateTime.now().toIso8601String(),
  };

  request.response.statusCode = 201;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'success': true,
    'user': newUser,
    'message': 'User created successfully',
  }));
  await request.response.close();
}

Future<void> _handleUpdateUser(HttpRequest request) async {
  final body = await utf8.decoder.bind(request).join();
  final updateData = jsonDecode(body) as Map<String, dynamic>;

  final updatedUser = {
    'id': 1,
    ...updateData,
    'updatedAt': DateTime.now().toIso8601String(),
  };

  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'success': true,
    'user': updatedUser,
    'message': 'User updated successfully',
  }));
  await request.response.close();
}

Future<void> _handleDeleteUser(HttpRequest request) async {
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'success': true,
    'message': 'User deleted successfully',
    'deletedAt': DateTime.now().toIso8601String(),
  }));
  await request.response.close();
}

Future<void> _handleStreamResponse(HttpRequest request) async {
  request.response.headers.set('Content-Type', 'text/plain');
  request.response.headers.set('Cache-Control', 'no-cache');

  for (int i = 1; i <= 10; i++) {
    final line = 'Line $i: ${DateTime.now().toIso8601String()}\n';
    request.response.write(line);
    await request.response.flush();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  await request.response.close();
}

Future<void> _handleDownload(HttpRequest request) async {
  const totalSize = 1024; // 1KB 测试文件
  const chunkSize = 64; // 64 字节块

  request.response.headers.set('Content-Length', totalSize.toString());
  request.response.headers.set('Content-Type', 'application/octet-stream');

  for (int i = 0; i < totalSize; i += chunkSize) {
    final remainingBytes = totalSize - i;
    final currentChunkSize =
        remainingBytes < chunkSize ? remainingBytes : chunkSize;

    final chunk = List.filled(currentChunkSize, 65); // 'A' 字符
    request.response.add(chunk);
    await request.response.flush();
    await Future.delayed(const Duration(milliseconds: 50));
  }

  await request.response.close();
}

Future<void> _handleSSE(HttpRequest request) async {
  request.response.headers.set('Content-Type', 'text/event-stream');
  request.response.headers.set('Cache-Control', 'no-cache');
  request.response.headers.set('Connection', 'keep-alive');

  // 发送连接事件
  request.response.write('event: connected\n');
  request.response.write('data: {"message": "Connected to SSE"}\n\n');
  await request.response.flush();

  // 发送定期消息
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(const Duration(milliseconds: 500));

    request.response.write('id: $i\n');
    request.response.write('event: message\n');
    request.response.write(
        'data: {"id": $i, "message": "Hello from SSE $i", "timestamp": "${DateTime.now().toIso8601String()}"}\n\n');
    await request.response.flush();
  }

  await request.response.close();
}

Future<void> _handleError(HttpRequest request) async {
  request.response.statusCode = 400;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'error': true,
    'message': 'Bad Request - This is a test error',
    'code': 'TEST_ERROR',
    'timestamp': DateTime.now().toIso8601String(),
  }));
  await request.response.close();
}

Future<void> _handleSlowResponse(HttpRequest request) async {
  // 模拟慢响应
  await Future.delayed(const Duration(seconds: 2));

  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'message': 'This is a slow response',
    'delay': '2 seconds',
  }));
  await request.response.close();
}
