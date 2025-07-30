import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:vettore/constants/ui_constants.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/grufio_text_field_simple.dart';
import 'package:vettore/widgets/grufio_dropdown_form_field.dart';
import 'package:vettore/widgets/grufio_checkbox.dart';

class OutputTabView extends StatelessWidget {
  final SettingsService settings;
  final TextEditingController objectOutputSizeController;
  final TextEditingController outputFontSizeController;
  final TextEditingController customPageWidthController;
  final TextEditingController customPageHeightController;
  final bool isSaving;
  final bool canGenerate;
  final VoidCallback onGenerate;
  final Map<String, dynamic> pageFormats;
  final String selectedPageFormat;
  final Function(String) onPageFormatChanged;
  final bool printCells;
  final Function(bool) onPrintCellsChanged;
  final bool printBorders;
  final Function(bool) onPrintBordersChanged;
  final bool printNumbers;
  final Function(bool) onPrintNumbersChanged;
  final PdfViewerController pdfController;

  const OutputTabView({
    super.key,
    required this.settings,
    required this.objectOutputSizeController,
    required this.outputFontSizeController,
    required this.customPageWidthController,
    required this.customPageHeightController,
    required this.isSaving,
    required this.canGenerate,
    required this.onGenerate,
    required this.pageFormats,
    required this.selectedPageFormat,
    required this.onPageFormatChanged,
    required this.printCells,
    required this.onPrintCellsChanged,
    required this.printBorders,
    required this.onPrintBordersChanged,
    required this.printNumbers,
    required this.onPrintNumbersChanged,
    required this.pdfController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingM),
        child: Column(
          children: [
            GrufioTextFieldSimple(
              controller: objectOutputSizeController,
              topLabel: 'Object Output Size (mm)',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final val = double.tryParse(value);
                if (val != null) {
                  settings.setObjectOutputSize(val);
                }
              },
            ),
            const SizedBox(height: kSpacingM),
            GrufioTextFieldSimple(
              controller: outputFontSizeController,
              topLabel: 'Font Size',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final val = int.tryParse(value);
                if (val != null) {
                  settings.setOutputFontSize(val);
                }
              },
            ),
            const SizedBox(height: kSpacingM),
            GrufioDropdownFormField<String>(
              topLabel: 'Page Format',
              value: selectedPageFormat,
              items: pageFormats.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onPageFormatChanged(newValue);
                }
              },
            ),
            if (selectedPageFormat == 'Custom')
              Row(
                children: [
                  Expanded(
                    child: GrufioTextFieldSimple(
                      controller: customPageWidthController,
                      topLabel: 'Width (mm)',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final val = double.tryParse(value);
                        if (val != null) {
                          settings.setCustomPageWidth(val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GrufioTextFieldSimple(
                      controller: customPageHeightController,
                      topLabel: 'Height (mm)',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final val = double.tryParse(value);
                        if (val != null) {
                          settings.setCustomPageHeight(val);
                        }
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: kSpacingM),
            GrufioCheckbox(
              title: 'Print Cells',
              value: printCells,
              onChanged: (bool? value) {
                onPrintCellsChanged(value ?? false);
              },
            ),
            const SizedBox(height: 2.0),
            GrufioCheckbox(
              title: 'Print Borders',
              value: printBorders,
              onChanged: (bool? value) {
                onPrintBordersChanged(value ?? false);
              },
            ),
            const SizedBox(height: 2.0),
            GrufioCheckbox(
              title: 'Print Numbers',
              value: printNumbers,
              onChanged: (bool? value) {
                onPrintNumbersChanged(value ?? false);
              },
            ),
            const SizedBox(height: kSpacingM),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canGenerate ? onGenerate : null,
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.preview_outlined),
                label: Text(isSaving ? 'Generating...' : 'Update Preview'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
