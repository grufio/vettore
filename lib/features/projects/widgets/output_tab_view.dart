import 'package:flutter/material.dart';
import 'package:vettore/services/settings_service.dart';

class OutputTabView extends StatefulWidget {
  final SettingsService settings;
  final bool isSaving;
  final bool canGenerate;
  final VoidCallback onGenerate;
  final Map<String, dynamic> pageFormats;
  final String selectedPageFormat;
  final Function(String) onPageFormatChanged;
  final bool isLandscape;
  final Function(bool) onLandscapeChanged;
  final bool centerImage;
  final Function(bool) onCenterImageChanged;
  final bool printBackground;
  final Function(bool) onPrintBackgroundChanged;

  final TextEditingController objectOutputSizeController;
  final TextEditingController outputFontSizeController;
  final TextEditingController outputBordersController;
  final TextEditingController customPageWidthController;
  final TextEditingController customPageHeightController;

  const OutputTabView({
    super.key,
    required this.settings,
    required this.isSaving,
    required this.canGenerate,
    required this.onGenerate,
    required this.pageFormats,
    required this.selectedPageFormat,
    required this.onPageFormatChanged,
    required this.isLandscape,
    required this.onLandscapeChanged,
    required this.centerImage,
    required this.onCenterImageChanged,
    required this.printBackground,
    required this.onPrintBackgroundChanged,
    required this.objectOutputSizeController,
    required this.outputFontSizeController,
    required this.outputBordersController,
    required this.customPageWidthController,
    required this.customPageHeightController,
  });

  @override
  State<OutputTabView> createState() => _OutputTabViewState();
}

class _OutputTabViewState extends State<OutputTabView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: widget.objectOutputSizeController,
              decoration: const InputDecoration(
                labelText: 'Object Output Size (mm)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  widget.settings.setObjectOutputSize(double.parse(value)),
            ),
            TextField(
              controller: widget.outputFontSizeController,
              decoration: const InputDecoration(
                labelText: 'Font Size',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  widget.settings.setOutputFontSize(int.parse(value)),
            ),
            TextField(
              controller: widget.outputBordersController,
              decoration: const InputDecoration(
                labelText: 'Output Borders (mm)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  widget.settings.setOutputBorders(double.parse(value)),
            ),
            DropdownButtonFormField<String>(
              value: widget.selectedPageFormat,
              decoration: const InputDecoration(
                labelText: 'Page Format',
              ),
              items: widget.pageFormats.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onPageFormatChanged(newValue);
                }
              },
            ),
            if (widget.selectedPageFormat == 'Custom')
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.customPageWidthController,
                      decoration: const InputDecoration(
                        labelText: 'Width (mm)',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => widget.settings
                          .setCustomPageWidth(double.parse(value)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.customPageHeightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (mm)',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => widget.settings
                          .setCustomPageHeight(double.parse(value)),
                    ),
                  ),
                ],
              ),
            CheckboxListTile(
              title: const Text('Landscape'),
              value: widget.isLandscape,
              onChanged: (bool? value) {
                widget.onLandscapeChanged(value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Center Image'),
              value: widget.centerImage,
              onChanged: (bool? value) {
                widget.onCenterImageChanged(value ?? true);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Print background'),
              value: widget.printBackground,
              onChanged: (bool? value) {
                widget.onPrintBackgroundChanged(value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            if (widget.isSaving)
              const CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.canGenerate ? widget.onGenerate : null,
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                  ),
                  label: const Text('Generate PDF'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
