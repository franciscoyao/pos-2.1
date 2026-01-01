import 'package:flutter/material.dart';
import 'package:pos_system/features/admin/history_tab.dart';
import 'package:pos_system/features/admin/menu_tab.dart';
import 'package:pos_system/features/admin/printers_tab.dart';
import 'package:pos_system/features/admin/settings_tab.dart';
import 'package:pos_system/features/admin/users_tab.dart';
import 'package:pos_system/features/auth/role_selection_screen.dart';
import 'package:pos_system/features/reports/reports_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const ReportsTab(), // New Light Reports
    const MenuTab(),
    const PrintersTab(),
    const UsersTab(),
    const AdminHistoryTab(),
    const SettingsTab(),
  ];

  final List<String> _titles = [
    'Reports',
    'Menu',
    'Printers',
    'Users',
    'History',
    'Settings',
  ];

  final List<IconData> _icons = [
    Icons.grid_view_rounded,
    Icons.restaurant_menu_rounded,
    Icons.print_outlined,
    Icons.people_alt_outlined,
    Icons.history_rounded,
    Icons.settings_outlined,
  ];

  Widget _buildSidebar({bool isDrawer = false}) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'POS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Admin User',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                if (isDrawer)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _titles.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    if (isDrawer) Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF3F4F6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _icons[index],
                          size: 20,
                          color: isSelected
                              ? const Color(0xFF111827)
                              : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _titles[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF111827)
                                : Colors.grey.shade500,
                          ),
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

  @override
  Widget build(BuildContext context) {
    // Force Light Theme for Admin Dashboard as per reference image
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        dividerColor: Colors.grey.shade200,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF111827), // Dark Sidebar Text
          secondary: Color(0xFF3B82F6), // Blue Accents
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 850;

          // On Desktop/Tablet, we show sidebar. On Mobile, we use drawer.
          final showPermanentSidebar = !isMobile;

          return Scaffold(
            key: _scaffoldKey,
            drawer: !showPermanentSidebar
                ? Drawer(child: _buildSidebar(isDrawer: true))
                : null,
            body: Row(
              children: [
                // Sidebar for Desktop/Tablet
                if (showPermanentSidebar) ...[
                  _buildSidebar(),
                  // Vertical Divider
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey.shade200,
                  ),
                ],

                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      // Top Bar
                      Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ), // Reduced padding
                        color: Colors.white,
                        child: Row(
                          children: [
                            if (!showPermanentSidebar)
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
                              ),
                            if (!showPermanentSidebar) const SizedBox(width: 8),

                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _titles[_selectedIndex] == 'Reports'
                                            ? 'Reports Dashboard'
                                            : _titles[_selectedIndex],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_titles[_selectedIndex] ==
                                              'Reports' &&
                                          !isMobile)
                                        Text(
                                          'Sales analytics and insights',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (!isMobile)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Online',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (!isMobile) const SizedBox(width: 16),
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RoleSelectionScreen(),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.logout,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                        label: isMobile
                                            ? const SizedBox.shrink()
                                            : const Text(
                                                'Logout',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Content Body
                      Expanded(
                        child: ColoredBox(
                          color: const Color(0xFFF9FAFB),
                          child: _pages[_selectedIndex],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
