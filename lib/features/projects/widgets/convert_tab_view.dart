import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/settings_service.dart';

class ConvertTabView extends StatelessWidget {
  final Project project;
  final SettingsService settings;
  final VoidCallback onShowColorSettings;
  final Function(bool) onShowVectorsChanged;
  final Function(bool) onShowBackgroundChanged;
  final bool showVectors;
  final bool showBackground;
  final TextEditingController maxObjectColorsController;

  const ConvertTabView({
    super.key,
    required this.project,
    required this.settings,
    required this.onShowColorSettings,
    required this.onShowVectorsChanged,
    required this.onShowBackgroundChanged,
    required this.showVectors,
    required this.showBackground,
    required this.maxObjectColorsController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: maxObjectColorsController,
              decoration: const InputDecoration(
                labelText: 'Max. Object Colors',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  settings.setMaxObjectColors(int.parse(value)),
            ),
            const Divider(height: 32),
            const Text('Preview'),
            CheckboxListTile(
              title: const Text('Show Vectors'),
              value: showVectors,
              onChanged: (bool? value) {
                onShowVectorsChanged(value ?? true);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Show Background'),
              value: showBackground,
              onChanged: (bool? value) {
                onShowBackgroundChanged(value ?? true);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            TextButton.icon(
              onPressed: onShowColorSettings,
              icon: const Icon(Icons.palette_outlined),
              label: Text(
                project.isConverted
                    ? 'Colors: ${project.uniqueColorCount ?? 0}'
                    : 'Colors: N/A',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      if (project.isConverted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text(
                              'This will overwrite the existing grid and resolution data. Are you sure?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ref
                                      .read(projectLogicProvider(project.id))
                                      .convertProject();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        ref
                            .read(projectLogicProvider(project.id))
                            .convertProject();
                      }
                    },
                    icon: const Icon(Icons.transform),
                    label: const Text('Convert'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
