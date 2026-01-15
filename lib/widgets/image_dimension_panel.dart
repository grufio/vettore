import 'package:flutter/widgets.dart';
import 'package:grufio/widgets/button_app.dart' show OutlinedActionButton;
import 'package:grufio/widgets/input_value_type/dimension_compare_utils.dart';
import 'package:grufio/widgets/input_value_type/dimension_row.dart';
import 'package:grufio/widgets/input_value_type/interpolation_selector.dart';
import 'package:grufio/widgets/input_value_type/resolution_selector.dart';
import 'package:grufio/widgets/input_value_type/unit_value_controller.dart';
import 'package:grufio/widgets/section_sidebar.dart';

class ImageDimensionPanel extends StatefulWidget {
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

  @override
  State<ImageDimensionPanel> createState() => _ImageDimensionPanelState();
}

class _ImageDimensionPanelState extends State<ImageDimensionPanel> {
  VoidCallback? _wTextListener;
  VoidCallback? _hTextListener;
  VoidCallback? _wVcListener;
  VoidCallback? _hVcListener;
  // Baseline of committed texts (updated on model commits)
  String _baselineWText = '';
  String _baselineHText = '';

  @override
  void initState() {
    super.initState();
    _baselineWText = widget.widthTextController.text;
    _baselineHText = widget.heightTextController.text;
    _attachListeners();
  }

  @override
  void didUpdateWidget(covariant ImageDimensionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attachListeners(
        oldWtc: oldWidget.widthTextController,
        oldHtc: oldWidget.heightTextController,
        oldWvc: oldWidget.widthValueController,
        oldHvc: oldWidget.heightValueController);
    // Reset baselines on DPI change so Resize remains disabled until user edits
    if (oldWidget.currentDpi != widget.currentDpi) {
      _baselineWText = widget.widthTextController.text;
      _baselineHText = widget.heightTextController.text;
      setState(() {});
    }
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
      _wVcListener = () {
        // On model commit (e.g., resize or remote phys update), sync baselines
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _baselineWText = widget.widthTextController.text;
          _baselineHText = widget.heightTextController.text;
          setState(() {});
        });
      };
      widget.widthValueController?.addListener(_wVcListener!);
    }
    if (oldHvc != widget.heightValueController) {
      oldHvc?.removeListener(_hVcListener ?? () {});
      _hVcListener = () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _baselineWText = widget.widthTextController.text;
          _baselineHText = widget.heightTextController.text;
          setState(() {});
        });
      };
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
    final String wText = trimTrailingDot(widget.widthTextController.text);
    final String hText = trimTrailingDot(widget.heightTextController.text);
    // Current committed physical px (not used in baseline model)
    // final double? curPhysW = widget.widthValueController?.valuePx;
    // final double? curPhysH = widget.heightValueController?.valuePx;

    final bool wNumericPos = isParsableNumber(wText);
    final bool hNumericPos = isParsableNumber(hText);

    // Compare against baselines captured at last commit
    final String baseW = _baselineWText.trim().endsWith('.')
        ? _baselineWText.trim().substring(0, _baselineWText.trim().length - 1)
        : _baselineWText.trim();
    final String baseH = _baselineHText.trim().endsWith('.')
        ? _baselineHText.trim().substring(0, _baselineHText.trim().length - 1)
        : _baselineHText.trim();
    final bool differsW = wNumericPos && differsFromBaseline(wText, baseW);
    final bool differsH = hNumericPos && differsFromBaseline(hText, baseH);

    // Enable Resize when either field has a valid number and differs from committed phys
    final bool canResize = widget.enabled &&
        (wNumericPos || hNumericPos) &&
        (differsW || differsH);

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
          dpiOverride: widget.currentDpi,
          // use controller DPI
        ),
        DimensionRow(
          primaryController: widget.heightTextController,
          partnerController: widget.widthTextController,
          valueController: widget.heightValueController,
          enabled: widget.enabled,
          isWidth: false,
          onUnitChanged: widget.onHeightUnitChanged,
          initialUnit: widget.initialHeightUnit,
          dpiOverride: widget.currentDpi,
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
