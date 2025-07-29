import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/features/projects/project_overview_page.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/services/seeding_service.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.init();

  final database = AppDatabase();
  await SeedingService(database).seedVendorColors();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const VettoreApp(),
    ),
  );
}

class VettoreApp extends StatelessWidget {
  const VettoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vettore',
      theme: appTheme,
      home: const ProjectOverviewPage(),
    );
  }
}
