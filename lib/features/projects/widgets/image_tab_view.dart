import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/features/projects/widgets/resize_dialog.dart';
import 'package:vettore/providers/project_provider.dart';

class ImageTabView extends ConsumerWidget {
  final Project project;

  const ImageTabView({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isImageTooLarge =
        (project.imageWidth ?? 0) > 500 || (project.imageHeight ?? 0) > 500;

    return Padding(
      padding: const EdgeInsets.all(8.0),
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
          const SizedBox(height: 16),
          if (isImageTooLarge)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Image > 500px. Please update.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog<ResizeResult>(
                      context: context,
                      builder: (context) => const ResizeDialog(),
                    );

                    if (result != null) {
                      ref.read(projectLogicProvider(project.id)).updateImage(
                            result.percentage,
                            result.filterQuality,
                          );
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
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ref
                                      .read(projectLogicProvider(project.id))
                                      .resetImage();
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
        ],
      ),
    );
  }
}
