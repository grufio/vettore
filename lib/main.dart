import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_overview.dart';
import 'theme/app_theme_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure native window BEFORE first frame on macOS
  if (Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await WindowManipulator.initialize();
  }

  runApp(const ProviderScope(child: MyApp()));

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
    if (Platform.isMacOS) {
      return const MacosApp(
        debugShowCheckedModeBanner: false,
        home: AppOverviewPage(),
      );
    }

    // On non-macOS (e.g., iOS), use a minimal WidgetsApp to render content
    // without importing Material or Cupertino themes.
    return WidgetsApp(
      color: kWhite,
      builder: (context, _) => const AppOverviewPage(),
    );
  }
}
