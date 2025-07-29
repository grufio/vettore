import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/features/palettes/palette_detail_page.dart';
import 'package:vettore/providers/palette_list_provider.dart';
import 'package:vettore/repositories/palette_repository.dart';
import 'package:vettore/widgets/adaptive_dialog.dart';
import 'package:vettore/widgets/grufio_text_field_simple.dart';

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
          title: 'Add Custom Palette',
          content: GrufioTextFieldSimple(
            controller: nameController,
            hintText: "Palette Name",
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
                      .createNewPredefinedPalette(nameController.text);
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

          // Palettes from the '+' button have isPredefined = true
          final customPalettes =
              palettes.where((p) => p.palette.isPredefined).toList();
          // Palettes from image conversion have isPredefined = false (the default)
          final imagePalettes =
              palettes.where((p) => !p.palette.isPredefined).toList();

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              if (customPalettes.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Custom Palettes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _PaletteGrid(palettes: customPalettes),
                const SizedBox(height: 16),
              ],
              if (imagePalettes.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Image Palettes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _PaletteGrid(palettes: imagePalettes),
              ],
            ],
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

class _PaletteGrid extends ConsumerWidget {
  final List<FullPalette> palettes;

  const _PaletteGrid({required this.palettes});

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
          content: const Text(
              'This will reset the associated project and its conversion data. You will need to convert it again.'),
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: palettes.length,
      itemBuilder: (context, index) {
        final fullPalette = palettes[index];
        final palette = fullPalette.palette;

        return Card(
          clipBehavior: Clip.antiAlias,
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
            child: GridTile(
              footer: GridTileBar(
                backgroundColor: Colors.black45,
                title: Text(
                  palette.name,
                  textAlign: TextAlign.center,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaletteDetailPage(paletteId: palette.id),
                          ),
                        );
                      },
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () => _showDeleteConfirmDialog(
                          context, ref, palette.id, palette.name),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
              child: (palette.thumbnail != null)
                  ? Image.memory(
                      palette.thumbnail!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
          ),
        );
      },
    );
  }
}
