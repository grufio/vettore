import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/constants/ui_constants.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/grufio_text_field_simple.dart';
import 'package:vettore/widgets/grufio_checkbox.dart';

class ConvertTabView extends StatelessWidget {
  final Project project;
  final SettingsService settings;
  final VoidCallback onShowColorSettings;
  final Function(bool) onShowVectorsChanged;
  final Function(bool) onShowBackgroundChanged;
  final bool showVectors;
  final bool showBackground;
  final TextEditingController maxObjectColorsController;
  final TextEditingController colorSeparationController;
  final TextEditingController klController;
  final TextEditingController kcController;
  final TextEditingController khController;

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
    required this.colorSeparationController,
    required this.klController,
    required this.kcController,
    required this.khController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GrufioTextFieldSimple(
              controller: maxObjectColorsController,
              topLabel: 'Colors',
            ),
            const SizedBox(height: kSpacingS),
            TextButton.icon(
              onPressed: onShowColorSettings,
              icon: const Icon(Icons.palette_outlined),
              label: Text(
                project.uniqueColorCount != null
                    ? 'Colors: ${project.uniqueColorCount}'
                    : 'Colors: N/A',
              ),
            ),
            const Divider(height: kSpacingXl),
            GrufioTextFieldSimple(
              controller: colorSeparationController,
              topLabel: 'Color Separation',
              onChanged: (value) {
                final val = double.tryParse(value);
                if (val != null) {
                  settings.setColorSeparation(val);
                }
              },
            ),
            const SizedBox(height: kSpacingS),
            GrufioTextFieldSimple(
              controller: klController,
              topLabel: 'Lightness (Kl)',
              onChanged: (value) {
                final val = double.tryParse(value);
                if (val != null) {
                  settings.setKl(val);
                }
              },
            ),
            const SizedBox(height: kSpacingS),
            GrufioTextFieldSimple(
              controller: kcController,
              topLabel: 'Chroma (Kc)',
              onChanged: (value) {
                final val = double.tryParse(value);
                if (val != null) {
                  settings.setKc(val);
                }
              },
            ),
            const SizedBox(height: kSpacingS),
            GrufioTextFieldSimple(
              controller: khController,
              topLabel: 'Hue (Kh)',
              onChanged: (value) {
                final val = double.tryParse(value);
                if (val != null) {
                  settings.setKh(val);
                }
              },
            ),
            const Divider(height: kSpacingXl),
            const Text('Preview'),
            GrufioCheckbox(
              title: 'Show Vectors',
              value: showVectors,
              onChanged: (bool? value) {
                onShowVectorsChanged(value ?? true);
              },
            ),
            const SizedBox(height: 2.0),
            GrufioCheckbox(
              title: 'Show Background',
              value: showBackground,
              onChanged: (bool? value) {
                onShowBackgroundChanged(value ?? true);
              },
            ),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      final maxColors =
                          int.tryParse(maxObjectColorsController.text) ?? 256;
                      settings.setMaxObjectColors(maxColors);

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
