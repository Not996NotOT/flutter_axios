# Flutter Axios

一个受 [Axios](https://axios-http.com/) 启发的基于 Promise 的 Flutter HTTP 客户端。提供拦截器、请求/响应转换、错误处理等功能。

[![pub package](https://img.shields.io/pub/v/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)

## 功能特性

- ✅ 类似 Axios 的 Promise 风格 API
- ✅ 请求和响应拦截器  
- ✅ 请求和响应数据转换
- ✅ 自动请求体序列化（JSON、表单数据）
- ✅ 自动响应数据解析
- ✅ 详细的错误处理和错误类型
- ✅ 请求/响应超时支持
- ✅ 查询参数序列化
- ✅ 自定义实例创建和基础配置
- ✅ 上传/下载进度回调
- ✅ 请求取消支持

## 安装

在你的 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  flutter_axios: ^1.0.0
```

然后运行：

```bash
flutter pub get
```

## 快速开始

### 基本用法

执行 `GET` 请求（类似 [Axios 示例](https://axios-http.com/docs/example)）：

```dart
import 'package:flutter_axios/flutter_axios.dart';

// 根据给定 ID 请求用户信息
try {
  final response = await Axios.get<Map<String, dynamic>>(
    'https://jsonplaceholder.typicode.com/users/1'
  );
  // 处理成功响应
  print(response.data);
} catch (error) {
  // 处理错误
  print(error);
}

// 也可以这样写
try {
  final response = await Axios.get<List<dynamic>>(
    'https://jsonplaceholder.typicode.com/users',
    params: {
      'id': 1,
      '_limit': 1,
    },
  );
  print(response.data);
} catch (error) {
  print(error);
} finally {
  // 总是会执行
  print('请求完成');
}

// 想使用 async/await？这样做：
Future<void> getUser() async {
  try {
    final response = await Axios.get<Map<String, dynamic>>(
      'https://jsonplaceholder.typicode.com/users/1'
    );
    print(response.data);
  } catch (error) {
    print(error);
  }
}
```

### 创建实例

```dart
final api = Axios.create(const AxiosConfig(
  baseURL: 'https://api.example.com',
  timeout: Duration(seconds: 30),
  headers: {
    'Authorization': 'Bearer your-token',
    'Content-Type': 'application/json',
  },
));

// 使用实例
final response = await api.get<List<dynamic>>('/users');
```

## API 参考

### Axios 类

提供常用 HTTP 操作的静态方法：

```dart
// GET 请求
Future<AxiosResponse<T>> Axios.get<T>(String url, {
  QueryParameters? params,
  Headers? headers,
  Duration? timeout,
  ProgressCallback? onDownloadProgress,
  ValidateStatus? validateStatus,
});

// POST 请求  
Future<AxiosResponse<T>> Axios.post<T>(String url, {
  RequestData? data,
  QueryParameters? params,
  Headers? headers,
  Duration? timeout,
  ProgressCallback? onUploadProgress,
  ProgressCallback? onDownloadProgress,
  ValidateStatus? validateStatus,
});

// PUT、PATCH、DELETE、HEAD 方法同样可用
```

### AxiosInstance

创建带有自定义配置的实例：

```dart
final instance = Axios.create(AxiosConfig(
  baseURL: 'https://api.example.com',
  timeout: Duration(seconds: 10),
  headers: {'Authorization': 'Bearer token'},
));
```

### 请求选项

配置单个请求：

```dart
final response = await Axios.request<Map<String, dynamic>>(
  RequestOptions(
    url: '/users',
    method: HttpMethod.get,
    params: {'page': 1, 'limit': 10},
    headers: {'X-Custom-Header': 'value'},
    timeout: Duration(seconds: 5),
  ),
);
```

### 响应对象

```dart
class AxiosResponse<T> {
  final T data;              // 解析后的响应数据
  final int status;          // HTTP 状态码
  final String statusText;   // HTTP 状态消息
  final Headers headers;     // 响应头
  final AxiosRequest request; // 原始请求
  final String? rawData;     // 原始响应体
}
```

## 拦截器

### 请求拦截器

在请求发送前修改请求：

```dart
// 添加认证头
Axios.interceptors.add(AuthInterceptor(token: 'your-token'));

// 自定义请求拦截器
Axios.interceptors.add(RequestInterceptor((request) {
  print('发送请求到 ${request.url}');
  return request.copyWith(
    headers: {...request.headers, 'X-Timestamp': DateTime.now().toString()},
  );
}));
```

### 响应拦截器

处理响应或错误：

```dart
// 日志拦截器
Axios.interceptors.add(LoggingResponseInterceptor(
  logger: (message) => print(message),
));

// 自定义响应拦截器
Axios.interceptors.add(ResponseInterceptor((response) {
  print('从 ${response.request.url} 收到 ${response.status} 响应');
  return response;
}));
```

### 内置拦截器

- `AuthInterceptor` - 添加认证头
- `HeadersInterceptor` - 添加自定义头
- `LoggingRequestInterceptor` - 记录请求日志
- `LoggingResponseInterceptor` - 记录响应日志
- `RetryInterceptor` - 重试失败请求

## 错误处理

Flutter Axios 提供详细的错误信息：

```dart
try {
  final response = await Axios.get('/api/data');
  print(response.data);
} catch (error) {
  if (error is AxiosError) {
    switch (error.type) {
      case AxiosErrorType.network:
        print('网络错误: ${error.message}');
        break;
      case AxiosErrorType.timeout:
        print('请求超时');
        break;
      case AxiosErrorType.response:
        print('HTTP 错误: ${error.response?.status}');
        break;
      case AxiosErrorType.cancelled:
        print('请求已取消');
        break;
      default:
        print('未知错误: ${error.message}');
    }
  }
}
```

## 配置

### 全局配置

配置默认实例：

```dart
// 访问默认实例
final defaultInstance = Axios.instance;

// 添加全局拦截器
Axios.interceptors.add(LoggingRequestInterceptor(
  logger: (message) => debugPrint(message),
));
```

### 实例配置

```dart
final api = Axios.create(const AxiosConfig(
  baseURL: 'https://api.example.com',
  timeout: Duration(seconds: 30),
  headers: {
    'User-Agent': 'MyApp/1.0',
    'Accept': 'application/json',
  },
  validateStatus: (status) => status != null && status < 400,
));
```

## 示例

### 带进度的文件上传

```dart
final response = await Axios.post<Map<String, dynamic>>(
  '/upload',
  data: formData,
  onUploadProgress: (count, total) {
    final progress = count / total;
    print('上传进度: ${(progress * 100).toStringAsFixed(1)}%');
  },
);
```

### 查询参数

```dart
final response = await Axios.get<List<dynamic>>(
  '/users',
  params: {
    'page': 1,
    'limit': 20,
    'sort': 'name',
    'active': true,
  },
);
```

### 自定义头

```dart
final response = await Axios.post<Map<String, dynamic>>(
  '/api/data',
  data: {'key': 'value'},
  headers: {
    'Authorization': 'Bearer token',
    'X-API-Key': 'api-key',
    'Content-Type': 'application/json',
  },
);
```

## 测试

模拟 HTTP 客户端进行测试：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_axios/flutter_axios.dart';

void main() {
  test('应该处理 GET 请求', () async {
    final mockClient = MockClient();
    final axios = AxiosInstance(client: mockClient);
    
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('{"result": "success"}', 200));
    
    final response = await axios.get<Map<String, dynamic>>('/test');
    
    expect(response.data['result'], 'success');
  });
}
```

## 从 http 包迁移

### 之前（http 包）

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

final response = await http.get(
  Uri.parse('https://api.example.com/users'),
  headers: {'Authorization': 'Bearer token'},
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  print(data);
} else {
  throw Exception('加载数据失败');
}
```

### 之后（flutter_axios）

```dart
import 'package:flutter_axios/flutter_axios.dart';

final api = Axios.create(const AxiosConfig(
  baseURL: 'https://api.example.com',
  headers: {'Authorization': 'Bearer token'},
));

try {
  final response = await api.get<List<dynamic>>('/users');
  print(response.data);
} catch (error) {
  print('错误: $error');
}
```

## CRUD 示例

查看 `example/lib/main.dart` 中的完整 CRUD 示例，展示了如何使用 Flutter Axios 与真实的 RESTful API 进行交互。

该示例包括：
- 获取用户列表（GET）
- 创建新用户（POST）
- 更新用户信息（PUT）
- 删除用户（DELETE）
- 带分页的查询
- 错误处理和加载状态
- 美观的 Flutter UI

## 贡献

欢迎贡献代码！请随时提交 Pull Request。

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解更改列表。
