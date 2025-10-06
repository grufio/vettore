import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class ContentToolbar extends StatelessWidget {
  final List<Widget> children;
  final double height;
  final double horizontalPadding;
  final double gap;

  const ContentToolbar({
    super.key,
    required this.children,
    this.height = 48.0,
    this.horizontalPadding = 24.0,
    this.gap = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kBordersColor, width: 1.0),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.max,
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

class ContentToolbarTitle extends StatelessWidget {
  final String title;
  final double height;
  final double horizontalPadding;

  const ContentToolbarTitle({
    super.key,
    required this.title,
    this.height = 48.0,
    this.horizontalPadding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kBordersColor, width: 1.0),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: appTextStyles.bodyM.copyWith(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: kGrey100,
          height: 1.0,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
