# Flutter Axios 示例

这是一个完整的 Flutter Axios + build_runner 使用示例，展示了如何使用现代化的方式进行 HTTP 请求和 JSON 处理。

## 🚀 快速开始

### 1. 安装依赖

```bash
dart pub get
```

### 2. 生成 JSON 映射代码

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. 运行示例

```bash
dart lib/main.dart
```

## 📁 项目结构

```
example/
├── lib/
│   ├── main.dart                    # 主示例文件
│   ├── models/
│   │   ├── user.dart               # 用户模型
│   │   ├── user.flutter_axios.g.dart      # 生成的用户 JSON 映射
│   │   ├── product.dart            # 产品模型
│   │   └── product.flutter_axios.g.dart   # 生成的产品 JSON 映射
│   └── services/
│       └── api_service.dart        # API 服务封装
├── pubspec.yaml                    # 依赖配置
└── README.md                       # 本文件
```

## 🎯 核心特性演示

### 1. JSON 序列化/反序列化

```dart
// 定义模型（只需要注解）
@JsonSerializable()
class User {
  final String id;
  final String name;
  // ... 其他字段
}

// build_runner 自动生成 JSON 映射代码
// 运行：dart run build_runner build

// 使用生成的方法
final user = User(id: '1', name: '张三');
final jsonString = user.toJsonString();        // 序列化
final restored = UserJsonFactory.fromJsonString(jsonString); // 反序列化
```

### 2. 类型安全的 HTTP 请求

```dart
// 自动类型转换
final response = await api.get<User>('/users/1');
final user = response.data;  // 已经是 User 对象！

final users = await api.get<List<User>>('/users');
final userList = users.data; // 已经是 List<User>！
```

### 3. 拦截器系统

```dart
class CustomInterceptor extends Interceptor {
  @override
  FutureOr<AxiosRequest> onRequest(AxiosRequest request) async {
    print('请求: ${request.method} ${request.url}');
    return request;
  }

  @override
  FutureOr<AxiosResponse<dynamic>> onResponse(AxiosResponse<dynamic> response) async {
    print('响应: ${response.status}');
    return response;
  }
}
```

### 4. 错误处理

```dart
try {
  final response = await api.get<User>('/users/1');
} catch (e) {
  if (e is AxiosError) {
    print('错误类型: ${e.type}');
    print('状态码: ${e.response?.status}');
  }
}
```

## 🔧 开发工作流

### 监听模式（推荐）

```bash
# 启动监听模式，文件变更时自动重新生成
dart run build_runner watch --delete-conflicting-outputs
```

### 一次性构建

```bash
# 生产环境构建
dart run build_runner build --delete-conflicting-outputs
```

### 清理生成文件

```bash
# 清理所有生成的文件
dart run build_runner clean
```

## 📊 示例输出

运行示例时，你将看到以下演示：

1. **JSON 映射器初始化** - 注册模型的序列化方法
2. **JSON 序列化演示** - 对象 ↔ JSON 字符串转换
3. **HTTP 请求演示** - GET、POST 等请求
4. **CRUD 操作演示** - 增删改查完整流程
5. **错误处理演示** - 网络错误、超时等场景

## 💡 最佳实践

### 1. 模型定义

- 使用 `@JsonSerializable()` 注解
- 提供完整的构造函数
- 添加 `copyWith` 方法便于更新
- 实现 `toString`、`==`、`hashCode` 方法

### 2. API 服务

- 封装所有 HTTP 请求到服务类
- 使用拦截器进行日志和错误处理
- 统一的错误处理策略

### 3. 开发流程

- 先定义模型，再运行 `build_runner`
- 使用 watch 模式进行开发
- 利用生成的扩展方法和工厂方法

## 🎉 总结

这个示例展示了 Flutter Axios 与 build_runner 结合的强大功能：

✅ **零手写 JSON 代码** - 完全自动生成  
✅ **类型安全请求** - 编译时检查  
✅ **现代化工作流** - 标准 build_runner  
✅ **完整功能演示** - 从基础到高级  
✅ **生产就绪** - 错误处理和最佳实践  

开始享受现代化的 HTTP 客户端开发体验吧！🚀

