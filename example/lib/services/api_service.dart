import 'dart:async';

import 'package:flutter_axios/flutter_axios.dart';

import '../models/product.dart';
import '../models/user.dart';

/// API 服务类 - 封装所有 HTTP 请求
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final AxiosInstance _axios;

  /// 初始化 API 服务
  void initialize() {
    _axios = AxiosInstance(
      config: AxiosConfig(
        baseURL: 'https://jsonplaceholder.typicode.com',
        timeout: Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// 设置拦截器
  void _setupInterceptors() {
    // 创建自定义拦截器
    final loggingInterceptor = _LoggingInterceptor();
    _axios.interceptors.add(loggingInterceptor);
  }

  /// 获取 Axios 实例
  AxiosInstance get axios => _axios;

  // ==================== 用户相关 API ====================

  /// 获取用户列表
  Future<List<User>> getUsers() async {
    try {
      final response = await _axios.get<List<User>>('/users');
      return response.data;
    } catch (e) {
      print('获取用户列表失败: $e');
      return [];
    }
  }

  /// 获取单个用户
  Future<User?> getUser(String id) async {
    try {
      final response = await _axios.get<User>('/users/$id');
      return response.data;
    } catch (e) {
      print('获取用户失败: $e');
      return null;
    }
  }

  /// 创建用户
  Future<User?> createUser(User user) async {
    try {
      final response = await _axios.post<User>('/users', data: user);
      return response.data;
    } catch (e) {
      print('创建用户失败: $e');
      return null;
    }
  }

  /// 更新用户
  Future<User?> updateUser(String id, User user) async {
    try {
      final response = await _axios.put<User>('/users/$id', data: user);
      return response.data;
    } catch (e) {
      print('更新用户失败: $e');
      return null;
    }
  }

  /// 删除用户
  Future<bool> deleteUser(String id) async {
    try {
      await _axios.delete('/users/$id');
      return true;
    } catch (e) {
      print('删除用户失败: $e');
      return false;
    }
  }

  // ==================== 产品相关 API ====================

  /// 获取产品列表
  Future<List<Product>> getProducts() async {
    try {
      final response = await _axios.get<List<Product>>('/posts'); // 使用 posts 模拟产品
      return response.data;
    } catch (e) {
      print('获取产品列表失败: $e');
      return [];
    }
  }

  /// 获取单个产品
  Future<Product?> getProduct(String id) async {
    try {
      final response = await _axios.get<Product>('/posts/$id');
      return response.data;
    } catch (e) {
      print('获取产品失败: $e');
      return null;
    }
  }

  /// 搜索产品
  Future<List<Product>> searchProducts(String keyword) async {
    try {
      final response = await _axios.get<List<Product>>('/posts', params: {
        'q': keyword,
      });
      return response.data;
    } catch (e) {
      print('搜索产品失败: $e');
      return [];
    }
  }

  /// 关闭连接
  void close() {
    _axios.close();
  }
}

/// 自定义日志拦截器
class _LoggingInterceptor extends Interceptor {
  @override
  FutureOr<AxiosRequest> onRequest(AxiosRequest request) async {
    print('📤 ${request.method.name.toUpperCase()} ${request.url}');
    return request;
  }

  @override
  FutureOr<AxiosResponse<dynamic>> onResponse(AxiosResponse<dynamic> response) async {
    print('📥 ${response.status} ${response.request.url} (${response.data.toString().length} 字符)');
    return response;
  }

  @override
  FutureOr<void> onError(AxiosError error) async {
    print('❌ 错误: ${error.response?.status} ${error.message}');
  }
}