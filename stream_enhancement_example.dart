import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// 演示如何为 flutter_axios 添加流和 SSE 支持的概念示例
///
/// 注意：这是一个概念演示，展示如何扩展 flutter_axios 来支持流式响应

/// 流式响应类
class StreamedAxiosResponse<T> {
  final int status;
  final String statusText;
  final Map<String, String> headers;
  final Stream<T> dataStream;

  StreamedAxiosResponse({
    required this.status,
    required this.statusText,
    required this.headers,
    required this.dataStream,
  });
}

/// SSE 事件类
class SSEEvent {
  final String? id;
  final String? event;
  final String data;
  final int? retry;

  SSEEvent({
    this.id,
    this.event,
    required this.data,
    this.retry,
  });

  @override
  String toString() => 'SSEEvent(id: $id, event: $event, data: $data)';
}

/// 扩展的 Axios 实例，支持流式响应
class StreamingAxiosInstance {
  final http.Client _client;
  final String? baseURL;

  StreamingAxiosInstance({
    this.baseURL,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// 流式 GET 请求
  Future<StreamedAxiosResponse<String>> getStream(String url) async {
    final uri = _buildUri(url);
    final request = http.Request('GET', uri);

    final streamedResponse = await _client.send(request);

    // 将字节流转换为字符串流
    final dataStream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    return StreamedAxiosResponse<String>(
      status: streamedResponse.statusCode,
      statusText: streamedResponse.reasonPhrase ?? '',
      headers: streamedResponse.headers,
      dataStream: dataStream,
    );
  }

  /// Server-Sent Events 支持
  Stream<SSEEvent> getSSE(String url) async* {
    final uri = _buildUri(url);
    final request = http.Request('GET', uri);
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';

    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      throw Exception('SSE connection failed: ${streamedResponse.statusCode}');
    }

    String buffer = '';
    String? currentId;
    String? currentEvent;
    String currentData = '';
    int? currentRetry;

    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      buffer += chunk;

      while (buffer.contains('\n')) {
        final lineEnd = buffer.indexOf('\n');
        final line = buffer.substring(0, lineEnd);
        buffer = buffer.substring(lineEnd + 1);

        if (line.isEmpty) {
          // 空行表示事件结束
          if (currentData.isNotEmpty) {
            yield SSEEvent(
              id: currentId,
              event: currentEvent,
              data: currentData.trim(),
              retry: currentRetry,
            );
          }

          // 重置状态
          currentId = null;
          currentEvent = null;
          currentData = '';
          currentRetry = null;
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
    }
  }

  /// 流式下载大文件
  Stream<List<int>> downloadStream(String url) async* {
    final uri = _buildUri(url);
    final request = http.Request('GET', uri);

    final streamedResponse = await _client.send(request);

    if (streamedResponse.statusCode != 200) {
      throw Exception('Download failed: ${streamedResponse.statusCode}');
    }

    yield* streamedResponse.stream;
  }

  Uri _buildUri(String url) {
    if (url.startsWith('http')) {
      return Uri.parse(url);
    }

    if (baseURL == null) {
      throw ArgumentError('Relative URL requires baseURL to be set');
    }

    return Uri.parse('$baseURL$url');
  }

  void close() {
    _client.close();
  }
}

/// 使用示例
void main() async {
  print('🚀 演示流式 HTTP 客户端功能\n');

  final streamingAxios = StreamingAxiosInstance(
    baseURL: 'https://httpbin.org',
  );

  // 示例 1: 流式响应
  await demonstrateStreamingResponse(streamingAxios);

  // 示例 2: SSE 模拟
  await demonstrateSSE();

  // 示例 3: 流式下载
  await demonstrateStreamingDownload(streamingAxios);

  streamingAxios.close();
  print('\n✅ 演示完成');
}

Future<void> demonstrateStreamingResponse(StreamingAxiosInstance axios) async {
  print('1️⃣ 流式响应演示:');

  try {
    final response = await axios.getStream('/stream/5');
    print('   📡 状态: ${response.status}');
    print('   📥 接收流式数据:');

    int lineCount = 0;
    await for (final line in response.dataStream.take(3)) {
      lineCount++;
      print(
          '   📦 第 $lineCount 行: ${line.length > 50 ? line.substring(0, 50) + '...' : line}');
    }
  } catch (e) {
    print('   ❌ 流式响应失败: $e');
  }
}

Future<void> demonstrateSSE() async {
  print('\n2️⃣ Server-Sent Events 演示:');
  print('   💡 这是一个概念演示 - 实际 SSE 需要支持的服务器');

  // 模拟 SSE 数据
  final sseData = '''
data: {"message": "Hello World", "timestamp": "2024-01-01T00:00:00Z"}

data: {"message": "Second message", "timestamp": "2024-01-01T00:00:01Z"}

event: custom
data: {"type": "custom", "payload": "Custom event data"}

''';

  print('   📡 模拟 SSE 流:');

  // 解析 SSE 格式
  final lines = sseData.split('\n');
  String? currentEvent;
  String currentData = '';

  for (final line in lines) {
    if (line.isEmpty) {
      if (currentData.isNotEmpty) {
        print(
            '   📨 事件: ${currentEvent ?? 'message'} - 数据: ${currentData.trim()}');
        currentData = '';
        currentEvent = null;
      }
    } else if (line.startsWith('data:')) {
      currentData += line.substring(5) + '\n';
    } else if (line.startsWith('event:')) {
      currentEvent = line.substring(6).trim();
    }
  }
}

Future<void> demonstrateStreamingDownload(StreamingAxiosInstance axios) async {
  print('\n3️⃣ 流式下载演示:');

  try {
    print('   📥 开始流式下载...');

    int totalBytes = 0;
    int chunkCount = 0;

    await for (final chunk in axios.downloadStream('/bytes/1024').take(5)) {
      chunkCount++;
      totalBytes += chunk.length;
      print(
          '   📦 块 $chunkCount: ${chunk.length} bytes (总计: $totalBytes bytes)');
    }

    print('   ✅ 下载完成: $totalBytes bytes in $chunkCount chunks');
  } catch (e) {
    print('   ❌ 流式下载失败: $e');
  }
}
