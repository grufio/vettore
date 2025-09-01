import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/input_value_type.dart';

class InputRowFull extends StatelessWidget {
  final TextEditingController controller;
  final String? placeholder;
  final String? suffixText;
  final String prefixIconAsset;
  final String? actionIconAsset;
  final VoidCallback? onActionTap;

  const InputRowFull({
    super.key,
    required this.controller,
    this.placeholder,
    this.suffixText,
    this.prefixIconAsset = 'assets/icons/32/document--blank.svg',
    this.actionIconAsset = 'assets/icons/32/checkmark.svg',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SectionInput(
      full: InputValueType.text(
        controller: controller,
        placeholder: placeholder,
        suffixText: suffixText,
        prefixIconAsset: prefixIconAsset,
      ),
      actionIconAsset: actionIconAsset,
      onActionTap: onActionTap,
    );
  }
}
