import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/main.dart';
import 'package:vettore/palettes_overview.dart';
import 'package:vettore/project_editor_page.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/repositories/project_repository.dart';
import 'package:vettore/services/project_service.dart';
import 'package:vettore/settings_dialog.dart';

class ProjectListNotifier extends StateNotifier<List<Project>> {
  final ProjectRepository _projectRepository;
  final ProjectService _projectService;

  ProjectListNotifier(this._projectRepository, this._projectService)
    : super(_projectRepository.getProjects());

  Future<void> createNewProject() async {
    final newProject = await _projectService.createProjectFromFile();
    if (newProject != null) {
      await _projectRepository.addProject(newProject);
      state = _projectRepository.getProjects();
    }
  }

  Future<void> deleteProject(int key) async {
    await _projectRepository.deleteProject(key);
    state = _projectRepository.getProjects();
  }
}

final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, List<Project>>((ref) {
      return ProjectListNotifier(
        ref.watch(projectRepositoryProvider),
        ref.watch(projectServiceProvider),
      );
    });

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _deleteProject(
    BuildContext context,
    WidgetRef ref,
    dynamic key,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(projectListProvider.notifier).deleteProject(key);
    }
  }

  Future<void> _pickImages(BuildContext context, WidgetRef ref) async {
    await ref.read(projectListProvider.notifier).createNewProject();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PalettesOverview(),
                ),
              );
            },
            child: const Text('Palettes'),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (projects.isEmpty) {
            return const Center(
              child: Text('No projects yet. Click + to add one.'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProjectEditorPage(projectKey: project.key),
                    ),
                  );
                },
                child: GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black45,
                    title: Text(
                      project.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.white,
                      tooltip: 'Delete Project',
                      onPressed: () =>
                          _deleteProject(context, ref, project.key),
                    ),
                  ),
                  child: Image.memory(project.thumbnailData, fit: BoxFit.cover),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickImages(context, ref),
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
      ),
    );
  }
}
