// ignore_for_file: always_use_package_imports
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/image_repository_pg.dart';
import '../repositories/project_repository_pg.dart';
import '../services/project_service.dart';
// duplicate imports removed

/// In-memory/no-op repositories (DB removed)
final projectRepositoryPgProvider =
    Provider.autoDispose<ProjectRepositoryPg>((ref) {
  return ProjectRepositoryPg();
});

final imageRepositoryPgProvider =
    Provider.autoDispose<ImageRepositoryPg>((ref) {
  return ImageRepositoryPg();
});

// removed legacy projectsNew provider

//-
// Service Providers
//-
final projectServiceProvider = Provider<ProjectService>((ref) {
  final repoPg = ref.watch(projectRepositoryPgProvider);
  return ProjectService(repo: repoPg);
});

// removed AIService and legacy providers

//-
// UI State Providers
//-
// Removed: DPI is now image-scoped (images.dpi)

// Overview menu selection (HomeNavigation) - default Projects / All (ephemeral)
class HomeNavIndexNotifier extends StateNotifier<int> {
  HomeNavIndexNotifier() : super(1);
  void set(int index) {
    state = index;
  }
}

final homeNavSelectedIndexProvider =
    StateNotifierProvider<HomeNavIndexNotifier, int>((ref) {
  return HomeNavIndexNotifier();
});
