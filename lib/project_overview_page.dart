import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:vettore/palette_model.dart';
import 'package:vettore/palettes_overview.dart';
import 'package:vettore/project_editor_page.dart';
import 'package:vettore/project_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box<Project> _projectsBox = Hive.box<Project>('projects');

  Future<void> _deleteProject(dynamic key) async {
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
      await _projectsBox.delete(key);
    }
  }

  void _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      dynamic firstProjectKey;

      for (var file in result.files) {
        if (file.path != null) {
          final imageData = await File(file.path!).readAsBytes();
          final originalImage = img.decodeImage(imageData);
          if (originalImage == null) continue;

          // Create a thumbnail
          final thumbnail = img.copyResize(originalImage, width: 200);
          final thumbnailData = img.encodePng(thumbnail);

          final project = Project()
            ..name = p.basename(file.path!)
            ..imageData = imageData
            ..thumbnailData = thumbnailData;

          final newKey = await _projectsBox.add(project);
          firstProjectKey ??= newKey;
        }
      }

      if (firstProjectKey != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProjectEditorPage(projectKey: firstProjectKey),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
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
      body: ValueListenableBuilder(
        valueListenable: _projectsBox.listenable(),
        builder: (context, Box<Project> box, _) {
          if (box.values.isEmpty) {
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
            itemCount: box.length,
            itemBuilder: (context, index) {
              final project = box.getAt(index)!;
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
                      onPressed: () => _deleteProject(project.key),
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
        onPressed: _pickImages,
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
      ),
    );
  }
}
