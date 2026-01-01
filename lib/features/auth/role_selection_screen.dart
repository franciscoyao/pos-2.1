import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/data/repositories/auth_repository.dart';
import 'package:pos_system/features/bar/bar_screen.dart';
import 'package:pos_system/features/dashboard/admin_dashboard.dart';
import 'package:pos_system/features/dashboard/waiter_dashboard.dart';
import 'package:pos_system/features/kitchen/kitchen_screen.dart';
import 'package:pos_system/features/kiosk/presentation/kiosk_screen.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});
  // ... (existing code omitted)

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
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

    // Quick Access Logic (No Auth required for demo/this specific flow as per previous implementation)
    // However, the reference image shows Username/PIN fields even for the active tab.
    // We will assume standard auth for Admin/Waiter and simplified/mock auth for others
    // OR we will adapt the UI to hide fields if not needed.
    // Looking at the image, it seems generic. Let's enforce PIN for everyone for security
    // or keep the previous "Quick Access" pattern but maybe just ask for a PIN?
    // For now, I'll allow "Quick Access" to bypass username but maybe require PIN if desired.
    // Let's stick to the previous logic: Admin/Waiter need credentials. Others might just need a button or simple PIN.

    // Actually, to match the UI perfectly, the form is always there.
    // Let's assume we need at least a PIN for everyone, or just Username/PIN for Admin/Waiter.

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
      // Simulate login delay
      await Future.delayed(const Duration(seconds: 1));

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
      case 'kitchen':
        destination = const KitchenScreen();
        break;
      case 'bar':
        destination = const BarScreen();
        break;
      case 'kiosk':
        destination = const KioskScreen();
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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current role theme color (optional, or just stick to black/white)
    final isQuickAccess = ['kitchen', 'bar', 'kiosk'].contains(_selectedRole);

    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Dark Navy Background
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
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
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Select your role to continue',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),

                          // Role Tabs
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Changed to center or start
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
                                      width: 80, // Fixed width or padding-based
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
                                        borderRadius: BorderRadius.circular(12),
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
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            role['label'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.black
                                                  : Colors.grey,
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

                          // Role Icon Indicator
                          Icon(
                            _roles.firstWhere(
                              (r) => r['id'] == _selectedRole,
                            )['icon'],
                            size: 48,
                            color: const Color(0xFF111827),
                          ),

                          const SizedBox(height: 32),

                          // Form
                          if (isQuickAccess) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Quick Access Mode',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No login required for ${_roles.firstWhere((r) => r['id'] == _selectedRole)['label']}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Username',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(color: Color(0xFF111827)),
                              cursorColor: const Color(0xFF111827),
                              decoration: InputDecoration(
                                hintText: 'Enter username',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _pinController,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              style: const TextStyle(color: Color(0xFF111827)),
                              cursorColor: const Color(0xFF111827),
                              decoration: InputDecoration(
                                hintText: '4-digit PIN',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                                backgroundColor: const Color(0xFF111827),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      isQuickAccess
                                          ? 'Enter ${_roles.firstWhere((r) => r['id'] == _selectedRole)['label']} Mode'
                                          : 'Login as ${_roles.firstWhere((r) => r['id'] == _selectedRole)['label']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          if (!isQuickAccess)
                            const Text(
                              'Default: admin / 1111',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button (Help)
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF1F2937),
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
