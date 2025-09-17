import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/widgets/button_toggle.dart';
import 'package:vettore/widgets/constants/input_constants.dart';
import 'package:vettore/widgets/input_value_type/unit_conversion.dart';
// no providers used here currently

class WidthRow extends StatefulWidget {
  final TextEditingController widthController;
  final TextEditingController heightController;
  final bool enabled;
  final bool initialLinked;
  final ValueChanged<bool>? onLinkChanged;
  final ValueChanged<String>? onUnitChanged;
  final bool readOnlyView;
  final int? dpiOverride;
  final List<String>? units;
  final String? initialUnit;

  const WidthRow({
    super.key,
    required this.widthController,
    required this.heightController,
    required this.enabled,
    this.initialLinked = false,
    this.onLinkChanged,
    this.onUnitChanged,
    this.readOnlyView = false,
    this.dpiOverride,
    this.units,
    this.initialUnit,
  });

  @override
  State<WidthRow> createState() => _WidthRowState();
}

class _WidthRowState extends State<WidthRow> {
  static const List<String> _defaultUnits = kUnits;

  bool _linked = false;
  bool _syncing = false;
  double? _aspect; // height / width
  String _unit = 'px';
  // Preserve high-precision value in base pixels to avoid mm→px→mm drift
  double? _valuePx; // may be fractional

  @override
  void initState() {
    super.initState();
    _linked = widget.initialLinked;
    _unit = widget.initialUnit ?? _unit;
    _seedAspectFromFields();
    widget.widthController.addListener(_onWidthChanged);
    widget.heightController.addListener(_onHeightChanged);
    // Initialize internal px value from current text if present
    final int dpi = widget.dpiOverride ?? 72;
    final double? initial = double.tryParse(widget.widthController.text);
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
  void dispose() {
    widget.widthController.removeListener(_onWidthChanged);
    widget.heightController.removeListener(_onHeightChanged);
    super.dispose();
  }

  void _seedAspectFromFields() {
    final int? w = int.tryParse(widget.widthController.text);
    final int? h = int.tryParse(widget.heightController.text);
    if (w != null && w > 0 && h != null && h > 0) {
      _aspect = h / w;
    }
  }

  void _onWidthChanged() {
    if (!_linked || _syncing) return;
    final int? w = int.tryParse(widget.widthController.text);
    if (w == null || w <= 0) return;
    final double aspect = _aspect ?? 1.0;
    _syncing = true;
    final int h = (w * aspect).round();
    widget.heightController.text = h.toString();
    _syncing = false;
  }

  void _onHeightChanged() {
    if (!_linked || _syncing) return;
    final int? h = int.tryParse(widget.heightController.text);
    if (h == null || h <= 0) return;
    final double aspect = _aspect ?? 1.0;
    _syncing = true;
    final int w = (h / aspect).round();
    widget.widthController.text = w.toString();
    _syncing = false;
  }

  @override
  Widget build(BuildContext context) {
    // Source DPI from current image if available via a provider higher up.
    // Fallback to 72 when not available in this context.
    int dpi = widget.dpiOverride ?? 72;
    final bool readOnly = !widget.enabled;
    final List<String> units = widget.units ?? _defaultUnits;
    return SectionInput(
      full: InputValueType(
        key: const ValueKey('width'),
        controller: widget.widthController,
        placeholder: 'Width',
        prefixIconAsset: 'assets/icons/16/width.svg',
        prefixIconFit: BoxFit.none,
        prefixIconAlignment: Alignment.centerLeft,
        dropdownItems: units,
        selectedItem: _unit,
        suffixText: _unit,
        variant: InputVariant.selector,
        readOnly: readOnly,
        readOnlyView: widget.readOnlyView,
        onChanged: (raw) {
          // allow digits and dot for decimal input
          final sanitized = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
          if (sanitized != raw) {
            widget.widthController.text = sanitized;
            final newOffset = sanitized.length.clamp(0, sanitized.length);
            widget.widthController.selection =
                TextSelection.collapsed(offset: newOffset);
          }
          // Update precise px cache from current unit value
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
          final String text = widget.widthController.text.trim();
          final double? value = double.tryParse(text);
          setState(() {
            if (value != null) {
              // Convert using high-precision px cache to avoid drift
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
              widget.widthController.text =
                  formatFieldUnitValue(converted, nextUnit);
              // If linked, immediately recompute height based on new width value
              if (_linked) {
                _onWidthChanged();
              }
            }
            _unit = nextUnit;
            widget.onUnitChanged?.call(_unit);
          });
        },
      ),
      action: ButtonToggle(
        value: _linked,
        disabled: widget.readOnlyView,
        onChanged: (v) {
          setState(() {
            _linked = v;
            if (_linked) {
              _seedAspectFromFields();
              _onWidthChanged();
            }
          });
          widget.onLinkChanged?.call(v);
        },
      ),
    );
  }

  // Conversion moved to shared unit_conversion.dart
}
