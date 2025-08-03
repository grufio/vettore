import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:vettore/app_overview.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
// Note: I'm leaving the other imports commented out for now
// as they are not used by the preview page, but we will need them back later.
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:vettore/features/projects/project_overview_page.dart';
// import 'package:vettore/services/settings_service.dart';
// import 'package:vettore/data/database.dart';
// import 'package:vettore/services/seeding_service.dart';
// import 'package:vettore/providers/application_providers.dart';
// import 'package:vettore/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use the recommended configuration from macos_ui
  const config = MacosWindowUtilsConfig(
    toolbarStyle: NSWindowToolbarStyle.expanded,
  );
  await config.apply();

  runApp(const MyApp());

  // The database and services are not needed for the UI preview.
  // We will uncomment this when we switch back.
  // final database = AppDatabase();
  // final settingsService = SettingsService(database);
  // await settingsService.init();
  // await SeedingService(database).seedVendorColors();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const AppOverviewPage(),
    );
  }
}
