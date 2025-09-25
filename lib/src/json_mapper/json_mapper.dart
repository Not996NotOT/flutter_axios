/// Flutter Axios JSON 映射器核心
/// 专为 build_runner 代码生成设计
library json_mapper;

import 'dart:convert';

/// JSON 序列化注解
/// 标记类需要生成 JSON 映射代码
class JsonSerializable {
  const JsonSerializable();
}

/// JSON 序列化注解实例
const jsonSerializable = JsonSerializable();

/// JSON 映射器核心类
/// 管理类型注册和序列化/反序列化
class JsonMapper {
  /// 类型处理器映射
  static final Map<Type, Function> _fromJsonHandlers = {};
  static final Map<Type, Function> _toJsonHandlers = {};

  /// 注册类型的序列化/反序列化处理器
  /// 通常由生成的代码调用
  static void register<T>(
    T Function(dynamic) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) {
    _fromJsonHandlers[T] = fromJson;
    _toJsonHandlers[T] = toJson;
  }

  /// 序列化对象为 JSON
  /// 支持基础类型、List、Map 和注册的自定义类型
  static dynamic serialize(dynamic obj) {
    if (obj == null) return null;

    // 基础类型直接返回
    if (obj is String || obj is num || obj is bool) {
      return obj;
    }

    // DateTime 转换为 ISO 8601 字符串
    if (obj is DateTime) {
      return obj.toIso8601String();
    }

    // List 处理
    if (obj is List) {
      return obj.map((item) => serialize(item)).toList();
    }

    // Map 处理
    if (obj is Map) {
      final result = <String, dynamic>{};
      obj.forEach((key, value) {
        result[key.toString()] = serialize(value);
      });
      return result;
    }

    // 查找注册的类型处理器
    final toJsonHandler = _toJsonHandlers[obj.runtimeType];
    if (toJsonHandler != null) {
      return toJsonHandler(obj);
    }

    // 未知类型，尝试转换为字符串
    return obj.toString();
  }

  /// 反序列化 JSON 为指定类型
  /// 支持基础类型、List、Map 和注册的自定义类型
  static T? deserialize<T>(dynamic json) {
    if (json == null) return null;

    // 字符串尝试解析为 JSON 对象
    if (json is String && (json.startsWith('{') || json.startsWith('['))) {
      try {
        json = jsonDecode(json);
      } catch (e) {
        // 解析失败，继续作为字符串处理
      }
    }

    // 如果已经是目标类型，直接返回
    if (json is T) return json;

    // String 类型处理
    if (T == String) {
      return json.toString() as T;
    }

    // 数值类型处理
    if (T == int) {
      if (json is num) return json.toInt() as T;
      if (json is String) return int.tryParse(json) as T?;
    }

    if (T == double) {
      if (json is num) return json.toDouble() as T;
      if (json is String) return double.tryParse(json) as T?;
    }

    // bool 类型处理
    if (T == bool) {
      if (json is bool) return json as T;
      if (json is String) return (json.toLowerCase() == 'true') as T;
      return (json == 1 || json == '1') as T;
    }

    // DateTime 类型处理
    if (T == DateTime) {
      if (json is String) {
        return DateTime.tryParse(json) as T?;
      }
    }

    // List 类型处理
    if (T.toString().startsWith('List<')) {
      if (json is List) {
        // 提取泛型类型
        final typeString = T.toString();
        final match = RegExp(r'List<(.+)>').firstMatch(typeString);
        if (match != null) {
          final elementTypeName = match.group(1)!;
          
          // 处理基础类型列表
          if (elementTypeName == 'String') {
            return json.map((e) => e.toString()).toList() as T;
          }
          if (elementTypeName == 'int') {
            return json.map((e) => (e as num).toInt()).toList() as T;
          }
          if (elementTypeName == 'double') {
            return json.map((e) => (e as num).toDouble()).toList() as T;
          }
          if (elementTypeName == 'bool') {
            return json.map((e) => e == true).toList() as T;
          }
          if (elementTypeName == 'dynamic') {
            return json.map((e) => e).toList() as T;
          }
          
          // 复杂类型列表需要递归处理
          // 这里返回原始列表，让生成的代码处理具体类型转换
          return json as T;
        }
      }
      return json as T?;
    }

    // Map 类型处理
    if (T.toString().startsWith('Map<')) {
      if (json is Map) {
        return Map<String, dynamic>.from(json) as T;
      }
    }

    // 查找注册的类型处理器
    final fromJsonHandler = _fromJsonHandlers[T];
    if (fromJsonHandler != null) {
      return fromJsonHandler(json) as T?;
    }


    return null;
  }

  /// 清除所有注册的处理器
  /// 主要用于测试
  static void clear() {
    _fromJsonHandlers.clear();
    _toJsonHandlers.clear();
  }

  /// 获取统计信息
  /// 返回已注册的类型数量
  static Map<String, dynamic> getStats() {
    return {
      'registeredTypes': _fromJsonHandlers.length,
      'types': _fromJsonHandlers.keys.map((type) => type.toString()).toList(),
    };
  }
}

/// 初始化 JSON 映射器
/// 必须在使用前调用一次
void initializeJsonMapper() {
  // 确保映射器已初始化
  // 清除可能存在的旧注册
  JsonMapper.clear();
}