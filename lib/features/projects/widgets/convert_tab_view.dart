import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/constants/ui_constants.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/grufio_text_field_simple.dart';

class ConvertTabView extends ConsumerWidget {
  final Project project;
  final SettingsService settings;
  final VoidCallback onShowColorSettings;
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
    required this.maxObjectColorsController,
    required this.colorSeparationController,
    required this.klController,
    required this.kcController,
    required this.khController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                                  .quantizeImage();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    ref.read(projectLogicProvider(project.id)).quantizeImage();
                  }
                },
                icon: const Icon(Icons.transform),
                label: const Text('Convert'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
