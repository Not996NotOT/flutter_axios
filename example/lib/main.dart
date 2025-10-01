import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_axios/flutter_axios.dart';

import 'axios_json_initializers.g.dart'; // Global initializer
// Import models and generated mapping code
import 'models/user.dart';
import 'models/user.flutter_axios.g.dart';

void main() {
  // 🎉 One-line initialization for all JSON mappers!
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

  /// Initialize Axios instance
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

    // Add interceptors
    final interceptor = _CustomInterceptor();
    _axios.interceptors.add(interceptor);

    setState(() {
      _isInitialized = true;
    });

    // Load data immediately after initialization
    _loadUsers();
  }

  /// Load user list
  Future<void> _loadUsers() async {
    if (!_isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _axios.get('/user');

      // Parse user list
      List<User> users = [];
      if (response.data is List) {
        final rawList = response.data as List;
        users = rawList
            .map(
                (item) => UserJsonFactory.fromMap(item as Map<String, dynamic>))
            .whereType<User>()
            .toList();
      }

      setState(() {
        _users = users;
      });
      _showSuccessSnackBar('Loaded ${_users.length} users');
    } catch (e) {
      print('Failed to load users: $e');
      _showErrorSnackBar('Failed to load users');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Create new user
  Future<void> _createUser() async {
    if (_nameController.text.isEmpty ||
        _avatarController.text.isEmpty ||
        _cityController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    try {
      final newUser = User(
        id: '', // MockAPI will auto-generate ID
        name: _nameController.text,
        avatar: _avatarController.text,
        city: _cityController.text,
      );

      final response = await _axios.post<User>('/user', data: newUser);

      final createdUser = response.data;
      if (createdUser is User) {
        setState(() {
          _users.add(createdUser);
        });
        _clearForm();
        _showSuccessSnackBar('User created successfully');
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      print('Failed to create user: $e');
      _showErrorSnackBar('Failed to create user');
    }
  }

  /// Update user
  Future<void> _updateUser(User user) async {
    try {
      final updatedUser = user.copyWith(
        name:
            _nameController.text.isNotEmpty ? _nameController.text : user.name,
        avatar: _avatarController.text.isNotEmpty
            ? _avatarController.text
            : user.avatar,
        city:
            _cityController.text.isNotEmpty ? _cityController.text : user.city,
      );

      final response =
          await _axios.put<User>('/user/${user.id}', data: updatedUser);

      final updatedUserData = response.data;
      if (updatedUserData is User) {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          setState(() {
            _users[index] = updatedUserData;
          });
        }
        _clearForm();
        _showSuccessSnackBar('User updated successfully');
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      print('Failed to update user: $e');
      _showErrorSnackBar('Failed to update user');
    }
  }

  /// Delete user
  Future<void> _deleteUser(User user) async {
    final confirmed = await _showDeleteConfirmDialog(user);
    if (!confirmed) return;

    try {
      await _axios.delete<void>('/user/${user.id}');

      setState(() {
        _users.removeWhere((u) => u.id == user.id);
      });
      _showSuccessSnackBar('User deleted successfully');
    } catch (e) {
      print('Failed to delete user: $e');
      _showErrorSnackBar('Failed to delete user');
    }
  }

  /// Show create/edit user dialog
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
        title: Text(user == null ? 'Create User' : 'Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter user name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _avatarController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  hintText: 'Enter avatar link',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Enter city name',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (user == null) {
                _createUser();
              } else {
                _updateUser(user);
              }
            },
            child: Text(user == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmDialog(User user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete user "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Clear form fields
  void _clearForm() {
    _nameController.clear();
    _avatarController.clear();
    _cityController.clear();
  }

  /// Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error message
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
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        tooltip: 'Add user',
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
            Text('Initializing Axios...'),
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
            Text('Loading user data...'),
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
              'No user data',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Reload'),
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
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
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
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
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
            Text('👤 Name: ${user.name}'),
            const SizedBox(height: 8),
            Text('🏙️ City: ${user.city}'),
            const SizedBox(height: 16),
            const Text('JSON Data:',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showUserDialog(user: user);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

/// Custom interceptor
class _CustomInterceptor extends Interceptor {
  @override
  Future<AxiosRequest> onRequest(AxiosRequest request) async {
    print('📤 ${request.method} ${request.url}');
    if (request.data != null) {
      print('   📦 Request data: ${request.data}');
    }
    return request;
  }

  @override
  Future<AxiosResponse<dynamic>> onResponse(
      AxiosResponse<dynamic> response) async {
    print('📥 ${response.status} ${response.request.url}');
    final dataStr = response.data.toString();
    final preview =
        dataStr.length > 100 ? '${dataStr.substring(0, 100)}...' : dataStr;
    print('   📦 Response data: $preview');
    return response;
  }

  @override
  Future<void> onError(AxiosError error) async {
    print('❌ Request error: ${error.response?.status} ${error.message}');
  }
}
