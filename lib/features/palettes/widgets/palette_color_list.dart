import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';

class PaletteColorList extends ConsumerWidget {
  final List<PaletteColor> colors;
  final Function(PaletteColor) onEdit;
  final Function(int) onDelete;

  const PaletteColorList({
    super.key,
    required this.colors,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final colorData = colors[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onEdit(colorData),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Container(color: Color(colorData.color))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '#${colorData.color.toRadixString(16).substring(2).toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit Color',
                      onPressed: () => onEdit(colorData),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      tooltip: 'Delete Color',
                      onPressed: () => onDelete(colorData.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
