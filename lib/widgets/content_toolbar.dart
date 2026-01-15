import 'package:flutter/widgets.dart';
// ignore_for_file: always_use_package_imports
import '../theme/app_theme_colors.dart';
import '../theme/app_theme_typography.dart';

class ContentToolbar extends StatelessWidget {
  const ContentToolbar({super.key, this.title, this.trailing});
  final String? title;
  final List<Widget>? trailing;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = appTextStyles.bodyM.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(bottom: BorderSide(color: kBordersColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          if (title != null) Text(title!, style: titleStyle),
          const Spacer(),
          if (trailing != null) ...trailing!,
        ],
      ),
    );
  }
}
