import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/features/palettes/palettes_overview.dart';
import 'package:vettore/features/projects/project_editor_page.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/widgets/settings_dialog.dart';
import 'package:vettore/providers/project_list_provider.dart';

class ProjectOverviewPage extends ConsumerWidget {
  const ProjectOverviewPage({super.key});

  Future<void> _deleteProject(
    BuildContext context,
    WidgetRef ref,
    int? key,
  ) async {
    if (key == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Project key is missing.')),
      );
      return;
    }
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
    // We keep using the projectListProvider to handle the business logic of creating a project.
    await ref.read(projectListProvider.notifier).createNewProject();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectListenable = ref.watch(projectListenableProvider);

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
      body: ValueListenableBuilder<Box<Project>>(
        valueListenable: projectListenable,
        builder: (context, box, _) {
          final projects = box.values.toList();
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
              final projectKey = box.keyAt(index) as int;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProjectEditorPage(projectKey: projectKey),
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
                      onPressed: () {
                        _deleteProject(context, ref, projectKey);
                      },
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
