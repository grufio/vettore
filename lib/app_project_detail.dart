import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/app_header_bar.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart' show GrufioTab;
import 'package:vettore/widgets/side_panel.dart';

class AppProjectDetailPage extends StatefulWidget {
  final int initialActiveIndex;
  final ValueChanged<int>? onNavigateTab;
  const AppProjectDetailPage({
    super.key,
    this.initialActiveIndex = 1,
    this.onNavigateTab,
  });

  @override
  State<AppProjectDetailPage> createState() => _AppProjectDetailPageState();
}

class _AppProjectDetailPageState extends State<AppProjectDetailPage> {
  static const double _kToolbarHeight = 40.0;

  late int _activeIndex;
  final _tabs = <GrufioTabData>[
    const GrufioTabData(iconPath: 'assets/icons/32/home.svg', width: 40),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Palette'),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Example'),
  ];

  void _onTabSelected(int i) {
    setState(() => _activeIndex = i);
    widget.onNavigateTab?.call(i);
  }

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialActiveIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Project Detail')),
        child: Center(child: Text('Project Detail')),
      );
    }

    return ColoredBox(
      color: kWhite,
      child: Column(
        children: [
          AppHeaderBar(
            tabs: _tabs,
            activeIndex: _activeIndex,
            onTabSelected: _onTabSelected,
            height: _kToolbarHeight,
            leftPaddingWhenWindowed: 72,
          ),
          Expanded(
            child: ColoredBox(
              color: kWhite,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main detail area placeholder
                  Expanded(
                    child: Center(
                      child: Text(
                        'Project Detail (Tab ${_activeIndex + 1})',
                      ),
                    ),
                  ),
                  // Right side panel (empty for now)
                  SidePanel(
                    side: SidePanelSide.right,
                    width: 260.0,
                    topPadding: 8.0,
                    horizontalPadding: 16.0,
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
