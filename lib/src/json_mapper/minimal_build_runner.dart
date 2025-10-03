/// 最小化的 build_runner 代码生成器.
/// 专注于核心功能，避免复杂的列表处理.
library minimal_build_runner;

import 'dart:async';

import 'package:build/build.dart';
import 'package:glob/glob.dart';

/// 全局初始化文件生成器.
class GlobalInitializerBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': ['axios_json_initializers.g.dart']
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final allAssets =
        await buildStep.findAssets(Glob('lib/**/*.dart')).toList();
    final classNames = <String>[];

    // 扫描所有 Dart 文件，找到带有 @AxiosJson() 注解的类
    for (final asset in allAssets) {
      final content = await buildStep.readAsString(asset);
      if (content.contains('@AxiosJson()')) {
        final classRegex = RegExp(r'class\s+(\w+)\s*{');
        final matches = classRegex.allMatches(content);
        for (final match in matches) {
          final className = match.group(1)!;
          if (!classNames.contains(className)) {
            classNames.add(className);
          }
        }
      }
    }

    if (classNames.isEmpty) return;

    // 生成全局初始化代码
    final code = _generateGlobalInitializer(classNames);
    final outputId = AssetId(
        buildStep.inputId.package, 'lib/axios_json_initializers.g.dart');
    await buildStep.writeAsString(outputId, code);

    log.info(
        'Generated global initializer for ${classNames.length} classes: ${classNames.join(", ")}');
  }

  String _generateGlobalInitializer(List<String> classNames) {
    final buffer = StringBuffer();

    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Global Axios JSON Initializer');
    buffer.writeln('// Generated on: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    // 导入所有模型类和生成的文件
    for (final className in classNames) {
      final snakeCase = _camelToSnake(className);
      buffer.writeln('import \'models/$snakeCase.dart\';');
      buffer.writeln('import \'models/$snakeCase.flutter_axios.g.dart\';');
    }
    buffer.writeln();

    // 生成初始化所有映射器的函数
    buffer.writeln('/// 一键初始化所有 Axios JSON 映射器');
    buffer.writeln('/// 无需手动调用每个类的初始化函数');
    buffer.writeln('void initializeAllAxiosJsonMappers() {');
    for (final className in classNames) {
      buffer.writeln('  initialize${className}JsonMappers();');
    }
    buffer.writeln('}');
    buffer.writeln();

    // 生成按类型初始化的函数
    buffer.writeln('/// 按类型列表初始化 JSON 映射器');
    buffer.writeln('/// 使用方式: initializeAxiosJsonMappers([User, Product])');
    buffer.writeln('void initializeAxiosJsonMappers(List<Type> types) {');
    buffer.writeln('  for (final type in types) {');
    buffer.writeln('    switch (type) {');
    for (final className in classNames) {
      buffer.writeln('      case $className:');
      buffer.writeln('        initialize${className}JsonMappers();');
      buffer.writeln('        break;');
    }
    buffer.writeln('      default:');
    buffer.writeln('        print(\'警告: 未找到类型 \$type 的 JSON 映射器\');');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    // 生成类型映射表
    buffer.writeln('/// 支持的类型列表');
    buffer.writeln('final supportedAxiosJsonTypes = <Type>[');
    for (final className in classNames) {
      buffer.writeln('  $className,');
    }
    buffer.writeln('];');

    return buffer.toString();
  }

  String _camelToSnake(String camelCase) {
    return camelCase
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .substring(1); // 移除开头的下划线
  }
}

/// 最小化 JSON 生成器.
class MinimalJsonBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.flutter_axios.g.dart']
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;

    // 只处理有 @AxiosJson() 注解的文件
    final content = await buildStep.readAsString(inputId);

    if (!content.contains('@AxiosJson()')) {
      return;
    }

    // 提取类信息
    final classInfo = _extractClassInfo(content);
    if (classInfo == null) {
      return;
    }

    // 生成代码
    final generatedCode = _generateCode(classInfo, inputId);

    // 写入生成的文件
    final outputId = inputId.changeExtension('.flutter_axios.g.dart');
    await buildStep.writeAsString(outputId, generatedCode);

    log.info('Generated JSON mapper for ${classInfo.className}');
  }

  /// 提取类信息
  _ClassInfo? _extractClassInfo(String content) {
    // 简单的正则表达式来提取类信息
    final classRegex = RegExp(r'class\s+(\w+)\s*{');
    final classMatch = classRegex.firstMatch(content);

    if (classMatch == null) return null;

    final className = classMatch.group(1)!;

    // 提取字段
    final fieldRegex = RegExp(r'final\s+([^;]+?)\s+(\w+);');
    final fieldMatches = fieldRegex.allMatches(content);

    final fields = <_FieldInfo>[];
    for (final match in fieldMatches) {
      final type = match.group(1)!.trim();
      final name = match.group(2)!;

      fields.add(_FieldInfo(
        name: name,
        type: type,
        isOptional: type.endsWith('?'),
      ));
    }

    return _ClassInfo(className: className, fields: fields);
  }

  /// 生成代码
  String _generateCode(_ClassInfo classInfo, AssetId inputId) {
    final className = classInfo.className;
    final fields = classInfo.fields;
    final originalFileName = inputId.path.split('/').last;

    final buffer = StringBuffer();

    // 文件头
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Flutter Axios JSON Serialization');
    buffer.writeln('// Generated on: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    // 导入必要的库
    buffer.writeln("import 'dart:convert';");
    buffer.writeln("import 'package:flutter_axios/flutter_axios.dart';");
    buffer.writeln("import '$originalFileName';");
    buffer.writeln();

    // 序列化辅助函数
    buffer.writeln('''
/// 序列化值的辅助函数.
dynamic _serializeValue(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toIso8601String();
  if (value is String || value is num || value is bool) return value;
  if (value is List) return value.map(_serializeValue).toList();
  if (value is Map) return value;
  
  // 尝试使用 JsonMapper 序列化自定义对象
  try {
    return JsonMapper.serialize(value);
  } catch (e) {
    return value.toString();
  }
}
''');

    // 注册函数
    buffer.writeln('/// 自动生成的 $className JSON 映射注册器');
    buffer.writeln('void register${className}JsonMapper() {');
    buffer.writeln('  JsonMapper.register<$className>(');
    buffer.writeln('    (json) => $className(');

    for (final field in fields) {
      final conversion = _generateFromJsonConversion(field);
      buffer.writeln('      ${field.name}: $conversion,');
    }

    buffer.writeln('    ),');
    buffer.writeln('    (obj) => {');

    for (final field in fields) {
      final jsonKey = _toSnakeCase(field.name);
      if (field.isOptional) {
        buffer.writeln(
            "      if (obj.${field.name} != null) '$jsonKey': _serializeValue(obj.${field.name}),");
      } else {
        buffer.writeln("      '$jsonKey': _serializeValue(obj.${field.name}),");
      }
    }

    buffer.writeln('    },');
    buffer.writeln('  );');
    buffer.writeln('}');
    buffer.writeln();

    // 简化的初始化函数
    buffer.writeln('/// 一键注册 $className 的 JSON 映射');
    buffer.writeln('void initialize${className}JsonMappers() {');
    buffer.writeln('  register${className}JsonMapper();');
    buffer.writeln('}');
    buffer.writeln();

    // 扩展方法
    buffer.writeln('/// $className 的 JSON 序列化扩展方法');
    buffer.writeln('extension ${className}JsonExtension on $className {');
    buffer.writeln('  /// 序列化为 JSON 字符串');
    buffer.writeln('  String toJsonString() {');
    buffer.writeln('    final serialized = JsonMapper.serialize(this);');
    buffer.writeln('    return jsonEncode(serialized);');
    buffer.writeln('  }');
    buffer.writeln('  /// 序列化为 Map');
    buffer.writeln('  Map<String, dynamic> toMap() {');
    buffer.writeln('    final serialized = JsonMapper.serialize(this);');
    buffer.writeln(
        '    return serialized is Map<String, dynamic> ? serialized as Map<String, dynamic> : <String, dynamic>{};');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    // 静态工厂方法 - 使用类扩展
    buffer.writeln('/// $className 的 JSON 反序列化工厂方法');
    buffer.writeln('class ${className}JsonFactory {');
    buffer.writeln('  /// 从 JSON 字符串创建对象');
    buffer.writeln('  static $className? fromJsonString(String jsonString) {');
    buffer
        .writeln('    return JsonMapper.deserialize<$className>(jsonString);');
    buffer.writeln('  }');
    buffer.writeln('  /// 从 Map 创建对象');
    buffer.writeln('  static $className? fromMap(Map<String, dynamic> map) {');
    buffer.writeln('    return JsonMapper.deserialize<$className>(map);');
    buffer.writeln('  }');
    buffer.writeln('  /// 从 JSON 字符串创建对象列表');
    buffer.writeln(
        '  static List<$className> listFromJsonString(String jsonString) {');
    buffer.writeln('    try {');
    buffer.writeln(
        '      return JsonMapper.deserialize<List<$className>>(jsonString) ?? [];');
    buffer.writeln('    } catch (e) {');
    buffer.writeln('      return [];');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln('  /// 从 List 创建对象列表');
    buffer.writeln(
        '  static List<$className> listFromMaps(List<Map<String, dynamic>> maps) {');
    buffer.writeln(
        '    return maps.map((map) => fromMap(map)).whereType<$className>().toList();');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// 生成 fromJson 转换代码
  String _generateFromJsonConversion(_FieldInfo field) {
    final jsonKey = _toSnakeCase(field.name);
    final type = field.type.replaceAll('?', '');
    final isOptional = field.isOptional;

    if (type == 'String') {
      return isOptional
          ? "json['$jsonKey']?.toString()"
          : "json['$jsonKey']?.toString() ?? ''";
    }

    if (type == 'int') {
      return isOptional
          ? "(json['$jsonKey'] as num?)?.toInt()"
          : "(json['$jsonKey'] as num?)?.toInt() ?? 0";
    }

    if (type == 'double') {
      return isOptional
          ? "(json['$jsonKey'] as num?)?.toDouble()"
          : "(json['$jsonKey'] as num?)?.toDouble() ?? 0.0";
    }

    if (type == 'bool') {
      return isOptional
          ? "json['$jsonKey'] as bool?"
          : "json['$jsonKey'] == true";
    }

    if (type.startsWith('List<String>')) {
      return isOptional
          ? "(json['$jsonKey'] as List?)?.map((e) => e.toString()).toList()"
          : "(json['$jsonKey'] as List?)?.map((e) => e.toString()).toList() ?? []";
    }

    if (type.startsWith('List<int>')) {
      return isOptional
          ? "(json['$jsonKey'] as List?)?.map((e) => (e as num).toInt()).toList()"
          : "(json['$jsonKey'] as List?)?.map((e) => (e as num).toInt()).toList() ?? []";
    }

    if (type.startsWith('List<')) {
      return isOptional
          ? "(json['$jsonKey'] as List?)"
          : "(json['$jsonKey'] as List?) ?? []";
    }

    if (type.startsWith('Map<')) {
      return isOptional
          ? "json['$jsonKey'] as Map<String, dynamic>?"
          : "Map<String, dynamic>.from(json['$jsonKey'] ?? {})";
    }

    if (type == 'DateTime') {
      return isOptional
          ? "json['$jsonKey'] != null ? DateTime.tryParse(json['$jsonKey'].toString()) : null"
          : "DateTime.tryParse(json['$jsonKey']?.toString() ?? '') ?? DateTime.now()";
    }

    // 默认处理
    return "json['$jsonKey']";
  }

  /// 转换为 snake_case
  String _toSnakeCase(String camelCase) {
    return camelCase
        .replaceAllMapped(
            RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_'), '');
  }
}

/// 类信息.
class _ClassInfo {
  final String className;
  final List<_FieldInfo> fields;

  const _ClassInfo({required this.className, required this.fields});
}

/// 字段信息.
class _FieldInfo {
  final String name;
  final String type;
  final bool isOptional;

  const _FieldInfo(
      {required this.name, required this.type, required this.isOptional});
}

/// 构建器工厂.
Builder minimalJsonBuilder(BuilderOptions options) => MinimalJsonBuilder();
Builder globalInitializerBuilder(BuilderOptions options) =>
    GlobalInitializerBuilder();
