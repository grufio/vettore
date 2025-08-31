import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class SectionSidebar extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionSidebar({
    super.key,
    required this.title,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 8.0, left: 12.0, right: 12.0, bottom: 12.0),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kBordersColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: appTextStyles.bodyMMedium.copyWith(
                fontWeight: FontWeight.bold, color: kGrey100, height: 1.0),
          ),
          if (children.isNotEmpty) const SizedBox(height: 12.0),
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12.0),
          ],
        ],
      ),
    );
  }
}
