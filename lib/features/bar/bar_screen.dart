import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/core/theme/app_colors.dart';
import 'package:pos_system/data/repositories/order_repository.dart';
import 'package:pos_system/features/auth/role_selection_screen.dart';

class BarScreen extends ConsumerStatefulWidget {
  const BarScreen({super.key});

  @override
  ConsumerState<BarScreen> createState() => _BarScreenState();
}

class _BarScreenState extends ConsumerState<BarScreen> {
  bool _barOnly = true;

  @override
  Widget build(BuildContext context) {
    final stream = _barOnly
        ? ref.watch(orderRepositoryProvider).watchOrdersByStation('bar')
        : ref.watch(orderRepositoryProvider).watchAllActiveOrdersWithItems();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bar Orders',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            StreamBuilder(
              stream: stream,
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Text(
                  '$count active orders',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ],
        ),
        // ... existing code ...
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Bar Only')),
                    ButtonSegment(value: false, label: Text('All Stations')),
                  ],
                  selected: {_barOnly},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _barOnly = newSelection.first;
                    });
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const RoleSelectionScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<OrderWithDetails>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          final newOrders = orders
              .where(
                (o) => o.order.status == 'pending' || o.order.status == 'sent',
              )
              .toList();
          final acceptedOrders = orders
              .where((o) => o.order.status == 'accepted')
              .toList();

          final readyOrders = orders
              .where((o) => o.order.status == 'ready')
              .toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 800;

              if (isMobile) {
                return DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildSummaryHeader(
                          newOrders.length,
                          acceptedOrders.length,
                          0,
                          readyOrders.length,
                        ),
                      ),
                      const TabBar(
                        isScrollable: true,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: 'New Orders'),
                          Tab(text: 'Accepted'),
                          Tab(text: 'Ready'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildColumn(
                              'New Orders',
                              newOrders,
                              Colors.red.shade50,
                              'accepted',
                            ),
                            _buildColumn(
                              'Accepted',
                              acceptedOrders,
                              Colors.orange.shade50,
                              'cooking', // Bar might allow cooking status? or direct to ready? preserving existing logic
                            ),
                            _buildColumn(
                              'Ready',
                              readyOrders,
                              Colors.green.shade50,
                              'served',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  _buildSummaryHeader(
                    newOrders.length,
                    acceptedOrders.length,
                    0, // No cooking/mixing stage
                    readyOrders.length,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildColumn(
                              'New Orders',
                              newOrders,
                              Colors.red.shade50,
                              'accepted',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildColumn(
                              'Accepted',
                              acceptedOrders,
                              Colors.orange.shade50,
                              'cooking',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildColumn(
                              'Ready',
                              readyOrders,
                              Colors.green.shade50,
                              'served',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildColumn(
    String title,
    List<OrderWithDetails> orders,
    Color bg,
    String nextStatus,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: orders.isNotEmpty
                      ? Colors.grey.shade100
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${orders.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: orders.isNotEmpty
                        ? Colors.black87
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_bar_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No orders',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _BarOrderCard(
                      orderWithDetails: orders[index],
                      nextStatus: nextStatus,
                      onStatusChange: (status) {
                        ref
                            .read(orderRepositoryProvider)
                            .updateOrderStatus(orders[index].order.id, status);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(
    int newCount,
    int acceptedCount,
    int cookingCount,
    int readyCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          _buildSummaryItem('Pending', newCount, Colors.red),
          const SizedBox(width: 32),
          _buildSummaryItem('Accepted', acceptedCount, Colors.orange),

          const SizedBox(width: 32),
          _buildSummaryItem('Ready', readyCount, Colors.green),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

class _BarOrderCard extends StatelessWidget {
  final OrderWithDetails orderWithDetails;
  final String nextStatus;
  final Function(String) onStatusChange;

  const _BarOrderCard({
    required this.orderWithDetails,
    required this.nextStatus,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final order = orderWithDetails.order;
    final duration = DateTime.now().difference(order.createdAt);
    final isDelayed = duration.inMinutes > 10; // 10 min for bar

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDelayed
              ? AppColors.error.withValues(alpha: 0.5)
              : AppColors.border,
          width: isDelayed ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDelayed
                ? AppColors.error.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'bar',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Table ${order.tableNumber}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '${duration.inMinutes} min ago',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              if (isDelayed) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Delayed',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 24),

          ...orderWithDetails.items.map((itemWithMenu) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    '${itemWithMenu.item.quantity}x',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(itemWithMenu.menu.name)),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              if (order.status == 'pending' || order.status == 'sent') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onStatusChange('accepted'),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onStatusChange('cancelled'),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ] else if (order.status == 'accepted') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onStatusChange('ready'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark Ready'),
                  ),
                ),
              ] else if (order.status == 'ready') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onStatusChange('served'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Served'),
                  ),
                ),
              ],
            ],
          ),
          if (order.status == 'pending' || order.status == 'sent')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Printing order to bar printer...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.print, size: 16),
                label: const Text('Reprint'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(36),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
