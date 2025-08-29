import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

/// Active filter chip
/// Specs:
/// - height: 20px
/// - padding left/right: 8px
/// - text: bold 12px black
/// - background: kWhite
class ContentChip extends StatelessWidget {
  final String label;

  const ContentChip.active({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final appText = Theme.of(context).extension<AppTextStyles>();
    final TextStyle textStyle =
        (appText?.bodyM ?? const TextStyle(fontSize: 12.0))
            .copyWith(fontWeight: FontWeight.bold, color: kBlack, height: 1.0);

    return Container(
      height: 20.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: kWhite,
      ),
      child: Text(
        label,
        style: textStyle,
        strutStyle: const StrutStyle(height: 1.0, leading: 0),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
