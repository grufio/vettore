import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/repositories/palette_repository.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/services/ai_service.dart';

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

//-
// Service Providers
//-
final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});

final aiServiceProvider = Provider<AIService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return AIService(settingsService: settingsService);
});
