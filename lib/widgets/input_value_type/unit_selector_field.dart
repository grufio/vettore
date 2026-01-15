import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:grufio/widgets/input_value_type/input_value_type.dart';
import 'package:grufio/widgets/input_value_type/number_utils.dart';

/// A thin wrapper around InputValueType that renders a text field with a unit
/// selector dropdown and a suffix that mirrors the selected unit. It centralizes
/// unit selector wiring to keep parent widgets simpler.
class UnitSelectorField extends StatelessWidget {
  const UnitSelectorField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.placeholder,
    required this.prefixIconAsset,
    this.prefixIconFit,
    this.prefixIconAlignment,
    required this.readOnly,
    required this.readOnlyView,
    required this.units,
    required this.selectedUnit,
    required this.onUnitSelected,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String placeholder;
  final String prefixIconAsset;
  final BoxFit? prefixIconFit;
  final AlignmentGeometry? prefixIconAlignment;
  final bool readOnly;
  final bool readOnlyView;
  final List<String> units;
  final String selectedUnit;
  final ValueChanged<String> onUnitSelected;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return InputValueType(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      prefixIconAsset: prefixIconAsset,
      prefixIconFit: prefixIconFit,
      prefixIconAlignment: prefixIconAlignment,
      dropdownItems: units,
      selectedItem: selectedUnit,
      suffixText: selectedUnit,
      variant: InputVariant.selector,
      readOnly: readOnly,
      readOnlyView: readOnlyView,
      inputFormatters: inputFormatters,
      onChanged: (raw) {
        // Central numeric sanitize; do not change meaning while typing.
        final String sanitized = sanitizeNumber(raw);
        if (sanitized != raw) {
          controller.text = sanitized;
          final int newOffset = sanitized.length.clamp(0, sanitized.length);
          controller.selection = TextSelection.collapsed(offset: newOffset);
        }
      },
      onItemSelected: onUnitSelected,
    );
  }
}
