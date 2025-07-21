import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/models/palette_color.dart';

class PaletteColorList extends ConsumerWidget {
  final List<PaletteColor> colors;
  final Function(int, PaletteColor) onEdit;
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
        childAspectRatio: 0.8, // To make cards taller than they are wide
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final colorData = colors[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onEdit(index, colorData),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Container(color: Color(colorData.color))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    colorData.title, // This now correctly uses the HEX value
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
                      onPressed: () => onEdit(index, colorData),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      tooltip: 'Delete Color',
                      onPressed: () => onDelete(index),
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
