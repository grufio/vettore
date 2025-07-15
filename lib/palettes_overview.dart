import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/palette_detail_page.dart';
import 'package:vettore/palette_model.dart';

class PalettesOverview extends StatefulWidget {
  const PalettesOverview({super.key});

  @override
  State<PalettesOverview> createState() => _PalettesOverviewState();
}

class _PalettesOverviewState extends State<PalettesOverview> {
  final Box<Palette> _palettesBox = Hive.box<Palette>('palettes');

  Future<void> _showAddDialog() async {
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
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _palettesBox.add(Palette()..name = nameController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaletteCardList(Box<Palette> box) {
    return ListView.builder(
      itemCount: box.values.length,
      itemBuilder: (context, index) {
        final palette = box.getAt(index)!;
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaletteDetailPage(palette: palette),
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
                                builder: (context) =>
                                    PaletteDetailPage(palette: palette),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete Palette',
                          onPressed: () => _showDeleteConfirmDialog(palette),
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
  }

  Future<void> _showDeleteConfirmDialog(Palette palette) async {
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
              onPressed: () {
                palette.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Palettes')),
      body: ValueListenableBuilder(
        valueListenable: _palettesBox.listenable(),
        builder: (context, Box<Palette> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No palettes created yet.'));
          }
          return _buildPaletteCardList(box);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'Add Palette',
        child: const Icon(Icons.add),
      ),
    );
  }
}
