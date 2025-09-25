# Flutter Axios

<div align="center">

[![pub package](https://img.shields.io/pub/v/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)

A promise-based HTTP client for Flutter inspired by [Axios](https://axios-http.com/). Provides interceptors, request/response transformation, error handling, and **revolutionary automatic JSON conversion**.

[English](README.md) | [中文](README_CN.md)

</div>

## ✨ Features

### 🚀 Core HTTP Features
- **Promise-based API** - Familiar Axios-like syntax
- **Request/Response Interceptors** - Powerful middleware system
- **Automatic Request/Response Transformation** - Built-in JSON handling
- **Request/Response Timeout** - Configurable timeouts
- **Request Cancellation** - Cancel requests with AbortController
- **Error Handling** - Comprehensive error types and handling
- **Base URL and Relative URLs** - Flexible URL management
- **Query Parameters** - Easy query string handling

### 🎯 Revolutionary JSON Mapper
- **Zero-Code JSON Conversion** - Automatic serialization/deserialization
- **build_runner Integration** - Standard Dart code generation
- **Type-Safe HTTP Requests** - `api.get<User>('/users/123')`
- **Smart Field Mapping** - camelCase ↔ snake_case conversion
- **Complex Object Support** - Nested objects, lists, maps
- **Flutter Optimized** - No reflection, pure compile-time generation

### 🛠️ Developer Experience
- **TypeScript-like API** - Familiar for web developers
- **Hot Reload Support** - Watch mode with build_runner
- **Comprehensive Documentation** - Examples and guides
- **Unit Tested** - Reliable and production-ready

## 🚀 Quick Start

> **注解说明**: 我们使用 `@AxiosJson()` 而不是常见的 `@JsonSerializable()`，这样可以避免与 `json_annotation` 包冲突，同时保持简洁性。

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_axios: ^1.1.0

dev_dependencies:
  build_runner: ^2.7.1  # For code generation
```

### Basic Usage

```dart
import 'package:flutter_axios/flutter_axios.dart';

void main() async {
  // Create instance
  final api = Axios.create(AxiosConfig(
    baseURL: 'https://jsonplaceholder.typicode.com',
    timeout: Duration(seconds: 10),
  ));

  try {
    // GET request
    final response = await api.get('/posts/1');
    print(response.data);

    // POST request
    final newPost = await api.post('/posts', data: {
      'title': 'foo',
      'body': 'bar',
      'userId': 1,
    });
    print('Created: ${newPost.data}');

  } catch (e) {
    if (e is AxiosError) {
      print('Error: ${e.message}');
      print('Status: ${e.response?.statusCode}');
    }
  } finally {
    api.close();
  }
}
```

## 🎯 Automatic JSON Conversion

### Step 1: Define Your Model

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

  // Only business methods needed - JSON mapping is auto-generated!
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

### Step 2: Generate Code

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (recommended for development)
dart run build_runner watch --delete-conflicting-outputs
```

This generates `user.flutter_axios.g.dart` with:
- Registration functions
- Extension methods (toJsonString, toMap)
- Factory methods (fromJsonString, fromMap)
- List handling utilities

### Step 3: Use Type-Safe HTTP Requests

```dart
import 'package:flutter_axios/flutter_axios.dart';
import 'models/user.dart';
import 'models/user.flutter_axios.g.dart';  // Import generated file

void main() async {
  // Initialize JSON mapper
  initializeJsonMapper();
  
  // Register your models (one line per model!)
  initializeUserJsonMappers();
  
  // Create HTTP client
  final api = Axios.create(AxiosConfig(
    baseURL: 'https://api.example.com',
  ));

  // 🎉 Enjoy type-safe HTTP requests!
  
  // GET single user - automatic deserialization
  final userResponse = await api.get<User>('/users/123');
  final user = userResponse.data;  // Already a User object!
  print('Welcome ${user.name}!');

  // GET user list - automatic list deserialization  
  final usersResponse = await api.get<List<User>>('/users');
  final users = usersResponse.data;  // Already List<User>!
  print('Found ${users.length} users');

  // POST new user - automatic serialization
  final newUser = User(
    id: 'new-id',
    name: 'John Doe',
    email: 'john@example.com',
    age: 30,
    isActive: true,
    tags: ['developer'],
    profile: {'skills': ['Flutter', 'Dart']},
    createdAt: DateTime.now(),
  );

  final createResponse = await api.post<User>('/users', data: newUser);
  print('Created user: ${createResponse.data.name}');

  // PUT update user - automatic serialization
  final updatedUser = user.copyWith(name: 'Updated Name');
  await api.put<User>('/users/123', data: updatedUser);

  // Use generated extension methods
  final jsonString = user.toJsonString();  // Serialize to JSON string
  final userMap = user.toMap();           // Serialize to Map

  // Use generated factory methods
  final restoredUser = UserJsonFactory.fromJsonString(jsonString);
  final userFromMap = UserJsonFactory.fromMap(userMap);
  
  api.close();
}
```

## 🔧 Advanced Features

### Interceptors

```dart
final api = Axios.create(AxiosConfig(
  baseURL: 'https://api.example.com',
));

// Request interceptor
api.interceptors.request.use(
  onRequest: (config) async {
    config.headers['Authorization'] = 'Bearer $token';
    print('→ ${config.method.toUpperCase()} ${config.url}');
    return config;
  },
  onError: (error) async {
    print('Request error: ${error.message}');
    return error;
  },
);

// Response interceptor  
api.interceptors.response.use(
  onResponse: (response) async {
    print('← ${response.statusCode} ${response.config.url}');
    return response;
  },
  onError: (error) async {
    if (error.response?.statusCode == 401) {
      // Handle unauthorized
      await refreshToken();
    }
    return error;
  },
);
```

### Error Handling

```dart
try {
  final response = await api.get<User>('/users/123');
  print('User: ${response.data.name}');
} catch (e) {
  if (e is AxiosError) {
    switch (e.type) {
      case AxiosErrorType.connectionTimeout:
        print('Connection timeout');
        break;
      case AxiosErrorType.receiveTimeout:
        print('Receive timeout');
        break;
      case AxiosErrorType.badResponse:
        print('Bad response: ${e.response?.statusCode}');
        break;
      case AxiosErrorType.connectionError:
        print('Connection error: ${e.message}');
        break;
      case AxiosErrorType.unknown:
        print('Unknown error: ${e.message}');
        break;
    }
  }
}
```

### Request Cancellation

```dart
final cancelToken = CancelToken();

// Start request
final future = api.get('/slow-endpoint', cancelToken: cancelToken);

// Cancel after 5 seconds
Timer(Duration(seconds: 5), () {
  cancelToken.cancel('Request timeout');
});

try {
  final response = await future;
  print(response.data);
} catch (e) {
  if (e is AxiosError && e.type == AxiosErrorType.cancelled) {
    print('Request was cancelled');
  }
}
```

### File Upload

```dart
import 'dart:io';

final file = File('path/to/image.jpg');
final formData = FormData();
formData.files.add(MapEntry(
  'file',
  await MultipartFile.fromFile(file.path, filename: 'image.jpg'),
));
formData.fields.add(MapEntry('description', 'Profile photo'));

final response = await api.post('/upload', data: formData);
print('Upload complete: ${response.data}');
```

## 🏗️ JSON Mapper Features

### Supported Types

The build_runner automatically handles:

**Basic Types:**
- `String`, `int`, `double`, `bool`
- `DateTime` (ISO 8601 conversion)
- Nullable variants (`String?`, `int?`, etc.)

**Collections:**
- `List<String>`, `List<int>`, `List<T>`
- `Map<String, dynamic>`
- Nested objects and lists

**Smart Conversions:**
- `camelCase` ↔ `snake_case` field mapping
- `userName` ↔ `user_name`
- `isActive` ↔ `is_active`
- `createdAt` ↔ `created_at`

### Complex Nested Objects

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

// Usage
void main() async {
  initializeJsonMapper();
  initializeAddressJsonMappers();
  initializeCompanyJsonMappers();  
  initializeEmployeeJsonMappers();

  final api = Axios.create(AxiosConfig(baseURL: 'https://api.company.com'));

  // Complex nested object - automatically handled!
  final employee = await api.get<Employee>('/employees/123');
  print('Employee: ${employee.data.name}');
  print('Company: ${employee.data.company.name}');
  print('City: ${employee.data.company.address.city}');
}
```

### Generated Extension Methods

Every model gets useful extension methods:

```dart
final user = User(/* ... */);

// Serialization extensions
final jsonString = user.toJsonString();     // Convert to JSON string
final userMap = user.toMap();               // Convert to Map

// Factory methods  
final newUser = UserJsonFactory.fromJsonString(jsonString);
final userFromMap = UserJsonFactory.fromMap(userMap);
final userList = UserJsonFactory.listFromJsonString(jsonArrayString);
```

## 📊 Performance Comparison

| Feature | Manual JSON | json_serializable | flutter_axios |
|---------|-------------|------------------|---------------|
| **Development Time** | 20-30 min/model | 10-15 min/model | **2-3 min/model** |
| **Code Lines** | 80-120 lines | 40-60 lines | **0 user lines** |
| **Maintenance** | High | Medium | **Minimal** |
| **Type Safety** | Manual | Complete | **Complete** |
| **Runtime Performance** | Fast | Fast | **Fast** |
| **Compile Time** | Fast | Medium | **Fast** |
| **Learning Curve** | High | Medium | **Low** |
| **Hot Reload** | Manual | Rebuild needed | **Watch mode** |

## 🔄 Migration Guide

### From Manual JSON Handling

1. **Add the annotation:**
   ```dart
   @JsonSerializable()
   class User {
     // existing fields...
   }
   ```

2. **Remove manual code:**
   ```dart
   // Remove these methods:
   // factory User.fromJson(Map<String, dynamic> json) { ... }
   // Map<String, dynamic> toJson() { ... }
   ```

3. **Generate and register:**
   ```bash
   dart run build_runner build
   ```
   ```dart
   initializeJsonMapper();
   initializeUserJsonMappers();
   ```

### From json_annotation

1. **Update dependencies:**
   ```yaml
   dependencies:
     flutter_axios: ^1.1.0  # Replace json_annotation
   
   dev_dependencies:
     build_runner: ^2.7.1   # Keep build_runner
   ```

2. **Update imports:**
   ```dart
   import 'package:flutter_axios/flutter_axios.dart';  // Replace json_annotation
   ```

3. **Regenerate code:**
   ```bash
   dart run build_runner clean
   dart run build_runner build
   ```

## 🛠️ Development Workflow

### Watch Mode (Recommended)

```bash
# Start watch mode - auto-regenerates on file changes
dart run build_runner watch --delete-conflicting-outputs
```

### Production Build

```bash
# One-time generation for production
dart run build_runner build --delete-conflicting-outputs
```

### Clean Generated Files

```bash
# Clean all generated files
dart run build_runner clean
```

## 🔧 Configuration

### Custom Build Configuration

Create `build.yaml` in your project root:

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

### Exclude Files

```yaml
targets:
  $default:
    builders:
      flutter_axios|simple_json:
        generate_for:
          - lib/**
          - "!lib/legacy/**"  # Exclude legacy code
```

## 🐛 Troubleshooting

### Common Issues

**Q: Generated files not found?**
```bash
# Make sure you ran code generation
dart run build_runner build
```

**Q: Import errors for generated functions?**
```dart
// Make sure you import the generated file
import 'user.flutter_axios.g.dart';
```

**Q: Type not supported?**
- Check if your field type is in the supported types list
- Complex custom types may need their own `@JsonSerializable()` annotation

**Q: Watch mode not working?**
```bash
# Restart watch mode
dart run build_runner clean
dart run build_runner watch --delete-conflicting-outputs
```

**Q: Build errors after updating?**
```bash
# Clean and rebuild
dart run build_runner clean
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

```bash
git clone https://github.com/Not996NotOT/flutter_axios.git
cd flutter_axios
dart pub get
dart test
```

### Running Examples

```bash
cd example
dart pub get
dart run build_runner build
dart main.dart
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Axios](https://axios-http.com/) - The excellent HTTP client for JavaScript
- Built with [build_runner](https://pub.dev/packages/build_runner) - Dart's code generation tool
- Thanks to the Flutter and Dart teams for the amazing framework

## 📈 Roadmap

- [ ] GraphQL support
- [ ] WebSocket integration  
- [ ] Caching mechanisms
- [ ] Retry mechanisms
- [ ] Upload progress tracking
- [ ] More serialization options

---

<div align="center">

**[⭐ Star this repo](https://github.com/Not996NotOT/flutter_axios) if it helped you!**

Made with ❤️ for the Flutter community

</div>