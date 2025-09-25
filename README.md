# Flutter Axios

A powerful HTTP client for Flutter inspired by Axios.js, featuring revolutionary JSON mapping with build_runner integration.

[![pub package](https://img.shields.io/pub/v/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)
[![popularity](https://img.shields.io/pub/popularity/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)
[![likes](https://img.shields.io/pub/likes/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)

## ✨ Key Features

- **🚀 Zero-Code JSON Mapping** - Just add `@AxiosJson()` annotation, no boilerplate
- **🔧 build_runner Integration** - Standard Dart ecosystem toolchain
- **🎯 Type-Safe Requests** - `await api.get<User>('/users/123')`
- **⚡ 10x Development Speed** - 2-3 minutes vs 20-30 minutes per model
- **🔄 Smart Serialization** - Automatic camelCase ↔ snake_case conversion
- **📱 Flutter Optimized** - No dart:mirrors, compile-time generation only
- **🌐 Promise-based API** - Familiar Axios.js experience for web developers
- **🛡️ Comprehensive Error Handling** - Network, timeout, and API errors
- **🔌 Powerful Interceptors** - Request/response transformation and logging
- **🎨 TypeScript-like API** - Familiar for web developers
- **🔥 Hot Reload Support** - Watch mode with build_runner
- **📚 Comprehensive Documentation** - Examples and guides
- **✅ Unit Tested** - Reliable and production-ready

## 🚀 Quick Start

> **Annotation Note**: We use `@AxiosJson()` instead of the common `@JsonSerializable()` to avoid conflicts with the `json_annotation` package while maintaining conciseness.

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_axios: ^1.1.1

dev_dependencies:
  build_runner: ^2.4.12
```

### Step 1: Define Model

Just add one annotation:

```dart
import 'package:flutter_axios/flutter_axios.dart';

@AxiosJson()  // 🎉 Concise annotation, avoids framework conflicts
class User {
  final String id;
  final String name;
  final String email;
  
  const User({required this.id, required this.name, required this.email});
}
```

### Step 2: Generate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 3: Use It

```dart
import 'package:flutter_axios/flutter_axios.dart';
import 'models/user.dart';
import 'models/user.flutter_axios.g.dart'; // Generated file

void main() async {
  // Initialize JSON mappers
  initializeJsonMapper();
  initializeUserJsonMappers();
  
  // Create HTTP client
  final api = Axios.create(AxiosOptions(
    baseURL: 'https://api.example.com',
  ));
  
  // Type-safe HTTP requests
  final response = await api.get<List<User>>('/users');
  final users = response.data; // Already parsed as List<User>!
  
  // Create new user
  final newUser = User(id: '1', name: 'John', email: 'john@example.com');
  await api.post<User>('/users', data: newUser); // Auto-serialized!
}
```

## 🎯 Complete CRUD Example

Here's a real-world example using MockAPI:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_axios/flutter_axios.dart';

// Import model and generated code
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
  
  // GET - Read users
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
  
  // POST - Create user
  Future<User?> createUser(User user) async {
    final response = await _api.post<User>('/user', data: user);
    return response.data;
  }
  
  // PUT - Update user
  Future<User?> updateUser(String id, User user) async {
    final response = await _api.put<User>('/user/$id', data: user);
    return response.data;
  }
  
  // DELETE - Remove user
  Future<bool> deleteUser(String id) async {
    try {
      await _api.delete<void>('/user/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Model definition (in models/user.dart)
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

## 🔧 Advanced Features

### 1. Complex Nested Objects

```dart
@AxiosJson()
class Order {
  final String id;
  final User customer;           // Nested object
  final List<Product> items;     // List of objects
  final Address? shipping;       // Nullable object
  final DateTime createdAt;      // Auto ISO8601 conversion
  final Map<String, dynamic> metadata; // Dynamic data
  
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

### 2. Generated Helper Methods

After running `build_runner`, you get powerful helper methods:

```dart
// Serialization
final jsonString = user.toJsonString();
final map = user.toMap();

// Deserialization
final user = UserJsonFactory.fromJsonString('{"id":"1","name":"John"}');
final users = UserJsonFactory.listFromJsonString('[{"id":"1"},{"id":"2"}]');

// From maps
final user = UserJsonFactory.fromMap({'id': '1', 'name': 'John'});
final users = UserJsonFactory.listFromMaps([{'id': '1'}, {'id': '2'}]);
```

### 3. Interceptors with Auto JSON Handling

```dart
class LoggingInterceptor extends Interceptor {
  @override
  Future<AxiosRequest> onRequest(AxiosRequest request) async {
    print('🚀 ${request.method} ${request.url}');
    if (request.data != null) {
      // Data is automatically serialized
      print('📤 ${request.data}');
    }
    return request;
  }

  @override
  Future<AxiosResponse> onResponse(AxiosResponse response) async {
    print('✅ ${response.status} ${response.request.url}');
    // Response data is automatically parsed
    print('📥 ${response.data}');
    return response;
  }
}

final api = Axios.create(AxiosOptions(baseURL: 'https://api.example.com'));
api.interceptors.add(LoggingInterceptor());
```

### 4. Error Handling

```dart
try {
  final user = await api.get<User>('/users/123');
  print('User: ${user.data?.name}');
} on AxiosError catch (e) {
  if (e.type == AxiosErrorType.timeout) {
    print('Request timeout');
  } else if (e.response?.status == 404) {
    print('User not found');
  } else {
    print('Error: ${e.message}');
  }
}
```

## 🔄 Development Workflow

### Watch Mode (Recommended)

```bash
dart run build_runner watch --delete-conflicting-outputs
```

This watches for changes and automatically regenerates code when you modify your models.

### Build Once

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Clean Generated Files

```bash
dart run build_runner clean
```

## 📊 Performance Comparison

| Feature | Manual JSON | json_serializable | flutter_axios |
|---------|-------------|------------------|---------------|
| Development Time | 20-30 min/model | 10-15 min/model | **2-3 min/model** |
| Code Lines | 80-120 lines | 40-60 lines | **0 user lines** |
| Type Safety | Manual | Complete | **Complete** |
| Hot Reload | Manual | Rebuild needed | **Watch mode** |
| Framework Conflicts | None | Possible | **None** |
| Learning Curve | High | Medium | **Low** |

## 🏗️ Project Structure

```
your_project/
├── lib/
│   ├── models/
│   │   ├── user.dart                      # Your model
│   │   └── user.flutter_axios.g.dart      # Generated code
│   └── main.dart
├── pubspec.yaml
└── build.yaml                             # build_runner config
```

## 🔧 Configuration

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

### Supported Types

- **Basic**: `String`, `int`, `double`, `bool`, `DateTime`
- **Collections**: `List<T>`, `Map<String, dynamic>`
- **Nullable**: `String?`, `DateTime?`, etc.
- **Custom Objects**: Any class with `@AxiosJson()`
- **Nested**: Complex object hierarchies

## 🚀 Migration Guide

### From json_annotation

Replace `@JsonSerializable()` with `@AxiosJson()`:

```dart
// Before
@JsonSerializable()
class User {
  // ... fields
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// After
@AxiosJson()
class User {
  // ... fields only, no manual methods needed!
}
```

### From Manual JSON

Replace all manual `fromJson`/`toJson` with just `@AxiosJson()`:

```dart
// Before: 50+ lines of manual JSON code
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

// After: Just the annotation!
@AxiosJson()
class User {
  final String id;
  final String name;
  
  const User({required this.id, required this.name});
}
```

## 🆕 What's New in v1.1.1

### Changed
- **Annotation Renamed**: `@JsonSerializable()` → `@AxiosJson()`
  - Avoids conflicts with `json_annotation` package
  - More concise 10-character annotation
  - Clearly indicates this is Flutter Axios specific
  - Maintains all existing functionality

## 🛠️ Troubleshooting

### Common Issues

1. **Generated file not found**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Type 'dynamic' is not a subtype**
   - Make sure to initialize JSON mappers: `initializeUserJsonMappers()`
   - Check that your model has `@AxiosJson()` annotation

3. **Build runner conflicts**
   ```bash
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

### Best Practices

- Use `const` constructors when possible
- Initialize JSON mappers early in `main()`
- Use watch mode during development
- Handle nullable fields appropriately
- Use descriptive field names

## 📚 Examples

Check out the `/example` directory for:
- Complete CRUD application
- Complex nested objects
- Error handling patterns
- Interceptor usage
- Real API integration

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Show Your Support

If this package helped you, please give it a ⭐ on [GitHub](https://github.com/Not996NotOT/flutter_axios) and 👍 on [pub.dev](https://pub.dev/packages/flutter_axios)!