import 'package:flutter_axios/flutter_axios.dart';

/// 流式功能演示
void main() async {
  print('🚀 Flutter Axios 流式功能演示\n');

  // 创建 axios 实例
  final axios = AxiosInstance(
    config: const AxiosConfig(
      baseURL: 'https://httpbin.org',
      timeout: Duration(seconds: 30),
    ),
  );

  await demonstrateStreamResponse(axios);
  await demonstrateProgressiveDownload(axios);
  await demonstrateSSE(axios);
  await demonstrateWebSocket(axios);

  print('\n✅ 演示完成！');
}

/// 演示流式响应
Future<void> demonstrateStreamResponse(AxiosInstance axios) async {
  print('1️⃣ 流式响应演示:');

  try {
    final response = await axios.getStream('/stream/3');
    print('   📡 状态: ${response.status}');
    print('   📊 内容长度: ${response.contentLength ?? "未知"}');
    print('   📥 接收流式数据:');

    int lineCount = 0;
    await for (final line in response.dataStream.take(3)) {
      lineCount++;
      final preview = line.length > 60 ? '${line.substring(0, 60)}...' : line;
      print('   📦 第 $lineCount 行: $preview');
    }

    print('   ✅ 流式响应完成\n');
  } catch (e) {
    print('   ❌ 流式响应失败: $e\n');
  }
}

/// 演示渐进式下载
Future<void> demonstrateProgressiveDownload(AxiosInstance axios) async {
  print('2️⃣ 渐进式下载演示:');

  try {
    print('   📥 开始下载 5KB 数据...');

    int lastPercent = -1;
    await for (final progress in axios.downloadStream('/bytes/5120')) {
      final percent = progress.progressPercent?.round() ?? 0;

      // 只在进度变化时显示
      if (percent != lastPercent && percent % 20 == 0) {
        final speed = progress.speed != null
            ? '${(progress.speed! / 1024).toStringAsFixed(1)} KB/s'
            : '计算中...';
        print('   📊 进度: $percent% - 速度: $speed');
        lastPercent = percent;
      }
    }

    print('   ✅ 下载完成\n');
  } catch (e) {
    print('   ❌ 下载失败: $e\n');
  }
}

/// 演示 SSE（模拟）
Future<void> demonstrateSSE(AxiosInstance axios) async {
  print('3️⃣ Server-Sent Events 演示:');
  print('   💡 这是一个概念演示，展示 SSE 事件处理');

  // 模拟 SSE 事件
  final events = [
    SSEEvent.now(
      id: 'msg1',
      event: 'message',
      data: '{"type": "welcome", "message": "欢迎连接到 SSE 流"}',
    ),
    SSEEvent.now(
      id: 'msg2',
      event: 'update',
      data: '{"type": "data", "payload": "实时数据更新"}',
    ),
    SSEEvent.now(
      id: 'msg3',
      event: 'notification',
      data: '{"type": "alert", "message": "重要通知"}',
    ),
  ];

  for (final event in events) {
    print('   📨 事件: ${event.event} - ID: ${event.id}');
    print('       数据: ${event.data}');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  print('   ✅ SSE 演示完成\n');
}

/// 演示 WebSocket（模拟）
Future<void> demonstrateWebSocket(AxiosInstance axios) async {
  print('4️⃣ WebSocket 演示:');
  print('   💡 这是一个概念演示，展示 WebSocket 消息处理');

  // 模拟 WebSocket 消息
  final messages = [
    WebSocketMessage.now(
      type: WebSocketMessageType.open,
      data: 'WebSocket 连接已建立',
    ),
    WebSocketMessage.text('{"type": "auth", "token": "abc123"}'),
    WebSocketMessage.text('{"type": "subscribe", "channel": "updates"}'),
    WebSocketMessage.now(
      type: WebSocketMessageType.ping,
      data: 'ping',
    ),
    WebSocketMessage.text('{"type": "data", "message": "实时消息推送"}'),
    WebSocketMessage.now(
      type: WebSocketMessageType.close,
      data: '连接正常关闭',
    ),
  ];

  for (final message in messages) {
    String logMessage;
    switch (message.type) {
      case WebSocketMessageType.open:
        logMessage = '🔗 连接: ${message.data}';
        break;
      case WebSocketMessageType.text:
        logMessage = '📨 消息: ${message.data}';
        break;
      case WebSocketMessageType.ping:
        logMessage = '🏓 Ping: ${message.data}';
        break;
      case WebSocketMessageType.close:
        logMessage = '🔌 关闭: ${message.data}';
        break;
      default:
        logMessage = '📦 其他: ${message.type} - ${message.data}';
    }

    print('   $logMessage');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  print('   ✅ WebSocket 演示完成\n');
}
