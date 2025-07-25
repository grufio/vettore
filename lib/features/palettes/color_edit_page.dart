import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vettore/services/ai_service.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/import_recipe_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/vendor_color_provider.dart';
import 'package:vettore/providers/palette_detail_provider.dart';
import 'package:vettore/repositories/palette_repository.dart';
import 'package:drift/drift.dart' as drift;

class ColorEditPage extends ConsumerStatefulWidget {
  final PaletteColorWithComponents initialColor;
  final Function(
    PaletteColorsCompanion,
    List<ColorComponentsCompanion>,
  ) onSave;

  const ColorEditPage({
    super.key,
    required this.initialColor,
    required this.onSave,
  });

  @override
  ConsumerState<ColorEditPage> createState() => _ColorEditPageState();
}

class _ColorEditPageState extends ConsumerState<ColorEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _statusController;
  late Color _currentColor;
  late List<ColorComponentsCompanion> _components;
  final _titleFocusNode = FocusNode();
  final _statusFocusNode = FocusNode();

  late final AIService _aiService;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialColor.color.title);
    _statusController =
        TextEditingController(text: widget.initialColor.color.status);
    _currentColor = Color(widget.initialColor.color.color);
    _components =
        widget.initialColor.components.map((c) => c.toCompanion(true)).toList();
    _aiService = AIService(settingsService: ref.read(settingsServiceProvider));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _statusController.dispose();
    _titleFocusNode.dispose();
    _statusFocusNode.dispose();
    super.dispose();
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => ImportRecipeDialog(
        onImageImported: (imageData) async {
          await _importFromImage(imageData);
        },
      ),
    );
  }

  Future<void> _importFromImage(Uint8List imageData) async {
    final vendorColors = await ref.read(vendorColorsProvider.future);
    final result = await _aiService.importRecipeFromImage(imageData);

    final componentsData = result['components'] as List<dynamic>? ?? [];

    final newComponents = <ColorComponentsCompanion>[];
    for (final item in componentsData) {
      final name = item['name'] as String?;
      final percentage = item['percentage'] as num?;

      if (name != null && percentage != null) {
        // Find the corresponding vendor color variant by name (case-insensitive)
        final vendorColor = vendorColors.firstWhere(
          (vc) => vc.color.name.toLowerCase() == name.toLowerCase(),
          orElse: () =>
              throw Exception('Vendor color not found for name: "$name"'),
        );
        final variant = vendorColor.variants.first;

        newComponents.add(
          ColorComponentsCompanion(
            vendorColorId: drift.Value(vendorColor.color.id),
            percentage: drift.Value(percentage.toDouble()),
          ),
        );
      }
    }

    setState(() {
      _components = newComponents;
    });
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
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Color Name',
                    ),
                    autofocus: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: statusController,
                    decoration: const InputDecoration(labelText: 'Status'),
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
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Color Settings',
            onPressed: _showColorSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.import_export),
            tooltip: 'Import Recipe',
            onPressed: isApiEnabled ? _showImportDialog : null,
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
  final ColorComponentsCompanion? component;
  final Function(ColorComponentsCompanion) onSave;

  const _ComponentDialog({this.component, required this.onSave});

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

        void _onColorNameSelected(String? name) {
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
                onChanged: _onColorNameSelected,
              ),
              TextField(
                controller: _percentageController,
                decoration: const InputDecoration(labelText: 'Percentage'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
