import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_system/data/database/database_provider.dart';
import 'package:pos_system/data/database/seed_service.dart';
import 'package:pos_system/features/auth/role_selection_screen.dart';
import 'package:pos_system/core/theme/app_theme.dart';

import 'package:pos_system/data/services/sync_provider.dart';

import 'package:pos_system/core/services/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.load();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final db = ref.read(databaseProvider);
    final seeder = SeedService(db);
    await seeder.seedIfNeeded();

    // Initialize WebSocket connection

    // Initial Sync
    final syncService = ref.read(syncServiceProvider);
    await syncService.syncAll();

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'POS System',
      theme: AppTheme.lightTheme,
      home: const RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
