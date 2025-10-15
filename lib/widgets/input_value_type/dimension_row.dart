import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/widgets/button_toggle.dart';
import 'package:vettore/widgets/constants/input_constants.dart';
import 'package:vettore/widgets/input_value_type/unit_conversion.dart';
import 'package:vettore/widgets/input_value_type/unit_value_controller.dart';
import 'package:vettore/widgets/input_value_type/number_utils.dart';

/// A unified dimension row that can render either width or height input.
/// It consolidates shared logic from WidthRow and HeightRow while preserving
/// the public API semantics used by existing call sites.
class DimensionRow extends StatefulWidget {
  // defaults to 96 when provided

  const DimensionRow({
    super.key,
    required this.primaryController,
    this.partnerController,
    this.valueController,
    required this.enabled,
    required this.isWidth,
    this.showLinkToggle = false,
    this.initialLinked = false,
    this.onLinkChanged,
    this.onUnitChanged,
    this.readOnlyView = false,
    this.dpiOverride,
    this.units,
    this.initialUnit,
    this.inputFormatters,
    this.clampPxMin,
    this.clampPxMax,
    this.clampDpi,
  });
  final TextEditingController primaryController;
  final TextEditingController? partnerController; // for linked updates
  final UnitValueController?
      valueController; // optional external value/unit controller
  final bool enabled;
  final bool isWidth; // true => width, false => height
  final bool showLinkToggle; // show the link/unlink button
  final bool initialLinked;
  final ValueChanged<bool>? onLinkChanged;
  final ValueChanged<String>? onUnitChanged;
  final bool readOnlyView;
  final int? dpiOverride;
  final List<String>? units;
  final String? initialUnit;
  final List<TextInputFormatter>? inputFormatters;
  final double? clampPxMin;
  final double? clampPxMax;
  final int? clampDpi;

  @override
  State<DimensionRow> createState() => _DimensionRowState();
}

class _DimensionRowState extends State<DimensionRow> {
  static const List<String> _defaultUnits = kUnits;

  bool _linked = false;
  bool _echoing = false;
  double? _lastEchoedPx;
  bool _suppressEcho = false;
  FocusNode? _focusNode;
  // Linking/aspect disabled in typing-only mode
  String _unit = 'px';
  // Preserve state only via UnitValueController; no local px cache
  VoidCallback? _vcListener;

  @override
  void initState() {
    super.initState();
    _linked = widget.initialLinked;
    _unit = widget.initialUnit ?? widget.valueController?.unit ?? _unit;
    // Linking/aspect disabled; no seeding
    widget.primaryController.addListener(_onPrimaryChanged);
    widget.partnerController?.addListener(_onPartnerChanged);
    _focusNode = FocusNode();
    _focusNode!.addListener(_onFocusChanged);
    // Initialize internal px value from current text if present
    final int? dpiOverride = widget.dpiOverride;
    final double? initial = double.tryParse(widget.primaryController.text);
    if (widget.valueController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (dpiOverride != null) {
          widget.valueController!.setDpi(dpiOverride);
        }
        widget.valueController!.setUnit(_unit);
        if (initial != null) {
          widget.valueController!.setValueFromUnit(initial);
        }
      });
      _vcListener = () {
        if (!mounted) return;
        // Echo from model whenever pixel value changes (always show real dimensions)
        final double? px = widget.valueController!.valuePx;
        final bool pxChanged = px != _lastEchoedPx;
        if (_suppressEcho) {
          // Skip one echo triggered by our own onChanged write
          _suppressEcho = false;
          _lastEchoedPx = px;
        } else if (pxChanged && !_echoing) {
          final double? v = widget.valueController!.getValueInUnit();
          final String txt = (v == null)
              ? ''
              : formatFieldUnitValue(v, widget.valueController!.unit);
          _echoing = true;
          widget.primaryController.text = txt;
          widget.primaryController.selection =
              TextSelection.collapsed(offset: txt.length);
          _echoing = false;
          _lastEchoedPx = px;
        }
        // Always update unit for suffix, but do not rewrite numeric text on unit-only change
        setState(() {
          _unit = widget.valueController!.unit;
        });
      };
      widget.valueController!.addListener(_vcListener!);
    }
  }

  @override
  void didUpdateWidget(covariant DimensionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent updates the initial unit (e.g., after DB load), reflect it
    if (oldWidget.initialUnit != widget.initialUnit &&
        widget.initialUnit != null) {
      setState(() {
        _unit = widget.initialUnit!;
      });
      if (widget.valueController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.valueController!.setUnit(_unit);
        });
      }
    }
    // Sync controller DPI only when override is provided
    if (widget.dpiOverride != null) {
      final int newDpi = widget.dpiOverride!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.valueController?.setDpi(newDpi);
      });
    }
  }

  @override
  void dispose() {
    widget.primaryController.removeListener(_onPrimaryChanged);
    widget.partnerController?.removeListener(_onPartnerChanged);
    if (_vcListener != null && widget.valueController != null) {
      widget.valueController!.removeListener(_vcListener!);
    }
    _focusNode?.dispose();
    super.dispose();
  }

  // Removed aspect seeding; linking disabled in typing-only mode

  void _onPrimaryChanged() {
    // Typing-only mode: do nothing
    return;
  }

  void _onPartnerChanged() {
    // Typing-only mode: do nothing
    return;
  }

  void _onFocusChanged() {
    if (_focusNode == null || _focusNode!.hasFocus) return;
    // Lost focus: format to 2 decimals if missing
    final String text = widget.primaryController.text.trim();
    if (text.isEmpty) return;
    final double? v = double.tryParse(text);
    if (v == null) return;
    final String formatted = formatFieldUnitValue(v, _unit);
    if (formatted != text) {
      _echoing = true;
      widget.primaryController.text = formatted;
      widget.primaryController.selection =
          TextSelection.collapsed(offset: formatted.length);
      _echoing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final int dpi = widget.dpiOverride ?? 96;
    // DPI sync is handled in didUpdateWidget via post-frame callback
    final bool readOnly = !widget.enabled;
    final List<String> units = widget.units ?? _defaultUnits;
    final String iconAsset = widget.isWidth
        ? 'assets/icons/16/width.svg'
        : 'assets/icons/16/height.svg';
    final Key fieldKey = ValueKey(widget.isWidth ? 'width' : 'height');

    final input = InputValueType(
      key: fieldKey,
      controller: widget.primaryController,
      focusNode: _focusNode,
      placeholder: widget.isWidth ? 'Width' : 'Height',
      prefixIconAsset: iconAsset,
      prefixIconFit: BoxFit.none,
      prefixIconAlignment: Alignment.centerLeft,
      dropdownItems: units,
      selectedItem: _unit, // strictly controlled
      suffixText: _unit,
      variant: InputVariant.selector,
      readOnly: readOnly,
      readOnlyView: widget.readOnlyView,
      inputFormatters: widget.inputFormatters,
      onChanged: (raw) {
        // central sanitize utility
        final String sanitized = sanitizeNumber(raw);
        if (sanitized != raw) {
          widget.primaryController.text = sanitized;
          final int newOffset = sanitized.length.clamp(0, sanitized.length);
          widget.primaryController.selection =
              TextSelection.collapsed(offset: newOffset);
        }
        // Update value controller from typed value (kept as 4-dec phys px internally)
        // Do not write into the model while typing; commit on blur/resize
        // No user-edit guard; model → field echo always applies on updates
        return;
      },
      onItemSelected: (nextUnit) {
        setState(() {
          _unit =
              nextUnit; // Update suffix/unit only; do not rewrite numeric text
          widget.valueController?.setUnit(nextUnit);
          widget.onUnitChanged?.call(nextUnit);
        });
      },
    );

    if (!widget.showLinkToggle) {
      return SectionInput(full: input);
    }

    return SectionInput(
      full: input,
      action: ButtonToggle(
        value: _linked,
        disabled: widget.readOnlyView,
        onChanged: (v) {
          setState(() {
            _linked = v;
          });
          if (widget.valueController != null) {
            widget.valueController!.setLinked(v);
          }
          widget.onLinkChanged?.call(v);
        },
      ),
    );
  }
}
