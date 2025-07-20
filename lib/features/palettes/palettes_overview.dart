import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/features/palettes/palette_detail_page.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/providers/palette_provider.dart';
import 'package:vettore/widgets/adaptive_dialog.dart';

/// A page that displays a list of all the user's color palettes.
class PalettesOverview extends ConsumerWidget {
  const PalettesOverview({super.key});

  /// Shows a dialog to add a new palette.
  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AdaptiveDialog(
          title: 'Add Palette',
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

  /// Shows a confirmation dialog before deleting a palette.
  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    int paletteKey,
    String paletteName,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AdaptiveDialog(
          title: 'Delete Palette',
          content: Text('Are you sure you want to delete "$paletteName"?'),
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
                    .deletePalette(paletteKey);
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
    final paletteBox = ref.watch(paletteListProvider);
    final paletteKeys = paletteBox.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Palettes')),
      body: Builder(
        builder: (context) {
          if (paletteBox.isEmpty) {
            return const Center(child: Text('No palettes created yet.'));
          }
          return ListView.builder(
            itemCount: paletteKeys.length,
            itemBuilder: (context, index) {
              final paletteKey = paletteKeys[index];
              final palette = paletteBox.get(paletteKey);

              if (palette == null) {
                return const Card(
                  child: ListTile(title: Text('Error: Could not load palette')),
                );
              }

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaletteDetailPage(paletteKey: paletteKey as int),
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
                                        paletteKey: paletteKey as int,
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
                                    paletteKey as int,
                                    palette.name,
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
