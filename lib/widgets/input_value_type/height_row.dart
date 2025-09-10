import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart' show SectionInput;
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/widgets/constants/input_constants.dart';

class HeightRow extends StatelessWidget {
  final TextEditingController heightController;
  final bool enabled;

  const HeightRow({
    super.key,
    required this.heightController,
    required this.enabled,
  });

  static const List<String> _units = kUnits;

  @override
  Widget build(BuildContext context) {
    final bool readOnly = !enabled;
    return SectionInput(
      full: InputValueType(
        key: const ValueKey('height'),
        controller: heightController,
        placeholder: enabled ? null : 'Height',
        prefixIconAsset: 'assets/icons/16/height.svg',
        prefixIconFit: BoxFit.none,
        prefixIconAlignment: Alignment.centerLeft,
        dropdownItems: _units,
        selectedItem: 'px',
        variant: InputVariant.valueDropdown,
        readOnly: readOnly,
      ),
    );
  }
}
