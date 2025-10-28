import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class ContentToolbar extends StatelessWidget {
  const ContentToolbar({
    super.key,
    this.title,
    this.trailing = const <Widget>[],
    this.height = 48.0,
    this.horizontalPadding = 24.0,
    this.gap = 8.0,
  });

  final String? title;
  final List<Widget> trailing;
  final double height;
  final double horizontalPadding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = appTextStyles.bodyM.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: kGrey100,
      height: 1.0,
    );

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kBordersColor),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          if (title != null)
            Flexible(
              fit: FlexFit.tight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title!,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          else
            const Spacer(),
          Row(children: _withGaps(trailing, gap)),
        ],
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

// ContentToolbarTitle merged into ContentToolbar via the `title` property.
