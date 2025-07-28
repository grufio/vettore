import 'package:flutter/material.dart';
import 'package:vettore/constants/ui_constants.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/widgets/grufio_text_field_simple.dart';
import 'package:vettore/widgets/grufio_dropdown_form_field.dart';
import 'package:vettore/widgets/grufio_checkbox.dart';

class OutputTabView extends StatefulWidget {
  final SettingsService settings;
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

  final TextEditingController objectOutputSizeController;
  final TextEditingController outputFontSizeController;
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
    required this.printCells,
    required this.onPrintCellsChanged,
    required this.printBorders,
    required this.onPrintBordersChanged,
    required this.printNumbers,
    required this.onPrintNumbersChanged,
    required this.objectOutputSizeController,
    required this.outputFontSizeController,
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
            GrufioTextFieldSimple(
              controller: widget.objectOutputSizeController,
              topLabel: 'Object Output Size (mm)',
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  widget.settings.setObjectOutputSize(double.parse(value)),
            ),
            const SizedBox(height: kSpacingM),
            GrufioTextFieldSimple(
              controller: widget.outputFontSizeController,
              topLabel: 'Font Size',
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  widget.settings.setOutputFontSize(int.parse(value)),
            ),
            const SizedBox(height: kSpacingM),
            GrufioDropdownFormField<String>(
              topLabel: 'Page Format',
              value: widget.selectedPageFormat,
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
                    child: GrufioTextFieldSimple(
                      controller: widget.customPageWidthController,
                      topLabel: 'Width (mm)',
                      keyboardType: TextInputType.number,
                      onChanged: (value) => widget.settings
                          .setCustomPageWidth(double.parse(value)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GrufioTextFieldSimple(
                      controller: widget.customPageHeightController,
                      topLabel: 'Height (mm)',
                      keyboardType: TextInputType.number,
                      onChanged: (value) => widget.settings
                          .setCustomPageHeight(double.parse(value)),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: kSpacingM),
            GrufioCheckbox(
              title: 'Print Cells',
              value: widget.printCells,
              onChanged: (bool? value) {
                widget.onPrintCellsChanged(value ?? false);
              },
            ),
            const SizedBox(height: 2.0),
            GrufioCheckbox(
              title: 'Print Borders',
              value: widget.printBorders,
              onChanged: (bool? value) {
                widget.onPrintBordersChanged(value ?? false);
              },
            ),
            const SizedBox(height: 2.0),
            GrufioCheckbox(
              title: 'Print Numbers',
              value: widget.printNumbers,
              onChanged: (bool? value) {
                widget.onPrintNumbersChanged(value ?? false);
              },
            ),
            const SizedBox(height: kSpacingM),
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
