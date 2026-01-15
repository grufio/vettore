import 'dart:io' show Platform;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: always_use_package_imports
import 'app_router.dart';
import 'theme/app_theme_colors.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure native window BEFORE first frame on macOS
  if (Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

  runApp(const ProviderScope(
    child: MyApp(),
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
    // Use WidgetsApp with explicit localization delegates (no Material shell)
    return WidgetsApp.router(
      color: kWhite,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
    );
  }
}
