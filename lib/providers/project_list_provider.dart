import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/repositories/palette_repository.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';

class ProjectListNotifier extends StateNotifier<List<Project>> {
  final ProjectRepository _projectRepository;
  final ProjectService _projectService;
  final PaletteRepository _paletteRepository;

  ProjectListNotifier(
    this._projectRepository,
    this._projectService,
    this._paletteRepository,
  ) : super(_projectRepository.getProjects()) {
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
    // First, find the project to get its paletteKey
    final projectToDelete = _projectRepository.getProject(key);

    if (projectToDelete != null && projectToDelete.paletteKey != null) {
      // If a palette is linked, delete it first.
      await _paletteRepository.deletePalette(projectToDelete.paletteKey!);
    }

    // Then, delete the project itself.
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
        ref.watch(paletteRepositoryProvider),
      );
    });
