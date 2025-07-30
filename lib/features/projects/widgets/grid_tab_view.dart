import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/widgets/grufio_checkbox.dart';

class GridTabView extends ConsumerWidget {
  final Project project;
  final Function(bool) onShowVectorsChanged;
  final Function(bool) onShowBackgroundChanged;
  final Function(bool) onShowBordersChanged;
  final Function(bool) onShowNumbersChanged;
  final bool showVectors;
  final bool showBackground;
  final bool showBorders;
  final bool showNumbers;

  const GridTabView({
    super.key,
    required this.project,
    required this.onShowVectorsChanged,
    required this.onShowBackgroundChanged,
    required this.onShowBordersChanged,
    required this.onShowNumbersChanged,
    required this.showVectors,
    required this.showBackground,
    required this.showBorders,
    required this.showNumbers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 2.0),
          GrufioCheckbox(
            title: 'Show Borders',
            value: showBorders,
            onChanged: (bool? value) {
              onShowBordersChanged(value ?? true);
            },
          ),
          const SizedBox(height: 2.0),
          GrufioCheckbox(
            title: 'Show Numbers',
            value: showNumbers,
            onChanged: (bool? value) {
              onShowNumbersChanged(value ?? true);
            },
          ),
          const Divider(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!project.isConverted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please convert the image first.'),
                    ),
                  );
                  return;
                }
                ref.read(projectLogicProvider(project.id)).generateGrid();
              },
              icon: const Icon(Icons.grid_on),
              label: const Text('Create Grid'),
            ),
          ),
        ],
      ),
    );
  }
}
