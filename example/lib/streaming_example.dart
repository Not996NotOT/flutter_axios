import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_axios/flutter_axios.dart';

/// 流式功能演示页面
class StreamingExamplePage extends StatefulWidget {
  const StreamingExamplePage({super.key});

  @override
  State<StreamingExamplePage> createState() => _StreamingExamplePageState();
}

class _StreamingExamplePageState extends State<StreamingExamplePage> {
  late final AxiosInstance _axios;
  final List<String> _logs = [];
  StreamSubscription? _currentSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAxios();
  }

  void _initializeAxios() {
    _axios = AxiosInstance(
      config: const AxiosConfig(
        baseURL: 'https://httpbin.org',
        timeout: Duration(seconds: 30),
      ),
    );
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $message');
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  /// 演示流式响应
  Future<void> _demonstrateStreamResponse() async {
    _clearLogs();
    _addLog('🚀 开始流式响应演示...');

    try {
      final response = await _axios.getStream('/stream/5');
      _addLog('✅ 连接成功，状态: ${response.status}');
      _addLog('📊 内容长度: ${response.contentLength ?? "未知"}');

      int lineCount = 0;
      _currentSubscription = response.dataStream.listen(
        (line) {
          lineCount++;
          _addLog(
              '📦 第 $lineCount 行: ${line.length > 50 ? line.substring(0, 50) + '...' : line}');
        },
        onError: (error) {
          _addLog('❌ 流式响应错误: $error');
        },
        onDone: () {
          _addLog('✅ 流式响应完成，共接收 $lineCount 行');
        },
      );
    } catch (e) {
      _addLog('❌ 流式响应失败: $e');
    }
  }

  /// 演示流式下载
  Future<void> _demonstrateStreamDownload() async {
    _clearLogs();
    _addLog('📥 开始流式下载演示...');

    try {
      int totalBytes = 0;
      int chunkCount = 0;

      _currentSubscription = _axios
          .downloadStream(
        '/bytes/10240', // 下载 10KB 数据
        options: const StreamDownloadOptions(
          calculateSpeed: true,
          speedCalculationInterval: Duration(milliseconds: 500),
        ),
      )
          .listen(
        (progress) {
          chunkCount++;
          totalBytes = progress.downloaded;

          final percent = progress.progressPercent?.toStringAsFixed(1) ?? '未知';
          final speed = progress.speed != null
              ? '${(progress.speed! / 1024).toStringAsFixed(1)} KB/s'
              : '计算中...';

          _addLog(
              '📦 进度: $percent% (${progress.downloaded}/${progress.total ?? "?"} bytes) - 速度: $speed');
        },
        onError: (error) {
          _addLog('❌ 下载错误: $error');
        },
        onDone: () {
          _addLog('✅ 下载完成！总计: $totalBytes bytes，$chunkCount 个进度更新');
        },
      );
    } catch (e) {
      _addLog('❌ 下载失败: $e');
    }
  }

  /// 演示 SSE 连接（模拟）
  Future<void> _demonstrateSSE() async {
    _clearLogs();
    _addLog('📡 开始 SSE 演示...');
    _addLog('💡 注意：这是一个模拟演示，因为 httpbin.org 不支持真实的 SSE');

    // 模拟 SSE 事件
    _simulateSSEEvents();
  }

  void _simulateSSEEvents() {
    int eventCount = 0;
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (eventCount >= 5) {
        timer.cancel();
        _addLog('✅ SSE 演示完成');
        return;
      }

      eventCount++;
      final event = SSEEvent.now(
        id: 'event_$eventCount',
        event: eventCount == 3 ? 'custom' : 'message',
        data:
            '{"message": "这是第 $eventCount 个事件", "timestamp": "${DateTime.now().toIso8601String()}"}',
      );

      _addLog('📨 SSE 事件: ${event.event ?? "message"} - ${event.data}');
    });
  }

  /// 演示 WebSocket 连接（模拟）
  Future<void> _demonstrateWebSocket() async {
    _clearLogs();
    _addLog('🔌 开始 WebSocket 演示...');
    _addLog('💡 注意：这是一个模拟演示，展示 WebSocket 消息处理');

    // 模拟 WebSocket 消息
    _simulateWebSocketMessages();
  }

  void _simulateWebSocketMessages() {
    _addLog('🔗 WebSocket 连接已建立');

    final messages = [
      WebSocketMessage.text(
          '{"type": "welcome", "message": "欢迎连接到 WebSocket"}'),
      WebSocketMessage.text('{"type": "data", "payload": "实时数据更新"}'),
      WebSocketMessage.now(type: WebSocketMessageType.ping, data: 'ping'),
      WebSocketMessage.text('{"type": "notification", "message": "新消息通知"}'),
      WebSocketMessage.now(type: WebSocketMessageType.close, data: '连接关闭'),
    ];

    int messageIndex = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (messageIndex >= messages.length) {
        timer.cancel();
        _addLog('✅ WebSocket 演示完成');
        return;
      }

      final message = messages[messageIndex];
      messageIndex++;

      String logMessage;
      switch (message.type) {
        case WebSocketMessageType.text:
          logMessage = '📨 收到文本: ${message.data}';
          break;
        case WebSocketMessageType.ping:
          logMessage = '🏓 Ping: ${message.data}';
          break;
        case WebSocketMessageType.close:
          logMessage = '🔌 连接关闭: ${message.data}';
          break;
        default:
          logMessage = '📦 消息: ${message.type} - ${message.data}';
      }

      _addLog(logMessage);
    });
  }

  void _stopCurrentDemo() {
    _currentSubscription?.cancel();
    _currentSubscription = null;
    _addLog('⏹️ 演示已停止');
  }

  @override
  void dispose() {
    _currentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Axios 流式功能演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 控制按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton.icon(
                  onPressed: _demonstrateStreamResponse,
                  icon: const Icon(Icons.stream),
                  label: const Text('流式响应'),
                ),
                ElevatedButton.icon(
                  onPressed: _demonstrateStreamDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('流式下载'),
                ),
                ElevatedButton.icon(
                  onPressed: _demonstrateSSE,
                  icon: const Icon(Icons.event),
                  label: const Text('SSE 演示'),
                ),
                ElevatedButton.icon(
                  onPressed: _demonstrateWebSocket,
                  icon: const Icon(Icons.web),
                  label: const Text('WebSocket'),
                ),
                ElevatedButton.icon(
                  onPressed: _stopCurrentDemo,
                  icon: const Icon(Icons.stop),
                  label: const Text('停止'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.clear),
                  label: const Text('清空日志'),
                ),
              ],
            ),
          ),

          const Divider(),

          // 日志显示区域
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        '点击上方按钮开始演示\n\n🚀 流式响应 - 演示逐行接收数据\n📥 流式下载 - 演示带进度的文件下载\n📡 SSE 演示 - 演示服务器推送事件\n🔌 WebSocket - 演示双向实时通信',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
