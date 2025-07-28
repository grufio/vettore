import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vettore/constants/ui_constants.dart';

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
    // This decoration is now built from scratch inside the component,
    // ensuring a consistent, self-contained style.
    final decoration = InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
        borderSide: BorderSide(width: 2.0), // Uses theme's primary color
      ),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topLabel != null) ...[
          Text(
            topLabel!,
            style: const TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: kSpacingXs),
        ],
        TextField(
          key: key,
          controller: controller,
          decoration: decoration,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autofocus: autofocus,
          textAlign: textAlign,
          focusNode: focusNode,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 12.0),
        ),
      ],
    );
  }
}
