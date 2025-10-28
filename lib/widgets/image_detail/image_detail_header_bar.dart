import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/content_filter_bar.dart';

class ImageDetailHeaderBar extends StatelessWidget {
  const ImageDetailHeaderBar({
    super.key,
    required this.activeId,
    required this.onChanged,
  });

  final String activeId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kBordersColor),
        ),
      ),
      child: ContentFilterBar(
        items: const [
          FilterItem(id: 'project', label: 'Project'),
          FilterItem(id: 'image', label: 'Image'),
          FilterItem(id: 'icon', label: 'Icon Detail'),
          FilterItem(id: 'conversion', label: 'Conversion'),
          FilterItem(id: 'grid', label: 'Grid'),
          FilterItem(id: 'output', label: 'Output'),
        ],
        activeId: activeId,
        onChanged: onChanged,
      ),
    );
  }
}
