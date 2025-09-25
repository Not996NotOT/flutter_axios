# Flutter Axios

<div align="center">

[![pub package](https://img.shields.io/pub/v/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)

受 [Axios](https://axios-http.com/) 启发的 Flutter Promise 风格 HTTP 客户端。提供拦截器、请求/响应转换、错误处理和**革命性的自动 JSON 转换**功能。

[English](README.md) | [中文](README_CN.md)

</div>

## ✨ 特性

### 🚀 核心 HTTP 功能
- **Promise 风格 API** - 熟悉的 Axios 语法
- **请求/响应拦截器** - 强大的中间件系统
- **自动请求/响应转换** - 内置 JSON 处理
- **请求/响应超时** - 可配置的超时时间
- **请求取消** - 使用 AbortController 取消请求
- **错误处理** - 全面的错误类型和处理
- **基础 URL 和相对 URL** - 灵活的 URL 管理
- **查询参数** - 简单的查询字符串处理

### 🎯 革命性 JSON 映射器
- **零代码 JSON 转换** - 自动序列化/反序列化
- **build_runner 集成** - 标准 Dart 代码生成
- **类型安全的 HTTP 请求** - `api.get<User>('/users/123')`
- **智能字段映射** - camelCase ↔ snake_case 转换
- **复杂对象支持** - 嵌套对象、列表、映射
- **Flutter 优化** - 无反射，纯编译时生成

### 🛠️ 开发体验
- **TypeScript 风格 API** - Web 开发者的熟悉体验
- **热重载支持** - build_runner 的监听模式
- **全面的文档** - 示例和指南
- **单元测试** - 可靠且生产就绪

## 🚀 快速开始

> **注解说明**: 我们使用 `@AxiosJson()` 而不是常见的 `@JsonSerializable()`，这样可以避免与 `json_annotation` 包冲突，同时保持简洁性。

### 安装

添加到你的 `pubspec.yaml`：

```yaml
dependencies:
  flutter_axios: ^1.1.0

dev_dependencies:
  build_runner: ^2.7.1  # 用于代码生成
```

### 基础用法

```dart
import 'package:flutter_axios/flutter_axios.dart';

void main() async {
  // 创建实例
  final api = Axios.create(AxiosConfig(
    baseURL: 'https://jsonplaceholder.typicode.com',
    timeout: Duration(seconds: 10),
  ));

  try {
    // GET 请求
    final response = await api.get('/posts/1');
    print(response.data);

    // POST 请求
    final newPost = await api.post('/posts', data: {
      'title': 'foo',
      'body': 'bar',
      'userId': 1,
    });
    print('创建成功: ${newPost.data}');

  } catch (e) {
    if (e is AxiosError) {
      print('错误: ${e.message}');
      print('状态码: ${e.response?.statusCode}');
    }
  } finally {
    api.close();
  }
}
```

## 🎯 自动 JSON 转换

### 第一步：定义你的模型

```dart
// lib/models/user.dart
import 'package:flutter_axios/flutter_axios.dart';

@AxiosJson()
class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final bool isActive;
  final List<String> tags;
  final Map<String, dynamic> profile;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.isActive,
    required this.tags,
    required this.profile,
    this.createdAt,
  });

  // 只需要业务方法 - JSON 映射会自动生成！
  User copyWith({
    String? name,
    String? email,
    int? age,
    bool? isActive,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      isActive: isActive ?? this.isActive,
      tags: tags,
      profile: profile,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'User{id: $id, name: $name, email: $email}';
}
```

### 第二步：生成代码

```bash
# 一次性生成
dart run build_runner build --delete-conflicting-outputs

# 监听模式（开发时推荐）
dart run build_runner watch --delete-conflicting-outputs
```

这将生成 `user.flutter_axios.g.dart` 文件，包含：
- 注册函数
- 扩展方法 (toJsonString, toMap)
- 工厂方法 (fromJsonString, fromMap)
- 列表处理工具

### 第三步：使用类型安全的 HTTP 请求

```dart
import 'package:flutter_axios/flutter_axios.dart';
import 'models/user.dart';
import 'models/user.flutter_axios.g.dart';  // 导入生成的文件

void main() async {
  // 初始化 JSON 映射器
  initializeJsonMapper();
  
  // 注册你的模型（每个模型一行！）
  initializeUserJsonMappers();
  
  // 创建 HTTP 客户端
  final api = Axios.create(AxiosConfig(
    baseURL: 'https://api.example.com',
  ));

  // 🎉 享受类型安全的 HTTP 请求！
  
  // GET 单个用户 - 自动反序列化
  final userResponse = await api.get<User>('/users/123');
  final user = userResponse.data;  // 已经是 User 对象！
  print('欢迎 ${user.name}！');

  // GET 用户列表 - 自动列表反序列化  
  final usersResponse = await api.get<List<User>>('/users');
  final users = usersResponse.data;  // 已经是 List<User>！
  print('找到 ${users.length} 个用户');

  // POST 新用户 - 自动序列化
  final newUser = User(
    id: 'new-id',
    name: '张三',
    email: 'zhangsan@example.com',
    age: 30,
    isActive: true,
    tags: ['开发者'],
    profile: {'技能': ['Flutter', 'Dart']},
    createdAt: DateTime.now(),
  );

  final createResponse = await api.post<User>('/users', data: newUser);
  print('创建用户: ${createResponse.data.name}');

  // PUT 更新用户 - 自动序列化
  final updatedUser = user.copyWith(name: '更新的名字');
  await api.put<User>('/users/123', data: updatedUser);

  // 使用生成的扩展方法
  final jsonString = user.toJsonString();  // 序列化为 JSON 字符串
  final userMap = user.toMap();           // 序列化为 Map

  // 使用生成的工厂方法
  final restoredUser = UserJsonFactory.fromJsonString(jsonString);
  final userFromMap = UserJsonFactory.fromMap(userMap);
  
  api.close();
}
```

## 🔧 高级功能

### 拦截器

```dart
final api = Axios.create(AxiosConfig(
  baseURL: 'https://api.example.com',
));

// 请求拦截器
api.interceptors.request.use(
  onRequest: (config) async {
    config.headers['Authorization'] = 'Bearer $token';
    print('→ ${config.method.toUpperCase()} ${config.url}');
    return config;
  },
  onError: (error) async {
    print('请求错误: ${error.message}');
    return error;
  },
);

// 响应拦截器  
api.interceptors.response.use(
  onResponse: (response) async {
    print('← ${response.statusCode} ${response.config.url}');
    return response;
  },
  onError: (error) async {
    if (error.response?.statusCode == 401) {
      // 处理未授权
      await refreshToken();
    }
    return error;
  },
);
```

### 错误处理

```dart
try {
  final response = await api.get<User>('/users/123');
  print('用户: ${response.data.name}');
} catch (e) {
  if (e is AxiosError) {
    switch (e.type) {
      case AxiosErrorType.connectionTimeout:
        print('连接超时');
        break;
      case AxiosErrorType.receiveTimeout:
        print('接收超时');
        break;
      case AxiosErrorType.badResponse:
        print('响应错误: ${e.response?.statusCode}');
        break;
      case AxiosErrorType.connectionError:
        print('连接错误: ${e.message}');
        break;
      case AxiosErrorType.unknown:
        print('未知错误: ${e.message}');
        break;
    }
  }
}
```

### 请求取消

```dart
final cancelToken = CancelToken();

// 开始请求
final future = api.get('/slow-endpoint', cancelToken: cancelToken);

// 5秒后取消
Timer(Duration(seconds: 5), () {
  cancelToken.cancel('请求超时');
});

try {
  final response = await future;
  print(response.data);
} catch (e) {
  if (e is AxiosError && e.type == AxiosErrorType.cancelled) {
    print('请求已取消');
  }
}
```

### 文件上传

```dart
import 'dart:io';

final file = File('path/to/image.jpg');
final formData = FormData();
formData.files.add(MapEntry(
  'file',
  await MultipartFile.fromFile(file.path, filename: 'image.jpg'),
));
formData.fields.add(MapEntry('description', '头像照片'));

final response = await api.post('/upload', data: formData);
print('上传完成: ${response.data}');
```

## 🏗️ JSON 映射器功能

### 支持的类型

build_runner 自动处理：

**基础类型：**
- `String`、`int`、`double`、`bool`
- `DateTime`（ISO 8601 转换）
- 可选变体（`String?`、`int?` 等）

**集合类型：**
- `List<String>`、`List<int>`、`List<T>`
- `Map<String, dynamic>`
- 嵌套对象和列表

**智能转换：**
- `camelCase` ↔ `snake_case` 字段映射
- `userName` ↔ `user_name`
- `isActive` ↔ `is_active`
- `createdAt` ↔ `created_at`

### 复杂嵌套对象

```dart
@JsonSerializable()
class Address {
  final String street;
  final String city;
  final String zipCode;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.zipCode,
    required this.country,
  });
}

@JsonSerializable()
class Company {
  final String name;
  final Address address;
  final List<String> departments;

  const Company({
    required this.name,
    required this.address,
    required this.departments,
  });
}

@JsonSerializable()
class Employee {
  final String id;
  final String name;
  final Company company;
  final List<Address> previousAddresses;
  final Map<String, dynamic> skills;

  const Employee({
    required this.id,
    required this.name,
    required this.company,
    required this.previousAddresses,
    required this.skills,
  });
}

// 使用
void main() async {
  initializeJsonMapper();
  initializeAddressJsonMappers();
  initializeCompanyJsonMappers();  
  initializeEmployeeJsonMappers();

  final api = Axios.create(AxiosConfig(baseURL: 'https://api.company.com'));

  // 复杂嵌套对象 - 自动处理！
  final employee = await api.get<Employee>('/employees/123');
  print('员工: ${employee.data.name}');
  print('公司: ${employee.data.company.name}');
  print('城市: ${employee.data.company.address.city}');
}
```

### 生成的扩展方法

每个模型都会获得有用的扩展方法：

```dart
final user = User(/* ... */);

// 序列化扩展
final jsonString = user.toJsonString();     // 转换为 JSON 字符串
final userMap = user.toMap();               // 转换为 Map

// 工厂方法  
final newUser = UserJsonFactory.fromJsonString(jsonString);
final userFromMap = UserJsonFactory.fromMap(userMap);
final userList = UserJsonFactory.listFromJsonString(jsonArrayString);
```

## 📊 性能对比

| 特性 | 手写 JSON | json_serializable | flutter_axios |
|------|-----------|------------------|---------------|
| **开发时间** | 20-30分钟/模型 | 10-15分钟/模型 | **2-3分钟/模型** |
| **代码行数** | 80-120行 | 40-60行 | **0行用户代码** |
| **维护成本** | 高 | 中等 | **最低** |
| **类型安全** | 手动保证 | 完整 | **完整** |
| **运行性能** | 快 | 快 | **快** |
| **编译时间** | 快 | 中等 | **快** |
| **学习曲线** | 高 | 中等 | **低** |
| **热重载** | 手动 | 需要重建 | **监听模式** |

## 🔄 迁移指南

### 从手写 JSON 处理迁移

1. **添加注解：**
   ```dart
   @JsonSerializable()
   class User {
     // 现有字段...
   }
   ```

2. **移除手动代码：**
   ```dart
   // 移除这些方法：
   // factory User.fromJson(Map<String, dynamic> json) { ... }
   // Map<String, dynamic> toJson() { ... }
   ```

3. **生成和注册：**
   ```bash
   dart run build_runner build
   ```
   ```dart
   initializeJsonMapper();
   initializeUserJsonMappers();
   ```

### 从 json_annotation 迁移

1. **更新依赖：**
   ```yaml
   dependencies:
     flutter_axios: ^1.1.0  # 替换 json_annotation
   
   dev_dependencies:
     build_runner: ^2.7.1   # 保留 build_runner
   ```

2. **更新导入：**
   ```dart
   import 'package:flutter_axios/flutter_axios.dart';  // 替换 json_annotation
   ```

3. **重新生成代码：**
   ```bash
   dart run build_runner clean
   dart run build_runner build
   ```

## 🛠️ 开发工作流

### 监听模式（推荐）

```bash
# 启动监听模式 - 文件变更时自动重新生成
dart run build_runner watch --delete-conflicting-outputs
```

### 生产构建

```bash
# 生产环境一次性生成
dart run build_runner build --delete-conflicting-outputs
```

### 清理生成文件

```bash
# 清理所有生成的文件
dart run build_runner clean
```

## 🔧 配置

### 自定义构建配置

在项目根目录创建 `build.yaml`：

```yaml
targets:
  $default:
    builders:
      flutter_axios|simple_json:
        enabled: true
        generate_for:
          - lib/**
          - test/**
        options:
          generate_extensions: true
          generate_factories: true
```

### 排除文件

```yaml
targets:
  $default:
    builders:
      flutter_axios|simple_json:
        generate_for:
          - lib/**
          - "!lib/legacy/**"  # 排除遗留代码
```

## 🐛 故障排除

### 常见问题

**问：找不到生成的文件？**
```bash
# 确保运行了代码生成
dart run build_runner build
```

**问：生成函数的导入错误？**
```dart
// 确保导入了生成的文件
import 'user.flutter_axios.g.dart';
```

**问：不支持的类型？**
- 检查字段类型是否在支持类型列表中
- 复杂自定义类型可能需要自己的 `@JsonSerializable()` 注解

**问：监听模式不工作？**
```bash
# 重启监听模式
dart run build_runner clean
dart run build_runner watch --delete-conflicting-outputs
```

**问：更新后构建错误？**
```bash
# 清理并重新构建
dart run build_runner clean
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

## 🤝 贡献

欢迎贡献！请随时提交 Pull Request。

### 开发设置

```bash
git clone https://github.com/Not996NotOT/flutter_axios.git
cd flutter_axios
dart pub get
dart test
```

### 运行示例

```bash
cd example
dart pub get
dart run build_runner build
dart main.dart
```

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- 受 [Axios](https://axios-http.com/) 启发 - JavaScript 的优秀 HTTP 客户端
- 使用 [build_runner](https://pub.dev/packages/build_runner) 构建 - Dart 的代码生成工具
- 感谢 Flutter 和 Dart 团队提供的出色框架

## 📈 路线图

- [ ] GraphQL 支持
- [ ] WebSocket 集成  
- [ ] 缓存机制
- [ ] 重试机制
- [ ] 上传进度跟踪
- [ ] 更多序列化选项

---

<div align="center">

**[⭐ 为这个仓库点星](https://github.com/Not996NotOT/flutter_axios) 如果它对你有帮助！**

用 ❤️ 为 Flutter 社区制作

</div>