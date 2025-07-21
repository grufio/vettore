import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/features/palettes/color_edit_page.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/providers/palette_provider.dart';
import 'package:vettore/features/palettes/widgets/palette_color_list.dart';

/// A page that displays the details of a single color palette
/// and allows the user to edit it.
class PaletteDetailPage extends ConsumerStatefulWidget {
  final int paletteKey;
  const PaletteDetailPage({super.key, required this.paletteKey});

  @override
  ConsumerState<PaletteDetailPage> createState() => _PaletteDetailPageState();
}

class _PaletteDetailPageState extends ConsumerState<PaletteDetailPage> {
  /// Shows a dialog to edit the settings of the palette.
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
                      .read(paletteProvider(widget.paletteKey).notifier)
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

  /// Navigates to the color edit page for the selected color.
  void _editColor(int index, PaletteColor color) {
    final palette = ref.read(paletteProvider(widget.paletteKey));
    if (palette == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColorEditPage(
          initialColor: color,
          sizeInMl: palette.sizeInMl,
          factor: palette.factor,
          onSave: (newColor) async {
            await ref
                .read(paletteProvider(widget.paletteKey).notifier)
                .updateColor(index, newColor);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(paletteProvider(widget.paletteKey));

    if (palette == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        colors: palette.colors,
        onEdit: (index, color) => _editColor(index, color),
        onDelete: (index) async => await ref
            .read(paletteProvider(widget.paletteKey).notifier)
            .deleteColor(index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newColor = PaletteColor(
            title: 'New Color',
            color: Colors.black.toARGB32(),
            status: 'new',
            componentKeys: [],
            components: [],
          );

          await ref
              .read(paletteProvider(widget.paletteKey).notifier)
              .addNewColor(newColor);

          if (!context.mounted) return;

          final updatedPalette = ref.read(paletteProvider(widget.paletteKey));
          if (updatedPalette != null) {
            final newColorFromServer = updatedPalette.colors.last;
            _editColor(updatedPalette.colors.length - 1, newColorFromServer);
          }
        },
        tooltip: 'Add Color',
        child: const Icon(Icons.add),
      ),
    );
  }
}
