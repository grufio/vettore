import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/app_router.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
// Legacy VendorColorsOverviewPage removed with projects feature cleanup
import 'package:vettore/services/init_service.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure native window BEFORE first frame on macOS
  if (Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

  // Initialize database and settings service before building UI
  final db = AppDatabase();
  final settings = SettingsService(db);
  await settings.init();
  // Run one-time background tasks (import, cleanup) guarded by settings flags
  unawaited(InitService(db: db, settings: settings).run());

  runApp(ProviderScope(
    overrides: [
      settingsServiceProvider.overrideWithValue(settings),
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const MyApp(),
  ));

  // Only perform desktop window setup on macOS.
  if (Platform.isMacOS) {
    doWhenWindowReady(() {
      appWindow.minSize = const Size(400, 300);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Use go_router for all platforms.
    return WidgetsApp.router(
      color: kWhite,
      routerConfig: appRouter,
    );
  }
}
