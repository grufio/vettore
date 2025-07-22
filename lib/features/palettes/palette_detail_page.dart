import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/features/palettes/color_edit_page.dart';
import 'package:vettore/providers/palette_detail_provider.dart';
import 'package:vettore/features/palettes/widgets/palette_color_list.dart';
import 'package:drift/drift.dart' as drift;
import 'package:vettore/repositories/palette_repository.dart';

class PaletteDetailPage extends ConsumerStatefulWidget {
  final int paletteId;
  const PaletteDetailPage({super.key, required this.paletteId});

  @override
  ConsumerState<PaletteDetailPage> createState() => _PaletteDetailPageState();
}

class _PaletteDetailPageState extends ConsumerState<PaletteDetailPage> {
  Future<void> _showPaletteSettingsDialog(Palette palette) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: palette.name);
    final sizeController = TextEditingController(
      text: palette.sizeInMl.toString(),
    );
    final factorController = TextEditingController(
      text: palette.factor.toString(),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Palette Settings'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Palette Name',
                    ),
                    autofocus: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: sizeController,
                    decoration: const InputDecoration(labelText: 'Size in ml'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a size.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: factorController,
                    decoration: const InputDecoration(labelText: 'Factor'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a factor.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await ref
                      .read(paletteDetailLogicProvider(widget.paletteId))
                      .updateDetails(
                        name: nameController.text,
                        size: double.tryParse(sizeController.text) ?? 60.0,
                        factor: double.tryParse(factorController.text) ?? 1.5,
                      );
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editColor(PaletteColorWithComponents color) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColorEditPage(
          initialColor: color,
          onSave: (newColor, newComponents) {
            ref
                .read(paletteDetailLogicProvider(widget.paletteId))
                .updateColorAndComponents(newColor, newComponents);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paletteAsync =
        ref.watch(paletteDetailStreamProvider(widget.paletteId));

    return paletteAsync.when(
      data: (fullPalette) {
        final palette = fullPalette.palette;
        final colors = fullPalette.colors;

        return Scaffold(
          appBar: AppBar(
            title: Text(palette.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Palette Settings',
                onPressed: () => _showPaletteSettingsDialog(palette),
              ),
            ],
          ),
          body: PaletteColorList(
            colors: colors,
            onEdit: _editColor,
            onDelete: (colorId) async => await ref
                .read(paletteDetailLogicProvider(widget.paletteId))
                .deleteColor(colorId),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final newColor = PaletteColorsCompanion.insert(
                paletteId: widget.paletteId,
                title: 'New Color',
                color: Colors.black.value,
                status: drift.Value('new'),
              );

              await ref
                  .read(paletteDetailLogicProvider(widget.paletteId))
                  .addColor(newColor);
            },
            tooltip: 'Add Color',
            child: const Icon(Icons.add),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
