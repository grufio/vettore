import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';

class ProjectListNotifier extends StateNotifier<List<Project>> {
  final ProjectRepository _projectRepository;
  final ProjectService _projectService;

  ProjectListNotifier(this._projectRepository, this._projectService)
    : super(_projectRepository.getProjects()) {
    _listenToProjects();
  }

  void _listenToProjects() {
    _projectRepository.getProjectsListenable().addListener(_updateState);
  }

  void _updateState() {
    state = _projectRepository.getProjects();
  }

  Future<void> createNewProject() async {
    final newProject = await _projectService.createProjectFromFile();
    if (newProject != null) {
      await _projectRepository.addProject(newProject);
      // State is updated automatically by the listener
    }
  }

  Future<void> deleteProject(int key) async {
    await _projectRepository.deleteProject(key);
    // State is updated automatically by the listener
  }

  @override
  void dispose() {
    _projectRepository.getProjectsListenable().removeListener(_updateState);
    super.dispose();
  }
}

final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, List<Project>>((ref) {
      return ProjectListNotifier(
        ref.watch(projectRepositoryProvider),
        ref.watch(projectServiceProvider),
      );
    });
