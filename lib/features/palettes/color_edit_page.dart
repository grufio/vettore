import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/import_recipe_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/vendor_color_provider.dart';
import 'package:vettore/providers/palette_detail_provider.dart';
import 'package:vettore/repositories/palette_repository.dart';
import 'package:drift/drift.dart' as drift;
import 'package:vettore/widgets/grufio_text_field_simple.dart';

class ColorEditPage extends ConsumerStatefulWidget {
  const ColorEditPage({
    super.key,
    required this.initialColor,
    required this.onSave,
  });
  final PaletteColorWithComponents initialColor;
  final void Function(
    PaletteColorsCompanion,
    List<ColorComponentsCompanion>,
  ) onSave;

  @override
  ConsumerState<ColorEditPage> createState() => _ColorEditPageState();
}

class _ColorEditPageState extends ConsumerState<ColorEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _statusController;
  late Color _currentColor;
  // Removed unused _components field
  final _titleFocusNode = FocusNode();
  final _statusFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialColor.color.title);
    _statusController =
        TextEditingController(text: widget.initialColor.color.status);
    _currentColor = Color(widget.initialColor.color.color);
    // Components are managed via palette detail logic; no local cache needed
  }

  @override
  void dispose() {
    _titleController.dispose();
    _statusController.dispose();
    _titleFocusNode.dispose();
    _statusFocusNode.dispose();
    super.dispose();
  }

  Future<void> _importFromImage(Uint8List imageData) async {
    try {
      await ref
          .read(paletteDetailLogicProvider(widget.initialColor.color.paletteId))
          .importAiRecipe(widget.initialColor.color.paletteId,
              widget.initialColor.color.id, imageData);
      if (mounted) {
        Navigator.of(context).pop(); // Close the import dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close the import dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing recipe: ${e.toString()}')),
        );
      }
    }
  }

  void _showImportDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => ImportRecipeDialog(
        onImageImported: (imageData) async {
          await _importFromImage(imageData);
        },
      ),
    );
  }

  void _save() {
    final newColor = PaletteColorsCompanion(
      id: drift.Value(widget.initialColor.color.id),
      paletteId: drift.Value(widget.initialColor.color.paletteId),
      title: drift.Value(_titleController.text),
      color: drift.Value(_currentColor.value),
      status: drift.Value(_statusController.text),
    );
    // This now only saves the main color details, not the components.
    ref
        .read(paletteDetailLogicProvider(widget.initialColor.color.paletteId))
        .updateColor(newColor);
  }

  Future<void> _showColorSettingsDialog() async {
    // We need to create new controllers for the dialog to avoid issues
    // with the widget tree when the main text fields are removed.
    final titleController = TextEditingController(text: _titleController.text);
    final statusController =
        TextEditingController(text: _statusController.text);
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Color Settings'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GrufioTextFieldSimple(
                    controller: titleController,
                    topLabel: 'Color Name',
                    onChanged: (value) {
                      // Update color name
                    },
                  ),
                  const SizedBox(height: 16),
                  GrufioTextFieldSimple(
                    controller: statusController,
                    topLabel: 'Status',
                    onChanged: (value) {
                      // Update status
                    },
                  ),
                ],
              ),
            ),
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
                if (formKey.currentState!.validate()) {
                  // Update the main controllers so the UI reflects the change
                  _titleController.text = titleController.text;
                  _statusController.text = statusController.text;
                  // Call the save method to persist the changes
                  _save();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showComponentDialog({
    ColorComponentsCompanion? component,
    int? index,
  }) async {
    final logic = ref
        .read(paletteDetailLogicProvider(widget.initialColor.color.paletteId));
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _ComponentDialog(
          component: component,
          onSave: (newComponent) {
            if (component != null) {
              // This is an edit
              logic.updateComponent(
                newComponent.copyWith(id: component.id),
              );
            } else {
              // This is a new component
              logic.addComponent(
                newComponent.copyWith(
                  paletteColorId: drift.Value(widget.initialColor.color.id),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _deleteComponent(int componentId) {
    ref
        .read(paletteDetailLogicProvider(widget.initialColor.color.paletteId))
        .deleteComponent(componentId);
  }

  Widget _buildComponentList() {
    // Watch the components directly from the database for live updates
    final componentsStream = ref.watch(
        paletteColorComponentsStreamProvider(widget.initialColor.color.id));

    return componentsStream.when(
      data: (components) {
        return ref.watch(vendorColorsProvider).when(
              data: (vendorColors) {
                if (components.isEmpty) {
                  return const SizedBox.shrink();
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: components.length,
                  itemBuilder: (context, index) {
                    final component = components[index];
                    final vendorColor = vendorColors
                        .firstWhere(
                            (vc) => vc.color.id == component.vendorColorId)
                        .color;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: GridTile(
                        footer: GridTileBar(
                          backgroundColor: Colors.black45,
                          title: Text(
                            vendorColor.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10),
                          ),
                          subtitle: Text(
                            '${component.percentage.toStringAsFixed(1)}%',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    size: 20, color: Colors.white),
                                onPressed: () => _showComponentDialog(
                                    component: component.toCompanion(true),
                                    index: index),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 20, color: Colors.white),
                                onPressed: () => _deleteComponent(component.id),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                        child: Image.asset(
                          vendorColor.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);
    final isApiEnabled = settings.isGeminiApiEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialColor.color.title),
        actions: [
          if (isApiEnabled)
            IconButton(
              icon: const Icon(Icons.cloud_upload_outlined),
              tooltip: 'Import AI Recipe',
              onPressed: _showImportDialog,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Color Settings',
            onPressed: _showColorSettingsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComponentList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComponentDialog(),
        tooltip: 'Add Component',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ComponentDialog extends ConsumerStatefulWidget {
  const _ComponentDialog({this.component, required this.onSave});
  final ColorComponentsCompanion? component;
  final void Function(ColorComponentsCompanion) onSave;

  @override
  ConsumerState<_ComponentDialog> createState() => _ComponentDialogState();
}

class _ComponentDialogState extends ConsumerState<_ComponentDialog> {
  late final TextEditingController _percentageController;
  String? _selectedColorName;
  int? _selectedVendorColorId;
  List<String> _colorNames = [];

  @override
  void initState() {
    super.initState();
    _percentageController = TextEditingController();
  }

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

  void _save() {
    final percentage = double.tryParse(_percentageController.text);
    if (_selectedVendorColorId != null && percentage != null) {
      final newComponent = ColorComponentsCompanion.insert(
        paletteColorId: -1, // This will be set by the caller
        vendorColorId: _selectedVendorColorId!,
        percentage: percentage,
      );
      widget.onSave(newComponent);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorColorsAsync = ref.watch(vendorColorsProvider);

    return vendorColorsAsync.when(
      data: (vendorColors) {
        _colorNames = vendorColors.map((c) => c.color.name).toSet().toList()
          ..sort();

        void onColorNameSelected(String? name) {
          if (name == null) return;
          setState(() {
            _selectedColorName = name;
            _selectedVendorColorId = vendorColors
                .firstWhere((c) => c.color.name == _selectedColorName)
                .color
                .id;
          });
        }

        return AlertDialog(
          title: Text(
            widget.component != null ? 'Edit Component' : 'Add Component',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedColorName,
                hint: const Text('Select Color'),
                isExpanded: true,
                items: _colorNames.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: onColorNameSelected,
              ),
              GrufioTextFieldSimple(
                controller: _percentageController,
                topLabel: 'Percentage',
                onChanged: (value) {
                  // Update percentage
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(onPressed: _save, child: const Text('Save')),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading vendor colors: $error')),
    );
  }
}
