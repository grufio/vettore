import 'package:flutter/material.dart';
import 'package:vettore/constants/ui_constants.dart';

class GrufioDropdownFormField<T> extends StatelessWidget {
  const GrufioDropdownFormField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.topLabel,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? topLabel;

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
        borderSide: BorderSide(width: 2.0, color: Colors.blue), // Example color
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
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: decoration,
          style: const TextStyle(fontSize: 12.0, color: Colors.black),
        ),
      ],
    );
  }
}
