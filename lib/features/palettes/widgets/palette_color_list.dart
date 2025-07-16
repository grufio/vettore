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
    return ListView.builder(
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final colorData = colors[index];
        return ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('#${index + 1}'),
              const SizedBox(width: 16),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(colorData.color),
                  border: Border.all(color: Colors.grey),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          title: Text(colorData.title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Color',
                onPressed: () => onEdit(index, colorData),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete Color',
                onPressed: () => onDelete(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
