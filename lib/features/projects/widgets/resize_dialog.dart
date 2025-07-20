import 'package:flutter/material.dart';
import 'dart:ui'; // Required for FilterQuality

// Using a record for a clear and type-safe return value.
typedef ResizeResult = ({double percentage, FilterQuality filterQuality});

class ResizeDialog extends StatefulWidget {
  const ResizeDialog({super.key});

  @override
  State<ResizeDialog> createState() => _ResizeDialogState();
}

class _ResizeDialogState extends State<ResizeDialog> {
  late final TextEditingController _controller;
  FilterQuality _selectedFilterQuality = FilterQuality.high; // Default

  final Map<String, FilterQuality> _filterOptions = {
    'Bikubisch (Glatt)': FilterQuality.high,
    'Pixelwiederholung (Harte Kanten)': FilterQuality.none,
  };

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final percentage = double.tryParse(_controller.text);
    if (percentage != null && percentage > 0) {
      Navigator.of(
        context,
      ).pop((percentage: percentage, filterQuality: _selectedFilterQuality));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid, positive percentage.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Resize Image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Resize Percentage',
              suffixText: '%',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<FilterQuality>(
            value: _selectedFilterQuality,
            decoration: const InputDecoration(
              labelText: 'Interpolation',
              border: OutlineInputBorder(),
            ),
            items: _filterOptions.entries.map((entry) {
              return DropdownMenuItem<FilterQuality>(
                value: entry.value,
                child: Text(entry.key),
              );
            }).toList(),
            onChanged: (FilterQuality? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedFilterQuality = newValue;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Resize')),
      ],
    );
  }
}
