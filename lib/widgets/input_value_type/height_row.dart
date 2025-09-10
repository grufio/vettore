import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/widgets/constants/input_constants.dart';

class HeightRow extends StatefulWidget {
  final TextEditingController heightController;
  final bool enabled;
  final int dpi;
  final ValueChanged<String>? onUnitChanged;

  const HeightRow({
    super.key,
    required this.heightController,
    required this.enabled,
    this.dpi = 96,
    this.onUnitChanged,
  });

  @override
  State<HeightRow> createState() => _HeightRowState();
}

class _HeightRowState extends State<HeightRow> {
  static const List<String> _units = kUnits;
  String _unit = 'px';

  @override
  Widget build(BuildContext context) {
    final bool readOnly = !widget.enabled;
    return SectionInput(
      full: InputValueType(
        key: const ValueKey('height'),
        controller: widget.heightController,
        placeholder: widget.enabled ? null : 'Height',
        prefixIconAsset: 'assets/icons/16/height.svg',
        prefixIconFit: BoxFit.none,
        prefixIconAlignment: Alignment.centerLeft,
        dropdownItems: _units,
        selectedItem: _unit,
        variant: InputVariant.valueDropdown,
        readOnly: readOnly,
        onItemSelected: (nextUnit) {
          final String text = widget.heightController.text.trim();
          final double? value = double.tryParse(text);
          setState(() {
            if (value != null) {
              final double converted = _convertUnit(
                value: value,
                from: _unit,
                to: nextUnit,
                dpi: widget.dpi,
              );
              widget.heightController.text = _formatValue(converted, nextUnit);
            }
            _unit = nextUnit;
            widget.onUnitChanged?.call(_unit);
          });
        },
      ),
    );
  }

  static double _convertUnit({
    required double value,
    required String from,
    required String to,
    required int dpi,
  }) {
    double toInches(double v, String unit) {
      switch (unit) {
        case 'px':
          return v / dpi;
        case 'in':
          return v;
        case 'cm':
          return v / 2.54;
        case 'mm':
          return v / 25.4;
        default:
          return v;
      }
    }

    double fromInches(double inches, String unit) {
      switch (unit) {
        case 'px':
          return inches * dpi;
        case 'in':
          return inches;
        case 'cm':
          return inches * 2.54;
        case 'mm':
          return inches * 25.4;
        default:
          return inches;
      }
    }

    final double inches = toInches(value, from);
    return fromInches(inches, to);
  }

  static String _formatValue(double v, String unit) {
    if (unit == 'px') {
      return v.round().toString();
    }
    return v.toStringAsFixed(2);
  }
}
