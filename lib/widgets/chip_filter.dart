import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

/// Active filter chip
/// - height: 20px
/// - padding left/right: 8px
/// - font: medium 12px, color kGrey90
/// - background: kChipActiveBackground
class ContentChip extends StatelessWidget {
  final String label;

  const ContentChip.active({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = appTextStyles.bodyMMedium;

    return Container(
      height: 20.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: kChipActiveBackground),
      child: Text(
        label,
        style: textStyle,
        strutStyle: const StrutStyle(height: 1.0, leading: 0),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
