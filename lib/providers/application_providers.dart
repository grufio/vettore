import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/repositories/palette_repository.dart';

final projectListenableProvider = Provider<ValueListenable<Box<Project>>>((
  ref,
) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  return projectRepository.getProjectsListenable();
});

final projectBoxProvider = Provider<Box<Project>>((ref) {
  return Hive.box<Project>('projects');
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
