import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/features/auth/role_selection_screen.dart';
import 'package:pos_system/features/checkout/checkout_table_selection_screen.dart';
import 'package:pos_system/features/dashboard/dashboard_provider.dart';
import 'package:pos_system/features/order/bills_screen.dart';
import 'package:pos_system/features/order/new_order_screen.dart';
import 'package:pos_system/features/order/order_history_screen.dart';
import 'package:pos_system/features/order/tables_screen.dart';

class WaiterDashboard extends ConsumerStatefulWidget {
  const WaiterDashboard({super.key});

  @override
  ConsumerState<WaiterDashboard> createState() => _WaiterDashboardState();
}

class _WaiterDashboardState extends ConsumerState<WaiterDashboard> {
  // _selectedIndex is now managed by the provider

  final List<Widget> _pages = const [
    NewOrderScreen(),
    TablesScreen(),
    CheckoutTableSelectionScreen(),
    OrderHistoryScreen(),
    BillsScreen(),
  ];

  final List<String> _titles = [
    'New Order',
    'Tables',
    'Checkout',
    'Orders',
    'Bills',
  ];

  final List<IconData> _icons = [
    Icons.shopping_cart_outlined,
    Icons.grid_view,
    Icons.payment,
    Icons.history,
    Icons.receipt_long,
  ];

  Widget _buildSidebar({bool isDrawer = false}) {
    // We can't access ref inside a standalone method easily without context if we need it,
    // but here we just need to read/watch.
    // Since this method is inside State, we can access `ref` directly if the State mixes in ConsumerState.
    // WaiterDashboard is ConsumerStatefulWidget, so valid.

    // We need to get the selected index again or pass it in.
    // But since it's a method on the State class, we can just use `ref` inside the builder or
    // pass the current index.
    // Actually better to just build it here since it's small.

    // Note: To avoid "ref" issues in extraction, I will keep it simple.
    // But wait, the original code used `ref.watch` in build.
    // I should probably use a Consumer or just use `ref` from the State.

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
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
                      'John Doe', // Placeholder user name
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
          Expanded(
            child: ListView.builder(
              itemCount: _titles.length,
              itemBuilder: (context, index) {
                // We need to watch it here to rebuild sidebar when index changes if it's external,
                // but usually the parent rebuilds.
                // Let's use ref.read for actions and assume rebuild happens from parent.
                final selectedIndex = ref.watch(dashboardControllerProvider);
                final isSelected = selectedIndex == index;

                return InkWell(
                  onTap: () {
                    ref
                        .read(dashboardControllerProvider.notifier)
                        .setIndex(index);
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
    final selectedIndex = ref.watch(dashboardControllerProvider);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;
        final showPermanentSidebar = !isMobile;

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF9FAFB),
          drawer: isMobile
              ? Drawer(child: _buildSidebar(isDrawer: true))
              : null,
          body: Row(
            children: [
              // Sidebar
              if (showPermanentSidebar) ...[
                _buildSidebar(),
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
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (isMobile)
                                IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () =>
                                      scaffoldKey.currentState?.openDrawer(),
                                ),
                              if (isMobile) const SizedBox(width: 8),
                            ],
                          ),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(20),
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
                              const SizedBox(width: 16),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
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
                                        style: TextStyle(color: Colors.grey),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: Colors.grey.shade200),
                    // Page Content
                    Expanded(child: _pages[selectedIndex]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
