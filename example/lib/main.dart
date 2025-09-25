import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_axios/flutter_axios.dart';

// 导入模型和生成的映射代码
import 'models/user.dart';
import 'models/product.dart';
import 'axios_json_initializers.g.dart'; // 全局初始化器

void main() {
  // 🎉 一键初始化所有 JSON 映射器！
  initializeAllAxiosJsonMappers();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Axios + Build Runner Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const UserManagementPage(),
    );
  }
}

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  // Axios 实例
  late final AxiosInstance _axios;
  
  // 用户列表
  List<User> _users = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // 表单控制器
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();
  final _cityController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _initializeAxios();
  }

  /// 初始化 Axios 实例
  void _initializeAxios() {
    _axios = AxiosInstance(
      config: AxiosConfig(
        baseURL: 'https://628c335f3df57e983ecafc59.mockapi.io',
        timeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加拦截器
    final interceptor = _CustomInterceptor();
    _axios.interceptors.add(interceptor);

    setState(() {
      _isInitialized = true;
    });
    
    // 初始化完成后立即加载数据
    _loadUsers();
  }

  /// 加载用户列表
  Future<void> _loadUsers() async {
    if (!_isInitialized) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _axios.get('/user');
      
      // 解析用户列表
      List<User> users = [];
      if (response.data is List) {
        final rawList = response.data as List;
        users = rawList.map((item) => 
          UserJsonFactory.fromMap(item as Map<String, dynamic>)
        ).whereType<User>().toList();
      }
      
      setState(() {
        _users = users;
      });
      _showSuccessSnackBar('加载了 ${_users.length} 个用户');
    } catch (e) {
      print('加载用户失败: $e');
      _showErrorSnackBar('加载用户失败');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 创建新用户
  Future<void> _createUser() async {
    if (_nameController.text.isEmpty || 
        _avatarController.text.isEmpty || 
        _cityController.text.isEmpty) {
      _showErrorSnackBar('请填写所有字段');
      return;
    }

    try {
      final newUser = User(
        id: '', // MockAPI 会自动生成 ID
        name: _nameController.text,
        avatar: _avatarController.text,
        city: _cityController.text,
      );

      final response = await _axios.post<User>('/user', data: newUser);
      
      final createdUser = response.data;
      if (createdUser != null) {
        setState(() {
          _users.add(createdUser);
        });
        _clearForm();
        _showSuccessSnackBar('用户创建成功');
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      print('创建用户失败: $e');
      _showErrorSnackBar('创建用户失败');
    }
  }

  /// 更新用户
  Future<void> _updateUser(User user) async {
    try {
      final updatedUser = user.copyWith(
        name: _nameController.text.isNotEmpty ? _nameController.text : user.name,
        avatar: _avatarController.text.isNotEmpty ? _avatarController.text : user.avatar,
        city: _cityController.text.isNotEmpty ? _cityController.text : user.city,
      );

      final response = await _axios.put<User>('/user/${user.id}', data: updatedUser);
      
      final updatedUserData = response.data;
      if (updatedUserData != null) {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          setState(() {
            _users[index] = updatedUserData;
          });
        }
        _clearForm();
        _showSuccessSnackBar('用户更新成功');
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      print('更新用户失败: $e');
      _showErrorSnackBar('更新用户失败');
    }
  }

  /// 删除用户
  Future<void> _deleteUser(User user) async {
    final confirmed = await _showDeleteConfirmDialog(user);
    if (!confirmed) return;

    try {
      await _axios.delete<void>('/user/${user.id}');
      
      setState(() {
        _users.removeWhere((u) => u.id == user.id);
      });
      _showSuccessSnackBar('用户删除成功');
    } catch (e) {
      print('删除用户失败: $e');
      _showErrorSnackBar('删除用户失败');
    }
  }

  /// 显示创建/编辑用户对话框
  void _showUserDialog({User? user}) {
    if (user != null) {
      _nameController.text = user.name;
      _avatarController.text = user.avatar;
      _cityController.text = user.city;
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? '创建用户' : '编辑用户'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名',
                  hintText: '请输入用户姓名',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _avatarController,
                decoration: const InputDecoration(
                  labelText: '头像URL',
                  hintText: '请输入头像链接',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: '城市',
                  hintText: '请输入所在城市',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (user == null) {
                _createUser();
              } else {
                _updateUser(user);
              }
            },
            child: Text(user == null ? '创建' : '更新'),
          ),
        ],
      ),
    );
  }

  /// 显示删除确认对话框
  Future<bool> _showDeleteConfirmDialog(User user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除用户 "${user.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 清空表单
  void _clearForm() {
    _nameController.clear();
    _avatarController.clear();
    _cityController.clear();
  }

  /// 显示成功消息
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 显示错误消息
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Axios + Build Runner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: '刷新数据',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        tooltip: '添加用户',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在初始化 Axios...'),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在加载用户数据...'),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '暂无用户数据',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.avatar),
                onBackgroundImageError: (_, __) {},
                child: user.avatar.isEmpty 
                    ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
                    : null,
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏙️ ${user.city}'),
                  Text('🆔 ID: ${user.id}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (action) {
                  switch (action) {
                    case 'edit':
                      _showUserDialog(user: user);
                      break;
                    case 'delete':
                      _deleteUser(user);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('编辑'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('删除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => _showUserDetails(user),
            ),
          );
        },
      ),
    );
  }

  /// 显示用户详情
  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                user.avatar,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, size: 50),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('🆔 ID: ${user.id}'),
            const SizedBox(height: 8),
            Text('👤 姓名: ${user.name}'),
            const SizedBox(height: 8),
            Text('🏙️ 城市: ${user.city}'),
            const SizedBox(height: 16),
            const Text('JSON 数据:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.toJsonString(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showUserDialog(user: user);
            },
            child: const Text('编辑'),
          ),
        ],
      ),
    );
  }
}

/// 自定义拦截器
class _CustomInterceptor extends Interceptor {
  @override
  Future<AxiosRequest> onRequest(AxiosRequest request) async {
    print('📤 ${request.method} ${request.url}');
    if (request.data != null) {
      print('   📦 请求数据: ${request.data}');
    }
    return request;
  }

  @override
  Future<AxiosResponse<dynamic>> onResponse(AxiosResponse<dynamic> response) async {
    print('📥 ${response.status} ${response.request.url}');
    final dataStr = response.data.toString();
    final preview = dataStr.length > 100 ? '${dataStr.substring(0, 100)}...' : dataStr;
    print('   📦 响应数据: $preview');
    return response;
  }

  @override
  Future<void> onError(AxiosError error) async {
    print('❌ 请求错误: ${error.response?.status} ${error.message}');
  }
}
