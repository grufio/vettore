import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/features/palettes/palette_detail_page.dart';
import 'package:vettore/providers/palette_list_provider.dart';
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
                      .read(paletteListLogicProvider)
                      .createNewPalette(nameController.text);
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
    int paletteId,
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
                    .read(paletteListLogicProvider)
                    .deletePalette(paletteId);
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
    final palettesAsync = ref.watch(paletteListStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Palettes')),
      body: palettesAsync.when(
        data: (palettes) {
          if (palettes.isEmpty) {
            return const Center(child: Text('No palettes created yet.'));
          }
          return ListView.builder(
            itemCount: palettes.length,
            itemBuilder: (context, index) {
              final fullPalette = palettes[index];
              final palette = fullPalette.palette;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaletteDetailPage(paletteId: palette.id),
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
                                        paletteId: palette.id,
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
                                    palette.id,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        tooltip: 'Add Palette',
        child: const Icon(Icons.add),
      ),
    );
  }
}
