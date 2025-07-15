import 'package:flutter/material.dart';
import 'package:vettore/color_edit_page.dart';
import 'package:vettore/palette_color.dart';
import 'package:vettore/palette_model.dart';

class PaletteDetailPage extends StatefulWidget {
  final Palette palette;
  const PaletteDetailPage({super.key, required this.palette});

  @override
  State<PaletteDetailPage> createState() => _PaletteDetailPageState();
}

class _PaletteDetailPageState extends State<PaletteDetailPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _sizeController;
  late final TextEditingController _factorController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.palette.name);
    _sizeController = TextEditingController(
      text: widget.palette.sizeInMl.toString(),
    );
    _factorController = TextEditingController(
      text: widget.palette.factor.toString(),
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
      setState(() {
        widget.palette.name = _nameController.text;
        widget.palette.sizeInMl = double.tryParse(_sizeController.text) ?? 60.0;
        widget.palette.factor = double.tryParse(_factorController.text) ?? 1.5;
        widget.palette.save();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Palette saved!')));
    }
  }

  Future<void> _showEditNameDialog() async {
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
                // Reset controller to original name if cancelled
                _nameController.text = widget.palette.name;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  setState(() {
                    widget.palette.name = _nameController.text;
                    widget.palette.save();
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addColor() {
    setState(() {
      widget.palette.colors.add(
        PaletteColor(title: 'New Color', color: Colors.black.value),
      );
      widget.palette.save();
    });
  }

  void _deleteColor(int index) {
    setState(() {
      widget.palette.colors.removeAt(index);
      widget.palette.save();
    });
  }

  void _editColor(int index, PaletteColor color) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColorEditPage(
          initialColor: color,
          sizeInMl: widget.palette.sizeInMl,
          factor: widget.palette.factor,
          onSave: (newColor) {
            setState(() {
              widget.palette.colors[index] = newColor;
              widget.palette.save();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.palette.name),
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
                itemCount: widget.palette.colors.length,
                itemBuilder: (context, index) {
                  final colorData = widget.palette.colors[index];
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
                          onPressed: () => _deleteColor(index),
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
        onPressed: _addColor,
        tooltip: 'Add Color',
        child: const Icon(Icons.add),
      ),
    );
  }
}
