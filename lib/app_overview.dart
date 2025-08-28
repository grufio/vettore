// lib/app_overview.dart

import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart' show GrufioTab;
import 'package:vettore/widgets/app_header_bar.dart';
import 'package:vettore/theme/app_theme_colors.dart';

const double _kToolbarHeight = 40.0;

/// A lightweight wrapper that connects all tabs into a scrollable Row:
class GrufioTabsApp extends StatelessWidget {
  final List<GrufioTabData> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const GrufioTabsApp({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final t = tabs[i];
        return GrufioTab(
          iconPath: t.iconPath,
          label: t.label,
          width: t.width,
          isActive: i == activeIndex,
          showLeftBorder: i == 0, // home: left border
          showRightBorder: true, // all tabs: right border (home has both)
          onTap: () => onTabSelected(i),
        );
      }),
    );
  }
}

class AppOverviewPage extends StatefulWidget {
  const AppOverviewPage({super.key});
  @override
  State<AppOverviewPage> createState() => _AppOverviewPageState();
}

class _AppOverviewPageState extends State<AppOverviewPage> {
  int _activeIndex = 0;
  final _tabs = <GrufioTabData>[
    const GrufioTabData(iconPath: 'assets/icons/32/home.svg', width: 40),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Palette'),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Example'),
  ];

  void _onTabSelected(int i) => setState(() => _activeIndex = i);

  void _onCloseTab(int index) {
    if (index <= 0 || index >= _tabs.length)
      return; // do not close home; guard bounds
    setState(() {
      _tabs.removeAt(index);
      if (_activeIndex >= _tabs.length) {
        _activeIndex = _tabs.length - 1;
      }
    });
  }

  void _onAddTab() {
    final int paletteIndex = _tabs.indexWhere((t) => t.label == 'Palette');
    final int insertIndex = paletteIndex >= 0 ? paletteIndex + 1 : _tabs.length;
    setState(() {
      _tabs.insert(
        insertIndex,
        const GrufioTabData(
          iconPath: 'assets/icons/32/color-palette.svg',
          label: 'Example',
        ),
      );
      _activeIndex = insertIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return ColoredBox(
        color: kBackgroundColor,
        child: Column(
          children: [
            // ─────────── Titlebar region (custom frame) ───────────
            AppHeaderBar(
              tabs: _tabs,
              activeIndex: _activeIndex,
              onTabSelected: _onTabSelected,
              height: _kToolbarHeight,
              leftPaddingWhenWindowed: 72,
              onCloseTab: _onCloseTab,
              onAddTab: _onAddTab,
            ),

            // ─────────── Content region ───────────
            Expanded(
              child: ColoredBox(
                color: kBackgroundColor,
                child: Center(
                  child: Text('Content for Tab ${_activeIndex + 1}'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // iOS and other non-macOS platforms: render without macOS-specific widgets.
    return Container(
      color: kBackgroundColor,
      child: Column(
        children: [
          // Simple header area with tabs
          Container(
            height: _kToolbarHeight,
            color: const Color(0xFFF0F0F0),
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: GrufioTabsApp(
                tabs: _tabs,
                activeIndex: _activeIndex,
                onTabSelected: _onTabSelected,
              ),
            ),
          ),
          // Content
          Expanded(
            child: Center(
              child: Text('Content for Tab ${_activeIndex + 1}'),
            ),
          ),
        ],
      ),
    );
  }
}
