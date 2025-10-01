import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../axios_error.dart';
import '../axios_instance.dart';
import '../axios_request.dart';
import '../types/types.dart';
import 'sse_client.dart';
import 'stream_types.dart';
import 'websocket_client.dart';

/// AxiosInstance 的流式扩展
extension AxiosStreamingExtension on AxiosInstance {
  /// 流式 GET 请求
  ///
  /// 返回一个流式响应，可以逐步处理大量数据而不需要等待完整响应
  ///
  /// ```dart
  /// final response = await axios.getStream('/large-data');
  /// await for (final chunk in response.dataStream) {
  ///   print('Received chunk: $chunk');
  /// }
  /// ```
  Future<StreamedAxiosResponse<String>> getStream(
    String url, {
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
  }) async {
    final request = AxiosRequest(
      url: url,
      method: HttpMethod.get,
      headers: headers ?? {},
      params: params,
      timeout: timeout,
      baseURL: config.baseURL,
    );

    return _executeStreamRequest(request);
  }

  /// 流式 POST 请求
  Future<StreamedAxiosResponse<String>> postStream(
    String url, {
    RequestData? data,
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
  }) async {
    final request = AxiosRequest(
      url: url,
      method: HttpMethod.post,
      data: data,
      headers: headers ?? {},
      params: params,
      timeout: timeout,
      baseURL: config.baseURL,
    );

    return _executeStreamRequest(request);
  }

  /// 流式下载文件
  ///
  /// 提供下载进度回调和流式数据处理
  ///
  /// ```dart
  /// final stream = axios.downloadStream('/large-file.zip');
  /// await for (final progress in stream) {
  ///   print('Downloaded: ${progress.progressPercent}%');
  /// }
  /// ```
  Stream<DownloadProgress> downloadStream(
    String url, {
    QueryParameters? params,
    Headers? headers,
    Duration? timeout,
    StreamDownloadOptions? options,
  }) async* {
    final downloadOptions = options ?? const StreamDownloadOptions();
    final uri = _buildStreamUri(url, params);
    final requestHeaders = Map<String, String>.from(headers ?? {});

    // 添加配置中的默认头
    if (config.headers != null) {
      requestHeaders.addAll(config.headers!);
    }

    final request = http.Request('GET', uri);
    request.headers.addAll(requestHeaders);

    final streamedResponse = await http.Client().send(request);

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      throw AxiosError.network(
        message: 'Download failed with status ${streamedResponse.statusCode}',
        request: AxiosRequest(
          url: url,
          method: HttpMethod.get,
          headers: requestHeaders,
          params: params,
          baseURL: config.baseURL,
        ),
      );
    }

    int downloaded = 0;
    final total = streamedResponse.contentLength;
    DateTime? lastSpeedCalculation;
    int? lastDownloaded;
    double? currentSpeed;

    await for (final chunk in streamedResponse.stream) {
      downloaded += chunk.length;

      // 计算下载速度
      if (downloadOptions.calculateSpeed) {
        final now = DateTime.now();
        if (lastSpeedCalculation != null && lastDownloaded != null) {
          final timeDiff = now.difference(lastSpeedCalculation).inMilliseconds;
          if (timeDiff >=
              downloadOptions.speedCalculationInterval.inMilliseconds) {
            final bytesDiff = downloaded - lastDownloaded;
            currentSpeed = (bytesDiff * 1000) / timeDiff; // bytes per second
            lastSpeedCalculation = now;
            lastDownloaded = downloaded;
          }
        } else {
          lastSpeedCalculation = now;
          lastDownloaded = downloaded;
        }
      }

      // 计算剩余时间
      double? remainingTime;
      if (currentSpeed != null && currentSpeed > 0 && total != null) {
        final remaining = total - downloaded;
        remainingTime = remaining / currentSpeed;
      }

      yield DownloadProgress(
        downloaded: downloaded,
        total: total,
        speed: currentSpeed,
        remainingTime: remainingTime,
      );
    }
  }

  /// 创建 Server-Sent Events 连接
  ///
  /// 用于接收服务器推送的实时事件
  ///
  /// ```dart
  /// final sseStream = axios.connectSSE('/events');
  /// await for (final event in sseStream) {
  ///   print('Received event: ${event.data}');
  /// }
  /// ```
  Stream<SSEEvent> connectSSE(
    String url, {
    SSEOptions? options,
    Headers? headers,
  }) {
    final sseClient = SSEClient(
      client: http.Client(),
      config: config,
    );

    return sseClient.connect(url, options: options, headers: headers);
  }

  /// 创建 WebSocket 连接
  ///
  /// 用于双向实时通信
  ///
  /// ```dart
  /// final wsStream = axios.connectWebSocket('/ws');
  /// await for (final message in wsStream) {
  ///   print('Received: ${message.data}');
  /// }
  /// ```
  Stream<WebSocketMessage> connectWebSocket(
    String url, {
    WebSocketOptions? options,
  }) {
    final wsClient = WebSocketClient(config: config);
    return wsClient.connect(url, options: options);
  }

  /// 执行流式请求的内部方法
  Future<StreamedAxiosResponse<String>> _executeStreamRequest(
    AxiosRequest request,
  ) async {
    final uri = _buildStreamUri(request.url, request.params);
    final headers = Map<String, String>.from(request.headers);

    // 添加配置中的默认头
    if (config.headers != null) {
      headers.addAll(config.headers!);
    }

    // 设置默认 Content-Type
    if (request.method == HttpMethod.post && request.data != null) {
      headers.putIfAbsent('content-type', () => 'application/json');
    }

    final httpRequest = http.Request(_getMethodName(request.method), uri);
    httpRequest.headers.addAll(headers);

    // 添加请求体
    if (request.data != null) {
      if (request.data is String) {
        httpRequest.body = request.data as String;
      } else {
        httpRequest.body = jsonEncode(request.data);
      }
    }

    final streamedResponse = await http.Client().send(httpRequest);

    // 将字节流转换为字符串流
    final dataStream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    return StreamedAxiosResponse<String>(
      status: streamedResponse.statusCode,
      statusText: streamedResponse.reasonPhrase ?? '',
      headers: streamedResponse.headers,
      dataStream: dataStream,
      request: request,
      contentLength: streamedResponse.contentLength,
    );
  }

  /// 获取 HTTP 方法名称
  String _getMethodName(HttpMethod method) {
    switch (method) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.delete:
        return 'DELETE';
      case HttpMethod.head:
        return 'HEAD';
      case HttpMethod.options:
        return 'OPTIONS';
    }
  }

  /// 构建流式请求的 URI
  Uri _buildStreamUri(String url, QueryParameters? params) {
    String fullUrl;
    if (url.startsWith('http')) {
      fullUrl = url;
    } else {
      final baseUrl = config.baseURL ?? '';
      fullUrl = '$baseUrl$url';
    }

    final uri = Uri.parse(fullUrl);

    if (params == null || params.isEmpty) {
      return uri;
    }

    final queryParams = <String, String>{};
    params.forEach((key, value) {
      queryParams[key] = value.toString();
    });

    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });
  }
}
