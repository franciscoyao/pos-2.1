import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_system/data/repositories/order_repository.dart';
import 'package:pos_system/features/auth/role_selection_screen.dart';
import 'package:intl/intl.dart';

class KitchenDashboard extends ConsumerStatefulWidget {
  const KitchenDashboard({super.key});

  @override
  ConsumerState<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends ConsumerState<KitchenDashboard> {
  @override
  Widget build(BuildContext context) {
    // Watch orders filtered by 'kitchen' station

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E), // Premium Dark Background
      appBar: AppBar(
        title: const Text(
          'KITCHEN DISPLAY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF272739),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<OrderWithDetails>>(
        stream: ref
            .watch(orderRepositoryProvider)
            .watchOrdersByStation('kitchen'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7, // Taller cards for tickets
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _OrderTicket(orderWithDetails: orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'All Caught Up!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for new orders...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTicket extends ConsumerWidget {
  final OrderWithDetails orderWithDetails;

  const _OrderTicket({required this.orderWithDetails});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = orderWithDetails.order;
    final items = orderWithDetails.items;
    final duration = DateTime.now().difference(order.createdAt);

    // Determine color based on wait time
    Color statusColor = Colors.greenAccent; // Fresh
    if (duration.inMinutes > 20) {
      statusColor = Colors.redAccent; // Critical
    } else if (duration.inMinutes > 10) {
      statusColor = Colors.orangeAccent; // Warning
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF272739),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'T-${order.tableNumber ?? "?"}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
                Text(
                  '#${order.orderNumber.substring(order.orderNumber.length - 4)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: 'Monospace',
                  ),
                ),
              ],
            ),
          ),

          // Time Bar
          LinearProgressIndicator(
            value: null, // Indeterminate to show activity
            color: statusColor,
            backgroundColor: Colors.transparent,
            minHeight: 2,
          ),

          // Info Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('HH:mm').format(order.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  '${duration.inMinutes} min',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white10),

          // Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isDone =
                    item.item.status == 'ready' || item.item.status == 'served';

                return InkWell(
                  onTap: () {
                    // Toggle individual item status?
                    // For now simplicity: just visual row
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.item.quantity}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.menu.name,
                            style: TextStyle(
                              color: isDone ? Colors.grey : Colors.white,
                              fontSize: 16,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () {
                _markOrderReady(ref, order.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'MARK READY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markOrderReady(WidgetRef ref, int orderId) async {
    // Optimistic UI update could happen here, but stream will handle it
    await ref.read(orderRepositoryProvider).updateOrderStatus(orderId, 'ready');
  }
}
