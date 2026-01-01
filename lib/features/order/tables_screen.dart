import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/core/theme/app_colors.dart';
import 'package:pos_system/data/database/database.dart';
import 'package:pos_system/data/repositories/order_repository.dart';
import 'package:pos_system/data/repositories/table_repository.dart';
import 'package:pos_system/features/order/table_details_sidebar.dart';

class TablesScreen extends ConsumerStatefulWidget {
  const TablesScreen({super.key});

  @override
  ConsumerState<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends ConsumerState<TablesScreen> {
  RestaurantTable? _selectedTable;

  @override
  Widget build(BuildContext context) {
    final tablesStream = ref.watch(tableRepositoryProvider).watchAllTables();
    final activeOrdersStream = ref
        .watch(orderRepositoryProvider)
        .watchActiveOrders();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        return Row(
          children: [
            // Main Grid
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder(
                      stream: tablesStream,
                      builder: (context, tablesSnapshot) {
                        if (tablesSnapshot.hasError) {
                          return Text('Error: ${tablesSnapshot.error}');
                        }
                        if (!tablesSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final tables = tablesSnapshot.data!;

                        // We also need active orders to show status/totals
                        return StreamBuilder(
                          stream: activeOrdersStream,
                          builder: (context, ordersSnapshot) {
                            final orders = ordersSnapshot.data ?? [];

                            return Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tables',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tables.length} tables • ${orders.map((o) => o.tableNumber).toSet().length} active',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: isMobile ? 2 : 3,
                                            childAspectRatio: 1.2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                          ),
                                      itemCount:
                                          tables.length +
                                          1, // +1 for Add ScrollView
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return _AddTableCard(
                                            onTap: () =>
                                                _showAddTableDialog(context),
                                          );
                                        }
                                        final table = tables[index - 1];
                                        // Calculate totals
                                        final tableOrders = orders
                                            .where(
                                              (o) =>
                                                  o.tableNumber == table.name,
                                            )
                                            .toList();
                                        final total = tableOrders.fold(
                                          0.0,
                                          (sum, o) => sum + o.totalAmount,
                                        );
                                        final isActive = tableOrders.isNotEmpty;

                                        // Get first order time for duration calculation
                                        DateTime? firstOrderTime;
                                        if (tableOrders.isNotEmpty) {
                                          tableOrders.sort(
                                            (a, b) => a.createdAt.compareTo(
                                              b.createdAt,
                                            ),
                                          );
                                          firstOrderTime =
                                              tableOrders.first.createdAt;
                                        }

                                        return _TableCard(
                                          table: table,
                                          isActive: isActive,
                                          activeOrdersCount: tableOrders.length,
                                          totalAmount: total,
                                          isSelected:
                                              _selectedTable?.id == table.id,
                                          firstOrderTime: firstOrderTime,
                                          onTap: () {
                                            if (isMobile) {
                                              // On mobile, show modal or navigate
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (context) => Container(
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.85,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.background,
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            20,
                                                          ),
                                                        ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 4,
                                                        width: 40,
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey
                                                              .shade300,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                2,
                                                              ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child:
                                                            TableDetailsSidebar(
                                                              table: table,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ).then((_) {
                                                setState(() {
                                                  _selectedTable = null;
                                                });
                                              });
                                            }
                                            setState(() {
                                              _selectedTable = table;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Right Sidebar (Desktop only)
            if (!isMobile)
              Container(
                width: 400,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(left: BorderSide(color: AppColors.border)),
                ),
                child: _selectedTable == null
                    ? Center(
                        child: Text(
                          'Select a table',
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                      )
                    : TableDetailsSidebar(table: _selectedTable!),
              ),
          ],
        );
      },
    );
  }

  void _showAddTableDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Table'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Table Name (e.g. 5)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(tableRepositoryProvider).addTable(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _AddTableCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTableCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 32, color: AppColors.textTertiary),
                const SizedBox(height: 8),
                Text(
                  'Add Table',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;
    final path = Path();

    // Draw dashed rectangle
    double startX = 0;
    while (startX < size.width) {
      path.moveTo(startX, 0);
      path.lineTo(startX + dashWidth, 0);
      startX += dashWidth + dashSpace;
    }

    double startY = 0;
    while (startY < size.height) {
      path.moveTo(size.width, startY);
      path.lineTo(size.width, startY + dashWidth);
      startY += dashWidth + dashSpace;
    }

    startX = size.width;
    while (startX > 0) {
      path.moveTo(startX, size.height);
      path.lineTo(startX - dashWidth, size.height);
      startX -= dashWidth + dashSpace;
    }

    startY = size.height;
    while (startY > 0) {
      path.moveTo(0, startY);
      path.lineTo(0, startY - dashWidth);
      startY -= dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TableCard extends ConsumerWidget {
  final RestaurantTable table;
  final bool isActive;
  final int activeOrdersCount;
  final double totalAmount;
  final bool isSelected;
  final VoidCallback onTap;
  final DateTime? firstOrderTime;

  const _TableCard({
    required this.table,
    required this.isActive,
    required this.activeOrdersCount,
    required this.totalAmount,
    required this.isSelected,
    required this.onTap,
    this.firstOrderTime,
  });

  String _formatDuration(DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceLight : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.textPrimary
                : (isActive
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Table',
                  style: TextStyle(
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Table'),
                            content: Text(
                              'Are you sure you want to delete ${table.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(tableRepositoryProvider)
                                      .deleteTable(table.id);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    table.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            if (isActive)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$activeOrdersCount orders',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            else
              Text(
                'Available',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
              ),
            // Timer
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isActive
                      ? AppColors.textSecondary
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive && firstOrderTime != null
                      ? _formatDuration(firstOrderTime!)
                      : '-',
                  style: TextStyle(
                    color: isActive
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
