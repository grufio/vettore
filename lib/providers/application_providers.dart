import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/repositories/palette_repository.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/services/ai_service.dart';
// duplicate imports removed

//-
// Database Provider
//-
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

//-
// Repository Providers
//-
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProjectRepository(db);
});

final paletteRepositoryProvider = Provider<PaletteRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PaletteRepository(db);
});

// removed legacy projectsNew provider

//-
// Service Providers
//-
final projectServiceProvider = Provider<ProjectService>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return ProjectService(repo: repo);
});

final aiServiceProvider = Provider<AIService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return AIService(settingsService: settingsService);
});

// removed legacy projectNew service provider

//-
// UI State Providers
//-
final dpiProvider = StateProvider<int>((ref) => 96);

// Overview menu selection (HomeNavigation) - default Projects / All
final homeNavSelectedIndexProvider = StateProvider<int>((ref) => 1);
