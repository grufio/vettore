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
// Removed: DPI is now image-scoped (images.dpi)

// Overview menu selection (HomeNavigation) - default Projects / All
class HomeNavIndexNotifier extends StateNotifier<int> {
  final SettingsService _settings;
  static const String _key = 'homeNavIndex';
  HomeNavIndexNotifier(this._settings) : super(1) {
    try {
      final cached = _settings.getInt(_key, 1);
      state = cached;
    } catch (_) {
      // ignore settings read errors
    }
  }
  void set(int index) {
    state = index;
    _settings.setInt(_key, index);
  }
}

final homeNavSelectedIndexProvider =
    StateNotifierProvider<HomeNavIndexNotifier, int>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return HomeNavIndexNotifier(settings);
});
