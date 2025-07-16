import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/color_edit_page.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/providers/palette_provider.dart';

class PaletteDetailPage extends ConsumerStatefulWidget {
  final int paletteKey;
  const PaletteDetailPage({super.key, required this.paletteKey});

  @override
  ConsumerState<PaletteDetailPage> createState() => _PaletteDetailPageState();
}

class _PaletteDetailPageState extends ConsumerState<PaletteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sizeController;
  late final TextEditingController _factorController;

  @override
  void initState() {
    super.initState();
    final palette = ref.read(paletteProvider(widget.paletteKey));
    _nameController = TextEditingController(text: palette?.name ?? '');
    _sizeController = TextEditingController(
      text: palette?.sizeInMl.toString() ?? '60.0',
    );
    _factorController = TextEditingController(
      text: palette?.factor.toString() ?? '1.5',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _factorController.dispose();
    super.dispose();
  }

  void _savePalette() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(paletteProvider(widget.paletteKey).notifier)
          .updateDetails(
            name: _nameController.text,
            size: double.tryParse(_sizeController.text) ?? 60.0,
            factor: double.tryParse(_factorController.text) ?? 1.5,
          );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Palette saved!')));
    }
  }

  Future<void> _showEditNameDialog() async {
    final palette = ref.read(paletteProvider(widget.paletteKey));
    if (palette == null) return;

    _nameController.text = palette.name;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Palette Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Palette Name'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _nameController.text = palette.name;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  ref
                      .read(paletteProvider(widget.paletteKey).notifier)
                      .updateDetails(
                        name: _nameController.text,
                        size: palette.sizeInMl,
                        factor: palette.factor,
                      );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

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
          onSave: (newColor) {
            ref
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
      return const Scaffold(body: Center(child: Text('Palette not found.')));
    }

    // Update controllers if the state changes from outside
    _nameController.text = palette.name;
    _sizeController.text = palette.sizeInMl.toString();
    _factorController.text = palette.factor.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(palette.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Name',
            onPressed: _showEditNameDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Palette',
            onPressed: _savePalette,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _sizeController,
                      decoration: const InputDecoration(
                        labelText: 'Size in ml',
                        border: OutlineInputBorder(),
                      ),
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
                      controller: _factorController,
                      decoration: const InputDecoration(
                        labelText: 'Factor',
                        border: OutlineInputBorder(),
                      ),
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
            Expanded(
              child: ListView.builder(
                itemCount: palette.colors.length,
                itemBuilder: (context, index) {
                  final colorData = palette.colors[index];
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
                          onPressed: () => _editColor(index, colorData),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete Color',
                          onPressed: () => ref
                              .read(paletteProvider(widget.paletteKey).notifier)
                              .deleteColor(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(paletteProvider(widget.paletteKey).notifier).addColor(),
        tooltip: 'Add Color',
        child: const Icon(Icons.add),
      ),
    );
  }
}
