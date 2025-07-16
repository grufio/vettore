import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/main.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';
import 'package:flutter/material.dart';

final projectProvider = StateNotifierProvider.autoDispose
    .family<ProjectNotifier, Project?, int>((ref, projectKey) {
      final projectRepository = ref.watch(projectRepositoryProvider);
      final projectService = ref.watch(projectServiceProvider);
      try {
        final project = projectRepository.getProjects().firstWhere(
          (p) => p.key == projectKey,
        );
        return ProjectNotifier(project, projectRepository, projectService);
      } catch (e) {
        return ProjectNotifier(null, projectRepository, projectService);
      }
    });

class ProjectNotifier extends StateNotifier<Project?> {
  final ProjectRepository _projectRepository;
  final ProjectService _projectService;

  ProjectNotifier(
    Project? project,
    this._projectRepository,
    this._projectService,
  ) : super(project);

  void convertProject() {
    if (state == null) return;

    try {
      final updatedProject = _projectService.performVectorConversion(state!);
      _projectRepository.updateProject(state!.key, updatedProject);
      state = updatedProject;
    } catch (e) {
      // Handle or log the error appropriately
      debugPrint('Error during vector conversion: $e');
    }
  }
}
