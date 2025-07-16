import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/palette_detail_page.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/providers/palette_provider.dart';

class PalettesOverview extends ConsumerWidget {
  const PalettesOverview({super.key});

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Palette'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Palette Name'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await ref
                      .read(paletteListProvider.notifier)
                      .addPalette(Palette()..name = nameController.text);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    Palette palette,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Palette'),
          content: Text('Are you sure you want to delete "${palette.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await ref
                    .read(paletteListProvider.notifier)
                    .deletePalette(palette.key!);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palettes = ref.watch(paletteListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Palettes')),
      body: Builder(
        builder: (context) {
          if (palettes.isEmpty) {
            return const Center(child: Text('No palettes created yet.'));
          }
          return ListView.builder(
            itemCount: palettes.length,
            itemBuilder: (context, index) {
              final palette = palettes[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    if (palette.key == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaletteDetailPage(paletteKey: palette.key!),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            palette.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit Palette',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaletteDetailPage(
                                        paletteKey: palette.key!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Delete Palette',
                                onPressed: () {
                                  _showDeleteConfirmDialog(
                                    context,
                                    ref,
                                    palette,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        tooltip: 'Add Palette',
        child: const Icon(Icons.add),
      ),
    );
  }
}
