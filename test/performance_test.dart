import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_axios/flutter_axios.dart';
import 'package:flutter_test/flutter_test.dart';

/// 性能测试 - 测试各种场景下的性能表现
void main() {
  group('Flutter Axios Performance Tests', () {
    late AxiosInstance axios;

    setUpAll(() {
      axios = AxiosInstance(
        config: const AxiosConfig(
          baseURL: 'https://httpbin.org',
          timeout: Duration(seconds: 30),
        ),
      );
    });

    group('REST API 性能测试', () {
      test('单个请求响应时间', () async {
        final stopwatch = Stopwatch()..start();

        final response = await axios.get('/get');

        stopwatch.stop();
        final responseTime = stopwatch.elapsedMilliseconds;

        expect(response.status, 200);
        expect(responseTime, lessThan(5000)); // 应该在5秒内完成

        print('单个 GET 请求响应时间: ${responseTime}ms');
      });

      test('并发请求性能', () async {
        const concurrentRequests = 10;
        final stopwatch = Stopwatch()..start();

        final futures = List.generate(
          concurrentRequests,
          (i) => axios.get('/get', params: {'request': i}),
        );

        final responses = await Future.wait(futures);

        stopwatch.stop();
        final totalTime = stopwatch.elapsedMilliseconds;
        final avgTime = totalTime / concurrentRequests;

        expect(responses.length, concurrentRequests);
        for (final response in responses) {
          expect(response.status, 200);
        }

        print('$concurrentRequests 个并发请求总时间: ${totalTime}ms');
        print('平均每个请求时间: ${avgTime.toStringAsFixed(2)}ms');

        // 并发请求应该比串行快
        expect(totalTime, lessThan(concurrentRequests * 2000));
      });

      test('大数据 POST 请求性能', () async {
        final largeData = {
          'items': List.generate(
              1000,
              (i) => {
                    'id': i,
                    'name': 'Item $i',
                    'description':
                        'This is item number $i with some additional data',
                    'tags': List.generate(5, (j) => 'tag_${i}_$j'),
                    'metadata': {
                      'created': DateTime.now().toIso8601String(),
                      'version': '1.0.0',
                      'active': i % 2 == 0,
                    },
                  }),
        };

        final stopwatch = Stopwatch()..start();

        final response = await axios.post('/post', data: largeData);

        stopwatch.stop();
        final responseTime = stopwatch.elapsedMilliseconds;

        expect(response.status, 200);

        print('大数据 POST 请求 (1000 items) 响应时间: ${responseTime}ms');

        // 大数据请求应该在合理时间内完成
        expect(responseTime, lessThan(10000)); // 10秒内
      });

      test('连续请求性能', () async {
        const requestCount = 20;
        final responseTimes = <int>[];

        for (int i = 0; i < requestCount; i++) {
          final stopwatch = Stopwatch()..start();

          final response = await axios.get('/get', params: {'sequence': i});

          stopwatch.stop();
          responseTimes.add(stopwatch.elapsedMilliseconds);

          expect(response.status, 200);
        }

        final totalTime = responseTimes.reduce((a, b) => a + b);
        final avgTime = totalTime / requestCount;
        final minTime = responseTimes.reduce(min);
        final maxTime = responseTimes.reduce(max);

        print('连续 $requestCount 个请求统计:');
        print('  总时间: ${totalTime}ms');
        print('  平均时间: ${avgTime.toStringAsFixed(2)}ms');
        print('  最短时间: ${minTime}ms');
        print('  最长时间: ${maxTime}ms');

        // 检查性能一致性
        expect(maxTime - minTime, lessThan(3000)); // 时间差异不应该太大
      });
    });

    group('流式响应性能测试', () {
      test('流式响应 vs 普通响应性能对比', () async {
        // 测试普通响应
        final stopwatch1 = Stopwatch()..start();
        final normalResponse = await axios.get('/bytes/8192');
        stopwatch1.stop();

        // 测试流式响应
        final stopwatch2 = Stopwatch()..start();
        final streamResponse = await axios.getStream('/stream/10');
        int lineCount = 0;
        await for (final line in streamResponse.dataStream) {
          lineCount++;
        }
        stopwatch2.stop();

        expect(normalResponse.status, 200);
        expect(streamResponse.status, 200);
        expect(lineCount, 10);

        print('普通响应时间: ${stopwatch1.elapsedMilliseconds}ms');
        print('流式响应时间: ${stopwatch2.elapsedMilliseconds}ms');
        print('流式响应行数: $lineCount');
      });

      test('大文件下载性能', () async {
        const fileSize = 32768; // 32KB
        final progressUpdates = <DownloadProgress>[];
        final stopwatch = Stopwatch()..start();

        await for (final progress in axios.downloadStream('/bytes/$fileSize')) {
          progressUpdates.add(progress);
        }

        stopwatch.stop();
        final totalTime = stopwatch.elapsedMilliseconds;
        final finalProgress = progressUpdates.last;

        expect(finalProgress.downloaded, fileSize);
        expect(finalProgress.progress, 1.0);

        final downloadSpeed = (fileSize / 1024) / (totalTime / 1000); // KB/s

        print('下载 ${fileSize} 字节文件:');
        print('  总时间: ${totalTime}ms');
        print('  进度更新次数: ${progressUpdates.length}');
        print('  下载速度: ${downloadSpeed.toStringAsFixed(2)} KB/s');
        print(
            '  最终速度: ${finalProgress.speed?.toStringAsFixed(2) ?? 'N/A'} bytes/s');

        expect(downloadSpeed, greaterThan(1)); // 至少 1 KB/s
      });

      test('流式响应内存使用测试', () async {
        // 模拟处理大量流式数据而不累积在内存中
        int totalLines = 0;
        int maxMemoryUsage = 0;
        final processedLines = <String>[];

        final stopwatch = Stopwatch()..start();

        final response = await axios.getStream('/stream/100');
        await for (final line in response.dataStream) {
          totalLines++;

          // 模拟处理每行数据
          processedLines.add('Processed: $line');

          // 定期清理已处理的数据以节省内存
          if (processedLines.length > 10) {
            processedLines.removeRange(0, 5);
          }

          maxMemoryUsage = max(maxMemoryUsage, processedLines.length);
        }

        stopwatch.stop();

        print('流式处理 $totalLines 行数据:');
        print('  处理时间: ${stopwatch.elapsedMilliseconds}ms');
        print('  最大内存使用 (行数): $maxMemoryUsage');
        print('  最终内存使用 (行数): ${processedLines.length}');

        expect(totalLines, 100);
        expect(maxMemoryUsage, lessThan(15)); // 内存使用应该被控制
      });
    });

    group('SSE 性能测试', () {
      test('SSE 事件解析性能', () async {
        // 模拟大量 SSE 事件数据
        final sseData = List.generate(
            1000,
            (i) => '''
id: $i
event: message
data: {"id": $i, "message": "Event $i", "timestamp": "${DateTime.now().toIso8601String()}"}

''').join();

        final stopwatch = Stopwatch()..start();
        final events = <SSEEvent>[];

        // 模拟 SSE 解析过程
        final lines = sseData.split('\n');
        String? currentId;
        String? currentEvent;
        String currentData = '';

        for (final line in lines) {
          if (line.isEmpty) {
            if (currentData.isNotEmpty) {
              events.add(SSEEvent.now(
                id: currentId,
                event: currentEvent ?? 'message',
                data: currentData.trim(),
              ));
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

        stopwatch.stop();

        expect(events.length, 1000);

        print('解析 1000 个 SSE 事件:');
        print('  解析时间: ${stopwatch.elapsedMilliseconds}ms');
        print(
            '  平均每个事件: ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(3)}ms');

        // 验证解析结果
        expect(events.first.id, '0');
        expect(events.last.id, '999');
        expect(events.first.event, 'message');
      });

      test('SSE JSON 解析性能', () async {
        final events = List.generate(
            500,
            (i) => SSEEvent.now(
                  id: 'event-$i',
                  event: 'data',
                  data: jsonEncode({
                    'id': i,
                    'type': 'performance-test',
                    'payload': {
                      'items': List.generate(10, (j) => 'item_${i}_$j'),
                      'metadata': {
                        'timestamp': DateTime.now().toIso8601String(),
                        'version': '1.0.0',
                        'index': i,
                      },
                    },
                  }),
                ));

        final stopwatch = Stopwatch()..start();
        int successfulParses = 0;

        for (final event in events) {
          final json = event.toJson();
          if (json != null) {
            successfulParses++;
          }
        }

        stopwatch.stop();

        expect(successfulParses, 500);

        print('解析 500 个 SSE JSON 事件:');
        print('  解析时间: ${stopwatch.elapsedMilliseconds}ms');
        print('  成功解析: $successfulParses');
        print(
            '  平均每个事件: ${(stopwatch.elapsedMilliseconds / 500).toStringAsFixed(3)}ms');
      });
    });

    group('WebSocket 性能测试', () {
      test('WebSocket 消息创建性能', () async {
        const messageCount = 1000;
        final stopwatch = Stopwatch()..start();

        final textMessages = <WebSocketMessage>[];
        final binaryMessages = <WebSocketMessage>[];

        for (int i = 0; i < messageCount; i++) {
          textMessages.add(WebSocketMessage.text('Message $i'));
          binaryMessages.add(WebSocketMessage.binary(
            List.generate(100, (j) => (i + j) % 256),
          ));
        }

        stopwatch.stop();

        expect(textMessages.length, messageCount);
        expect(binaryMessages.length, messageCount);

        print('创建 ${messageCount * 2} 个 WebSocket 消息:');
        print('  创建时间: ${stopwatch.elapsedMilliseconds}ms');
        print(
            '  平均每个消息: ${(stopwatch.elapsedMilliseconds / (messageCount * 2)).toStringAsFixed(3)}ms');
      });

      test('WebSocket 消息类型处理性能', () async {
        final messages = <WebSocketMessage>[
          ...List.generate(
              250, (i) => WebSocketMessage.text('Text message $i')),
          ...List.generate(
              250, (i) => WebSocketMessage.binary([i, i + 1, i + 2])),
          ...List.generate(
              250,
              (i) => WebSocketMessage.now(
                    type: WebSocketMessageType.ping,
                    data: 'ping-$i',
                  )),
          ...List.generate(
              250,
              (i) => WebSocketMessage.now(
                    type: WebSocketMessageType.pong,
                    data: 'pong-$i',
                  )),
        ];

        final stopwatch = Stopwatch()..start();

        final textCount =
            messages.where((m) => m.type == WebSocketMessageType.text).length;
        final binaryCount =
            messages.where((m) => m.type == WebSocketMessageType.binary).length;
        final pingCount =
            messages.where((m) => m.type == WebSocketMessageType.ping).length;
        final pongCount =
            messages.where((m) => m.type == WebSocketMessageType.pong).length;

        stopwatch.stop();

        expect(textCount, 250);
        expect(binaryCount, 250);
        expect(pingCount, 250);
        expect(pongCount, 250);

        print('处理 1000 个 WebSocket 消息类型:');
        print('  处理时间: ${stopwatch.elapsedMilliseconds}ms');
        print('  文本消息: $textCount');
        print('  二进制消息: $binaryCount');
        print('  Ping 消息: $pingCount');
        print('  Pong 消息: $pongCount');
      });
    });

    group('内存和资源管理测试', () {
      test('大量请求后的资源清理', () async {
        const requestCount = 50;
        final responses = <AxiosResponse>[];

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < requestCount; i++) {
          final response = await axios.get('/get', params: {'batch': i});
          responses.add(response);

          // 模拟处理响应数据
          expect(response.status, 200);

          // 定期清理已处理的响应
          if (responses.length > 10) {
            responses.removeRange(0, 5);
          }
        }

        stopwatch.stop();

        print('处理 $requestCount 个请求的资源管理:');
        print('  总时间: ${stopwatch.elapsedMilliseconds}ms');
        print('  最终保留响应数: ${responses.length}');

        expect(responses.length, lessThan(15)); // 应该控制内存使用
      });

      test('流式响应的资源管理', () async {
        final streamControllers = <StreamController<String>>[];

        // 创建多个流控制器
        for (int i = 0; i < 10; i++) {
          final controller = StreamController<String>();
          streamControllers.add(controller);

          // 模拟向流中添加数据
          for (int j = 0; j < 100; j++) {
            controller.add('Stream $i, Line $j');
          }
          controller.close();
        }

        final stopwatch = Stopwatch()..start();
        int totalLinesProcessed = 0;

        // 并发处理所有流
        final futures = streamControllers.map((controller) async {
          int lineCount = 0;
          await for (final line in controller.stream) {
            lineCount++;
            // 模拟处理每行数据
          }
          return lineCount;
        });

        final results = await Future.wait(futures);
        totalLinesProcessed = results.reduce((a, b) => a + b);

        stopwatch.stop();

        expect(totalLinesProcessed, 1000); // 10 streams * 100 lines

        print('并发处理 10 个流 (总计 1000 行):');
        print('  处理时间: ${stopwatch.elapsedMilliseconds}ms');
        print('  总行数: $totalLinesProcessed');
      });

      test('拦截器性能影响', () async {
        // 不使用拦截器的请求
        final axiosWithoutInterceptors = AxiosInstance(
          config: const AxiosConfig(baseURL: 'https://httpbin.org'),
        );

        final stopwatch1 = Stopwatch()..start();
        await axiosWithoutInterceptors.get('/get');
        stopwatch1.stop();

        // 使用拦截器的请求
        final axiosWithInterceptors = AxiosInstance(
          config: const AxiosConfig(baseURL: 'https://httpbin.org'),
        );
        axiosWithInterceptors.interceptors
            .add(LoggingRequestInterceptor(logger: print));
        axiosWithInterceptors.interceptors
            .add(LoggingResponseInterceptor(logger: print));

        final stopwatch2 = Stopwatch()..start();
        await axiosWithInterceptors.get('/get');
        stopwatch2.stop();

        final timeWithoutInterceptors = stopwatch1.elapsedMilliseconds;
        final timeWithInterceptors = stopwatch2.elapsedMilliseconds;
        final overhead = timeWithInterceptors - timeWithoutInterceptors;

        print('拦截器性能影响:');
        print('  无拦截器: ${timeWithoutInterceptors}ms');
        print('  有拦截器: ${timeWithInterceptors}ms');
        print('  开销: ${overhead}ms');

        // 拦截器开销应该很小
        expect(overhead, lessThan(100)); // 应该小于100ms
      });
    });

    group('压力测试', () {
      test('高并发请求压力测试', () async {
        const concurrentRequests = 20;
        const batchCount = 5;
        final allResponseTimes = <int>[];

        for (int batch = 0; batch < batchCount; batch++) {
          final stopwatch = Stopwatch()..start();

          final futures = List.generate(
            concurrentRequests,
            (i) => axios.get('/get', params: {
              'batch': batch,
              'request': i,
            }),
          );

          final responses = await Future.wait(futures);
          stopwatch.stop();

          allResponseTimes.add(stopwatch.elapsedMilliseconds);

          expect(responses.length, concurrentRequests);
          for (final response in responses) {
            expect(response.status, 200);
          }

          print(
              '批次 ${batch + 1}: $concurrentRequests 个并发请求用时 ${stopwatch.elapsedMilliseconds}ms');
        }

        final avgBatchTime =
            allResponseTimes.reduce((a, b) => a + b) / batchCount;
        final minBatchTime = allResponseTimes.reduce(min);
        final maxBatchTime = allResponseTimes.reduce(max);

        print('压力测试统计 ($batchCount 批次, 每批次 $concurrentRequests 个请求):');
        print('  平均批次时间: ${avgBatchTime.toStringAsFixed(2)}ms');
        print('  最快批次: ${minBatchTime}ms');
        print('  最慢批次: ${maxBatchTime}ms');
        print('  总请求数: ${batchCount * concurrentRequests}');

        // 性能应该保持相对稳定
        expect(maxBatchTime - minBatchTime, lessThan(5000));
      });

      test('长时间运行稳定性测试', () async {
        const testDuration = Duration(seconds: 10);
        final endTime = DateTime.now().add(testDuration);
        int requestCount = 0;
        final responseTimes = <int>[];

        while (DateTime.now().isBefore(endTime)) {
          final stopwatch = Stopwatch()..start();

          try {
            final response = await axios.get('/get', params: {
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'request': requestCount,
            });

            stopwatch.stop();
            responseTimes.add(stopwatch.elapsedMilliseconds);

            expect(response.status, 200);
            requestCount++;
          } catch (e) {
            print('请求失败: $e');
          }

          // 短暂延迟避免过于频繁的请求
          await Future.delayed(const Duration(milliseconds: 100));
        }

        final avgResponseTime = responseTimes.isNotEmpty
            ? responseTimes.reduce((a, b) => a + b) / responseTimes.length
            : 0;

        print('长时间运行测试 (${testDuration.inSeconds}秒):');
        print('  总请求数: $requestCount');
        print('  成功请求数: ${responseTimes.length}');
        print('  平均响应时间: ${avgResponseTime.toStringAsFixed(2)}ms');
        print(
            '  请求频率: ${(requestCount / testDuration.inSeconds).toStringAsFixed(2)} req/s');

        expect(requestCount, greaterThan(10)); // 至少应该完成一些请求
        expect(responseTimes.length / requestCount,
            greaterThan(0.8)); // 成功率应该高于80%
      });
    });
  });
}
