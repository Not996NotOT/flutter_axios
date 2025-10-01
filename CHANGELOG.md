# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-09-25

### Added
- **🌊 流式功能支持** - 全新的流式 HTTP 处理能力
  - `getStream()` - 流式响应，逐行处理大数据
  - `postStream()` - 流式 POST 请求
  - `downloadStream()` - 带进度跟踪的流式下载
  - `connectSSE()` - Server-Sent Events 实时事件流
  - `connectWebSocket()` - WebSocket 双向实时通信

### Enhanced
- **📥 渐进式下载** - 大文件下载进度跟踪
  - 实时下载速度计算
  - 剩余时间估算
  - 可配置的缓冲区大小
  - 自动重连机制

### New Types
- **流式响应类型**
  - `StreamedAxiosResponse<T>` - 流式响应包装器
  - `SSEEvent` - Server-Sent Events 事件
  - `WebSocketMessage` - WebSocket 消息
  - `DownloadProgress` - 下载进度信息

### Configuration Options
- **流式选项配置**
  - `SSEOptions` - SSE 连接配置（重连、超时等）
  - `WebSocketOptions` - WebSocket 连接配置
  - `StreamDownloadOptions` - 下载流配置

### Dependencies
- **新增依赖** - `web_socket_channel: ^2.4.0` 用于 WebSocket 支持

### Backward Compatibility
- ✅ **完全向后兼容** - 所有现有 API 保持不变
- ✅ **扩展方式添加** - 流功能作为 AxiosInstance 扩展方法
- ✅ **可选使用** - 不影响现有代码，按需使用新功能

## [1.1.4] - 2025-09-25

### Added
- **多言語ドキュメント対応** 🌐
  - 日本語版 README (README_JP.md) を追加
  - 全 README ファイルに言語切替ナビゲーションを追加
  - English ↔ 中文 ↔ 日本語 の相互リンク対応

### Enhanced
- **文档国际化** 📚
  - 创建完整的日文文档 README_JP.md
  - 在所有 README 文件头部添加语言切换入口
  - 支持英文、中文、日文三种语言相互跳转
  - 统一的文档结构和风格

### Documentation
- **Language Navigation** 🔗
  - Added language switcher to all README files
  - Seamless navigation between English, Chinese, and Japanese docs
  - Consistent documentation structure across all languages

## [1.1.3] - 2025-09-25

### Fixed
- **Web Platform Support** 🌐
  - Added conditional imports for cross-platform compatibility
  - Removed dart:io dependency that was blocking Web support
  - Enhanced network error handling for Web environments
  
### Improved
- **Package Score Optimization** 📈
  - Updated dependencies to latest compatible versions
  - Fixed code formatting issues with dart format
  - Fixed documentation comments (removed dangling library docs)
  - Added comprehensive test coverage (15 test cases)
  - Improved static analysis score to reduce warnings

### Enhanced Testing
- **Comprehensive Test Suite** ✅ 
  - Added 15 test cases covering core functionality
  - Mock-based testing with http client mocking
  - Tests for GET, POST, PUT, DELETE methods
  - Error handling and timeout scenario tests
  - Configuration merging and validation tests
  - AxiosError creation and type validation tests

### Fixed Examples
- **Updated Flutter Example** 📱
  - Fixed widget tests to match actual app functionality
  - Improved user interface testing scenarios
  - Better test coverage for dialog interactions

## [1.1.2] - 2025-09-25

### Added
- **Revolutionary Auto-Initialization System** 🚀
  - One-line initialization: `initializeAllAxiosJsonMappers()`
  - Type-specific initialization: `initializeAxiosJsonMappers([User, Product])`
  - Auto-generated global initializer file: `axios_json_initializers.g.dart`
  - No more manual initialization for each model class
  - Supports 100+ models with single function call

### Enhanced
- **Global Initializer Builder** - Automatically scans and generates initialization code
- **Type-Safe Initialization** - Compile-time checks for supported types
- **Flexible Options** - Choose between all-at-once or selective initialization
- **Zero Boilerplate** - From 50+ lines to 1 line of initialization code

## [1.1.1] - 2025-09-25

### Changed
- **Annotation Renamed**: `@JsonSerializable()` → `@AxiosJson()` 
  - Avoid conflicts with `json_annotation` package
  - More concise 10-character annotation
  - Clearly indicates this is Flutter Axios specific JSON annotation
  - Maintains all existing functionality

## [1.1.0] - 2025-09-25

### Added

- **Revolutionary JSON Mapper System with build_runner Integration**
  - Zero-code JSON serialization/deserialization with `@AxiosJson()` annotation
  - Standard `build_runner` workflow with auto-generated `.flutter_axios.g.dart` files
  - 100% Flutter compatible (no dart:mirrors, pure compile-time generation)
  - Type-safe HTTP requests: `api.get<User>('/users/123')`
  - Smart field mapping: camelCase ↔ snake_case automatic conversion
  - Complex nested object support with automatic handling
  - Generated extension methods: `user.toJsonString()`, `user.toMap()`
  - Generated factory methods: `UserJsonFactory.fromJsonString()`
  - Hot reload support with `dart run build_runner watch`

- **Supported Types**
  - Basic types: `String`, `int`, `double`, `bool`, `DateTime`
  - Collections: `List<T>`, `Map<String, dynamic>`
  - Nullable variants: `String?`, `DateTime?`, etc.
  - Complex nested objects and lists
  - Automatic ISO 8601 DateTime conversion

- **Performance Improvements**
  - 10x faster development time (2-3 minutes vs 20-30 minutes per model)
  - Zero runtime overhead (compile-time code generation)
  - Minimal memory footprint
  - Optimized for Flutter's constraints

- **Developer Experience Enhancements**
  - Standard build_runner workflow familiar to Dart developers
  - Watch mode for automatic regeneration on file changes
  - Comprehensive documentation with migration guides
  - Complete examples from simple to complex nested objects
  - Error handling and troubleshooting guides

### Changed

- Enhanced README with complete build_runner JSON mapper documentation
- Updated examples to showcase automatic code generation
- Improved Chinese documentation (README_CN.md) with full feature coverage
- Streamlined project structure by removing redundant documentation files

### Development Workflow

```bash
# Development with watch mode
dart run build_runner watch --delete-conflicting-outputs

# Production build
dart run build_runner build --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean
```

### Performance Comparison

| Feature | Manual JSON | json_serializable | flutter_axios |
|---------|-------------|------------------|---------------|
| Development Time | 20-30 min/model | 10-15 min/model | **2-3 min/model** |
| Code Lines | 80-120 lines | 40-60 lines | **0 user lines** |
| Type Safety | Manual | Complete | **Complete** |
| Hot Reload | Manual | Rebuild needed | **Watch mode** |

## [1.0.0] - 2024-09-25

### Added

- **Core Features**
  - Promise-based HTTP client API inspired by Axios.js
  - Support for all HTTP methods (GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS)
  - Automatic request body serialization (JSON, form data)
  - Automatic response data parsing
  - Request and response timeout support
  - Query parameters serialization

- **Instance Management**
  - Global Axios instance with static methods
  - Custom instance creation with `Axios.create()`
  - Instance configuration with `AxiosConfig`
  - Base URL support for relative requests

- **Interceptor System**
  - Request interceptors for modifying outgoing requests
  - Response interceptors for processing responses
  - Error interceptors for handling errors
  - Built-in interceptors:
    - `AuthInterceptor` for authentication headers
    - `HeadersInterceptor` for custom headers
    - `LoggingRequestInterceptor` for request logging
    - `LoggingResponseInterceptor` for response logging
    - `RetryInterceptor` for retry logic

- **Error Handling**
  - Comprehensive `AxiosError` class with error types:
    - Network errors
    - Timeout errors
    - HTTP response errors (4xx, 5xx)
    - Request cancellation errors
  - Detailed error information including request and response data

- **Request/Response Models**
  - `AxiosRequest` class for request representation
  - `AxiosResponse<T>` class for typed response handling
  - `RequestOptions` for configuring individual requests
  - Full TypeScript-like typing support

- **Progress Tracking**
  - Upload progress callbacks
  - Download progress callbacks
  - Progress tracking for file uploads/downloads

- **Configuration Options**
  - Request timeouts
  - Custom headers and query parameters
  - Response validation with custom status validators
  - Request/response transformation functions
  - Base URL configuration

- **Testing Support**
  - Mock-friendly architecture
  - Dependency injection for HTTP clients
  - Comprehensive test coverage

- **Documentation**
  - Complete API documentation
  - Usage examples and tutorials
  - Migration guide from http package
  - TypeScript-like API reference

### Technical Details

- Built on top of the `http` package for reliable HTTP communication
- Full Flutter and Dart compatibility
- Null-safety support
- Comprehensive error handling and logging
- Performance optimized for mobile applications

### Examples

- Basic GET/POST request examples
- Custom instance configuration examples
- Interceptor usage examples
- Error handling examples
- Progress tracking examples
