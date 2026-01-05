import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_system/data/database/database.dart';

class SyncService {
  final AppDatabase db;
  final Dio dio;
  final String baseUrl; // http://localhost:3000
  late socket_io.Socket socket;

  SyncService(this.db, {String? baseUrl})
    : dio = Dio(),
      baseUrl = baseUrl ?? 'http://localhost:3000' {
    initRealtimeUpdates();
  }

  final List<Map<String, dynamic>> _offlineQueue = [];
  bool get isOnline => socket.connected;

  void initRealtimeUpdates() {
    socket = socket_io.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      debugPrint('Connected to WebSocket server');
      _processOfflineQueue();
    });

    socket.onDisconnect(
      (_) => debugPrint('Disconnected from WebSocket server'),
    );

    socket.on('order:new', (data) => upsertOrder(data));
    socket.on('order:update', (data) => upsertOrder(data));
    socket.on('table:update', (data) => upsertRestaurantTable(data));
    socket.on('category:update', (data) => upsertCategory(data));
    socket.on('menu-item:update', (data) => upsertMenuItem(data));
    socket.on('user:update', (data) => upsertUser(data));
    socket.on('printer:update', (data) => upsertPrinter(data));
    socket.on('setting:update', (data) => upsertSetting(data));
  }

  Future<void> _processOfflineQueue() async {
    if (_offlineQueue.isEmpty) return;

    debugPrint('Processing offline queue: ${_offlineQueue.length} items');
    final List<Map<String, dynamic>> remaining = [];

    for (var item in _offlineQueue) {
      try {
        final type = item['__type'];
        final data = item['data'];

        if (type == 'create_order') {
          await dio.post('$baseUrl/orders', data: data);
        } else if (type == 'update_order_status') {
          await dio.put('$baseUrl/orders/${item['id']}', data: data);
        }

        // Add more handlers as needed
      } catch (e) {
        debugPrint('Failed to process queue item: $e');
        remaining.add(item); // Keep it to retry later
      }
    }

    _offlineQueue.clear();
    _offlineQueue.addAll(remaining);
  }

  Future<void> syncAll() async {
    try {
      await syncTables();
      await syncCategories();
      await syncMenuItems();

      await syncOrders();
      await syncUsers();
      await syncPrinters();
      await syncSettings();
      debugPrint('Sync completed successfully');

      // Also try processing queue if we just synced successfully
      _processOfflineQueue();
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  Future<void> syncTables() async {
    try {
      final response = await dio.get('$baseUrl/tables');
      final List<dynamic> data = response.data;

      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          db.restaurantTables,
          data.map(
            (json) => RestaurantTablesCompanion(
              id: Value(json['id']),
              name: Value(json['name']),
              status: Value(json['status']),
              x: Value(json['x']),
              y: Value(json['y']),
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Failed to sync tables: $e');
    }
  }

  Future<void> syncCategories() async {
    try {
      final response = await dio.get('$baseUrl/categories');
      final List<dynamic> data = response.data;

      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          db.categories,
          data.map(
            (json) => CategoriesCompanion(
              id: Value(json['id']),
              name: Value(json['name']),
              menuType: Value(json['menuType']),
              sortOrder: Value(json['sortOrder']),
              station: Value(json['station']),
              status: Value(json['status']),
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Failed to sync categories: $e');
    }
  }

  Future<void> syncMenuItems() async {
    try {
      final response = await dio.get('$baseUrl/menu-items');
      final List<dynamic> data = response.data;

      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          db.menuItems,
          data.map(
            (json) => MenuItemsCompanion(
              id: Value(json['id']),
              code: Value(json['code']),
              name: Value(json['name']),
              price: Value(json['price'].toDouble()),
              categoryId: Value(json['categoryId']),
              station: Value(json['station']),
              type: Value(json['type']),
              status: Value(json['status']),
              allowPriceEdit: Value(json['allowPriceEdit']),
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Failed to sync menu items: $e');
    }
  }

  Future<void> syncOrders() async {
    try {
      final response = await dio.get('$baseUrl/orders/sync');
      final List<dynamic> data = response.data;

      for (var json in data) {
        await db
            .into(db.orders)
            .insertOnConflictUpdate(
              OrdersCompanion(
                id: Value(json['id']),
                orderNumber: Value(json['orderNumber']),
                tableNumber: Value(json['tableNumber']),
                type: Value(json['type']),
                status: Value(json['status']),
                totalAmount: Value(json['totalAmount'].toDouble()),
                taxAmount: Value(json['taxAmount']?.toDouble() ?? 0.0),
                serviceAmount: Value(json['serviceAmount']?.toDouble() ?? 0.0),
                paymentMethod: Value(json['paymentMethod']),
                tipAmount: Value(json['tipAmount']?.toDouble() ?? 0.0),
                taxNumber: Value(json['taxNumber']),
                completedAt: Value(
                  json['completedAt'] != null
                      ? DateTime.parse(json['completedAt'])
                      : null,
                ),
              ),
            );

        // Also handle items logic if needed (simplified here for brevity as per original)
        if (json['items'] != null) {
          // ... (restoring item sync logic if it was there, let's keep it robust)
          final List<dynamic> items = json['items'];
          for (var item in items) {
            await db
                .into(db.orderItems)
                .insertOnConflictUpdate(
                  OrderItemsCompanion(
                    id: Value(item['id']),
                    orderId: Value(item['orderId']),
                    menuItemId: Value(item['menuItemId']),
                    quantity: Value(item['quantity']),
                    priceAtTime: Value(item['priceAtTime']?.toDouble() ?? 0.0),
                    status: Value(item['status'] ?? 'pending'),
                  ),
                );
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to sync orders: $e');
    }
  }

  Future<void> createOrder(
    OrdersCompanion order,
    List<OrderItemsCompanion> items,
  ) async {
    final orderJson = {
      'orderNumber': order.orderNumber.value,
      'tableNumber': order.tableNumber.value,
      'type': order.type.value,
      'status': order.status.value,
      'totalAmount': order.totalAmount.value,
      'items': items
          .map(
            (i) => {
              'menuItemId': i.menuItemId.value,
              'quantity': i.quantity.value,
              'priceAtTime': i.priceAtTime.value,
            },
          )
          .toList(),
    };

    try {
      await dio.post('$baseUrl/orders', data: orderJson);
    } catch (e) {
      debugPrint('Failed to sync order upstream: $e. Adding to offline queue.');
      _offlineQueue.add({'__type': 'create_order', 'data': orderJson});
    }
  }

  Future<void> updateTableStatus(int id, String status) async {
    try {
      await dio.put('$baseUrl/tables/$id', data: {'status': status});
    } catch (e) {
      debugPrint('Failed to sync table status upstream: $e');
    }
  }

  Future<void> updateOrderStatus(int id, String status) async {
    try {
      await dio.put('$baseUrl/orders/$id', data: {'status': status});
    } catch (e) {
      debugPrint('Failed to sync order status upstream: $e. Adding to queue.');
      _offlineQueue.add({
        '__type': 'update_order_status',
        'id': id,
        'data': {'status': status},
      });
    }
  }

  // Real-time update handlers
  Future<void> upsertRestaurantTable(Map<String, dynamic> json) async {
    await db
        .into(db.restaurantTables)
        .insertOnConflictUpdate(
          RestaurantTablesCompanion(
            id: Value(json['id']),
            name: Value(json['name']),
            status: Value(json['status']),
            x: Value(json['x']),
            y: Value(json['y']),
          ),
        );
  }

  Future<void> upsertCategory(Map<String, dynamic> json) async {
    await db
        .into(db.categories)
        .insertOnConflictUpdate(
          CategoriesCompanion(
            id: Value(json['id']),
            name: Value(json['name']),
            menuType: Value(json['menuType']),
            sortOrder: Value(json['sortOrder']),
            station: Value(json['station']),
            status: Value(json['status']),
          ),
        );
  }

  Future<void> upsertMenuItem(Map<String, dynamic> json) async {
    await db
        .into(db.menuItems)
        .insertOnConflictUpdate(
          MenuItemsCompanion(
            id: Value(json['id']),
            code: Value(json['code']),
            name: Value(json['name']),
            price: Value(json['price'].toDouble()),
            categoryId: Value(json['categoryId']),
            station: Value(json['station']),
            type: Value(json['type']),
            status: Value(json['status']),
            allowPriceEdit: Value(json['allowPriceEdit']),
          ),
        );
  }

  Future<void> upsertOrder(Map<String, dynamic> json) async {
    // Upsert order
    await db
        .into(db.orders)
        .insertOnConflictUpdate(
          OrdersCompanion(
            id: Value(json['id']),
            orderNumber: Value(json['orderNumber']),
            tableNumber: Value(json['tableNumber']),
            type: Value(json['type']),
            status: Value(json['status']),
            totalAmount: Value(json['totalAmount'].toDouble()),
            taxAmount: Value(json['taxAmount']?.toDouble() ?? 0.0),
            serviceAmount: Value(json['serviceAmount']?.toDouble() ?? 0.0),
            paymentMethod: Value(json['paymentMethod']),
            tipAmount: Value(json['tipAmount']?.toDouble() ?? 0.0),
            taxNumber: Value(json['taxNumber']),
            completedAt: Value(
              json['completedAt'] != null
                  ? DateTime.parse(json['completedAt'])
                  : null,
            ),
          ),
        );

    // Upsert items if present
    if (json['items'] != null) {
      final List<dynamic> items = json['items'];
      for (var item in items) {
        await db
            .into(db.orderItems)
            .insertOnConflictUpdate(
              OrderItemsCompanion(
                id: Value(item['id']),
                orderId: Value(item['orderId']),
                menuItemId: Value(item['menuItemId']),
                quantity: Value(item['quantity']),
                priceAtTime: Value(item['priceAtTime']?.toDouble() ?? 0.0),
                status: Value(item['status'] ?? 'pending'),
              ),
            );
      }
    }
  }

  Future<void> syncUsers() async {
    try {
      final response = await dio.get('$baseUrl/users');
      final List<dynamic> data = response.data;

      for (var json in data) {
        await upsertUser(json);
      }
    } catch (e) {
      debugPrint('Failed to sync users: $e');
    }
  }

  Future<void> syncPrinters() async {
    try {
      final response = await dio.get('$baseUrl/printers');
      final List<dynamic> data = response.data;

      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          db.printers,
          data.map(
            (json) => PrintersCompanion(
              id: Value(json['id']),
              name: Value(json['name']),
              macAddress: Value(json['macAddress']),
              role: Value(json['role']),
              status: Value(json['status']),
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Failed to sync printers: $e');
    }
  }

  Future<void> syncSettings() async {
    try {
      final response = await dio.get('$baseUrl/settings');
      final List<dynamic> data = response.data;

      // Assuming one settings row or multiple, usually just one logic but we'll sync all
      await db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          db.settings,
          data.map(
            (json) => SettingsCompanion(
              id: Value(json['id']),
              taxRate: Value(json['taxRate']?.toDouble() ?? 0.0),
              serviceRate: Value(json['serviceRate']?.toDouble() ?? 0.0),
              currencySymbol: Value(json['currencySymbol'] ?? '\$'),
              kioskMode: Value(json['kioskMode'] ?? false),
              orderDelayThreshold: Value(json['orderDelayThreshold'] ?? 15),
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Failed to sync settings: $e');
    }
  }

  Future<void> upsertUser(Map<String, dynamic> json) async {
    await db
        .into(db.users)
        .insertOnConflictUpdate(
          UsersCompanion(
            id: Value(json['id']),
            fullName: Value(json['fullName']),
            username: Value(json['username']),
            pin: Value(json['pin']),
            role: Value(json['role']),
            status: Value(json['status'] ?? 'active'),
            createdAt: Value(
              json['createdAt'] != null
                  ? DateTime.parse(json['createdAt'])
                  : DateTime.now(),
            ),
          ),
        );
  }

  Future<void> upsertPrinter(Map<String, dynamic> json) async {
    await db
        .into(db.printers)
        .insertOnConflictUpdate(
          PrintersCompanion(
            id: Value(json['id']),
            name: Value(json['name']),
            macAddress: Value(json['macAddress']),
            role: Value(json['role']),
            status: Value(json['status']),
          ),
        );
  }

  Future<void> upsertSetting(Map<String, dynamic> json) async {
    await db
        .into(db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion(
            id: Value(json['id']),
            taxRate: Value(json['taxRate']?.toDouble() ?? 0.0),
            serviceRate: Value(json['serviceRate']?.toDouble() ?? 0.0),
            currencySymbol: Value(json['currencySymbol'] ?? '\$'),
            kioskMode: Value(json['kioskMode'] ?? false),
            orderDelayThreshold: Value(json['orderDelayThreshold'] ?? 15),
          ),
        );
  }
}
