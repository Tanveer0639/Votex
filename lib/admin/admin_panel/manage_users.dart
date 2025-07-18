import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  bool isBlocked;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isBlocked = false,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? 'No Name',
      email: map['email'] ?? 'No Email',
      role: 'User', // or use map['role'] if you have this in DB
    );
  }
}

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final supabase = Supabase.instance.client;
  List<User> users = [];
  String searchQuery = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => loading = true);
    try {
      final response = await supabase.from('users_list').select();
      users = (response as List).map((u) => User.fromMap(u)).toList();
    } catch (e) {
      print('❌ Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error loading users: $e')),
      );
    }
    setState(() => loading = false);
  }

  List<User> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    return users.where((user) {
      final q = searchQuery.toLowerCase();
      return user.name.toLowerCase().contains(q) || user.email.toLowerCase().contains(q);
    }).toList();
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await _showConfirmDialog(
      'Delete User',
      'Are you sure you want to delete ${user.name}? This cannot be undone.',
    );
    if (confirmed) {
      try {
        await supabase.from('users_list').delete().eq('id', user.id);
        setState(() {
          users.removeWhere((u) => u.id == user.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} has been deleted')),
        );
      } catch (e) {
        print('❌ Error deleting user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error deleting user: $e')),
        );
      }
    }
  }

  Future<void> _toggleBlockUser(User user) async {
    final action = user.isBlocked ? 'Unblock' : 'Block';
    final confirmed = await _showConfirmDialog(
      '$action User',
      'Are you sure you want to $action ${user.name}?',
    );
    if (confirmed) {
      setState(() {
        user.isBlocked = !user.isBlocked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} is now ${user.isBlocked ? 'blocked' : 'unblocked'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value.trim()),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(child: Text(user.name[0])),
                              title: Text(user.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email),
                                  Text('Role: ${user.role}'),
                                  Text(
                                    'Status: ${user.isBlocked ? 'Blocked' : 'Active'}',
                                    style: TextStyle(
                                      color: user.isBlocked ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Wrap(
                                spacing: 12,
                                children: [
                                  IconButton(
                                    icon: Icon(user.isBlocked ? Icons.lock_open : Icons.lock),
                                    color: user.isBlocked ? Colors.green : Colors.red,
                                    onPressed: () => _toggleBlockUser(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.grey[700],
                                    onPressed: () => _deleteUser(user),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
