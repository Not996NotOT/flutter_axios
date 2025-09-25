# Flutter Axios

> **ドキュメント言語**: [English](README.md) | [中文](README_CN.md) | [日本語](README_JP.md)

Axios.js からインスピレーションを受けた強力な Flutter HTTP クライアント。革新的な JSON マッピングと build_runner 統合機能を搭載。

[![pub package](https://img.shields.io/pub/v/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)
[![popularity](https://img.shields.io/pub/popularity/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)
[![likes](https://img.shields.io/pub/likes/flutter_axios.svg)](https://pub.dev/packages/flutter_axios)

## ✨ 主要機能

- **🚀 ゼロコード JSON マッピング** - `@AxiosJson()` アノテーションを追加するだけ、ボイラープレートコード不要
- **🔧 build_runner 統合** - 標準的な Dart エコシステムツールチェーン
- **🎯 型安全なリクエスト** - `await api.get<User>('/users/123')`
- **⚡ 10倍の開発速度** - モデル1つあたり 2-3分 vs 20-30分
- **🔄 スマートシリアライゼーション** - camelCase ↔ snake_case の自動変換
- **📱 Flutter 最適化** - dart:mirrors なし、コンパイル時生成のみ
- **🌐 Promise ベース API** - Web 開発者に馴染みのある Axios.js 体験
- **🛡️ 包括的なエラーハンドリング** - ネットワーク、タイムアウト、API エラー
- **🔌 強力なインターセプター** - リクエスト/レスポンス変換とログ
- **🎨 TypeScript ライクな API** - Web 開発者に馴染みやすい
- **🔥 ホットリロード対応** - build_runner のウォッチモード
- **📚 包括的なドキュメント** - 例とガイド
- **✅ ユニットテスト済み** - 信頼性が高く本番環境対応

## 🚀 クイックスタート

> **アノテーション注意**: `json_annotation` パッケージとの競合を避けながら簡潔性を保つため、一般的な `@JsonSerializable()` の代わりに `@AxiosJson()` を使用します。

### インストール

`pubspec.yaml` に追加：

```yaml
dependencies:
  flutter_axios: ^1.1.4

dev_dependencies:
  build_runner: ^2.4.12
```

### ステップ 1: モデル定義

アノテーションを1つ追加するだけ：

```dart
import 'package:flutter_axios/flutter_axios.dart';

@AxiosJson()  // 🎉 簡潔なアノテーション、フレームワーク競合を回避
class User {
  final String id;
  final String name;
  final String email;
  
  const User({required this.id, required this.name, required this.email});
}
```

### ステップ 2: コード生成

```bash
dart run build_runner build --delete-conflicting-outputs
```

### ステップ 3: 使用方法

```dart
import 'package:flutter_axios/flutter_axios.dart';
import 'models/user.dart';
import 'axios_json_initializers.g.dart'; // グローバル初期化ファイル

void main() async {
  // 🎉 すべての JSON マッパーを1行で初期化！
  initializeAllAxiosJsonMappers();
  
  // HTTP クライアント作成
  final api = Axios.create(AxiosOptions(
    baseURL: 'https://api.example.com',
  ));
  
  // 型安全な HTTP リクエスト
  final response = await api.get<List<User>>('/users');
  final users = response.data; // すでに List<User> として解析済み！
  
  // 新しいユーザーを作成
  final newUser = User(id: '1', name: 'John', email: 'john@example.com');
  await api.post<User>('/users', data: newUser); // 自動シリアライズ！
}
```

## 🔧 複数の初期化オプション

### オプション 1: すべて初期化（推奨）
```dart
import 'axios_json_initializers.g.dart';

void main() {
  // すべての @AxiosJson() クラスを自動的に初期化
  initializeAllAxiosJsonMappers();
  runApp(MyApp());
}
```

### オプション 2: 特定の型を初期化
```dart
import 'axios_json_initializers.g.dart';

void main() {
  // 必要な特定の型のみを初期化
  initializeAxiosJsonMappers([User, Product, Order]);
  runApp(MyApp());
}
```

### オプション 3: 手動初期化（レガシー）
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

## 🎯 完全な CRUD の例

MockAPI を使用した実際の例：

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_axios/flutter_axios.dart';

// モデルと生成されたコードをインポート
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
  
  // GET - ユーザー読み取り
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
  
  // POST - ユーザー作成
  Future<User?> createUser(User user) async {
    final response = await _api.post<User>('/user', data: user);
    return response.data;
  }
  
  // PUT - ユーザー更新
  Future<User?> updateUser(String id, User user) async {
    final response = await _api.put<User>('/user/$id', data: user);
    return response.data;
  }
  
  // DELETE - ユーザー削除
  Future<bool> deleteUser(String id) async {
    try {
      await _api.delete<void>('/user/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
}

// モデル定義（models/user.dart 内）
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

## 🔧 高度な機能

### 1. 複雑なネストオブジェクト

```dart
@AxiosJson()
class Order {
  final String id;
  final User customer;           // ネストオブジェクト
  final List<Product> items;     // オブジェクトのリスト
  final Address? shipping;       // null 許容オブジェクト
  final DateTime createdAt;      // 自動 ISO8601 変換
  final Map<String, dynamic> metadata; // 動的データ
  
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

### 2. 生成されたヘルパーメソッド

`build_runner` 実行後、強力なヘルパーメソッドが利用可能：

```dart
// シリアライゼーション
final jsonString = user.toJsonString();
final map = user.toMap();

// デシリアライゼーション
final user = UserJsonFactory.fromJsonString('{"id":"1","name":"John"}');
final users = UserJsonFactory.listFromJsonString('[{"id":"1"},{"id":"2"}]');

// マップから
final user = UserJsonFactory.fromMap({'id': '1', 'name': 'John'});
final users = UserJsonFactory.listFromMaps([{'id': '1'}, {'id': '2'}]);
```

### 3. 自動 JSON ハンドリング付きインターセプター

```dart
class LoggingInterceptor extends Interceptor {
  @override
  Future<AxiosRequest> onRequest(AxiosRequest request) async {
    print('🚀 ${request.method} ${request.url}');
    if (request.data != null) {
      // データは自動的にシリアライズされる
      print('📤 ${request.data}');
    }
    return request;
  }

  @override
  Future<AxiosResponse> onResponse(AxiosResponse response) async {
    print('✅ ${response.status} ${response.request.url}');
    // レスポンスデータは自動的に解析される
    print('📥 ${response.data}');
    return response;
  }
}

final api = Axios.create(AxiosOptions(baseURL: 'https://api.example.com'));
api.interceptors.add(LoggingInterceptor());
```

### 4. エラーハンドリング

```dart
try {
  final user = await api.get<User>('/users/123');
  print('ユーザー: ${user.data?.name}');
} on AxiosError catch (e) {
  if (e.type == AxiosErrorType.timeout) {
    print('リクエストタイムアウト');
  } else if (e.response?.status == 404) {
    print('ユーザーが見つかりません');
  } else {
    print('エラー: ${e.message}');
  }
}
```

## 🔄 開発ワークフロー

### ウォッチモード（推奨）

```bash
dart run build_runner watch --delete-conflicting-outputs
```

これは変更を監視し、モデルを修正すると自動的にコードを再生成します。

### 1回だけビルド

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 生成ファイルをクリーンアップ

```bash
dart run build_runner clean
```

## 📊 パフォーマンス比較

| 機能 | 手動 JSON | json_serializable | flutter_axios |
|------|-----------|------------------|---------------|
| 開発時間 | モデル1つあたり20-30分 | モデル1つあたり10-15分 | **モデル1つあたり2-3分** |
| コード行数 | 80-120行 | 40-60行 | **ユーザーコード0行** |
| 型安全性 | 手動 | 完全 | **完全** |
| ホットリロード | 手動 | 再ビルド必要 | **ウォッチモード** |
| フレームワーク競合 | なし | 可能性あり | **なし** |
| 学習コスト | 高い | 中程度 | **低い** |

## 🏗️ プロジェクト構造

```
your_project/
├── lib/
│   ├── models/
│   │   ├── user.dart                      # あなたのモデル
│   │   └── user.flutter_axios.g.dart      # 生成されたコード
│   └── main.dart
├── pubspec.yaml
└── build.yaml                             # build_runner 設定
```

## 🔧 設定

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

### サポートされる型

- **基本型**: `String`, `int`, `double`, `bool`, `DateTime`
- **コレクション**: `List<T>`, `Map<String, dynamic>`
- **null許容**: `String?`, `DateTime?` など
- **カスタムオブジェクト**: `@AxiosJson()` 付きの任意のクラス
- **ネスト**: 複雑なオブジェクト階層

## 🚀 移行ガイド

### json_annotation から

`@JsonSerializable()` を `@AxiosJson()` に置き換え：

```dart
// 移行前
@JsonSerializable()
class User {
  // ... フィールド
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// 移行後
@AxiosJson()
class User {
  // ... フィールドのみ、手動メソッド不要！
}
```

### 手動 JSON から

すべての手動 `fromJson`/`toJson` を `@AxiosJson()` だけに置き換え：

```dart
// 移行前：50行以上の手動 JSON コード
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

// 移行後：アノテーションだけ！
@AxiosJson()
class User {
  final String id;
  final String name;
  
  const User({required this.id, required this.name});
}
```

## 🆕 v1.1.1 の新機能

### 変更点
- **アノテーション名変更**: `@JsonSerializable()` → `@AxiosJson()`
  - `json_annotation` パッケージとの競合を回避
  - より簡潔な10文字のアノテーション
  - Flutter Axios 専用であることを明確に示す
  - 既存の機能はすべて維持

## 🛠️ トラブルシューティング

### よくある問題

1. **生成ファイルが見つからない**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **型 'dynamic' がサブタイプではない**
   - JSON マッパーを初期化していることを確認: `initializeUserJsonMappers()`
   - モデルに `@AxiosJson()` アノテーションがあることを確認

3. **build runner の競合**
   ```bash
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

### ベストプラクティス

- 可能な限り `const` コンストラクタを使用
- `main()` で早期に JSON マッパーを初期化
- 開発中はウォッチモードを使用
- null許容フィールドを適切に処理
- 説明的なフィールド名を使用

## 📚 例

以下については `/example` ディレクトリを確認してください：
- 完全な CRUD アプリケーション
- 複雑なネストオブジェクト
- エラーハンドリングパターン
- インターセプターの使用
- 実際の API 統合

## 🤝 貢献

貢献を歓迎します！詳細については [Contributing Guide](CONTRIBUTING.md) をご覧ください。

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています - 詳細については [LICENSE](LICENSE) ファイルをご覧ください。

## ⭐ サポートを示してください

このパッケージが役に立った場合は、[GitHub](https://github.com/Not996NotOT/flutter_axios) で ⭐ を、[pub.dev](https://pub.dev/packages/flutter_axios) で 👍 をお願いします！
