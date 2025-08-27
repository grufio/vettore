// lib/app_overview.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:macos_ui/macos_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'dart:io' show Platform;

import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart' show GrufioTab;
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
          showLeftBorder: i > 0,
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
  ];

  void _onTabSelected(int i) => setState(() => _activeIndex = i);

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return ColoredBox(
        color: kBackgroundColor,
        child: Column(
          children: [
            // ─────────── Titlebar region (custom frame) ───────────
            WindowTitleBarBox(
              child: TitlebarSafeArea(
                child: Container(
                  color: const Color(0xFFF0F0F0),
                  child: ToolBar(
                    height: _kToolbarHeight,
                    titleWidth: double.infinity,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MinimizeWindowButton(),
                        MaximizeWindowButton(),
                        CloseWindowButton(),
                      ],
                    ),
                    title: Row(
                      children: [
                        const SizedBox(width: 0),
                        SizedBox(
                          height: _kToolbarHeight,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: GrufioTabsApp(
                              tabs: _tabs,
                              activeIndex: _activeIndex,
                              onTabSelected: _onTabSelected,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: MoveWindow()),
                      ],
                    ),
                    actions: const [],
                  ),
                ),
              ),
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
