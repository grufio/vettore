import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/input_value_type/dimension_row.dart';
import 'package:vettore/widgets/input_value_type/interpolation_selector.dart';
import 'package:vettore/widgets/input_value_type/resolution_selector.dart';
import 'package:vettore/widgets/input_value_type/unit_value_controller.dart';
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/button_app.dart' show OutlinedActionButton;

class ImageDimensionPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SectionSidebar(
      title: 'Title',
      children: [
        DimensionRow(
          primaryController: widthTextController,
          partnerController: heightTextController,
          valueController: widthValueController,
          enabled: enabled,
          isWidth: true,
          showLinkToggle: true,
          initialLinked: initialLinked,
          onLinkChanged: onLinkChanged,
          onUnitChanged: onWidthUnitChanged,
          initialUnit: initialWidthUnit,
          // use controller DPI
        ),
        DimensionRow(
          primaryController: heightTextController,
          partnerController: widthTextController,
          valueController: heightValueController,
          enabled: enabled,
          isWidth: false,
          showLinkToggle: false,
          onUnitChanged: onHeightUnitChanged,
          initialUnit: initialHeightUnit,
          // use controller DPI
        ),
        InterpolationSelector(
          value: interpolation,
          onChanged: onInterpolationChanged,
          enabled: enabled,
        ),
        ResolutionSelector(
          value: currentDpi,
          enabled: enabled,
          onChanged: onDpiChanged,
        ),
        SectionInput(
          full: OutlinedActionButton(
            label: 'Resize',
            onTap: onResizeTap,
          ),
        ),
      ],
    );
  }
}
