import 'package:flutter_axios/flutter_axios.dart';

/// 用户模型 - 匹配 MockAPI 数据结构
/// 使用 build_runner 自动生成 JSON 映射
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

  /// 复制并修改部分字段
  User copyWith({
    String? id,
    String? name,
    String? avatar,
    String? city,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      city: city ?? this.city,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, avatar: $avatar, city: $city}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
           other.id == id &&
           other.name == name &&
           other.avatar == avatar &&
           other.city == city;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           name.hashCode ^ 
           avatar.hashCode ^ 
           city.hashCode;
  }
}