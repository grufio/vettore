import 'package:flutter/material.dart';
import 'package:vettore/constants/ui_constants.dart';
import 'package:vettore/theme/app_theme_typography.dart';

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
    Theme.of(context); // keep for future theming hooks

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topLabel != null) ...[
          Text(topLabel!, style: appTextStyles.bodyS),
          const SizedBox(height: kSpacingXs),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          // By passing a new InputDecoration, it will automatically
          // be decorated by the global inputDecorationTheme.
          decoration: const InputDecoration(),
          style: appTextStyles.bodyM,
        ),
      ],
    );
  }
}
