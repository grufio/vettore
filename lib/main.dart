import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/data/migration_service.dart';
import 'package:vettore/loading_page.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/repositories/palette_repository.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/initialization_service.dart';
import 'package:vettore/services/project_service.dart';

final initializationProvider = FutureProvider<void>((ref) async {
  final initializationService = InitializationService();
  await initializationService.initialize();

  // --- ONE-TIME MIGRATION ---
  // Uncomment the following line and run the app ONCE to migrate the database.
  // After a successful run, comment it out again or remove it.
  await MigrationService.migrateComponentsToSeparateBox();
  // -------------------------
});

final paletteRepositoryProvider = Provider<PaletteRepository>((ref) {
  final box = Hive.box<Palette>('palettes');
  return PaletteRepository(box);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final box = Hive.box<Project>('projects');
  return ProjectRepository(box);
});

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vettore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoadingPage(),
    );
  }
}
