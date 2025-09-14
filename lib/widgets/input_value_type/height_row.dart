import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/widgets/constants/input_constants.dart';
import 'package:vettore/widgets/input_value_type/unit_conversion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/application_providers.dart';

class HeightRow extends StatefulWidget {
  final TextEditingController heightController;
  final bool enabled;
  final ValueChanged<String>? onUnitChanged;
  final bool readOnlyView;

  const HeightRow({
    super.key,
    required this.heightController,
    required this.enabled,
    this.onUnitChanged,
    this.readOnlyView = false,
  });

  @override
  State<HeightRow> createState() => _HeightRowState();
}

class _HeightRowState extends State<HeightRow> {
  static const List<String> _units = kUnits;
  String _unit = 'px';
  double? _aspect; // width/height inverse used by WidthRow;
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final int dpi = ProviderScope.containerOf(context).read(dpiProvider);
    final bool readOnly = !widget.enabled;
    return SectionInput(
      full: InputValueType(
        key: const ValueKey('height'),
        controller: widget.heightController,
        placeholder: 'Height',
        prefixIconAsset: 'assets/icons/16/height.svg',
        prefixIconFit: BoxFit.none,
        prefixIconAlignment: Alignment.centerLeft,
        dropdownItems: _units,
        selectedItem: _unit,
        suffixText: _unit,
        variant: InputVariant.selector,
        readOnly: readOnly,
        readOnlyView: widget.readOnlyView,
        onChanged: (raw) {
          final sanitized = raw.replaceAll(RegExp(r'[^0-9]'), '');
          if (sanitized != raw) {
            widget.heightController.text = sanitized;
            final newOffset = sanitized.length.clamp(0, sanitized.length);
            widget.heightController.selection =
                TextSelection.collapsed(offset: newOffset);
          }
          // When linked, update width based on aspect (if known)
          if (_syncing) return;
          // Infer aspect from current fields when possible
          final int? h = int.tryParse(widget.heightController.text);
          // We cannot access linked state here; WidthRow handles forward link.
        },
        onItemSelected: (nextUnit) {
          final String text = widget.heightController.text.trim();
          final double? value = double.tryParse(text);
          setState(() {
            if (value != null) {
              final double converted = convertUnit(
                value: value,
                fromUnit: _unit,
                toUnit: nextUnit,
                dpi: dpi,
              );
              widget.heightController.text =
                  formatUnitValue(converted, nextUnit);
            }
            _unit = nextUnit;
            widget.onUnitChanged?.call(_unit);
          });
        },
      ),
    );
  }
}
