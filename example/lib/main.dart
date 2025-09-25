import 'package:flutter_axios/flutter_axios.dart';

import 'models/product.dart';
import 'models/product.flutter_axios.g.dart';
import 'models/user.dart';
// 导入生成的 JSON 映射文件
import 'models/user.flutter_axios.g.dart';
import 'services/api_service.dart';

void main() async {
  print('🚀 Flutter Axios + build_runner 完整示例');
  print('=========================================\n');

  // 1. 初始化 JSON 映射器
  await _initializeJsonMapper();

  // 2. 初始化 API 服务
  await _initializeApiService();

  // 3. 演示基础 JSON 操作
  await _demonstrateJsonSerialization();

  // 4. 演示 HTTP 请求
  await _demonstrateHttpRequests();

  // 5. 演示 CRUD 操作
  await _demonstrateCrudOperations();

  // 6. 演示错误处理
  await _demonstrateErrorHandling();

  // 7. 清理资源
  _cleanup();

  print('\n🎉 示例演示完成！');
  print('💡 总结:');
  print('   ✅ build_runner 自动生成 JSON 映射');
  print('   ✅ 类型安全的 HTTP 请求');
  print('   ✅ 完整的 CRUD 操作');
  print('   ✅ 强大的拦截器系统');
  print('   ✅ 优雅的错误处理');
}

/// 初始化 JSON 映射器
Future<void> _initializeJsonMapper() async {
  print('📋 初始化 JSON 映射器');
  print('====================');

  // 初始化核心映射器
  initializeJsonMapper();

  // 注册所有模型的 JSON 映射
  initializeUserJsonMappers();
  initializeProductJsonMappers();

  print('✅ JSON 映射器初始化完成');
  print('📊 注册统计: ${JsonMapper.getStats()}');
  print('');
}

/// 初始化 API 服务
Future<void> _initializeApiService() async {
  print('🌐 初始化 API 服务');
  print('==================');

  ApiService().initialize();

  print('✅ API 服务初始化完成');
  print('🔗 基础 URL: https://jsonplaceholder.typicode.com');
  print('⏱️ 超时时间: 10 秒');
  print('');
}

/// 演示 JSON 序列化
Future<void> _demonstrateJsonSerialization() async {
  print('📄 演示 JSON 序列化/反序列化');
  print('=============================');

  // 创建测试用户
  final user = User(
    id: 'DEMO_001',
    name: '张三',
    email: 'zhangsan@example.com',
    age: 28,
    isActive: true,
    tags: ['开发者', 'Flutter', '测试'],
    profile: {
      'city': '北京',
      'company': '科技公司',
      'skills': ['Dart', 'Flutter', 'HTTP'],
      'experience': 5,
    },
    createdAt: DateTime.now().subtract(Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  print('👤 创建的用户: $user');

  // 测试序列化
  final jsonString = user.toJsonString();
  print('📤 序列化为 JSON 字符串 (${jsonString.length} 字符):');
  print('   ${jsonString.substring(0, 100)}...');

  final userMap = user.toMap();
  print('📄 序列化为 Map (${userMap.keys.length} 个字段):');
  print('   键: ${userMap.keys.take(5).join(', ')}...');

  // 测试反序列化
  final restoredUser = UserJsonFactory.fromJsonString(jsonString);
  print('📥 从 JSON 字符串反序列化: ${restoredUser?.name}');

  final userFromMap = UserJsonFactory.fromMap(userMap);
  print('📄 从 Map 反序列化: ${userFromMap?.name}');

  // 验证数据完整性
  final isIntact = user.name == restoredUser?.name && 
                   user.email == restoredUser?.email &&
                   user.tags.length == restoredUser?.tags.length;
  print('🔍 数据完整性检验: ${isIntact ? "✅ 通过" : "❌ 失败"}');

  // 创建测试产品
  final product = Product(
    id: 'PROD_001',
    productName: 'Flutter Axios 教程',
    description: '学习使用 Flutter Axios 进行 HTTP 请求的完整教程',
    price: 99.99,
    originalPrice: 149.99,
    isAvailable: true,
    stockCount: 100,
    rating: 4.8,
    reviewCount: 256,
    categoryId: 'CAT_001',
    categoryName: '编程教程',
    brandName: 'Flutter 学院',
    imageUrls: [
      'https://example.com/image1.jpg',
      'https://example.com/image2.jpg',
    ],
    tags: ['Flutter', 'HTTP', '教程', '进阶'],
    specifications: {
      'format': 'PDF + 视频',
      'pages': 200,
      'duration': '5小时',
      'level': '中级',
    },
    createdAt: DateTime.now().subtract(Duration(days: 7)),
    updatedAt: DateTime.now(),
  );

  print('\n📦 创建的产品: $product');
  print('💰 折扣信息: ${product.hasDiscount ? "${product.discountPercentage.toStringAsFixed(1)}% 折扣" : "无折扣"}');
  print('⭐ 评分: ${product.rating} (${product.ratingDescription})');
  print('📦 库存: ${product.inStock ? "有库存 (${product.stockCount})" : "缺货"}');

  print('');
}

/// 演示 HTTP 请求
Future<void> _demonstrateHttpRequests() async {
  print('🌐 演示 HTTP 请求');
  print('================');

  final apiService = ApiService();

  try {
    // 演示 GET 请求
    print('📍 GET 请求示例:');
    final users = await apiService.getUsers();
    print('   获取到 ${users.length} 个用户');
    if (users.isNotEmpty) {
      print('   第一个用户: ${users.first.name} (${users.first.email})');
    }

    // 演示 GET 单个资源
    print('\n📍 GET 单个资源示例:');
    final user = await apiService.getUser('1');
    if (user != null) {
      print('   用户详情: $user');
    }

    // 演示 POST 请求
    print('\n📍 POST 请求示例:');
    final newUser = User(
      id: 'NEW_001',
      name: '新用户',
      email: 'newuser@example.com',
      age: 25,
      isActive: true,
      tags: ['新用户'],
      profile: {'source': 'API演示'},
      createdAt: DateTime.now(),
    );

    final createdUser = await apiService.createUser(newUser);
    if (createdUser != null) {
      print('   创建成功: ${createdUser.name}');
    }

  } catch (e) {
    print('❌ HTTP 请求演示出错: $e');
  }

  print('');
}

/// 演示 CRUD 操作
Future<void> _demonstrateCrudOperations() async {
  print('🔧 演示 CRUD 操作');
  print('=================');

  final apiService = ApiService();

  try {
    // CREATE - 创建
    print('📝 CREATE (创建):');
    final createUser = User(
      id: 'CRUD_001',
      name: 'CRUD 测试用户',
      email: 'crud@example.com',
      age: 30,
      isActive: true,
      tags: ['CRUD', '测试'],
      profile: {'operation': 'CREATE'},
      createdAt: DateTime.now(),
    );

    final created = await apiService.createUser(createUser);
    print('   ✅ 创建用户: ${created?.name}');

    // READ - 读取
    print('\n📖 READ (读取):');
    final read = await apiService.getUser('1');
    print('   ✅ 读取用户: ${read?.name}');

    // UPDATE - 更新
    print('\n✏️ UPDATE (更新):');
    if (read != null) {
      final updated = read.copyWith(
        name: '${read.name} (已更新)',
        updatedAt: DateTime.now(),
      );
      final result = await apiService.updateUser(read.id, updated);
      print('   ✅ 更新用户: ${result?.name}');
    }

    // DELETE - 删除
    print('\n🗑️ DELETE (删除):');
    final deleted = await apiService.deleteUser('1');
    print('   ${deleted ? "✅ 删除成功" : "❌ 删除失败"}');

  } catch (e) {
    print('❌ CRUD 操作演示出错: $e');
  }

  print('');
}

/// 演示错误处理
Future<void> _demonstrateErrorHandling() async {
  print('⚠️ 演示错误处理');
  print('===============');

  final apiService = ApiService();

  try {
    // 测试无效 URL
    print('📍 测试无效 URL:');
    await apiService.getUser('invalid-id-999999');

    // 测试超时
    print('\n📍 测试网络错误 (模拟):');
    final axios = AxiosInstance(
      config: AxiosConfig(
        baseURL: 'https://httpstat.us',
        timeout: Duration(milliseconds: 100), // 很短的超时
      ),
    );

    try {
      await axios.get('/500'); // 模拟服务器错误
    } catch (e) {
      if (e is AxiosError) {
        print('   错误类型: ${e.type}');
        print('   错误消息: ${e.message}');
        print('   状态码: ${e.response?.status}');
      }
    } finally {
      axios.close();
    }

  } catch (e) {
    print('❌ 错误处理演示出错: $e');
  }

  print('');
}

/// 清理资源
void _cleanup() {
  print('🧹 清理资源');
  print('============');

  ApiService().close();
  print('✅ API 服务已关闭');
}
