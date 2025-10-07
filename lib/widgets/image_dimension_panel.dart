import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/input_value_type/dimension_row.dart';
import 'package:vettore/widgets/input_value_type/interpolation_selector.dart';
import 'package:vettore/widgets/input_value_type/resolution_selector.dart';
import 'package:vettore/widgets/input_value_type/unit_value_controller.dart';
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/button_app.dart' show OutlinedActionButton;
import 'package:vettore/widgets/input_value_type/unit_conversion.dart';

class ImageDimensionPanel extends StatefulWidget {
  final TextEditingController widthTextController;
  final TextEditingController heightTextController;
  final UnitValueController? widthValueController;
  final UnitValueController? heightValueController;
  final bool enabled;
  final bool initialLinked;
  final ValueChanged<bool>? onLinkChanged;
  final String? initialWidthUnit;
  final String? initialHeightUnit;
  final ValueChanged<String> onWidthUnitChanged;
  final ValueChanged<String> onHeightUnitChanged;
  final int currentDpi;
  final ValueChanged<int> onDpiChanged;
  final String interpolation;
  final ValueChanged<String> onInterpolationChanged;
  final VoidCallback onResizeTap;

  const ImageDimensionPanel({
    super.key,
    required this.widthTextController,
    required this.heightTextController,
    required this.widthValueController,
    required this.heightValueController,
    required this.enabled,
    required this.initialLinked,
    required this.onLinkChanged,
    required this.initialWidthUnit,
    required this.initialHeightUnit,
    required this.onWidthUnitChanged,
    required this.onHeightUnitChanged,
    required this.currentDpi,
    required this.onDpiChanged,
    required this.interpolation,
    required this.onInterpolationChanged,
    required this.onResizeTap,
  });

  @override
  State<ImageDimensionPanel> createState() => _ImageDimensionPanelState();
}

class _ImageDimensionPanelState extends State<ImageDimensionPanel> {
  VoidCallback? _wTextListener;
  VoidCallback? _hTextListener;
  VoidCallback? _wVcListener;
  VoidCallback? _hVcListener;

  @override
  void initState() {
    super.initState();
    _attachListeners(oldWtc: null, oldHtc: null, oldWvc: null, oldHvc: null);
  }

  @override
  void didUpdateWidget(covariant ImageDimensionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attachListeners(
        oldWtc: oldWidget.widthTextController,
        oldHtc: oldWidget.heightTextController,
        oldWvc: oldWidget.widthValueController,
        oldHvc: oldWidget.heightValueController);
  }

  void _attachListeners({
    TextEditingController? oldWtc,
    TextEditingController? oldHtc,
    UnitValueController? oldWvc,
    UnitValueController? oldHvc,
  }) {
    if (oldWtc != widget.widthTextController) {
      oldWtc?.removeListener(_wTextListener ?? () {});
      _wTextListener = () => setState(() {});
      widget.widthTextController.addListener(_wTextListener!);
    }
    if (oldHtc != widget.heightTextController) {
      oldHtc?.removeListener(_hTextListener ?? () {});
      _hTextListener = () => setState(() {});
      widget.heightTextController.addListener(_hTextListener!);
    }
    if (oldWvc != widget.widthValueController) {
      oldWvc?.removeListener(_wVcListener ?? () {});
      _wVcListener = () => setState(() {});
      widget.widthValueController?.addListener(_wVcListener!);
    }
    if (oldHvc != widget.heightValueController) {
      oldHvc?.removeListener(_hVcListener ?? () {});
      _hVcListener = () => setState(() {});
      widget.heightValueController?.addListener(_hVcListener!);
    }
  }

  @override
  void dispose() {
    widget.widthTextController.removeListener(_wTextListener ?? () {});
    widget.heightTextController.removeListener(_hTextListener ?? () {});
    widget.widthValueController?.removeListener(_wVcListener ?? () {});
    widget.heightValueController?.removeListener(_hVcListener ?? () {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Enable Resize when any field changed vs current size (units aware)
    bool _isNumeric(String s) {
      if (s.isEmpty) return false;
      final String t = s.trim().endsWith('.')
          ? s.trim().substring(0, s.trim().length - 1)
          : s.trim();
      return double.tryParse(t) != null;
    }

    String _trimDot(String s) {
      final String t = s.trim();
      return t.endsWith('.') ? t.substring(0, t.length - 1) : t;
    }

    final String wText = _trimDot(widget.widthTextController.text);
    final String hText = _trimDot(widget.heightTextController.text);
    final int? curW = widget.widthValueController?.valuePx?.round();
    final int? curH = widget.heightValueController?.valuePx?.round();

    final bool wNumericPos =
        _isNumeric(wText) && (double.tryParse(wText) ?? 0) > 0;
    final bool hNumericPos =
        _isNumeric(hText) && (double.tryParse(hText) ?? 0) > 0;

    String normalize(String s) => s.trim();

    String? expectedW;
    String? expectedH;
    if (curW != null) {
      final String wUnit = (widget.widthValueController?.unit ?? 'px');
      final double wDisp = convertUnit(
        value: curW.toDouble(),
        fromUnit: 'px',
        toUnit: wUnit,
        dpi: widget.currentDpi,
      );
      expectedW = formatFieldUnitValue(wDisp, wUnit);
    }
    if (curH != null) {
      final String hUnit = (widget.heightValueController?.unit ?? 'px');
      final double hDisp = convertUnit(
        value: curH.toDouble(),
        fromUnit: 'px',
        toUnit: hUnit,
        dpi: widget.currentDpi,
      );
      expectedH = formatFieldUnitValue(hDisp, hUnit);
    }

    final bool differsW = wNumericPos &&
        expectedW != null &&
        normalize(wText) != normalize(expectedW);
    final bool differsH = hNumericPos &&
        expectedH != null &&
        normalize(hText) != normalize(expectedH);

    final bool canResize = widget.enabled &&
        ((curW == null || curH == null)
            ? (wNumericPos || hNumericPos)
            : (differsW || differsH));

    return SectionSidebar(
      title: 'Title',
      children: [
        DimensionRow(
          primaryController: widget.widthTextController,
          partnerController: widget.heightTextController,
          valueController: widget.widthValueController,
          enabled: widget.enabled,
          isWidth: true,
          showLinkToggle: true,
          initialLinked: widget.initialLinked,
          onLinkChanged: widget.onLinkChanged,
          onUnitChanged: widget.onWidthUnitChanged,
          initialUnit: widget.initialWidthUnit,
          // use controller DPI
        ),
        DimensionRow(
          primaryController: widget.heightTextController,
          partnerController: widget.widthTextController,
          valueController: widget.heightValueController,
          enabled: widget.enabled,
          isWidth: false,
          showLinkToggle: false,
          onUnitChanged: widget.onHeightUnitChanged,
          initialUnit: widget.initialHeightUnit,
          // use controller DPI
        ),
        InterpolationSelector(
          value: widget.interpolation,
          onChanged: widget.onInterpolationChanged,
          enabled: widget.enabled,
        ),
        ResolutionSelector(
          value: widget.currentDpi,
          enabled: widget.enabled,
          onChanged: widget.onDpiChanged,
        ),
        SectionInput(
          full: OutlinedActionButton(
            label: 'Resize',
            onTap: widget.onResizeTap,
            enabled: canResize,
          ),
        ),
      ],
    );
  }
}
