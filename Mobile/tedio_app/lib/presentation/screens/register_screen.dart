import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        childName: _childNameController.text.trim(),
        childAge: _childAgeController.text.isNotEmpty
            ? int.tryParse(_childAgeController.text)
            : null,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: AppColors.success,
        ));
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Join Tedio',
                        style: AppTypography.brand(fontSize: 32),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Help your child develop healthy YouTube habits',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.muted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Your Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter a password';
                          }
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _childNameController,
                        decoration: const InputDecoration(
                          labelText: 'Child\'s Name',
                          prefixIcon: Icon(Icons.child_care),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your child\'s name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _childAgeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Child\'s Age',
                          prefixIcon: Icon(Icons.cake),
                          suffixText: 'years old',
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your child\'s age';
                          }
                          final age = int.tryParse(value!);
                          if (age == null || age < 3 || age > 18) {
                            return 'Please enter a valid age (3-18)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (auth.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.08),
                            border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            auth.error!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.danger,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleRegister,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
