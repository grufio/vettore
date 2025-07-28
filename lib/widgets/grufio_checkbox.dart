import 'package:flutter/material.dart';

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
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: [
          Icon(
            value ? Icons.check_box : Icons.check_box_outline_blank,
            size: 16.0,
            color: value
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).unselectedWidgetColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}
