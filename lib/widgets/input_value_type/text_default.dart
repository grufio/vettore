import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show TextCapitalization;
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/input_value_type/input_value_type.dart';

/// Reusable text input (standalone IVT) used for the Title field and similar cases.
/// - Renders within a `SectionInput` row
/// - Supports an optional right-side action icon
/// - Uses the document icon by default; can be overridden
class TextDefaultInput extends StatelessWidget {
  const TextDefaultInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.placeholder,
    this.suffixText,
    this.prefixIconAsset = 'assets/icons/32/document--blank.svg',
    this.actionIconAsset,
    this.onActionTap,
    this.onSubmitted,
    this.onChanged,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.readOnlyView = false,
  });
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final String? suffixText;
  final String prefixIconAsset;
  final String? actionIconAsset;
  final VoidCallback? onActionTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final bool readOnlyView;

  @override
  Widget build(BuildContext context) {
    return SectionInput(
      full: InputValueType(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        suffixText: suffixText,
        prefixIconAsset: prefixIconAsset,
        prefixIconWidth: 16.0,
        prefixIconHeight: 16.0,
        prefixIconFit: BoxFit.contain,
        prefixIconAlignment: Alignment.centerLeft,
        onChanged: onChanged,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        readOnlyView: readOnlyView,
        onSubmitted: onSubmitted,
      ),
      actionIconAsset: actionIconAsset,
      onActionTap: onActionTap,
    );
  }
}
