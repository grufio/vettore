import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vettore/constants/ui_constants.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class GrufioTextFieldSimple extends StatelessWidget {
  const GrufioTextFieldSimple({
    super.key,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.inputFormatters,
    this.hintText,
    this.topLabel,
    this.suffixText,
  });

  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final String? topLabel;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topLabel != null) ...[
          Text(topLabel!, style: appTextStyles.bodyS),
          const SizedBox(height: kSpacingXs),
        ],
        TextField(
          key: key,
          controller: controller,
          // By providing a new InputDecoration, it will automatically
          // be decorated by the global inputDecorationTheme.
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffixText,
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autofocus: autofocus,
          textAlign: textAlign,
          focusNode: focusNode,
          inputFormatters: inputFormatters,
          style: appTextStyles.bodyM,
        ),
      ],
    );
  }
}
