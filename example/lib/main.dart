/// Flutter Axios CRUD Example
/// 
/// A comprehensive CRUD (Create, Read, Update, Delete) example using Flutter Axios
/// with a real RESTful API from MockAPI.io
/// 
/// API Endpoint: https://mockapi.io/projects/628c335f3df57e983ecafc5a/user
/// Data Structure: User { id, name, avatar, city }

import 'package:flutter/material.dart';
import 'package:flutter_axios/flutter_axios.dart';

void main() {
  // Run console examples first
  runCrudExamples();
  
  // Then run the Flutter app
  runApp(const UserCrudApp());
}

// ============================================================================
// Data Models
// ============================================================================

/// User model matching the MockAPI data structure
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

  /// Create User from JSON (like Axios response.data)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
    );
  }

  /// Convert User to JSON (for POST/PUT requests)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
      'city': city,
    };
  }

  /// Create a copy with some fields updated
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
  String toString() => 'User(id: $id, name: $name, city: $city)';
}

// ============================================================================
// API Service using Flutter Axios (like Axios in JavaScript)
// ============================================================================

class UserApiService {
  // Create Axios instance with base configuration (like axios.create())
  static final _api = Axios.create(const AxiosConfig(
    baseURL: 'https://628c335f3df57e983ecafc59.mockapi.io',
    timeout: Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  /// GET /user - Fetch all users
  /// Equivalent to: axios.get('/user')
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await _api.get<List<dynamic>>('/user');
      
      print('✅ GET /user - Status: ${response.status}');
      print('📊 Found ${response.data.length} users');
      
      return response.data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
    } catch (error) {
      print('❌ GET /user failed: $error');
      rethrow;
    }
  }

  /// GET /user/:id - Fetch single user
  /// Equivalent to: axios.get(`/user/${id}`)
  static Future<User> getUserById(String id) async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/user/$id');
      
      print('✅ GET /user/$id - Status: ${response.status}');
      
      return User.fromJson(response.data);
    } catch (error) {
      print('❌ GET /user/$id failed: $error');
      rethrow;
    }
  }

  /// POST /user - Create new user
  /// Equivalent to: axios.post('/user', userData)
  static Future<User> createUser(User user) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/user',
        data: user.toJson(),
      );
      
      print('✅ POST /user - Status: ${response.status}');
      print('🆕 Created user with ID: ${response.data['id']}');
      
      return User.fromJson(response.data);
    } catch (error) {
      print('❌ POST /user failed: $error');
      rethrow;
    }
  }

  /// PUT /user/:id - Update existing user
  /// Equivalent to: axios.put(`/user/${id}`, userData)
  static Future<User> updateUser(String id, User user) async {
    try {
      final response = await _api.put<Map<String, dynamic>>(
        '/user/$id',
        data: user.toJson(),
      );
      
      print('✅ PUT /user/$id - Status: ${response.status}');
      print('📝 Updated user: ${response.data['name']}');
      
      return User.fromJson(response.data);
    } catch (error) {
      print('❌ PUT /user/$id failed: $error');
      rethrow;
    }
  }

  /// DELETE /user/:id - Delete user
  /// Equivalent to: axios.delete(`/user/${id}`)
  static Future<void> deleteUser(String id) async {
    try {
      final response = await _api.delete('/user/$id');
      
      print('✅ DELETE /user/$id - Status: ${response.status}');
      print('🗑️ User deleted successfully');
    } catch (error) {
      print('❌ DELETE /user/$id failed: $error');
      rethrow;
    }
  }

  /// GET /user with pagination and search
  /// Equivalent to: axios.get('/user', { params: { page, limit, search } })
  static Future<List<User>> getUsersWithParams({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      final response = await _api.get<List<dynamic>>(
        '/user',
        params: params,
      );
      
      print('✅ GET /user with params - Status: ${response.status}');
      print('📊 Page $page, Limit $limit, Found ${response.data.length} users');
      
      return response.data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
    } catch (error) {
      print('❌ GET /user with params failed: $error');
      rethrow;
    }
  }
}

// ============================================================================
// Console CRUD Examples (like Axios documentation examples)
// ============================================================================

Future<void> runCrudExamples() async {
  print('🚀 Flutter Axios CRUD Examples with MockAPI\n');
  
  // Setup global interceptors for logging
  UserApiService._api.interceptors.add(LoggingRequestInterceptor(
    logger: (message) => print('📤 $message'),
  ));
  
  UserApiService._api.interceptors.add(LoggingResponseInterceptor(
    logger: (message) => print('📥 $message'),
  ));

  try {
    // 1. READ - Get all users
    print('📖 1. READ - Fetching all users...');
    final users = await UserApiService.getAllUsers();
    print('   Found ${users.length} users');
    if (users.isNotEmpty) {
      print('   First user: ${users.first.name} from ${users.first.city}');
    }
    print('');

    // 2. READ - Get single user
    if (users.isNotEmpty) {
      print('📖 2. READ - Fetching single user...');
      final singleUser = await UserApiService.getUserById(users.first.id);
      print('   User details: ${singleUser.name} (${singleUser.city})');
      print('');
    }

    // 3. CREATE - Add new user
    print('➕ 3. CREATE - Adding new user...');
    final newUser = User(
      id: '', // Will be generated by API
      name: 'Flutter Axios User',
      avatar: 'https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/999.jpg',
      city: 'Axios City',
    );
    
    final createdUser = await UserApiService.createUser(newUser);
    print('   Created: ${createdUser.name} with ID ${createdUser.id}');
    print('');

    // 4. UPDATE - Modify the created user
    print('✏️ 4. UPDATE - Updating user...');
    final updatedUser = createdUser.copyWith(
      name: 'Updated Flutter User',
      city: 'Updated City',
    );
    
    final result = await UserApiService.updateUser(createdUser.id, updatedUser);
    print('   Updated: ${result.name} in ${result.city}');
    print('');

    // 5. DELETE - Remove the user
    print('🗑️ 5. DELETE - Deleting user...');
    await UserApiService.deleteUser(createdUser.id);
    print('   User ${createdUser.id} deleted successfully');
    print('');

    // 6. READ with parameters
    print('📖 6. READ with Pagination - First 5 users...');
    final paginatedUsers = await UserApiService.getUsersWithParams(
      page: 1,
      limit: 5,
    );
    print('   Paginated results: ${paginatedUsers.length} users');
    
  } catch (error) {
    print('❌ CRUD Example Error: $error');
  }
  
  print('✅ All CRUD examples completed!\n');
}

// ============================================================================
// Flutter App UI - Interactive CRUD Interface
// ============================================================================

class UserCrudApp extends StatelessWidget {
  const UserCrudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Axios CRUD Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> _users = [];
  bool _loading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Load all users using Flutter Axios
  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final users = await UserApiService.getAllUsers();
      setState(() {
        _users = users;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load users: $error';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Delete user with confirmation
  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete user "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await UserApiService.deleteUser(user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} deleted successfully')),
        );
        _loadUsers(); // Refresh list
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $error')),
        );
      }
    }
  }

  /// Navigate to user form for creating/editing
  Future<void> _navigateToUserForm([User? user]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormPage(user: user),
      ),
    );

    if (result == true) {
      _loadUsers(); // Refresh list if user was saved
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Axios CRUD Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌐 RESTful API CRUD with Flutter Axios',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'API: https://628c335f3df57e983ecafc59.mockapi.io/user',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Users: ${_users.length}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Error message
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Loading indicator
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),

          // User list
          if (!_loading && _users.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.avatar),
                        onBackgroundImageError: (_, __) {},
                        child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                      ),
                      title: Text(user.name),
                      subtitle: Text('📍 ${user.city} • ID: ${user.id}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _navigateToUserForm(user),
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () => _deleteUser(user),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                      onTap: () => _navigateToUserForm(user),
                    ),
                  );
                },
              ),
            ),

          // Empty state
          if (!_loading && _users.isEmpty && _errorMessage.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Tap + to add your first user', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToUserForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================================
// User Form Page (Create/Update)
// ============================================================================

class UserFormPage extends StatefulWidget {
  final User? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _avatarController = TextEditingController();
  bool _saving = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.user!.name;
      _cityController.text = widget.user!.city;
      _avatarController.text = widget.user!.avatar;
    } else {
      // Default avatar for new users
      _avatarController.text = 'https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/999.jpg';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final user = User(
        id: _isEditing ? widget.user!.id : '',
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        avatar: _avatarController.text.trim(),
      );

      if (_isEditing) {
        await UserApiService.updateUser(widget.user!.id, user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      } else {
        await UserApiService.createUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
      }

      Navigator.pop(context, true); // Return true to indicate success
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user: $error')),
      );
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit User' : 'Add User'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveUser,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar preview
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatarController.text.isNotEmpty
                    ? NetworkImage(_avatarController.text)
                    : null,
                onBackgroundImageError: (_, __) {},
                child: _avatarController.text.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // City field
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'City is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Avatar URL field
            TextFormField(
              controller: _avatarController,
              decoration: const InputDecoration(
                labelText: 'Avatar URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                helperText: 'Enter image URL for avatar',
              ),
              onChanged: (value) {
                setState(() {}); // Rebuild to update avatar preview
              },
            ),
            const SizedBox(height: 24),

            // API info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.api, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        _isEditing ? 'PUT Request' : 'POST Request',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEditing 
                        ? 'Updates user via PUT /user/${widget.user!.id}'
                        : 'Creates new user via POST /user',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}