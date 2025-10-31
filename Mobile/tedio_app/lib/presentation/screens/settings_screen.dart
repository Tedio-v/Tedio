import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';
import '../../data/services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();

    // First ensure we have fresh user data
    await authProvider.fetchUserData();

    final user = authProvider.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.childName;
        _emailController.text = user.email;
        _ageController.text = user.childAge?.toString() ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final updates = <String, dynamic>{};

      if (_nameController.text.isNotEmpty) {
        updates['child_name'] = _nameController.text;
      }
      if (_emailController.text.isNotEmpty) {
        updates['email'] = _emailController.text;
      }
      if (_ageController.text.isNotEmpty) {
        updates['child_age'] = int.parse(_ageController.text);
      }

      await _userService.updateUserSettings(token, updates);

      // Refresh user data after update
      await authProvider.fetchUserData();

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating settings: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() {
                            _isEditing = false;
                            // Reset values
                            _nameController.text = user?.childName ?? '';
                            _emailController.text = user?.email ?? '';
                            _ageController.text = user?.childAge?.toString() ?? '';
                          });
                        },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Child\'s Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Child\'s Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age < 1 || age > 18) {
                      return 'Please enter a valid age (1-18)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'App Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive insights and reminders'),
                value: true,
                onChanged: _isEditing ? (value) {} : null,
              ),
              SwitchListTile(
                title: const Text('Daily Summary'),
                subtitle: const Text('Get daily viewing summary'),
                value: true,
                onChanged: _isEditing ? (value) {} : null,
              ),
              SwitchListTile(
                title: const Text('Auto-refresh Insights'),
                subtitle: const Text('Automatically update insights daily'),
                value: false,
                onChanged: _isEditing ? (value) {} : null,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to terms
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}