import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../axios_config.dart';
import 'stream_types.dart';

/// WebSocket 客户端
class WebSocketClient {
  final AxiosConfig? _config;
  WebSocketChannel? _channel;
  StreamController<WebSocketMessage>? _controller;
  StreamSubscription<dynamic>? _subscription;
  Timer? _pingTimer;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  String? _lastUrl;
  WebSocketOptions? _lastOptions;

  WebSocketClient({AxiosConfig? config}) : _config = config;

  /// 连接到 WebSocket 端点
  Stream<WebSocketMessage> connect(
    String url, {
    WebSocketOptions? options,
  }) {
    if (_isConnected) {
      throw StateError('WebSocket client is already connected');
    }

    final wsOptions = options ?? const WebSocketOptions();
    _lastUrl = url;
    _lastOptions = wsOptions;
    _controller = StreamController<WebSocketMessage>.broadcast();
    _reconnectAttempts = 0;

    _connectInternal(url, wsOptions);

    return _controller!.stream;
  }

  Future<void> _connectInternal(String url, WebSocketOptions options) async {
    try {
      final uri = _buildUri(url);

      // 创建 WebSocket 连接
      _channel = WebSocketChannel.connect(
        uri,
        protocols: options.protocols,
      );

      // 等待连接建立
      if (options.connectTimeout != null) {
        await _channel!.ready.timeout(options.connectTimeout!);
      } else {
        await _channel!.ready;
      }

      _isConnected = true;
      _reconnectAttempts = 0;

      // 发送连接成功消息
      _controller?.add(WebSocketMessage.now(
        type: WebSocketMessageType.open,
        data: 'WebSocket connected to $url',
      ));

      // 监听消息
      _subscription = _channel!.stream.listen(
        (data) => _handleMessage(data),
        onError: (dynamic error) => _handleError(error, options),
        onDone: () => _handleDisconnection(options),
      );

      // 设置 Ping 定时器
      if (options.pingInterval != null) {
        _setupPingTimer(options.pingInterval!);
      }
    } on Exception catch (error) {
      _handleError(error, options);
    }
  }

  void _handleMessage(dynamic data) {
    WebSocketMessage message;

    if (data is String) {
      message = WebSocketMessage.text(data);
    } else if (data is List<int>) {
      message = WebSocketMessage.binary(data);
    } else {
      message = WebSocketMessage.now(
        type: WebSocketMessageType.text,
        data: data.toString(),
      );
    }

    _controller?.add(message);
  }

  void _handleError(dynamic error, WebSocketOptions options) {
    _isConnected = false;
    _pingTimer?.cancel();

    final errorMessage = WebSocketMessage.error(error.toString());
    _controller?.add(errorMessage);

    if (options.autoReconnect &&
        _reconnectAttempts < options.maxReconnectAttempts &&
        _lastUrl != null) {
      _reconnectAttempts++;
      Timer(options.reconnectInterval, () {
        _connectInternal(_lastUrl!, options);
      });
    }
  }

  void _handleDisconnection(WebSocketOptions options) {
    _isConnected = false;
    _pingTimer?.cancel();

    _controller?.add(WebSocketMessage.now(
      type: WebSocketMessageType.close,
      data: 'WebSocket disconnected',
    ));

    if (options.autoReconnect &&
        _reconnectAttempts < options.maxReconnectAttempts &&
        _lastUrl != null) {
      _reconnectAttempts++;
      Timer(options.reconnectInterval, () {
        _connectInternal(_lastUrl!, options);
      });
    } else {
      _controller?.close();
    }
  }

  void _setupPingTimer(Duration interval) {
    _pingTimer = Timer.periodic(interval, (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add('ping');
          _controller?.add(WebSocketMessage.now(
            type: WebSocketMessageType.ping,
            data: 'ping',
          ));
        } on Exception catch (e) {
          // Ping 失败，可能连接已断开
          _handleError(e, _lastOptions ?? const WebSocketOptions());
        }
      }
    });
  }

  Uri _buildUri(String url) {
    if (url.startsWith('ws://') || url.startsWith('wss://')) {
      return Uri.parse(url);
    }

    if (_config?.baseURL == null) {
      throw ArgumentError('Relative URL requires baseURL to be set in config');
    }

    final baseUrl = _config!.baseURL!;
    // 将 HTTP(S) 转换为 WS(S)
    final wsBaseUrl = baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');

    return Uri.parse('$wsBaseUrl$url');
  }

  /// 发送文本消息
  void sendText(String message) {
    if (!_isConnected || _channel == null) {
      throw StateError('WebSocket is not connected');
    }

    _channel!.sink.add(message);
  }

  /// 发送二进制消息
  void sendBinary(List<int> data) {
    if (!_isConnected || _channel == null) {
      throw StateError('WebSocket is not connected');
    }

    _channel!.sink.add(data);
  }

  /// 发送 JSON 消息
  void sendJson(Map<String, dynamic> data) {
    sendText(jsonEncode(data));
  }

  /// 发送 Ping
  void ping([String? data]) {
    if (!_isConnected || _channel == null) {
      throw StateError('WebSocket is not connected');
    }

    _channel!.sink.add(data ?? 'ping');
    _controller?.add(WebSocketMessage.now(
      type: WebSocketMessageType.ping,
      data: data ?? 'ping',
    ));
  }

  /// 断开 WebSocket 连接
  Future<void> disconnect([int? closeCode, String? closeReason]) async {
    _isConnected = false;
    _pingTimer?.cancel();

    await _subscription?.cancel();
    await _channel?.sink.close(closeCode ?? status.normalClosure, closeReason);
    await _controller?.close();

    _subscription = null;
    _channel = null;
    _controller = null;
  }

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 当前重连次数
  int get reconnectAttempts => _reconnectAttempts;

  /// 关闭客户端
  void close() {
    disconnect();
  }
}
