import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/features/projects/widgets/resize_dialog.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/widgets/grufio_section.dart';

class ImageTabView extends ConsumerWidget {
  final Project project;
  final bool isImageTooLarge;

  const ImageTabView({
    super.key,
    required this.project,
    required this.isImageTooLarge,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GrufioSection(
          title: 'Size',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Original Dimensions: ${project.originalImageWidth?.toInt() ?? 'N/A'} x ${project.originalImageHeight?.toInt() ?? 'N/A'}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Dimensions: ${project.imageWidth?.toInt() ?? 'N/A'} x ${project.imageHeight?.toInt() ?? 'N/A'}',
                ),
                if (isImageTooLarge)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Image > 500px. Please update.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        GrufioSection(
          title: 'Actions',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await showDialog<ResizeResult>(
                        context: context,
                        builder: (context) => const ResizeDialog(),
                      );

                      if (result != null) {
                        await ref
                            .read(projectLogicProvider(project.id))
                            .updateImage(
                              result.percentage,
                              result.filterQuality,
                            );
                        ref.invalidate(projectStreamProvider(project.id));
                      }
                    },
                    child: const Text('Resize Image'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (project.originalImageData == null)
                      ? null
                      : () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm'),
                              content: const Text(
                                'You are loosing all information',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await ref
                                        .read(projectLogicProvider(project.id))
                                        .resetImage();
                                    ref.invalidate(
                                        projectStreamProvider(project.id));
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
