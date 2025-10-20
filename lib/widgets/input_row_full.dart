import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/input_value_type/input_value_type.dart';

class InputRowFull extends StatelessWidget {
  const InputRowFull({
    super.key,
    required this.controller,
    this.focusNode,
    this.placeholder,
    this.suffixText,
    this.prefixIconAsset = 'assets/icons/32/document--blank.svg',
    this.actionIconAsset,
    this.onActionTap,
    this.onSubmitted,
  });
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? suffixText;
  final String prefixIconAsset;
  final String? actionIconAsset;
  final VoidCallback? onActionTap;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SectionInput(
      full: InputValueType.text(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        suffixText: suffixText,
        prefixIconAsset: prefixIconAsset,
        onSubmitted: onSubmitted,
      ),
      actionIconAsset: actionIconAsset,
      onActionTap: onActionTap,
    );
  }
}
