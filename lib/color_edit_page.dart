import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/color_component_model.dart';
import 'package:vettore/palette_color.dart';
import 'package:vettore/vendor_color_model.dart';

class ColorEditPage extends StatefulWidget {
  final PaletteColor initialColor;
  final double sizeInMl;
  final double factor;
  final Function(PaletteColor) onSave;

  const ColorEditPage({
    super.key,
    required this.initialColor,
    required this.sizeInMl,
    required this.factor,
    required this.onSave,
  });

  @override
  State<ColorEditPage> createState() => _ColorEditPageState();
}

class _ColorEditPageState extends State<ColorEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _statusController;
  late Color _currentColor;
  late List<ColorComponent> _components;
  final _titleFocusNode = FocusNode();
  final _statusFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialColor.title);
    _statusController = TextEditingController(text: widget.initialColor.status);
    _currentColor = Color(widget.initialColor.color);
    _components = List.from(widget.initialColor.components);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _statusController.dispose();
    _titleFocusNode.dispose();
    _statusFocusNode.dispose();
    super.dispose();
  }

  void _save() {
    final newColor = PaletteColor(
      title: _titleController.text,
      color: _currentColor.value,
      status: _statusController.text,
      components: _components,
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
    ColorComponent? component,
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
    final totalPercentage = _components.fold<double>(
      0.0,
      (sum, item) => sum + item.percentage,
    );
    final isTotal100 = totalPercentage == 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Color Components',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showComponentDialog(),
            ),
          ],
        ),
        if (_components.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('No components added yet.')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _components.length,
            itemBuilder: (context, index) {
              final component = _components[index];
              final weight =
                  (component.percentage / 100) *
                  widget.sizeInMl *
                  widget.factor;
              return ListTile(
                title: Text(component.name),
                subtitle: Text('${component.percentage}%'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${weight.toStringAsFixed(3)} g'),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showComponentDialog(
                        component: component,
                        index: index,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteComponent(index),
                    ),
                  ],
                ),
              );
            },
          ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total: ${totalPercentage.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isTotal100 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorColorBox = Hive.box<VendorColor>('vendor_colors');
    final sizes = vendorColorBox.values.map((c) => c.size).toSet().toList()
      ..sort();
    debugPrint(
      '[_ComponentDialog] Building with ${vendorColorBox.length} vendor colors.',
    );
    debugPrint('[_ComponentDialog] Found sizes: $sizes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Color'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _statusController,
              focusNode: _statusFocusNode,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showColorPicker,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _currentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '#${_currentColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            _buildComponentList(),
          ],
        ),
      ),
    );
  }
}

class _ComponentDialog extends StatefulWidget {
  final ColorComponent? component;
  final Function(ColorComponent) onSave;

  const _ComponentDialog({this.component, required this.onSave});

  @override
  State<_ComponentDialog> createState() => _ComponentDialogState();
}

class _ComponentDialogState extends State<_ComponentDialog> {
  final _vendorColorBox = Hive.box<VendorColor>('vendor_colors');
  late final TextEditingController _percentageController;
  int? _selectedSize;
  String? _selectedColorName;
  List<int> _availableSizes = [];

  @override
  void initState() {
    super.initState();
    _percentageController = TextEditingController(
      text: widget.component?.percentage.toString() ?? '',
    );

    // If editing, pre-fill the state
    if (widget.component != null) {
      final componentName = widget.component!.name;
      // Use the listenable builder's box for initial state check
      final allColorNames = Hive.box<VendorColor>(
        'vendor_colors',
      ).values.map((c) => c.name).toSet();

      if (allColorNames.contains(componentName)) {
        _selectedColorName = componentName;
        _onColorNameSelected(_selectedColorName, shouldSetDefaultSize: false);
      } else {
        // The component's name doesn't exist in the vendor list.
        // Set to null to avoid a crash and force the user to select a valid color.
        _selectedColorName = null;
      }
    }
  }

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

  void _onColorNameSelected(String? name, {bool shouldSetDefaultSize = true}) {
    if (name == null) return;
    setState(() {
      _selectedColorName = name;
      _availableSizes =
          _vendorColorBox.values
              .where((c) => c.name == name)
              .map((c) => c.size)
              .toSet()
              .toList()
            ..sort(
              (a, b) => b.compareTo(a),
            ); // Sort descending for largest first

      if (shouldSetDefaultSize) {
        _selectedSize = _availableSizes.isNotEmpty
            ? _availableSizes.first
            : null;
      } else {
        _selectedSize = null;
      }
    });
  }

  void _save() {
    final percentage = double.tryParse(_percentageController.text);
    if (_selectedColorName != null &&
        _selectedSize != null &&
        percentage != null) {
      final newComponent = ColorComponent(
        name: _selectedColorName!,
        percentage: percentage,
      );
      widget.onSave(newComponent);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<VendorColor>>(
      valueListenable: Hive.box<VendorColor>('vendor_colors').listenable(),
      builder: (context, box, _) {
        final colorNames = box.values.map((c) => c.name).toSet().toList()
          ..sort();

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
                items: colorNames.map((name) {
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
                  onChanged: (size) => setState(() => _selectedSize = size),
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
            TextButton(child: const Text('Save'), onPressed: _save),
          ],
        );
      },
    );
  }
}
