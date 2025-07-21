import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/data/database.dart';

// Provides the stream of all projects from the database.
// The UI will watch this provider to get a live-updating list of projects.
final projectListStreamProvider = StreamProvider<List<Project>>((ref) {
  final projectRepository = ref.watch(projectRepositoryProvider);
  return projectRepository.watchProjects();
});

// A provider for the business logic of creating and deleting projects.
final projectListLogicProvider = Provider<ProjectListLogic>((ref) {
  return ProjectListLogic(ref);
});

class ProjectListLogic {
  final Ref _ref;
  ProjectListLogic(this._ref);

  Future<void> createNewProject() async {
    final projectService = _ref.read(projectServiceProvider);
    final projectRepository = _ref.read(projectRepositoryProvider);

    final newProjectCompanion = await projectService.createProjectFromFile();
    if (newProjectCompanion != null) {
      await projectRepository.addProject(newProjectCompanion);
    }
  }

  Future<void> deleteProject(int id) async {
    final projectRepository = _ref.read(projectRepositoryProvider);
    final paletteRepository = _ref.read(paletteRepositoryProvider);

    // Get the project to check for a linked palette
    final projectToDelete = await projectRepository.getProject(id);
    if (projectToDelete.paletteId != null) {
      await paletteRepository.deletePalette(projectToDelete.paletteId!);
    }

    await projectRepository.deleteProject(id);
  }
}
