import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/features/projects/services/pdf_generator.dart'; // Import the new generator

class SettingsDialog extends StatefulWidget {
  final Project project;
  const SettingsDialog({super.key, required this.project});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late final Box _settingsBox;
  late final TextEditingController _downsampleScaleController;
  late final TextEditingController _objectOutputSizeController;
  late final TextEditingController _maxObjectColorsController;
  late final TextEditingController _fontSizeController;
  late final TextEditingController _outputFontSizeController;
  late final TextEditingController _customPageWidthController;
  late final TextEditingController _customPageHeightController;
  late final TextEditingController _outputBordersController;
  bool _printBackground = false;
  bool _isSaving = false;
  String _selectedPageFormat = 'A4';
  bool _centerImage = true;
  bool _isLandscape = false;
  int _selectedTabIndex = 0;

  final Map<String, PdfPageFormat?> _pageFormats = {
    'A4': PdfPageFormat.a4,
    'A3': PdfPageFormat.a3,
    'Letter': PdfPageFormat.letter,
    'Custom': null,
  };

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');

    _downsampleScaleController = TextEditingController(
      text: _settingsBox.get('downsampleScale', defaultValue: '10'),
    );
    _objectOutputSizeController = TextEditingController(
      text: _settingsBox.get('objectOutputSize', defaultValue: '10'),
    );
    _maxObjectColorsController = TextEditingController(
      text: _settingsBox.get('maxObjectColors', defaultValue: '40'),
    );
    _fontSizeController = TextEditingController(
      text: _settingsBox.get('fontSize', defaultValue: '10'),
    );
    _outputFontSizeController = TextEditingController(
      text: _settingsBox.get('outputFontSize', defaultValue: '10'),
    );
    _customPageWidthController = TextEditingController(
      text: _settingsBox.get('customPageWidth', defaultValue: '210'),
    );
    _customPageHeightController = TextEditingController(
      text: _settingsBox.get('customPageHeight', defaultValue: '297'),
    );
    _outputBordersController = TextEditingController(
      text: _settingsBox.get('outputBorders', defaultValue: '10'),
    );
    _printBackground = _settingsBox.get('printBackground', defaultValue: false);
    _selectedPageFormat = _settingsBox.get('pageFormat', defaultValue: 'A4');
    _centerImage = _settingsBox.get('centerImage', defaultValue: true);
    _isLandscape = _settingsBox.get('isLandscape', defaultValue: false);
  }

  Future<void> _handlePdfGeneration() async {
    setState(() => _isSaving = true);

    PdfPageFormat pageFormat;
    if (_selectedPageFormat == 'Custom') {
      final width = double.tryParse(_customPageWidthController.text) ?? 210;
      final height = double.tryParse(_customPageHeightController.text) ?? 297;
      pageFormat = PdfPageFormat(
        width * PdfPageFormat.mm,
        height * PdfPageFormat.mm,
      );
    } else {
      pageFormat = _pageFormats[_selectedPageFormat]!;
    }

    if (_isLandscape) {
      pageFormat = pageFormat.landscape;
    }

    await generateVectorPdf(
      vectorObjects: widget.project.vectorObjects,
      imageSize: Size(widget.project.imageWidth!, widget.project.imageHeight!),
      objectOutputSize: double.parse(_objectOutputSizeController.text),
      fontSize: double.parse(_outputFontSizeController.text),
      printBackground: _printBackground,
      originalImageData: widget.project.imageData,
      pageFormat: pageFormat,
      centerImage: _centerImage,
      outputBorders: double.tryParse(_outputBordersController.text) ?? 10.0,
    );
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SegmentedButton<int>(
        segments: const <ButtonSegment<int>>[
          ButtonSegment<int>(
            value: 0,
            label: Text('Conversion'),
            icon: Icon(Icons.transform),
          ),
          ButtonSegment<int>(
            value: 1,
            label: Text('Output'),
            icon: Icon(Icons.picture_as_pdf),
          ),
        ],
        selected: {_selectedTabIndex},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() {
            _selectedTabIndex = newSelection.first;
          });
        },
      ),
      content: SizedBox(
        height: 480,
        width: 400,
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            // Conversion Tab
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _downsampleScaleController,
                      decoration: const InputDecoration(
                        labelText: 'Downsample Scale (%)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _maxObjectColorsController,
                      decoration: const InputDecoration(
                        labelText: 'Max. Object Colors',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _fontSizeController,
                      decoration: const InputDecoration(labelText: 'Font Size'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            // Output Tab
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _objectOutputSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Object Output Size (mm)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _outputFontSizeController,
                      decoration: const InputDecoration(labelText: 'Font Size'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _outputBordersController,
                      decoration: const InputDecoration(
                        labelText: 'Output Borders (mm)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedPageFormat,
                      decoration: const InputDecoration(
                        labelText: 'Page Format',
                      ),
                      items: _pageFormats.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPageFormat = newValue!;
                        });
                      },
                    ),
                    if (_selectedPageFormat == 'Custom')
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customPageWidthController,
                              decoration: const InputDecoration(
                                labelText: 'Width (mm)',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _customPageHeightController,
                              decoration: const InputDecoration(
                                labelText: 'Height (mm)',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    CheckboxListTile(
                      title: const Text('Landscape'),
                      value: _isLandscape,
                      onChanged: (bool? value) {
                        setState(() {
                          _isLandscape = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Center Image'),
                      value: _centerImage,
                      onChanged: (bool? value) {
                        setState(() {
                          _centerImage = value ?? true;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Print background'),
                      value: _printBackground,
                      onChanged: (bool? value) {
                        setState(() {
                          _printBackground = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isSaving)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: widget.project.vectorObjects.isEmpty
                            ? null
                            : _handlePdfGeneration,
                        child: const Text('Generate PDF'),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
          child: const Text('Save & Close'),
          onPressed: () {
            _settingsBox.put(
              'downsampleScale',
              _downsampleScaleController.text,
            );
            _settingsBox.put(
              'objectOutputSize',
              _objectOutputSizeController.text,
            );
            _settingsBox.put('printBackground', _printBackground);
            _settingsBox.put('pageFormat', _selectedPageFormat);
            if (_selectedPageFormat == 'Custom') {
              _settingsBox.put(
                'customPageWidth',
                _customPageWidthController.text,
              );
              _settingsBox.put(
                'customPageHeight',
                _customPageHeightController.text,
              );
            }
            _settingsBox.put('centerImage', _centerImage);
            _settingsBox.put('isLandscape', _isLandscape);
            _settingsBox.put('outputBorders', _outputBordersController.text);
            _settingsBox.put('fontSize', _fontSizeController.text);
            _settingsBox.put('outputFontSize', _outputFontSizeController.text);
            _settingsBox.put(
              'maxObjectColors',
              _maxObjectColorsController.text,
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _downsampleScaleController.dispose();
    _objectOutputSizeController.dispose();
    _maxObjectColorsController.dispose();
    _fontSizeController.dispose();
    _outputFontSizeController.dispose();
    _customPageWidthController.dispose();
    _customPageHeightController.dispose();
    _outputBordersController.dispose();
    super.dispose();
  }
}
