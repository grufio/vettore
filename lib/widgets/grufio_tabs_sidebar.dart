import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class GrufioTabs extends StatelessWidget {
  final List<String> tabTitles;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const GrufioTabs({
    super.key,
    required this.tabTitles,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int index = 0; index < tabTitles.length; index++) ...[
          GestureDetector(
            onTap: () => onTabSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? theme.highlightColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                tabTitles[index],
                style: appTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.bold,
                  color: selectedIndex == index
                      ? theme.colorScheme.primary
                      : theme.unselectedWidgetColor,
                ),
              ),
            ),
          ),
          if (index < tabTitles.length - 1) const SizedBox(width: 4.0),
        ],
      ],
    );
  }
}
