// lib/app_overview.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:macos_ui/macos_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';
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

class _AppOverviewPageState extends State<AppOverviewPage>
    with WidgetsBindingObserver, WindowListener {
  int _activeIndex = 0;
  bool _isFullscreen = false;
  final _tabs = <GrufioTabData>[
    const GrufioTabData(iconPath: 'assets/icons/32/home.svg', width: 40),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Palette'),
  ];

  void _onTabSelected(int i) => setState(() => _activeIndex = i);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isMacOS) {
      windowManager.addListener(this);
      _refreshWindowInfo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (Platform.isMacOS) {
      _refreshWindowInfo();
    }
  }

  Future<void> _refreshWindowInfo() async {
    try {
      final isFs = await windowManager.isFullScreen();
      if (!mounted) return;
      setState(() {
        _isFullscreen = isFs;
      });
    } catch (_) {}
  }

  @override
  void onWindowEvent(String eventName) async {
    if (eventName == 'enter-full-screen' || eventName == 'leave-full-screen') {
      await _refreshWindowInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return ColoredBox(
        color: kBackgroundColor,
        child: Column(
          children: [
            // ─────────── Titlebar region (custom frame) ───────────
            WindowTitleBarBox(
              child: Container(
                height: _kToolbarHeight,
                decoration: BoxDecoration(
                  color: kHeaderBackgroundColor,
                  border: Border(
                      bottom: BorderSide(color: kHeaderDividerColor, width: 1)),
                ),
                padding: EdgeInsets.only(left: _isFullscreen ? 0 : 72),
                child: Row(
                  children: [
                    // Tabs left
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: GrufioTabsApp(
                        tabs: _tabs,
                        activeIndex: _activeIndex,
                        onTabSelected: _onTabSelected,
                      ),
                    ),
                    // Drag zone right
                    Expanded(child: MoveWindow()),
                  ],
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
