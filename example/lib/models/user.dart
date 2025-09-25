import 'package:flutter_axios/flutter_axios.dart';

/// 用户模型 - 使用 build_runner 自动生成 JSON 映射
@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final bool isActive;
  final List<String> tags;
  final Map<String, dynamic> profile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.isActive,
    required this.tags,
    required this.profile,
    this.createdAt,
    this.updatedAt,
  });

  /// 复制并修改部分字段
  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    bool? isActive,
    List<String>? tags,
    Map<String, dynamic>? profile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      profile: profile ?? this.profile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, age: $age, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
           other.id == id &&
           other.name == name &&
           other.email == email &&
           other.age == age &&
           other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           name.hashCode ^ 
           email.hashCode ^ 
           age.hashCode ^ 
           isActive.hashCode;
  }
}

