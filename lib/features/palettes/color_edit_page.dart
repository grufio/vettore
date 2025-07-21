import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vettore/services/ai_service.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/import_recipe_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/vendor_color_provider.dart';
import 'package:drift/drift.dart' as drift;

class ColorEditPage extends ConsumerStatefulWidget {
  final PaletteColor initialColor;
  final Function(PaletteColorsCompanion) onSave;

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
    _titleController = TextEditingController(text: widget.initialColor.title);
    _statusController = TextEditingController(text: widget.initialColor.status);
    _currentColor = Color(widget.initialColor.color);
    _components = []; // TODO: Load components
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
    // TODO: Re-implement import dialog
  }

  Future<void> _importFromImage(Uint8List imageData) async {
    // TODO: Re-implement import from image
  }

  void _save() {
    final newColor = PaletteColorsCompanion(
      id: drift.Value(widget.initialColor.id),
      paletteId: drift.Value(widget.initialColor.paletteId),
      title: drift.Value(_titleController.text),
      color: drift.Value(_currentColor.value),
      status: drift.Value(_statusController.text),
    );
    widget.onSave(newColor);
    Navigator.of(context).pop();
  }

  void _showColorPicker() {
    Color pickerColor = _currentColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => _currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showComponentDialog({
    ColorComponentsCompanion? component,
    int? index,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _ComponentDialog(
          component: component,
          onSave: (newComponent) {
            setState(() {
              if (index != null) {
                _components[index] = newComponent;
              } else {
                _components.add(newComponent);
              }
            });
          },
        );
      },
    );
  }

  void _deleteComponent(int index) {
    setState(() {
      _components.removeAt(index);
    });
  }

  Widget _buildComponentList() {
    // TODO: Re-implement component list logic
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialColor.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            tooltip: 'Import Recipe',
            onPressed: _showImportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Color',
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Color Name',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        TextFormField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Enter color name',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        TextFormField(
                          controller: _statusController,
                          focusNode: _statusFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Enter color status',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _showColorPicker,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${_currentColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _currentColor,
                        border: Border.all(color: Colors.grey),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              _buildComponentList(),
            ],
          ),
        ),
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
  int? _selectedSize;
  String? _selectedColorName;
  int? _selectedVendorColorId;
  List<int> _availableSizes = [];
  List<String> _colorNames = [];

  @override
  void initState() {
    super.initState();
    // TODO: Init state for editing
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
    final vendorColorsAsync = ref.watch(vendorColorStreamProvider);

    return vendorColorsAsync.when(
      data: (vendorColors) {
        _colorNames = vendorColors.map((c) => c.name).toSet().toList()..sort();

        void _updateAvailableSizes(String? name) {
          if (name == null) {
            _availableSizes = [];
            return;
          }
          _availableSizes = vendorColors
              .where((c) => c.name == name)
              .map((c) => c.size)
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));
        }

        void _onColorNameSelected(String? name) {
          if (name == null) return;
          setState(() {
            _selectedColorName = name;
            _updateAvailableSizes(name);
            _selectedSize =
                _availableSizes.isNotEmpty ? _availableSizes.first : null;
            if (_selectedColorName != null && _selectedSize != null) {
              _selectedVendorColorId = vendorColors
                  .firstWhere((c) =>
                      c.name == _selectedColorName && c.size == _selectedSize)
                  .id;
            }
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
              if (_selectedColorName != null)
                DropdownButtonFormField<int>(
                  value: _selectedSize,
                  hint: const Text('Select Size (ml)'),
                  isExpanded: true,
                  items: _availableSizes.map((size) {
                    return DropdownMenuItem<int>(
                      value: size,
                      child: Text('$size ml'),
                    );
                  }).toList(),
                  onChanged: (size) => setState(() {
                    _selectedSize = size;
                    if (_selectedColorName != null && _selectedSize != null) {
                      _selectedVendorColorId = vendorColors
                          .firstWhere((c) =>
                              c.name == _selectedColorName &&
                              c.size == _selectedSize)
                          .id;
                    }
                  }),
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
