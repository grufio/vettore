import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class GrufioCheckbox extends StatelessWidget {
  const GrufioCheckbox({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: [
          Icon(
            value ? Icons.check_box : Icons.check_box_outline_blank,
            size: 16.0,
            color:
                value ? theme.colorScheme.primary : theme.unselectedWidgetColor,
          ),
          const SizedBox(width: 8),
          Text(title, style: appTextStyles.bodyM),
        ],
      ),
    );
  }
}
