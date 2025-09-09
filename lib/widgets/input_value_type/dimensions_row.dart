import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/widgets/button_toggle.dart';
import 'package:vettore/widgets/constants/input_constants.dart';

class DimensionsRow extends StatefulWidget {
  final TextEditingController widthController;
  final TextEditingController heightController;
  final bool enabled;
  final bool initialLinked;
  final ValueChanged<bool>? onLinkChanged;

  const DimensionsRow({
    super.key,
    required this.widthController,
    required this.heightController,
    required this.enabled,
    this.initialLinked = false,
    this.onLinkChanged,
  });

  @override
  State<DimensionsRow> createState() => _DimensionsRowState();
}

class _DimensionsRowState extends State<DimensionsRow> {
  static const List<String> _units = kUnits;

  bool _linked = false;
  bool _syncing = false;
  double? _aspect; // height / width

  @override
  void initState() {
    super.initState();
    _linked = widget.initialLinked;
    _seedAspectFromFields();
    widget.widthController.addListener(_onWidthChanged);
    widget.heightController.addListener(_onHeightChanged);
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
    final bool readOnly = !widget.enabled;
    return SectionInput(
      left: InputValueType(
        key: const ValueKey('width'),
        controller: widget.widthController,
        placeholder: widget.enabled ? null : 'Width',
        dropdownItems: _units,
        selectedItem: 'px',
        variant: InputVariant.valueDropdown,
        readOnly: readOnly,
      ),
      right: InputValueType(
        key: const ValueKey('height'),
        controller: widget.heightController,
        placeholder: widget.enabled ? null : 'Height',
        dropdownItems: _units,
        selectedItem: 'px',
        variant: InputVariant.valueDropdown,
        readOnly: readOnly,
      ),
      action: ButtonToggle(
        value: _linked,
        onChanged: (v) {
          setState(() {
            _linked = v;
            if (_linked) {
              _seedAspectFromFields();
              // Snap the counterpart immediately for visual confirmation
              _onWidthChanged();
            }
          });
          widget.onLinkChanged?.call(v);
        },
      ),
    );
  }
}
