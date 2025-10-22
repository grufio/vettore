import 'package:flutter/widgets.dart';
import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/widgets/app_header_bar.dart';

class OverviewHeader extends StatelessWidget {
  const OverviewHeader({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    required this.onCloseTab,
    required this.onAddTab,
  });

  final List<GrufioTabData> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<int> onCloseTab;
  final VoidCallback onAddTab;

  @override
  Widget build(BuildContext context) {
    return AppHeaderBar(
      tabs: tabs,
      activeIndex: activeIndex,
      onTabSelected: onTabSelected,
      onCloseTab: onCloseTab,
      onAddTab: onAddTab,
    );
  }
}

