import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/data/database/database.dart';
import 'package:pos_system/data/repositories/menu_repository.dart';
import 'package:pos_system/features/order/cart_provider.dart';
import 'package:pos_system/data/repositories/order_repository.dart';
import 'package:drift/drift.dart' show Value;

import 'package:pos_system/data/repositories/report_repository.dart';

class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  final _searchController = TextEditingController();
  final _tableController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final categoriesStream = ref
        .watch(menuRepositoryProvider)
        .watchCategories();

    // Listen to cart changes to update table controller if set externally
    ref.listen<CartState>(cartProvider, (previous, next) {
      if (next.tableNumber != _tableController.text) {
        if (next.tableNumber != null) {
          _tableController.text = next.tableNumber!;
        } else {
          // Only clear if explicitly null and previous wasn't, to avoid clearing while typing if logic varies
          // For now, if tableNumber becomes null in state (e.g. clear), we clear text
          _tableController.clear();
        }
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        if (isMobile) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Column(
              children: [
                // Mobile Top Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildToggleBtn(
                              label: 'Dine-In',
                              isSelected: cart.type == 'dine-in',
                              onTap: () => ref
                                  .read(cartProvider.notifier)
                                  .setType('dine-in'),
                              compact: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildToggleBtn(
                              label: 'Takeaway',
                              isSelected: cart.type == 'takeaway',
                              onTap: () => ref
                                  .read(cartProvider.notifier)
                                  .setType('takeaway'),
                              compact: true,
                            ),
                          ),
                        ],
                      ),
                      if (cart.type == 'dine-in') ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.grid_view,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _tableController,
                                  decoration: InputDecoration(
                                    hintText: 'Table No.',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) => ref
                                      .read(cartProvider.notifier)
                                      .setTableNumber(val),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildMenuContent(
                      cart,
                      categoriesStream,
                      isMobile: true,
                    ),
                  ),
                ),

                // Mobile Cart Summary Bar
                if (cart.items.isNotEmpty)
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          height: MediaQuery.of(context).size.height * 0.9,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 4,
                                width: 40,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Expanded(
                                child: _CartSidebar(
                                  cart: cart,
                                  onSend: () => _sendOrder(context, ref),
                                  isMobile: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${cart.items.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'View Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return Row(
          children: [
            // Left Side: Menu Area
            Expanded(
              flex: 3,
              child: Container(
                color: const Color(0xFFF9FAFB),
                child: Column(
                  children: [
                    // Top Action Bar
                    Container(
                      padding: const EdgeInsets.all(24),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                _buildToggleBtn(
                                  label: 'Dine-In',
                                  isSelected: cart.type == 'dine-in',
                                  onTap: () => ref
                                      .read(cartProvider.notifier)
                                      .setType('dine-in'),
                                ),
                                _buildToggleBtn(
                                  label: 'Takeaway',
                                  isSelected: cart.type == 'takeaway',
                                  onTap: () => ref
                                      .read(cartProvider.notifier)
                                      .setType('takeaway'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          if (cart.type == 'dine-in')
                            Expanded(
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.grid_view,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _tableController,
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Table No.',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (val) => ref
                                            .read(cartProvider.notifier)
                                            .setTableNumber(val),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (cart.type == 'takeaway') const Spacer(),
                          const SizedBox(width: 16),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.qr_code,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildMenuContent(
                          cart,
                          categoriesStream,
                          isMobile: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Side: Cart
            SizedBox(
              width: 400,
              child: _CartSidebar(
                cart: cart,
                onSend: () => _sendOrder(context, ref),
                isMobile: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuContent(
    CartState cart,
    Stream<List<Category>> categoriesStream, {
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Color(0xFF111827)),
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search menu...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 24),

        // Most Selling
        FutureBuilder<List<TopSellingItem>>(
          future: ref
              .watch(reportRepositoryProvider)
              .getTopSellingItems(orderType: cart.type),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            final topItems = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most Selling',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: topItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final item = topItems[index];
                      return _MostSellingCard(
                        name: item.name,
                        price: item.price,
                        imageColor:
                            Colors.primaries[index % Colors.primaries.length],
                        isAvailable: item.status == 'active',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Categories
        StreamBuilder<List<Category>>(
          stream: categoriesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) return const SizedBox();
            final categories = snapshot.data!;
            if (categories.isEmpty) return const SizedBox();
            final filteredCategories = categories.where((c) {
              return c.menuType == cart.type;
            }).toList();
            if (filteredCategories.isEmpty) return const SizedBox();

            return SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryPill(
                    label: 'All',
                    isSelected: _selectedCategoryId == null,
                    onTap: () => setState(() => _selectedCategoryId = null),
                  ),
                  ...filteredCategories.map(
                    (c) => _CategoryPill(
                      label: c.name,
                      isSelected: _selectedCategoryId == c.id,
                      onTap: () => setState(() => _selectedCategoryId = c.id),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Menu Grid
        _MenuGrid(
          selectedCategoryId: _selectedCategoryId,
          searchQuery: _searchController.text,
          crossAxisCount: isMobile ? 2 : 3,
        ),
      ],
    );
  }

  Widget _buildToggleBtn({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: compact
            ? const EdgeInsets.symmetric(vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
        alignment: compact ? Alignment.center : null,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111827) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _sendOrder(BuildContext context, WidgetRef ref) async {
    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    if (cart.type == 'dine-in' &&
        (cart.tableNumber == null || cart.tableNumber!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a table number')),
      );
      return;
    }

    try {
      final orderRepo = ref.read(orderRepositoryProvider);

      // Create Order object
      final order = OrdersCompanion.insert(
        orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        tableNumber: Value(cart.tableNumber),
        status: const Value('pending'),
        type: Value(cart.type),
        totalAmount: Value(cart.total),
      );

      // Create Order Items
      final orderItems = cart.items.map((item) {
        return OrderItemsCompanion.insert(
          orderId: 0, // Will be set by repository transaction
          menuItemId: item.menuItem.id,
          quantity: Value(item.quantity),
          priceAtTime: item.menuItem.price,
          // note: Value(item.note), // Note column missing in schema, skipping for now
        );
      }).toList();

      // Submit to database
      await orderRepo.submitOrder(order: order, items: orderItems);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(cartProvider.notifier).clear();
        _tableController.clear();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ... Sub-widgets (Grid, Cards, Pills) ...

class _MenuGrid extends ConsumerWidget {
  final int? selectedCategoryId;
  final String searchQuery;
  final int crossAxisCount;

  const _MenuGrid({
    this.selectedCategoryId,
    required this.searchQuery,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsStream = ref.watch(menuRepositoryProvider).watchAllItems();

    return StreamBuilder<List<MenuItem>>(
      stream: itemsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(child: Text('No items found'));
        }

        final cart = ref.watch(cartProvider);
        final filtered = items.where((i) {
          final matchCat =
              selectedCategoryId == null || i.categoryId == selectedCategoryId;
          final matchSearch = i.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
          // Filter by item type matching cart type
          final matchType = i.type == cart.type;

          return matchCat && matchSearch && matchType;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No items found'));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount, // Adjust for screen size ideally
            childAspectRatio: 0.85, // Adjust card aspect
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            return _MenuItemCard(item: item);
          },
        );
      },
    );
  }
}

class _MenuItemCard extends ConsumerWidget {
  final MenuItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Opacity(
        opacity: item.status == 'active' ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF111827),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF111827),
                  ),
                ),
                if (item.status == 'active')
                  InkWell(
                    onTap: () {
                      ref.read(cartProvider.notifier).addItem(item);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  )
                else
                  const Text(
                    'Unavailable',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
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

class _CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.grey.shade300, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF111827) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _MostSellingCard extends StatelessWidget {
  final String name;
  final double price;
  final Color imageColor;
  final bool isAvailable;

  const _MostSellingCard({
    required this.name,
    required this.price,
    required this.imageColor,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Popular', style: TextStyle(fontSize: 10)),
                ),
                if (!isAvailable) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Unavailable',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                if (isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white, fontSize: 10),
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

class _CartItemRow extends ConsumerWidget {
  final CartItem item;

  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fastfood, size: 24, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.menuItem.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.total.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).removeItem(item.menuItem);
                  if (item.quantity == 1) {
                    // logic handled in provider but usually removes it
                  }
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ],
          ),
          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.yellow.shade200),
              ),
              child: Text(
                'Note: ${item.note}',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Quantity Controls
          Row(
            children: [
              _QuantityBtn(
                icon: Icons.remove,
                onTap: () {
                  ref.read(cartProvider.notifier).removeItem(item.menuItem);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF111827), // Fixed color
                  ),
                ),
              ),
              _QuantityBtn(
                icon: Icons.add,
                onTap: () =>
                    ref.read(cartProvider.notifier).addItem(item.menuItem),
              ),
              const Spacer(),
              const SizedBox(width: 8),
              // Price total for item line? Details?
              if (item.menuItem.allowPriceEdit)
                InkWell(
                  onTap: () => _showEditPriceDialog(context, ref, item),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  '\$${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showAddNoteDialog(context, ref, item),
            child: const Text(
              'Add details',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPriceDialog(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
  ) {
    final controller = TextEditingController(
      text: (item.overriddenPrice ?? item.menuItem.price).toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Price'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Price',
            border: OutlineInputBorder(),
            prefixText: '\$',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                ref
                    .read(cartProvider.notifier)
                    .updateItemPrice(item.menuItem, newPrice);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, WidgetRef ref, CartItem item) {
    final controller = TextEditingController(text: item.note);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter details (e.g., No onions)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(cartProvider.notifier)
                  .updateItemNote(item.menuItem, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _QuantityBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _CartSidebar extends StatelessWidget {
  final CartState cart;
  final VoidCallback onSend;
  final bool isMobile;

  const _CartSidebar({
    required this.cart,
    required this.onSend,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Order',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cart.tableNumber != null && cart.tableNumber!.isNotEmpty
                    ? 'Table ${cart.tableNumber}'
                    : 'Select a table',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Cart Items
        Expanded(
          child: cart.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cart is empty',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemRow(item: item);
                  },
                ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, -4),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items:', style: TextStyle(color: Colors.grey.shade600)),
                  Text(
                    '${cart.items.length}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal:',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Text(
                    '\$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: cart.items.isEmpty ? null : onSend,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
