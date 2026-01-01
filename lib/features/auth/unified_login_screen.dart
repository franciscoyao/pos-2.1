import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/core/theme/app_colors.dart';
import 'package:pos_system/data/repositories/auth_repository.dart';
import 'package:pos_system/features/dashboard/admin_dashboard.dart';
import 'package:pos_system/features/dashboard/waiter_dashboard.dart';

class UnifiedLoginScreen extends ConsumerStatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  ConsumerState<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends ConsumerState<UnifiedLoginScreen> {
  String _selectedRole = 'admin';
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'admin',
      'label': 'Admin',
      'icon': Icons.admin_panel_settings_outlined,
    },
    {'id': 'waiter', 'label': 'Waiter', 'icon': Icons.restaurant_menu},
    {'id': 'kitchen', 'label': 'Kitchen', 'icon': Icons.kitchen},
    {'id': 'bar', 'label': 'Bar', 'icon': Icons.local_bar},
    {'id': 'kiosk', 'label': 'Kiosk', 'icon': Icons.monitor},
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final isQuickAccess = ['kitchen', 'bar', 'kiosk'].contains(_selectedRole);

    if (!isQuickAccess) {
      if (_usernameController.text.isEmpty) {
        _showError('Username is required');
        return;
      }
      if (_pinController.text.isEmpty) {
        _showError('PIN is required');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (isQuickAccess) {
        if (mounted) _navigateBasedOnRole(_selectedRole);
        return;
      }

      final user = await ref
          .read(authRepositoryProvider)
          .login(_usernameController.text.trim(), _pinController.text.trim());

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        if (user.role == _selectedRole) {
          _navigateBasedOnRole(user.role);
        } else {
          _showError('User is not authorized for $_selectedRole role');
        }
      } else {
        _showError('Invalid credentials');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Error: $e');
    }
  }

  void _navigateBasedOnRole(String role) {
    Widget destination;
    switch (role) {
      case 'admin':
        destination = const AdminDashboard();
        break;
      case 'waiter':
        destination = const WaiterDashboard();
        break;
      default:
        destination = Scaffold(
          appBar: AppBar(title: Text('${role.toUpperCase()} Interface')),
          body: Center(child: Text('Welcome to $role interface')),
        );
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => destination));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isQuickAccess = ['kitchen', 'bar', 'kiosk'].contains(_selectedRole);

    return Scaffold(
      backgroundColor: AppColors.loginDark,
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.loginDark,
                  AppColors.loginDarkEnd,
                  AppColors.loginDark,
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // White Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'POS System',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select your role to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Role Tabs
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _roles.map((role) {
                                  final isSelected =
                                      _selectedRole == role['id'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRole = role['id'];
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 80,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 8,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.05),
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            role['icon'],
                                            size: 20,
                                            color: isSelected
                                                ? AppColors.textPrimary
                                                : AppColors.textTertiary,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            role['label'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? AppColors.textPrimary
                                                  : AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Role Icon
                          Icon(
                            _roles.firstWhere(
                              (r) => r['id'] == _selectedRole,
                            )['icon'],
                            size: 48,
                            color: AppColors.textPrimary,
                          ),

                          const SizedBox(height: 32),

                          // Form Fields
                          if (!isQuickAccess) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Username',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              cursorColor: AppColors.textPrimary,
                              decoration: InputDecoration(
                                hintText: 'Enter username',
                                hintStyle: TextStyle(
                                  color: AppColors.textTertiary,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'PIN',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _pinController,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              cursorColor: AppColors.textPrimary,
                              decoration: InputDecoration(
                                hintText: '4-digit PIN',
                                hintStyle: TextStyle(
                                  color: AppColors.textTertiary,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isQuickAccess
                                          ? 'Enter ${_roles.firstWhere((r) => r['id'] == _selectedRole)['label']} Mode'
                                          : 'Login as ${_roles.firstWhere((r) => r['id'] == _selectedRole)['label']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (!isQuickAccess)
                            const Text(
                              'Default: admin / 1111',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Help Button
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.textPrimary,
              child: const Icon(
                Icons.question_mark_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
