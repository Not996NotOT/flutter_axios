import 'dart:async';

import '../axios_request.dart';

/// 流式响应类
class StreamedAxiosResponse<T> {
  /// HTTP 状态码
  final int status;

  /// HTTP 状态文本
  final String statusText;

  /// 响应头
  final Map<String, String> headers;

  /// 数据流
  final Stream<T> dataStream;

  /// 原始请求
  final AxiosRequest request;

  /// 内容长度（如果可用）
  final int? contentLength;

  const StreamedAxiosResponse({
    required this.status,
    required this.statusText,
    required this.headers,
    required this.dataStream,
    required this.request,
    this.contentLength,
  });

  /// 是否成功响应
  bool get isSuccess => status >= 200 && status < 300;
}

/// Server-Sent Events 事件类
class SSEEvent {
  /// 事件 ID
  final String? id;

  /// 事件类型
  final String? event;

  /// 事件数据
  final String data;

  /// 重试间隔（毫秒）
  final int? retry;

  /// 时间戳
  final DateTime timestamp;

  const SSEEvent({
    this.id,
    this.event,
    required this.data,
    this.retry,
    required this.timestamp,
  });

  factory SSEEvent.now({
    String? id,
    String? event,
    required String data,
    int? retry,
  }) {
    return SSEEvent(
      id: id,
      event: event,
      data: data,
      retry: retry,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'SSEEvent(id: $id, event: $event, data: $data, timestamp: $timestamp)';
  }

  /// 将事件转换为 JSON 格式（如果数据是 JSON）
  Map<String, dynamic>? toJson() {
    try {
      return {
        'id': id,
        'event': event,
        'data': data,
        'retry': retry,
        'timestamp': timestamp.toIso8601String(),
      };
    } catch (e) {
      return null;
    }
  }
}

/// WebSocket 消息类型
enum WebSocketMessageType {
  /// 文本消息
  text,

  /// 二进制消息
  binary,

  /// 连接打开
  open,

  /// 连接关闭
  close,

  /// 错误
  error,

  /// Ping
  ping,

  /// Pong
  pong,
}

/// WebSocket 消息
class WebSocketMessage {
  /// 消息类型
  final WebSocketMessageType type;

  /// 消息数据
  final dynamic data;

  /// 时间戳
  final DateTime timestamp;

  /// 错误信息（仅当类型为 error 时）
  final String? error;

  const WebSocketMessage({
    required this.type,
    this.data,
    required this.timestamp,
    this.error,
  });

  factory WebSocketMessage.now({
    required WebSocketMessageType type,
    dynamic data,
    String? error,
  }) {
    return WebSocketMessage(
      type: type,
      data: data,
      timestamp: DateTime.now(),
      error: error,
    );
  }

  /// 创建文本消息
  factory WebSocketMessage.text(String data) {
    return WebSocketMessage.now(
      type: WebSocketMessageType.text,
      data: data,
    );
  }

  /// 创建二进制消息
  factory WebSocketMessage.binary(List<int> data) {
    return WebSocketMessage.now(
      type: WebSocketMessageType.binary,
      data: data,
    );
  }

  /// 创建错误消息
  factory WebSocketMessage.error(String error) {
    return WebSocketMessage.now(
      type: WebSocketMessageType.error,
      error: error,
    );
  }

  @override
  String toString() {
    return 'WebSocketMessage(type: $type, data: $data, timestamp: $timestamp)';
  }
}

/// 下载进度信息
class DownloadProgress {
  /// 已下载字节数
  final int downloaded;

  /// 总字节数（如果已知）
  final int? total;

  /// 下载速度（字节/秒）
  final double? speed;

  /// 剩余时间估计（秒）
  final double? remainingTime;

  const DownloadProgress({
    required this.downloaded,
    this.total,
    this.speed,
    this.remainingTime,
  });

  /// 下载进度百分比（0.0 - 1.0）
  double? get progress {
    if (total == null || total == 0) return null;
    return downloaded / total!;
  }

  /// 下载进度百分比（0 - 100）
  double? get progressPercent {
    final p = progress;
    return p != null ? p * 100 : null;
  }

  @override
  String toString() {
    final percent = progressPercent;
    return 'DownloadProgress(downloaded: $downloaded, total: $total, '
        'progress: ${percent?.toStringAsFixed(1)}%)';
  }
}

/// 流式下载选项
class StreamDownloadOptions {
  /// 缓冲区大小
  final int bufferSize;

  /// 是否计算下载速度
  final bool calculateSpeed;

  /// 速度计算间隔
  final Duration speedCalculationInterval;

  const StreamDownloadOptions({
    this.bufferSize = 8192,
    this.calculateSpeed = true,
    this.speedCalculationInterval = const Duration(seconds: 1),
  });
}

/// SSE 连接选项
class SSEOptions {
  /// 重连间隔
  final Duration reconnectInterval;

  /// 最大重连次数
  final int maxReconnectAttempts;

  /// 自定义请求头
  final Map<String, String>? headers;

  /// 是否自动重连
  final bool autoReconnect;

  const SSEOptions({
    this.reconnectInterval = const Duration(seconds: 3),
    this.maxReconnectAttempts = 5,
    this.headers,
    this.autoReconnect = true,
  });
}

/// WebSocket 连接选项
class WebSocketOptions {
  /// 子协议
  final List<String>? protocols;

  /// 自定义请求头
  final Map<String, String>? headers;

  /// 连接超时
  final Duration? connectTimeout;

  /// Ping 间隔
  final Duration? pingInterval;

  /// 是否自动重连
  final bool autoReconnect;

  /// 重连间隔
  final Duration reconnectInterval;

  /// 最大重连次数
  final int maxReconnectAttempts;

  const WebSocketOptions({
    this.protocols,
    this.headers,
    this.connectTimeout,
    this.pingInterval,
    this.autoReconnect = true,
    this.reconnectInterval = const Duration(seconds: 3),
    this.maxReconnectAttempts = 5,
  });
}
