import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/features/palettes/palettes_overview.dart';
import 'package:vettore/features/projects/project_editor_page.dart';
import 'package:vettore/providers/project_list_provider.dart';
import 'package:vettore/widgets/settings_dialog.dart';

class ProjectOverviewPage extends ConsumerWidget {
  const ProjectOverviewPage({super.key});

  Future<void> _deleteProject(
    BuildContext context,
    WidgetRef ref,
    int projectId,
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
      await ref.read(projectListLogicProvider).deleteProject(projectId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListStreamProvider);

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
      body: projectsAsync.when(
        data: (projects) {
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
                          ProjectEditorPage(projectId: project.id),
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
                      onPressed: () => _deleteProject(context, ref, project.id),
                    ),
                  ),
                  child: Image.memory(project.thumbnailData, fit: BoxFit.cover),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(projectListLogicProvider).createNewProject(),
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
      ),
    );
  }
}
