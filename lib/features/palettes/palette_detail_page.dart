import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/color_edit_page.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/providers/palette_provider.dart';
import 'package:vettore/features/palettes/widgets/palette_color_list.dart';
import 'package:vettore/features/palettes/widgets/palette_details_form.dart';

/// A page that displays the details of a single color palette
/// and allows the user to edit it.
class PaletteDetailPage extends ConsumerStatefulWidget {
  final int paletteKey;
  const PaletteDetailPage({super.key, required this.paletteKey});

  @override
  ConsumerState<PaletteDetailPage> createState() => _PaletteDetailPageState();
}

class _PaletteDetailPageState extends ConsumerState<PaletteDetailPage> {
  final _formKey = GlobalKey<FormState>();

  /// Shows a dialog to edit the name of the palette.
  Future<void> _showEditNameDialog(Palette palette) async {
    final nameController = TextEditingController(text: palette.name);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Palette Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Palette Name'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await ref
                      .read(paletteProvider(widget.paletteKey).notifier)
                      .updateDetails(
                        name: nameController.text,
                        size: palette.sizeInMl,
                        factor: palette.factor,
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
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Name',
            onPressed: () => _showEditNameDialog(palette),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Palette',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          PaletteDetailsForm(palette: palette, formKey: _formKey),
          Expanded(
            child: PaletteColorList(
              colors: palette.colors,
              onEdit: (index, color) => _editColor(index, color),
              onDelete: (index) async => await ref
                  .read(paletteProvider(widget.paletteKey).notifier)
                  .deleteColor(index),
            ),
          ),
        ],
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
