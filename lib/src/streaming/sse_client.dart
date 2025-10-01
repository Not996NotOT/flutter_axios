import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../axios_config.dart';
import '../axios_error.dart';
import '../axios_request.dart';
import '../types/types.dart';
import 'stream_types.dart';

/// Server-Sent Events 客户端
class SSEClient {
  final http.Client _client;
  final AxiosConfig? _config;
  StreamController<SSEEvent>? _controller;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  int _reconnectAttempts = 0;

  SSEClient({
    http.Client? client,
    AxiosConfig? config,
  })  : _client = client ?? http.Client(),
        _config = config;

  /// 连接到 SSE 端点
  Stream<SSEEvent> connect(
    String url, {
    SSEOptions? options,
    Map<String, String>? headers,
  }) {
    if (_isConnected) {
      throw StateError('SSE client is already connected');
    }

    final sseOptions = options ?? const SSEOptions();
    _controller = StreamController<SSEEvent>.broadcast();
    _reconnectAttempts = 0;

    _connectInternal(url, sseOptions, headers);

    return _controller!.stream;
  }

  Future<void> _connectInternal(
    String url,
    SSEOptions options,
    Map<String, String>? customHeaders,
  ) async {
    try {
      final uri = _buildUri(url);
      final request = http.Request('GET', uri);

      // 设置 SSE 必需的请求头
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      // 添加配置中的默认头
      if (_config?.headers != null) {
        request.headers.addAll(_config!.headers!);
      }

      // 添加 SSE 选项中的头
      if (options.headers != null) {
        request.headers.addAll(options.headers!);
      }

      // 添加自定义头
      if (customHeaders != null) {
        request.headers.addAll(customHeaders);
      }

      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode != 200) {
        throw AxiosError.network(
          message:
              'SSE connection failed with status ${streamedResponse.statusCode}',
          request: AxiosRequest(
            url: url,
            method: HttpMethod.get,
            headers: request.headers,
          ),
        );
      }

      _isConnected = true;
      _reconnectAttempts = 0;

      // 处理 SSE 流
      _subscription = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) => _processSSELine(line),
            onError: (error) =>
                _handleError(error, url, options, customHeaders),
            onDone: () => _handleDisconnection(url, options, customHeaders),
          );
    } catch (error) {
      _handleError(error, url, options, customHeaders);
    }
  }

  String _buffer = '';
  String? _currentId;
  String? _currentEvent;
  String _currentData = '';
  int? _currentRetry;

  void _processSSELine(String line) {
    if (line.isEmpty) {
      // 空行表示事件结束
      if (_currentData.isNotEmpty) {
        final event = SSEEvent.now(
          id: _currentId,
          event: _currentEvent,
          data: _currentData.trimRight(),
          retry: _currentRetry,
        );
        _controller?.add(event);
      }

      // 重置状态
      _currentId = null;
      _currentEvent = null;
      _currentData = '';
      _currentRetry = null;
    } else if (line.startsWith('data:')) {
      _currentData += line.substring(5);
      if (!line.endsWith('\n')) {
        _currentData += '\n';
      }
    } else if (line.startsWith('id:')) {
      _currentId = line.substring(3).trim();
    } else if (line.startsWith('event:')) {
      _currentEvent = line.substring(6).trim();
    } else if (line.startsWith('retry:')) {
      _currentRetry = int.tryParse(line.substring(6).trim());
    } else if (line.startsWith(':')) {
      // 注释行，忽略
    }
  }

  void _handleError(
    dynamic error,
    String url,
    SSEOptions options,
    Map<String, String>? headers,
  ) {
    _isConnected = false;

    if (options.autoReconnect &&
        _reconnectAttempts < options.maxReconnectAttempts) {
      _reconnectAttempts++;
      Timer(options.reconnectInterval, () {
        _connectInternal(url, options, headers);
      });
    } else {
      _controller?.addError(AxiosError.network(
        message: 'SSE connection error: $error',
        request: AxiosRequest(
          url: url,
          method: HttpMethod.get,
        ),
        cause: error,
      ));
    }
  }

  void _handleDisconnection(
    String url,
    SSEOptions options,
    Map<String, String>? headers,
  ) {
    _isConnected = false;

    if (options.autoReconnect &&
        _reconnectAttempts < options.maxReconnectAttempts) {
      _reconnectAttempts++;
      Timer(options.reconnectInterval, () {
        _connectInternal(url, options, headers);
      });
    } else {
      _controller?.close();
    }
  }

  Uri _buildUri(String url) {
    if (url.startsWith('http')) {
      return Uri.parse(url);
    }

    if (_config?.baseURL == null) {
      throw ArgumentError('Relative URL requires baseURL to be set in config');
    }

    final baseUrl = _config!.baseURL!;
    return Uri.parse('$baseUrl$url');
  }

  /// 断开 SSE 连接
  Future<void> disconnect() async {
    _isConnected = false;
    await _subscription?.cancel();
    await _controller?.close();
    _subscription = null;
    _controller = null;
  }

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 当前重连次数
  int get reconnectAttempts => _reconnectAttempts;

  /// 关闭客户端
  void close() {
    disconnect();
    _client.close();
  }
}
