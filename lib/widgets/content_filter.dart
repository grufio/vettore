import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';

class ContentFilter extends StatelessWidget {
  const ContentFilter({
    super.key,
    required this.children,
    this.height = 48.0,
    this.horizontalPadding = 24.0,
    this.gap = 4.0,
  });
  final List<Widget> children;
  final double height;
  final double horizontalPadding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: kWhite,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: Alignment.centerLeft,
      child: Row(
        children: _withGaps(children, gap),
      ),
    );
  }

  List<Widget> _withGaps(List<Widget> items, double space) {
    if (items.isEmpty) return const [];
    final List<Widget> result = [];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(SizedBox(width: space));
      }
    }
    return result;
  }
}
