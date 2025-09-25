# Flutter Axios

> **文档语言**: [English](README.md) | [中文](README_CN.md) | [日本語](README_JP.md)

一个强大的 Flutter HTTP 客户端，灵感来自 Axios.js，具有革命性的 JSON 映射和 build_runner 集成。

[![pub package](https://img.shields.io/pub/v/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)
[![popularity](https://img.shields.io/pub/popularity/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)
[![likes](https://img.shields.io/pub/likes/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)

## ✨ 核心特性

- **🚀 零代码 JSON 映射** - 只需添加 `@AxiosJson()` 注解，无需样板代码
- **🔧 build_runner 集成** - 标准 Dart 生态系统工具链
- **🎯 类型安全请求** - `await api.get<User>('/users/123')`
- **⚡ 10倍开发速度** - 每个模型 2-3 分钟 vs 20-30 分钟
- **🔄 智能序列化** - 自动 camelCase ↔ snake_case 转换
- **📱 Flutter 优化** - 无 dart:mirrors，仅编译时生成
- **🌐 Promise 风格 API** - Web 开发者熟悉的 Axios.js 体验
- **🛡️ 全面错误处理** - 网络、超时和 API 错误
- **🔌 强大拦截器** - 请求/响应转换和日志记录
- **🎨 TypeScript 风格 API** - Web 开发者的熟悉体验
- **🔥 热重载支持** - build_runner 的监听模式
- **📚 全面的文档** - 示例和指南
- **✅ 单元测试** - 可靠且生产就绪

## 🚀 快速开始

> **注解说明**: 我们使用 `@AxiosJson()` 而不是常见的 `@JsonSerializable()`，这样可以避免与 `json_annotation` 包冲突，同时保持简洁性。

### 安装

添加到你的 `pubspec.yaml`：

```yaml
dependencies:
  flutter_axios: ^1.1.4

dev_dependencies:
  build_runner: ^2.4.12
```

### 步骤 1: 定义模型

只需要添加一个注解：

```dart
import 'package:flutter_axios/flutter_axios.dart';

@AxiosJson()  // 🎉 简洁的注解，避免框架冲突
class User {
  final String id;
  final String name;
  final String email;
  
  const User({required this.id, required this.name, required this.email});
}
```

### 步骤 2: 生成代码

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 步骤 3: 使用它

```dart
import 'package:flutter_axios/flutter_axios.dart';
import 'models/user.dart';
import 'axios_json_initializers.g.dart'; // 全局初始化器

void main() async {
  // 🎉 一行代码初始化所有 JSON 映射器！
  initializeAllAxiosJsonMappers();
  
  // 创建 HTTP 客户端
  final api = Axios.create(AxiosOptions(
    baseURL: 'https://api.example.com',
  ));
  
  // 类型安全的 HTTP 请求
  final response = await api.get<List<User>>('/users');
  final users = response.data; // 已经解析为 List<User>！
  
  // 创建新用户
  final newUser = User(id: '1', name: 'John', email: 'john@example.com');
  await api.post<User>('/users', data: newUser); // 自动序列化！
}
```

## 🔧 多种初始化选项

### 选项一：初始化所有（推荐）
```dart
import 'axios_json_initializers.g.dart';

void main() {
  // 自动初始化所有 @AxiosJson() 类
  initializeAllAxiosJsonMappers();
  runApp(MyApp());
}
```

### 选项二：初始化指定类型
```dart
import 'axios_json_initializers.g.dart';

void main() {
  // 只初始化你需要的特定类型
  initializeAxiosJsonMappers([User, Product, Order]);
  runApp(MyApp());
}
```

### 选项三：手动初始化（传统方式）
```dart
import 'models/user.flutter_axios.g.dart';
import 'models/product.flutter_axios.g.dart';

void main() {
  initializeJsonMapper();
  initializeUserJsonMappers();
  initializeProductJsonMappers();
  runApp(MyApp());
}
```

## 🎯 完整 CRUD 示例

这是一个使用 MockAPI 的真实示例：

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_axios/flutter_axios.dart';

// 导入模型和生成的代码
import 'models/user.dart';
import 'models/user.flutter_axios.g.dart';

void main() {
  initializeJsonMapper();
  initializeUserJsonMappers();
  runApp(MyApp());
}

class UserService {
  late final AxiosInstance _api;
  
  UserService() {
    _api = Axios.create(AxiosOptions(
      baseURL: 'https://your-api.mockapi.io',
      timeout: Duration(seconds: 10),
    ));
  }
  
  // GET - 读取用户
  Future<List<User>> getUsers() async {
    final response = await _api.get('/user');
    if (response.data is List) {
      final rawList = response.data as List;
      return rawList.map((item) => 
        UserJsonFactory.fromMap(item as Map<String, dynamic>)
      ).whereType<User>().toList();
    }
    return [];
  }
  
  // POST - 创建用户
  Future<User?> createUser(User user) async {
    final response = await _api.post<User>('/user', data: user);
    return response.data;
  }
  
  // PUT - 更新用户
  Future<User?> updateUser(String id, User user) async {
    final response = await _api.put<User>('/user/$id', data: user);
    return response.data;
  }
  
  // DELETE - 删除用户
  Future<bool> deleteUser(String id) async {
    try {
      await _api.delete<void>('/user/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
}

// 模型定义 (在 models/user.dart 中)
@AxiosJson()
class User {
  final String id;
  final String name;
  final String avatar;
  final String city;

  const User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.city,
  });

  User copyWith({String? id, String? name, String? avatar, String? city}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      city: city ?? this.city,
    );
  }
}
```

## 🔧 高级特性

### 1. 复杂嵌套对象

```dart
@AxiosJson()
class Order {
  final String id;
  final User customer;           // 嵌套对象
  final List<Product> items;     // 对象列表
  final Address? shipping;       // 可空对象
  final DateTime createdAt;      // 自动 ISO8601 转换
  final Map<String, dynamic> metadata; // 动态数据
  
  const Order({
    required this.id,
    required this.customer,
    required this.items,
    this.shipping,
    required this.createdAt,
    this.metadata = const {},
  });
}

@AxiosJson()
class Product {
  final String id;
  final String name;
  final double price;
  final List<String> tags;
  
  const Product({required this.id, required this.name, required this.price, required this.tags});
}
```

### 2. 生成的辅助方法

运行 `build_runner` 后，你会得到强大的辅助方法：

```dart
// 序列化
final jsonString = user.toJsonString();
final map = user.toMap();

// 反序列化
final user = UserJsonFactory.fromJsonString('{"id":"1","name":"John"}');
final users = UserJsonFactory.listFromJsonString('[{"id":"1"},{"id":"2"}]');

// 从 Map
final user = UserJsonFactory.fromMap({'id': '1', 'name': 'John'});
final users = UserJsonFactory.listFromMaps([{'id': '1'}, {'id': '2'}]);
```

### 3. 自动 JSON 处理的拦截器

```dart
class LoggingInterceptor extends Interceptor {
  @override
  Future<AxiosRequest> onRequest(AxiosRequest request) async {
    print('🚀 ${request.method} ${request.url}');
    if (request.data != null) {
      // 数据自动序列化
      print('📤 ${request.data}');
    }
    return request;
  }

  @override
  Future<AxiosResponse> onResponse(AxiosResponse response) async {
    print('✅ ${response.status} ${response.request.url}');
    // 响应数据自动解析
    print('📥 ${response.data}');
    return response;
  }
}

final api = Axios.create(AxiosOptions(baseURL: 'https://api.example.com'));
api.interceptors.add(LoggingInterceptor());
```

### 4. 错误处理

```dart
try {
  final user = await api.get<User>('/users/123');
  print('用户: ${user.data?.name}');
} on AxiosError catch (e) {
  if (e.type == AxiosErrorType.timeout) {
    print('请求超时');
  } else if (e.response?.status == 404) {
    print('用户未找到');
  } else {
    print('错误: ${e.message}');
  }
}
```

## 🔄 开发工作流

### 监听模式（推荐）

```bash
dart run build_runner watch --delete-conflicting-outputs
```

这会监听变化并在你修改模型时自动重新生成代码。

### 单次构建

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 清理生成的文件

```bash
dart run build_runner clean
```

## 📊 性能对比

| 功能 | 手动 JSON | json_serializable | flutter_axios |
|------|----------|------------------|---------------|
| 开发时间 | 20-30 分钟/模型 | 10-15 分钟/模型 | **2-3 分钟/模型** |
| 代码行数 | 80-120 行 | 40-60 行 | **0 用户代码行** |
| 类型安全 | 手动 | 完整 | **完整** |
| 热重载 | 手动 | 需要重建 | **监听模式** |
| 框架冲突 | 无 | 可能 | **无** |
| 学习曲线 | 高 | 中等 | **低** |

## 🏗️ 项目结构

```
your_project/
├── lib/
│   ├── models/
│   │   ├── user.dart                      # 你的模型
│   │   └── user.flutter_axios.g.dart      # 生成的代码
│   └── main.dart
├── pubspec.yaml
└── build.yaml                             # build_runner 配置
```

## 🔧 配置

### build.yaml

```yaml
targets:
  $default:
    builders:
      flutter_axios:json_serializable:
        enabled: true
        generate_for:
          - lib/**
          - example/lib/**
```

### 支持的类型

- **基础类型**: `String`, `int`, `double`, `bool`, `DateTime`
- **集合**: `List<T>`, `Map<String, dynamic>`
- **可空类型**: `String?`, `DateTime?` 等
- **自定义对象**: 任何带有 `@AxiosJson()` 的类
- **嵌套**: 复杂对象层次结构

## 🚀 迁移指南

### 从 json_annotation 迁移

将 `@JsonSerializable()` 替换为 `@AxiosJson()`：

```dart
// 之前
@JsonSerializable()
class User {
  // ... 字段
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// 之后
@AxiosJson()
class User {
  // ... 只需要字段，不需要手动方法！
}
```

### 从手动 JSON 迁移

将所有手动 `fromJson`/`toJson` 替换为 `@AxiosJson()`：

```dart
// 之前: 50+ 行手动 JSON 代码
class User {
  final String id;
  final String name;
  
  User({required this.id, required this.name});
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// 之后: 只需要注解！
@AxiosJson()
class User {
  final String id;
  final String name;
  
  const User({required this.id, required this.name});
}
```

## 🆕 v1.1.1 新特性

### 变更
- **注解重命名**: `@JsonSerializable()` → `@AxiosJson()`
  - 避免与 `json_annotation` 包冲突
  - 更简洁的 10 字符注解
  - 明确表示这是 Flutter Axios 专用
  - 保持所有现有功能

## 🛠️ 故障排除

### 常见问题

1. **找不到生成的文件**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **类型 'dynamic' 不是子类型**
   - 确保初始化 JSON 映射器：`initializeUserJsonMappers()`
   - 检查你的模型是否有 `@AxiosJson()` 注解

3. **build runner 冲突**
   ```bash
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

### 最佳实践

- 尽可能使用 `const` 构造函数
- 在 `main()` 中早期初始化 JSON 映射器
- 开发期间使用监听模式
- 适当处理可空字段
- 使用描述性字段名

## 📚 示例

查看 `/example` 目录了解：
- 完整 CRUD 应用程序
- 复杂嵌套对象
- 错误处理模式
- 拦截器使用
- 真实 API 集成

## 🤝 贡献

我们欢迎贡献！请查看我们的[贡献指南](CONTRIBUTING.md)了解详情。

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## ⭐ 支持我们

如果这个包对你有帮助，请在 [GitHub](https://github.com/Not996NotOT/flutter_axios) 上给个 ⭐ 并在 [pub.dev](https://pub.dev/packages/flutter_axios) 上点个 👍！