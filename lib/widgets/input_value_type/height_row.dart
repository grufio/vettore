import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/widgets/constants/input_constants.dart';
import 'package:vettore/widgets/input_value_type/unit_conversion.dart';
// no providers used here currently

class HeightRow extends StatefulWidget {
  final TextEditingController heightController;
  final bool enabled;
  final ValueChanged<String>? onUnitChanged;
  final bool readOnlyView;
  final int? dpiOverride;
  final List<String>? units;
  final String? initialUnit;

  const HeightRow({
    super.key,
    required this.heightController,
    required this.enabled,
    this.onUnitChanged,
    this.readOnlyView = false,
    this.dpiOverride,
    this.units,
    this.initialUnit,
  });

  @override
  State<HeightRow> createState() => _HeightRowState();
}

class _HeightRowState extends State<HeightRow> {
  static const List<String> _defaultUnits = kUnits;
  String _unit = 'px';
  bool _syncing = false;
  double? _valuePx; // preserve precise px value

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit ?? _unit;
    final int dpi = widget.dpiOverride ?? 72;
    final double? initial = double.tryParse(widget.heightController.text);
    if (initial != null) {
      _valuePx = convertUnit(
        value: initial,
        fromUnit: _unit,
        toUnit: 'px',
        dpi: dpi,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int dpi = widget.dpiOverride ?? 72;
    final bool readOnly = !widget.enabled;
    final List<String> units = widget.units ?? _defaultUnits;
    return SectionInput(
      full: InputValueType(
        key: const ValueKey('height'),
        controller: widget.heightController,
        placeholder: 'Height',
        prefixIconAsset: 'assets/icons/16/height.svg',
        prefixIconFit: BoxFit.none,
        prefixIconAlignment: Alignment.centerLeft,
        dropdownItems: units,
        selectedItem: _unit,
        suffixText: _unit,
        variant: InputVariant.selector,
        readOnly: readOnly,
        readOnlyView: widget.readOnlyView,
        onChanged: (raw) {
          final sanitized = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
          if (sanitized != raw) {
            widget.heightController.text = sanitized;
            final newOffset = sanitized.length.clamp(0, sanitized.length);
            widget.heightController.selection =
                TextSelection.collapsed(offset: newOffset);
          }
          // When linked, update width based on aspect (if known)
          if (_syncing) return;
          // Infer aspect from current fields when possible
          // keep input sanitized; width-row linkage handles paired updates
          // We cannot access linked state here; WidthRow handles forward link.
          // Update precise px cache
          final double? v = double.tryParse(sanitized);
          if (v != null) {
            _valuePx = convertUnit(
              value: v,
              fromUnit: _unit,
              toUnit: 'px',
              dpi: dpi,
            );
          }
        },
        onItemSelected: (nextUnit) {
          final String text = widget.heightController.text.trim();
          final double? value = double.tryParse(text);
          setState(() {
            if (value != null) {
              final double pxValue = _valuePx ??
                  convertUnit(
                    value: value,
                    fromUnit: _unit,
                    toUnit: 'px',
                    dpi: dpi,
                  );
              final double converted = convertUnit(
                value: pxValue,
                fromUnit: 'px',
                toUnit: nextUnit,
                dpi: dpi,
              );
              widget.heightController.text =
                  formatFieldUnitValue(converted, nextUnit);
            }
            _unit = nextUnit;
            widget.onUnitChanged?.call(_unit);
          });
        },
      ),
    );
  }
}
